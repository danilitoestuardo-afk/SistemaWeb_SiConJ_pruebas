// Controllers/PedidosController.cs
// Cliente: registra su pedido eligiendo cómo lo recibe (recoger en la tienda aliada o a domicilio).
//          El stock se descuenta al instante, así nadie más compra esa pieza.
// Admin:   ve todos los pedidos con sus datos de entrega y los marca como Completado o Cancelado.
using System.Globalization;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using SiconJ.Api.Data;
using SiconJ.Api.Models;
using SiconJ.Api.Services;

namespace SiconJ.Api.Controllers;

[ApiController]
[Route("api/pedidos")]
public class PedidosController : ControllerBase
{
    private const string FormatoHora = @"hh\:mm";
    private readonly SiconJDb _db;
    private readonly ICorreo _correo;
    private readonly ILogger<PedidosController> _log;

    public PedidosController(SiconJDb db, ICorreo correo, ILogger<PedidosController> log)
    {
        _db = db;
        _correo = correo;
        _log = log;
    }

    // ---------- CLIENTE ----------

    [Authorize(Roles = "Cliente"), HttpPost]
    public async Task<IActionResult> Crear([FromBody] PedidoReq req)
    {
        if (!int.TryParse(User.FindFirst("cid")?.Value, out var clienteId)) return Unauthorized();
        if (!await _db.Clientes.AnyAsync(c => c.Id == clienteId)) return Unauthorized();

        // La forma de entrega es obligatoria y se valida ANTES de tocar el stock.
        var (errorEntrega, fecha, franja) = await ValidarEntrega(req);
        if (errorEntrega is not null) return BadRequest(new { mensaje = errorEntrega });
        var domicilio = req.TipoEntrega == TipoEntrega.Domicilio;

        // Si una pieza viene repetida, se suman las cantidades.
        var items = req.Items.GroupBy(i => i.InstanciaId)
            .Select(g => new { Id = g.Key, Cant = g.Sum(x => x.Cantidad) }).ToList();

        await using var tx = await _db.Database.BeginTransactionAsync();
        var detalles = new List<PedidoDetalle>();
        decimal total = 0;

        foreach (var item in items)
        {
            var id = item.Id;
            var cant = item.Cant;

            // Descuento atómico: solo se aplica si sigue Disponible, visible y alcanza el stock.
            // Dos clientes pidiendo la última pieza a la vez: uno gana y el otro recibe el aviso.
            var filas = await _db.Instancias
                .Where(i => i.Id == id && !i.Oculto && i.EstadoId == EstadoInv.Disponible && i.Stock >= cant)
                .ExecuteUpdateAsync(s => s.SetProperty(i => i.Stock, i => i.Stock - cant));
            if (filas == 0)
            {
                await tx.RollbackAsync();
                return Conflict(new { mensaje = "Alguna pieza ya no está disponible en esa cantidad. Actualiza el catálogo y revisa tu pedido." });
            }

            // Si se llevó la última unidad, queda Reservada (pedida pero aún no vendida).
            await _db.Instancias.Where(i => i.Id == id && i.Stock == 0)
                .ExecuteUpdateAsync(s => s.SetProperty(i => i.EstadoId, EstadoInv.Reservado));

            var precio = await _db.Instancias.Where(i => i.Id == id).Select(i => i.Precio).FirstAsync();
            detalles.Add(new PedidoDetalle { InstanciaId = id, Cantidad = cant, PrecioUnitario = precio });
            total += precio * cant;
        }

        var pedido = new Pedido
        {
            ClienteId = clienteId,
            Nota = string.IsNullOrWhiteSpace(req.Nota) ? null : req.Nota.Trim(),
            Total = total,
            Detalles = detalles,
            TipoEntrega = req.TipoEntrega,
            Direccion = domicilio ? req.Direccion!.Trim() : null,
            Latitud = domicilio && req.Latitud.HasValue ? Math.Round(req.Latitud.Value, 6) : null,
            Longitud = domicilio && req.Longitud.HasValue ? Math.Round(req.Longitud.Value, 6) : null,
            EntregaFecha = domicilio ? fecha : null,
            EntregaFranja = domicilio ? franja : null,
        };
        _db.Pedidos.Add(pedido);
        await _db.SaveChangesAsync();
        await tx.CommitAsync();

        await AvisarAlAdmin(pedido, clienteId, detalles);
        return Ok(new { id = pedido.Id, total });
    }

