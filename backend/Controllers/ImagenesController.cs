// Controllers/ImagenesController.cs - Entrega las fotos que sube el admin (guardadas en la base).
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using SiconJ.Api.Data;

namespace SiconJ.Api.Controllers;

[ApiController]
[Route("api/imagenes")]
public class ImagenesController : ControllerBase
{
    private readonly SiconJDb _db;
    public ImagenesController(SiconJDb db) => _db = db;

    [HttpGet("{id:int}")]
    public async Task<IActionResult> Obtener(int id)
    {
        var img = await _db.Imagenes.AsNoTracking().FirstOrDefaultAsync(i => i.Id == id);
        if (img is null) return NotFound();
        Response.Headers["Cache-Control"] = "public, max-age=86400";
        Response.Headers["X-Content-Type-Options"] = "nosniff";
        return File(img.Contenido, img.TipoMime);
    }
}
