// Program.cs - Arranque de la API de SiConJ.
// NINGÚN secreto va en el código: todo entra por variables de entorno (Railway) o
// "dotnet user-secrets" (en tu computadora). Ver LEEME.md.
using System.Globalization;
using System.Text;
using System.Threading.RateLimiting;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.AspNetCore.HttpOverrides;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using SiconJ.Api.Data;
using SiconJ.Api.Services;

CultureInfo.DefaultThreadCurrentCulture = CultureInfo.InvariantCulture; // decimales con punto

var builder = WebApplication.CreateBuilder(args);
var cfg = builder.Configuration;

// Railway indica el puerto en la variable PORT.
var port = Environment.GetEnvironmentVariable("PORT");
if (!string.IsNullOrEmpty(port)) builder.WebHost.UseUrls($"http://0.0.0.0:{port}");

// ---- Secretos obligatorios ----
var jwtKey = cfg["Jwt:Key"];
if (string.IsNullOrWhiteSpace(jwtKey) || jwtKey.Length < 32)
    throw new InvalidOperationException("Falta la variable Jwt__Key (mínimo 32 caracteres).");

// ---- Base de datos: ConnectionStrings__Default, o las variables MYSQL* que da Railway ----
static string ConexionRailway(IConfiguration c)
{
    var host = c["MYSQLHOST"];
    if (string.IsNullOrEmpty(host))
        throw new InvalidOperationException(
            "Falta la conexión a MySQL: define ConnectionStrings__Default o las variables MYSQLHOST/MYSQLPORT/MYSQLUSER/MYSQLPASSWORD/MYSQLDATABASE.");
    return $"Server={host};Port={c["MYSQLPORT"] ?? "3306"};Database={c["MYSQLDATABASE"]};User={c["MYSQLUSER"]};Password={c["MYSQLPASSWORD"]};";
}
var conn = cfg.GetConnectionString("Default") ?? ConexionRailway(cfg);
builder.Services.AddDbContext<SiconJDb>(o => o.UseMySql(conn, new MySqlServerVersion(new Version(8, 0, 36))));

// ---- Autenticación JWT ----
builder.Services.AddSingleton<Seguridad>();
builder.Services
    .AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
    .AddJwtBearer(o =>
    {
        o.MapInboundClaims = false; // los claims se quedan con su nombre corto: "role", "cid", "etapa"
        o.TokenValidationParameters = new TokenValidationParameters
        {
            ValidateIssuer = true, ValidIssuer = Seguridad.Issuer,
            ValidateAudience = true, ValidAudience = Seguridad.Audience,
            ValidateLifetime = true, ValidateIssuerSigningKey = true,
            IssuerSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(jwtKey)),
            RoleClaimType = "role", NameClaimType = "name",
            ClockSkew = TimeSpan.FromMinutes(1),
        };
    });
builder.Services.AddAuthorization(o =>
    o.AddPolicy("PinOk", p => p.RequireClaim("etapa", "pin"))); // token del primer paso del admin

// ---- Límite de intentos en las rutas de acceso (por IP) ----
builder.Services.AddRateLimiter(o =>
{
    o.RejectionStatusCode = StatusCodes.Status429TooManyRequests;
    o.AddPolicy("acceso", ctx => RateLimitPartition.GetFixedWindowLimiter(
        ctx.Connection.RemoteIpAddress?.ToString() ?? "desconocida",
        _ => new FixedWindowRateLimiterOptions { PermitLimit = 8, Window = TimeSpan.FromMinutes(1), QueueLimit = 0 }));
});

// Railway pone un proxy delante: así vemos la IP real del visitante.
builder.Services.Configure<ForwardedHeadersOptions>(o =>
{
    o.ForwardedHeaders = ForwardedHeaders.XForwardedFor | ForwardedHeaders.XForwardedProto;
    o.KnownNetworks.Clear();
    o.KnownProxies.Clear();
});

// ---- CORS: dominios que pueden usar la API (tu página en cPanel) ----
var origenes = (cfg["Cors:Origins"] ?? "http://localhost:5173")
    .Split(',', StringSplitOptions.RemoveEmptyEntries | StringSplitOptions.TrimEntries);
builder.Services.AddCors(o => o.AddPolicy("web", p => p.WithOrigins(origenes).AllowAnyHeader().AllowAnyMethod()));

// Gmail se habilita explícitamente y solo en Development para las pruebas locales.
// Los demás entornos conservan el envío HTTPS mediante cPanel.
builder.Services.AddHttpClient();
if (builder.Environment.IsDevelopment() &&
    string.Equals(cfg["Correo:Modo"], "Gmail", StringComparison.OrdinalIgnoreCase))
    builder.Services.AddSingleton<ICorreo, CorreoGmail>();
else
    builder.Services.AddSingleton<ICorreo, CorreoRelay>();

builder.Services.AddControllers();

var app = builder.Build();

// ---- PIN y clave del administrador: se guardan SOLO como hash (BCrypt) ----
// Se toman de Admin__Pin y Admin__Clave. Si cambias esas variables y reinicias, se actualizan.
using (var scope = app.Services.CreateScope())
{
    var db = scope.ServiceProvider.GetRequiredService<SiconJDb>();
    var pin = cfg["Admin:Pin"];
    var clave = cfg["Admin:Clave"];

    if (!string.IsNullOrWhiteSpace(pin) && !string.IsNullOrWhiteSpace(clave))
    {
        if (pin.Length < 8) throw new InvalidOperationException("Admin__Pin debe tener al menos 8 caracteres.");
        if (clave.Length < 10) throw new InvalidOperationException("Admin__Clave debe tener al menos 10 caracteres.");
        if (pin == clave) throw new InvalidOperationException("Admin__Pin y Admin__Clave deben ser distintos.");

        var admin = await db.Admin.FirstOrDefaultAsync(a => a.Id == 1);
        if (admin is null) { admin = new SiconJ.Api.Models.AdminAcceso { Id = 1 }; db.Admin.Add(admin); }
        admin.PinHash = BCrypt.Net.BCrypt.HashPassword(pin);
        admin.ClaveHash = BCrypt.Net.BCrypt.HashPassword(clave);
        admin.IntentosFallidos = 0;
        admin.BloqueadoHasta = null;
        await db.SaveChangesAsync();
    }
    else if (!await db.Admin.AnyAsync())
    {
        throw new InvalidOperationException("Falta Admin__Pin y Admin__Clave: se necesitan la primera vez para crear el acceso del administrador.");
    }
}

app.UseForwardedHeaders();
app.UseCors("web");
app.UseAuthentication();
app.UseAuthorization();
app.UseRateLimiter();

app.MapGet("/", () => "SiConJ API en línea");
app.MapControllers();
app.Run();
