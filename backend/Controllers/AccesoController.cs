// Controllers/AccesoController.cs
// Una sola puerta de entrada para todos:
//   POST api/acceso          -> el usuario escribe su clave. Si es el PIN del admin, recibe un token corto
//                               (solo sirve para el paso 2). Si es una clave de cliente, entra como cliente.
//   POST api/acceso/admin    -> paso 2: con ese token + la clave del admin se obtiene el token de Admin.
//   POST api/acceso/registro -> crea una cuenta de cliente y devuelve su clave (se muestra una sola vez).
using System.Security.Claims;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.RateLimiting;
using Microsoft.EntityFrameworkCore;
using SiconJ.Api.Data;
using SiconJ.Api.Models;
using SiconJ.Api.Services;

namespace SiconJ.Api.Controllers;

[ApiController]
[Route("api/acceso")]
public class AccesoController : ControllerBase
{
    private readonly SiconJDb _db;
    private readonly Seguridad _seg;
    public AccesoController(SiconJDb db, Seguridad seg) { _db = db; _seg = seg; }

    [HttpPost, EnableRateLimiting("acceso")]
    public async Task<IActionResult> Entrar([FromBody] ClaveReq req)
    {
        var clave = req.Clave.Trim();

        // 1) ¿Es el PIN del administrador?
        var admin = await _db.Admin.AsNoTracking().FirstOrDefaultAsync();
        if (admin is not null && BCrypt.Net.BCrypt.Verify(clave, admin.PinHash))
        {
            // Este token NO tiene rol: solo permite llamar a api/acceso/admin durante 5 minutos.
            var t = _seg.CrearToken(new[] { new Claim("etapa", "pin") }, TimeSpan.FromMinutes(5), out var exp);
            return Ok(new AccesoResp("admin-paso1", t, "Administrador", exp));
        }

        // 2) ¿Es la clave de un cliente?
        var hash = _seg.HashClaveCliente(clave);
        var cliente = await _db.Clientes.AsNoTracking().FirstOrDefaultAsync(c => c.ClaveHash == hash);
        if (cliente is not null) return Ok(TokenCliente(cliente));

        return Unauthorized(new { mensaje = "Clave incorrecta." });
    }

    [HttpPost("admin"), Authorize(Policy = "PinOk"), EnableRateLimiting("acceso")]
    public async Task<IActionResult> AdminClave([FromBody] ClaveReq req)
    {
        var admin = await _db.Admin.FirstOrDefaultAsync();
        if (admin is null) return Unauthorized(new { mensaje = "Clave incorrecta." });

        if (admin.BloqueadoHasta is { } hasta && hasta > DateTime.UtcNow)
            return StatusCode(StatusCodes.Status429TooManyRequests,
                new { mensaje = "Acceso bloqueado por intentos fallidos. Intenta de nuevo en unos minutos." });

        if (!BCrypt.Net.BCrypt.Verify(req.Clave, admin.ClaveHash))
        {
            admin.IntentosFallidos++;
            if (admin.IntentosFallidos >= 5)
            {
                admin.BloqueadoHasta = DateTime.UtcNow.AddMinutes(15);
                admin.IntentosFallidos = 0;
            }
            await _db.SaveChangesAsync();
            return Unauthorized(new { mensaje = "Clave incorrecta." });
        }

        admin.IntentosFallidos = 0;
        admin.BloqueadoHasta = null;
        await _db.SaveChangesAsync();

        var claims = new[] { new Claim("role", "Admin"), new Claim("name", "Administrador") };
        var token = _seg.CrearToken(claims, TimeSpan.FromHours(3), out var exp);
        return Ok(new AccesoResp("admin", token, "Administrador", exp));
    }

    [HttpPost("registro"), EnableRateLimiting("acceso")]
    public async Task<IActionResult> Registro([FromBody] RegistroReq req)
    {
        var correo = req.Correo.Trim().ToLowerInvariant();
        if (await _db.Clientes.AnyAsync(c => c.Correo == correo))
            return Conflict(new { mensaje = "Ese correo ya tiene una cuenta. Entra con tu clave de cliente." });

        var clave = _seg.NuevaClaveCliente();
        var cliente = new Cliente
        {
            Nombre = req.Nombre.Trim(),
            Correo = correo,
            ClaveHash = _seg.HashClaveCliente(clave),
            AceptaOfertas = req.AceptaOfertas,
        };
        _db.Clientes.Add(cliente);
        try { await _db.SaveChangesAsync(); }
        catch (DbUpdateException) { return Conflict(new { mensaje = "No se pudo crear la cuenta. Intenta de nuevo." }); }

        return Ok(new RegistroResp(clave, TokenCliente(cliente)));
    }

    private AccesoResp TokenCliente(Cliente c)
    {
        var claims = new[]
        {
            new Claim("role", "Cliente"),
            new Claim("cid", c.Id.ToString()),
            new Claim("name", c.Nombre),
        };
        var token = _seg.CrearToken(claims, TimeSpan.FromDays(7), out var exp);
        return new AccesoResp("cliente", token, c.Nombre, exp);
    }
}
