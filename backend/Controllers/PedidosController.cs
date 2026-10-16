// Controllers/PedidosController.cs
// Cliente: registra su pedido (se descuenta el stock al instante, así nadie más lo compra).
// Admin: ve todos los pedidos en vivo y los marca como Completado o Cancelado.
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using SiconJ.Api.Data;
using SiconJ.Api.Models;

namespace SiconJ.Api.Controllers;

[ApiController]
[Route("api/pedidos")]
public class PedidosController : ControllerBase
{
    private readonly SiconJDb _db;
    public PedidosController(SiconJDb db) => _db = db;

    // ---------- CLIENTE ----------

    [Authorize(Roles = "Cliente"), HttpPost]
    public async Task<IActionResult> Crear([FromBody] PedidoReq req)
    {
        if (!int.TryParse(User.FindFirst("cid")?.Value, out var clienteId)) return Unauthorized();
        if (!await _db.Clientes.AnyAsync(c => c.Id == clienteId)) return Unauthorized();

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

            // Descuento atómico: solo se aplica si sigue Disponible y alcanza el stock.
            // Dos clientes pidiendo la última pieza a la vez: uno gana y el otro recibe el aviso.
            var filas = await _db.Instancias
                .Where(i => i.Id == id && i.EstadoId == EstadoInv.Disponible && i.Stock >= cant)
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
        };
        _db.Pedidos.Add(pedido);
        await _db.SaveChangesAsync();
        await tx.CommitAsync();

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
}
