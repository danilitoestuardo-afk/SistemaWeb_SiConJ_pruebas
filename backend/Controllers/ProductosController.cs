// Controllers/ProductosController.cs
// Público: ver el catálogo. Solo Admin: crear, editar y eliminar (con foto y descripción).
// Cada tarjeta del catálogo es una UNIDAD (INSTANCIA_INVENTARIO): tiene su precio, condición y stock.
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using SiconJ.Api.Data;
using SiconJ.Api.Models;

namespace SiconJ.Api.Controllers;

[ApiController]
[Route("api/productos")]
public class ProductosController : ControllerBase
{
    private const long MaxBytes = 3 * 1024 * 1024; // 3 MB por foto
    private const string RutaImg = "/api/imagenes/";
    private readonly SiconJDb _db;
    public ProductosController(SiconJDb db) => _db = db;

    private IQueryable<Instancia> ConDatos() => _db.Instancias
        .Include(i => i.Producto!).ThenInclude(p => p.Categoria)
        .Include(i => i.Condicion);

    // ---------- PÚBLICO ----------

    /// <summary>GET api/productos?categoriaId=&amp;q=&amp;soloDisponibles=&amp;incluirOcultos=
    /// Las piezas ocultas solo las ve el administrador (si manda su sesión y pide incluirOcultos).</summary>
    [HttpGet]
    public async Task<List<ProductoDto>> Listar(
        [FromQuery] int categoriaId = 0, [FromQuery] string? q = null, [FromQuery] bool soloDisponibles = false,
        [FromQuery] bool incluirOcultos = false)
    {
        var query = ConDatos().AsNoTracking();
        if (!(incluirOcultos && User.IsInRole("Admin"))) query = query.Where(i => !i.Oculto);
        if (categoriaId > 0) query = query.Where(i => i.Producto!.CategoriaId == categoriaId);
        if (!string.IsNullOrWhiteSpace(q))
        {
            var texto = q.Trim();
            if (texto.Length > 80) texto = texto[..80];
            query = query.Where(i => i.Producto!.Nombre.Contains(texto));
        }
        if (soloDisponibles) query = query.Where(i => i.EstadoId == EstadoInv.Disponible && i.Stock > 0);

        var lista = await query.OrderByDescending(i => i.Id).ToListAsync();
        return lista.Select(ToDto).ToList();
    }

    // ---------- SOLO ADMIN ----------

    [Authorize(Roles = "Admin"), HttpPost, RequestSizeLimit(4_500_000)]
    public async Task<IActionResult> Crear([FromForm] ProductoForm f)
    {
        var error = await ValidarReferencias(f);
        if (error is not null) return BadRequest(new { mensaje = error });
        var (datos, mime, errorImg) = await LeerImagen(f.Imagen);
        if (errorImg is not null) return BadRequest(new { mensaje = errorImg });

        // Todo o nada: foto + ficha + unidad se guardan juntas.
        await using var tx = await _db.Database.BeginTransactionAsync();

        var imagenBase = "default.png";
        if (datos is not null)
        {
            var img = new ImagenArchivo { Contenido = datos, TipoMime = mime! };
            _db.Imagenes.Add(img);
            await _db.SaveChangesAsync();
            imagenBase = RutaImg + img.Id;
        }

        var producto = new ProductoCatalogo
        {
            Nombre = f.Nombre.Trim(),
            Descripcion = f.Descripcion?.Trim(),
            ImagenBase = imagenBase,
            CategoriaId = f.CategoriaId,
        };
        var unidad = new Instancia
        {
            Producto = producto,
            Precio = f.Precio,
            Stock = f.Stock,
            NotasCondicion = f.NotasCondicion?.Trim(),
            CondicionId = f.CondicionId,
            EstadoId = f.Stock > 0 ? EstadoInv.Disponible : EstadoInv.Agotado,
        };
        _db.Instancias.Add(unidad);
        await _db.SaveChangesAsync();
        await tx.CommitAsync();

        return Ok(ToDto(await ConDatos().AsNoTracking().FirstAsync(i => i.Id == unidad.Id)));
    }

    [Authorize(Roles = "Admin"), HttpPut("{id:int}"), RequestSizeLimit(4_500_000)]
    public async Task<IActionResult> Actualizar(int id, [FromForm] ProductoForm f)
    {
        var unidad = await _db.Instancias.Include(i => i.Producto).FirstOrDefaultAsync(i => i.Id == id);
        if (unidad is null) return NotFound();

        var error = await ValidarReferencias(f);
        if (error is not null) return BadRequest(new { mensaje = error });
        var (datos, mime, errorImg) = await LeerImagen(f.Imagen);
        if (errorImg is not null) return BadRequest(new { mensaje = errorImg });

        await using var tx = await _db.Database.BeginTransactionAsync();
        var producto = unidad.Producto!;

        if (datos is not null) // foto nueva: reemplaza la anterior
        {
            var vieja = IdImagen(producto.ImagenBase);
            var img = new ImagenArchivo { Contenido = datos, TipoMime = mime! };
            _db.Imagenes.Add(img);
            await _db.SaveChangesAsync();
            producto.ImagenBase = RutaImg + img.Id;
            if (vieja is not null) await _db.Imagenes.Where(x => x.Id == vieja).ExecuteDeleteAsync();
        }

        producto.Nombre = f.Nombre.Trim();
        producto.Descripcion = f.Descripcion?.Trim();
        producto.CategoriaId = f.CategoriaId;

        unidad.Precio = f.Precio;
        unidad.Stock = f.Stock;
        unidad.NotasCondicion = f.NotasCondicion?.Trim();
        unidad.CondicionId = f.CondicionId;
        // El estado siempre acompaña al stock: con existencias = Disponible; sin ellas, Reservado si ya
        // estaba reservada por un pedido, o Agotado.
        unidad.EstadoId = f.Stock > 0 ? EstadoInv.Disponible
            : unidad.EstadoId == EstadoInv.Reservado ? EstadoInv.Reservado : EstadoInv.Agotado;

        await _db.SaveChangesAsync();
        await tx.CommitAsync();

        return Ok(ToDto(await ConDatos().AsNoTracking().FirstAsync(i => i.Id == id)));
    }

