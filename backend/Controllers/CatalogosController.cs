// Controllers/CatalogosController.cs - Listas para los filtros y el formulario del admin.
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using SiconJ.Api.Data;

namespace SiconJ.Api.Controllers;

[ApiController]
[Route("api/catalogos")]
public class CatalogosController : ControllerBase
{
    private readonly SiconJDb _db;
    public CatalogosController(SiconJDb db) => _db = db;

    [HttpGet]
    public async Task<IActionResult> Obtener() => Ok(new
    {
        categorias = await _db.Categorias.AsNoTracking().OrderBy(c => c.Id)
            .Select(c => new { c.Id, c.Nombre }).ToListAsync(),
        condiciones = await _db.Condiciones.AsNoTracking().OrderBy(c => c.Id)
            .Select(c => new { c.Id, c.Nombre }).ToListAsync(),
    });
}