    // ---------- ADMIN ----------

    [Authorize(Roles = "Admin"), HttpGet]
    public async Task<IActionResult> Todos([FromQuery] string? estado = null)
    {
        var query = _db.Pedidos.AsNoTracking()
            .Include(p => p.Cliente)
            .Include(p => p.Detalles).ThenInclude(d => d.Instancia).ThenInclude(i => i!.Producto)
            .AsQueryable();
        if (!string.IsNullOrWhiteSpace(estado)) query = query.Where(p => p.Estado == estado);

        var lista = await query.OrderByDescending(p => p.Id).Take(200).ToListAsync();
        return Ok(lista.Select(p => new PedidoDto(
            p.Id, DateTime.SpecifyKind(p.Creado, DateTimeKind.Utc), p.Estado, p.Total, p.Nota,
            p.Cliente?.Nombre ?? "", p.Cliente?.Correo ?? "",
            p.TipoEntrega, p.Direccion, p.Latitud, p.Longitud,
            p.EntregaFecha?.ToString("yyyy-MM-dd", CultureInfo.InvariantCulture), p.EntregaFranja,
            p.Detalles.Select(d => new DetalleDto(
                d.InstanciaId, d.Instancia?.Producto?.Nombre ?? "(pieza eliminada)", d.Cantidad, d.PrecioUnitario)).ToList())));
    }

    [Authorize(Roles = "Admin"), HttpPut("{id:int}/estado")]
    public async Task<IActionResult> CambiarEstado(int id, [FromBody] EstadoReq req)
    {
        if (req.Estado != EstadoPedido.Completado && req.Estado != EstadoPedido.Cancelado)
            return BadRequest(new { mensaje = "Estado inválido." });

        await using var tx = await _db.Database.BeginTransactionAsync();
        var pedido = await _db.Pedidos.Include(p => p.Detalles).FirstOrDefaultAsync(p => p.Id == id);
        if (pedido is null) return NotFound();
        if (pedido.Estado != EstadoPedido.Pendiente)
            return Conflict(new { mensaje = "Este pedido ya fue cerrado." });

        foreach (var d in pedido.Detalles)
        {
            var instId = d.InstanciaId;
            var cant = d.Cantidad;
            if (req.Estado == EstadoPedido.Cancelado)
            {
                // Cancelado: las piezas vuelven al catálogo.
                await _db.Instancias.Where(i => i.Id == instId)
                    .ExecuteUpdateAsync(s => s.SetProperty(i => i.Stock, i => i.Stock + cant));
                await _db.Instancias.Where(i => i.Id == instId && i.Stock > 0 && i.EstadoId != EstadoInv.Disponible)
                    .ExecuteUpdateAsync(s => s.SetProperty(i => i.EstadoId, EstadoInv.Disponible));
            }
            else
            {
                // Completado: lo que estaba reservado pasa a vendido (Agotado).
                await _db.Instancias.Where(i => i.Id == instId && i.Stock == 0)
                    .ExecuteUpdateAsync(s => s.SetProperty(i => i.EstadoId, EstadoInv.Agotado));
            }
        }

        pedido.Estado = req.Estado;
        await _db.SaveChangesAsync();
        await tx.CommitAsync();
        return NoContent();
    }

    // ---------- Apoyo ----------

