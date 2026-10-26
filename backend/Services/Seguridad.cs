// Services/Seguridad.cs - Tokens JWT y claves de cliente.
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Security.Cryptography;
using System.Text;
using Microsoft.IdentityModel.Tokens;

namespace SiconJ.Api.Services;

public class Seguridad
{
    public const string Issuer = "SiconJ.Api";
    public const string Audience = "SiconJ.Web";
    private const string Alfabeto = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789"; // sin O, 0, I, 1 para no confundir

    private readonly byte[] _llave;

    public Seguridad(IConfiguration cfg) => _llave = Encoding.UTF8.GetBytes(cfg["Jwt:Key"]!);

    /// <summary>Las claves de cliente se generan al azar, así que basta un hash HMAC determinista:
    /// permite buscar al cliente por su clave sin guardarla.</summary>
    public string HashClaveCliente(string clave) =>
        Convert.ToHexString(HMACSHA256.HashData(_llave, Encoding.UTF8.GetBytes(Normalizar(clave))));

    /// <summary>Acepta minúsculas, espacios y guiones: "ab3 k9x" y "AB3-K9X" son la misma clave.</summary>
    public static string Normalizar(string clave) => clave.Replace(" ", "").Replace("-", "").ToUpperInvariant();

    /// <summary>6 caracteres, solo mayúsculas y números (sin O, 0, I, 1 para no confundirlos). Ej: K7M2QX</summary>
    public string NuevaClaveCliente()
    {
        var c = new char[6];
        for (int i = 0; i < c.Length; i++) c[i] = Alfabeto[RandomNumberGenerator.GetInt32(Alfabeto.Length)];
        return new string(c);
    }

    public string CrearToken(IEnumerable<Claim> claims, TimeSpan vida, out DateTime expira)
    {
        expira = DateTime.UtcNow.Add(vida);
        var cred = new SigningCredentials(new SymmetricSecurityKey(_llave), SecurityAlgorithms.HmacSha256);
        var jwt = new JwtSecurityToken(Issuer, Audience, claims, expires: expira, signingCredentials: cred);
        return new JwtSecurityTokenHandler().WriteToken(jwt);
    }
}