    [Authorize(Roles = "Admin"), HttpDelete("{id:int}")]
    public async Task<IActionResult> Eliminar(int id)
    {
        var unidad = await _db.Instancias.Include(i => i.Producto).FirstOrDefaultAsync(i => i.Id == id);
        if (unidad is null) return NotFound();

        if (await _db.PedidoDetalles.AnyAsync(d => d.InstanciaId == id))
            return Conflict(new
            {
                mensaje = "Esta pieza ya tiene pedidos registrados, por eso no se puede eliminar (se perdería el historial). Puedes ocultarla del catálogo.",
                puedeOcultar = true,
            });

        var producto = unidad.Producto!;
        var vieja = IdImagen(producto.ImagenBase);

        _db.Instancias.Remove(unidad);
        var hayMas = await _db.Instancias.AnyAsync(i => i.ProductoId == producto.Id && i.Id != id);
        if (!hayMas) _db.Productos.Remove(producto);
        await _db.SaveChangesAsync();

        if (!hayMas && vieja is not null) await _db.Imagenes.Where(x => x.Id == vieja).ExecuteDeleteAsync();
        return NoContent();
    }

    /// <summary>Oculta la pieza del catálogo (o la vuelve a mostrar) sin borrar su historial de pedidos.</summary>
    [Authorize(Roles = "Admin"), HttpPost("{id:int}/ocultar")]
    public async Task<IActionResult> Ocultar(int id, [FromQuery] bool oculto = true)
    {
        var filas = await _db.Instancias.Where(i => i.Id == id)
            .ExecuteUpdateAsync(s => s.SetProperty(i => i.Oculto, oculto));
        return filas == 0 ? NotFound() : NoContent();
    }

    // ---------- Apoyo ----------

    internal static ProductoDto ToDto(Instancia i)
    {
        var p = i.Producto!;
        var imagen = string.IsNullOrWhiteSpace(p.ImagenBase) || p.ImagenBase == "default.png" ? null : p.ImagenBase;
        return new ProductoDto(
            i.Id, p.Nombre, p.Descripcion ?? "",
            p.CategoriaId, p.Categoria?.Nombre ?? "",
            i.CondicionId, i.Condicion?.Nombre ?? "", i.NotasCondicion,
            i.Precio, i.Stock, i.EstadoId == EstadoInv.Disponible && i.Stock > 0 && !i.Oculto, i.Oculto, imagen);
    }

    private async Task<string?> ValidarReferencias(ProductoForm f)
    {
        if (!await _db.Categorias.AnyAsync(c => c.Id == f.CategoriaId)) return "Categoría inválida.";
        if (!await _db.Condiciones.AnyAsync(c => c.Id == f.CondicionId)) return "Condición inválida.";
        return null;
    }

    private static int? IdImagen(string? url) =>
        url is not null && url.StartsWith(RutaImg) && int.TryParse(url[RutaImg.Length..], out var n) ? n : null;

    /// <summary>Lee la foto y comprueba el tipo REAL por sus primeros bytes (no confía en la extensión).</summary>
    private static async Task<(byte[]? Datos, string? Mime, string? Error)> LeerImagen(IFormFile? archivo)
    {
        if (archivo is null || archivo.Length == 0) return (null, null, null);
        if (archivo.Length > MaxBytes) return (null, null, "La foto no debe pasar de 3 MB.");

        using var ms = new MemoryStream();
        await archivo.CopyToAsync(ms);
        var b = ms.ToArray();

        string? mime = null;
        if (b.Length > 12 && b[0] == 0xFF && b[1] == 0xD8 && b[2] == 0xFF) mime = "image/jpeg";
        else if (b.Length > 8 && b[0] == 0x89 && b[1] == 0x50 && b[2] == 0x4E && b[3] == 0x47) mime = "image/png";
        else if (b.Length > 12 && b[0] == 0x52 && b[1] == 0x49 && b[2] == 0x46 && b[3] == 0x46
                 && b[8] == 0x57 && b[9] == 0x45 && b[10] == 0x42 && b[11] == 0x50) mime = "image/webp";

        return mime is null ? (null, null, "Solo se permiten fotos JPG, PNG o WEBP.") : (b, mime, null);
    }
}
