// Controllers/EntregaController.cs
// Público: ver el punto de recogida y los horarios de entrega a domicilio.
// Solo Admin: cambiarlos (por ejemplo, quitar lunes a viernes después de cierta hora).
using System.Globalization;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using SiconJ.Api.Data;
using SiconJ.Api.Models;

namespace SiconJ.Api.Controllers;

[ApiController]
[Route("api/entrega")]
public class EntregaController : ControllerBase
{
    private const string FormatoHora = @"hh\:mm";
    private readonly SiconJDb _db;
    public EntregaController(SiconJDb db) => _db = db;

    // ---------- PÚBLICO ----------

    [HttpGet]
    public async Task<EntregaInfoDto> Obtener()
    {
        var ajustes = await _db.Ajustes.AsNoTracking().ToDictionaryAsync(a => a.Clave, a => a.Valor);
        string Dato(string clave) => ajustes.TryGetValue(clave, out var v) ? v : "";

        var horarios = await _db.Horarios.AsNoTracking()
            .OrderBy(h => h.DiaSemana).ThenBy(h => h.HoraInicio).ToListAsync();

        return new EntregaInfoDto(
            new RecogidaDto(Dato("recogida_nombre"), Dato("recogida_direccion"), Dato("recogida_indicaciones"), Dato("recogida_horario")),
            horarios.Select(ToDto).ToList());
    }

    // ---------- SOLO ADMIN ----------

    [Authorize(Roles = "Admin"), HttpPut("recogida")]
    public async Task<IActionResult> GuardarRecogida([FromBody] RecogidaReq req)
    {
        await Guardar("recogida_nombre", req.Nombre.Trim());
        await Guardar("recogida_direccion", req.Direccion?.Trim() ?? "");
        await Guardar("recogida_indicaciones", req.Indicaciones?.Trim() ?? "");
        await Guardar("recogida_horario", req.Horario?.Trim() ?? "");
        await _db.SaveChangesAsync();
        return NoContent();
    }

    [Authorize(Roles = "Admin"), HttpPost("horarios")]
    public async Task<IActionResult> CrearHorario([FromBody] HorarioReq req)
    {
        var (ini, fin, error) = LeerHoras(req);
        if (error is not null) return BadRequest(new { mensaje = error });

        var h = new HorarioEntrega { DiaSemana = req.DiaSemana, HoraInicio = ini, HoraFin = fin, Activo = req.Activo };
        _db.Horarios.Add(h);
        await _db.SaveChangesAsync();
        return Ok(ToDto(h));
    }

    [Authorize(Roles = "Admin"), HttpPut("horarios/{id:int}")]
    public async Task<IActionResult> ActualizarHorario(int id, [FromBody] HorarioReq req)
    {
        var h = await _db.Horarios.FirstOrDefaultAsync(x => x.Id == id);
        if (h is null) return NotFound();

        var (ini, fin, error) = LeerHoras(req);
        if (error is not null) return BadRequest(new { mensaje = error });

        h.DiaSemana = req.DiaSemana;
        h.HoraInicio = ini;
        h.HoraFin = fin;
        h.Activo = req.Activo;
        await _db.SaveChangesAsync();
        return Ok(ToDto(h));
    }

    [Authorize(Roles = "Admin"), HttpDelete("horarios/{id:int}")]
    public async Task<IActionResult> EliminarHorario(int id)
    {
        var filas = await _db.Horarios.Where(x => x.Id == id).ExecuteDeleteAsync();
        return filas == 0 ? NotFound() : NoContent();
    }

    // ---------- Apoyo ----------

    private static HorarioDto ToDto(HorarioEntrega h) =>
        new(h.Id, h.DiaSemana, h.HoraInicio.ToString(FormatoHora), h.HoraFin.ToString(FormatoHora), h.Activo);

    private static (TimeSpan Inicio, TimeSpan Fin, string? Error) LeerHoras(HorarioReq req)
    {
        if (!TimeSpan.TryParseExact(req.Inicio, FormatoHora, CultureInfo.InvariantCulture, out var ini) ||
            !TimeSpan.TryParseExact(req.Fin, FormatoHora, CultureInfo.InvariantCulture, out var fin))
            return (default, default, "Las horas deben tener el formato HH:mm.");
        if (fin <= ini) return (default, default, "La hora final debe ser después de la inicial.");
        return (ini, fin, null);
    }

    private async Task Guardar(string clave, string valor)
    {
        var a = await _db.Ajustes.FirstOrDefaultAsync(x => x.Clave == clave);
        if (a is null) _db.Ajustes.Add(new Ajuste { Clave = clave, Valor = valor });
        else a.Valor = valor;
    }
}