    /// <summary>Recoger no pide nada más. Domicilio exige dirección escrita, fecha y un horario que el admin tenga activo.</summary>
    private async Task<(string? Error, DateTime? Fecha, string? Franja)> ValidarEntrega(PedidoReq req)
    {
        if (req.TipoEntrega == TipoEntrega.Recoger) return (null, null, null);
        if (req.TipoEntrega != TipoEntrega.Domicilio)
            return ("Elige cómo quieres recibir tu pedido: recoger o a domicilio.", null, null);

        if (string.IsNullOrWhiteSpace(req.Direccion) || req.Direccion.Trim().Length < 6)
            return ("Escribe la dirección donde quieres recibir tu pedido.", null, null);

        if (req.Latitud.HasValue != req.Longitud.HasValue ||
            (req.Latitud is { } la && (la < -90 || la > 90)) ||
            (req.Longitud is { } lo && (lo < -180 || lo > 180)))
            return ("La ubicación del mapa no es válida. Vuelve a marcarla.", null, null);

        if (!DateTime.TryParseExact(req.Fecha, "yyyy-MM-dd", CultureInfo.InvariantCulture, DateTimeStyles.None, out var fecha))
            return ("Elige el día de entrega.", null, null);

        var ahora = DateTime.UtcNow.AddHours(-6); // hora de Guatemala (no usa horario de verano)
        if (fecha < ahora.Date || fecha > ahora.Date.AddDays(30))
            return ("El día de entrega no es válido.", null, null);

        var partes = (req.Franja ?? "").Split('-');
        if (partes.Length != 2 ||
            !TimeSpan.TryParseExact(partes[0], FormatoHora, CultureInfo.InvariantCulture, out var ini) ||
            !TimeSpan.TryParseExact(partes[1], FormatoHora, CultureInfo.InvariantCulture, out var fin))
            return ("Elige el horario de entrega.", null, null);

        var dia = (int)fecha.DayOfWeek; // 0 = domingo, igual que en HORARIO_ENTREGA
        var existe = await _db.Horarios.AnyAsync(h => h.Activo && h.DiaSemana == dia && h.HoraInicio == ini && h.HoraFin == fin);
        if (!existe) return ("Ese horario ya no está disponible. Elige otro.", null, null);
        if (fecha == ahora.Date && fin <= ahora.TimeOfDay) return ("Ese horario de hoy ya pasó. Elige otro.", null, null);

        return (null, fecha, ini.ToString(FormatoHora) + "-" + fin.ToString(FormatoHora));
    }

    /// <summary>Correo al administrador con el pedido nuevo. Si falla, el pedido ya está guardado: solo se registra en el log.</summary>
    private async Task AvisarAlAdmin(Pedido pedido, int clienteId, List<PedidoDetalle> detalles)
    {
        if (!_correo.Activo || string.IsNullOrWhiteSpace(_correo.CorreoAdmin)) return;
        try
        {
            var cliente = await _db.Clientes.AsNoTracking().FirstAsync(c => c.Id == clienteId);
            var ids = detalles.Select(d => d.InstanciaId).ToList();
            var nombres = await _db.Instancias.AsNoTracking().Where(i => ids.Contains(i.Id))
                .Select(i => new { i.Id, Nombre = i.Producto!.Nombre })
                .ToDictionaryAsync(x => x.Id, x => x.Nombre);

            var lineas = detalles
                .Select(d => (nombres.GetValueOrDefault(d.InstanciaId, "Pieza"), d.Cantidad, d.PrecioUnitario))
                .ToList();

            _correo.Enviar(_correo.CorreoAdmin, $"Nuevo pedido #{pedido.Id} de {cliente.Nombre}",
                PlantillasCorreo.NuevoPedido(pedido, cliente.Nombre, cliente.Correo, lineas));
        }
        catch (Exception e)
        {
            _log.LogWarning(e, "No se pudo preparar el aviso del pedido {Id}.", pedido.Id);
        }
    }
}
