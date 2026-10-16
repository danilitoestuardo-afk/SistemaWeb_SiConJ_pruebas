// Controllers/ClientesController.cs - Solo Admin: lista de clientes y ofertas.
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using SiconJ.Api.Data;
using SiconJ.Api.Models;
using SiconJ.Api.Services;

namespace SiconJ.Api.Controllers;

[ApiController]
[Route("api/clientes")]
[Authorize(Roles = "Admin")]
public class ClientesController : ControllerBase
{
    private readonly SiconJDb _db;
    private readonly Seguridad _seg;
    public ClientesController(SiconJDb db, Seguridad seg) { _db = db; _seg = seg; }

    [HttpGet]
    public async Task<IActionResult> Listar()
    {
        var lista = await _db.Clientes.AsNoTracking().OrderByDescending(c => c.Id)
            .Select(c => new { c.Id, c.Nombre, c.Correo, c.AceptaOfertas, c.Creado, Pedidos = _db.Pedidos.Count(p => p.ClienteId == c.Id) })
            .ToListAsync();
        return Ok(lista.Select(c => new ClienteDto(
            c.Id, c.Nombre, c.Correo, c.AceptaOfertas, DateTime.SpecifyKind(c.Creado, DateTimeKind.Utc), c.Pedidos)));
    }

    /// <summary>Si un cliente pierde su clave, el admin le genera una nueva (la anterior deja de servir).</summary>
    [HttpPost("{id:int}/clave")]
    public async Task<IActionResult> NuevaClave(int id)
    {
        var cliente = await _db.Clientes.FirstOrDefaultAsync(c => c.Id == id);
        if (cliente is null) return NotFound();
        var clave = _seg.NuevaClaveCliente();
        cliente.ClaveHash = _seg.HashClaveCliente(clave);
        await _db.SaveChangesAsync();
        return Ok(new { clave });
    }
}
