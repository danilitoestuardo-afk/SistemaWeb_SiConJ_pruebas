// Services/Correo.cs - Envío de correos.
//
// Railway BLOQUEA el SMTP directo (puertos 25, 465, 587) en los planes Free, Trial y Hobby, así que una
// librería SMTP (como MailKit) hablando con tu cPanel daría "timeout". En vez de eso, la API llama por HTTPS
// a un script pequeño en tu cPanel (enviar-correo.php) y ese script manda el correo con tu dominio.
// Si algún día pasan a Railway Pro, se puede cambiar esta clase por una con MailKit sin tocar lo demás.
using System.Globalization;
using System.Net;
using System.Text;
using System.Text.Json;
using SiconJ.Api.Models;

namespace SiconJ.Api.Services;

public interface ICorreo
{
    /// <summary>true si están configuradas Correo__Url y Correo__Token.</summary>
    bool Activo { get; }
    /// <summary>Dónde llegan los avisos de pedidos nuevos (Correo__AvisoPedidos).</summary>
    string? CorreoAdmin { get; }
    void Enviar(string para, string asunto, string html);
}

public class CorreoRelay : ICorreo
{
    private readonly IHttpClientFactory _http;
    private readonly ILogger<CorreoRelay> _log;
    private readonly string? _url;
    private readonly string? _token;

    public string? CorreoAdmin { get; }
    public bool Activo => !string.IsNullOrWhiteSpace(_url) && !string.IsNullOrWhiteSpace(_token);

    public CorreoRelay(IConfiguration cfg, IHttpClientFactory http, ILogger<CorreoRelay> log)
    {
        _http = http;
        _log = log;
        _url = cfg["Correo:Url"];
        _token = cfg["Correo:Token"];
        CorreoAdmin = cfg["Correo:AvisoPedidos"];
    }

    /// <summary>Se envía en segundo plano: el cliente no espera y, si falla, el pedido NO se cae (solo queda en el log).</summary>
    public void Enviar(string para, string asunto, string html)
    {
        if (!Activo)
        {
            _log.LogWarning("Correo desactivado (falta Correo__Url o Correo__Token). No se envió: {Asunto}", asunto);
            return;
        }

        _ = Task.Run(async () =>
        {
            try
            {
                using var req = new HttpRequestMessage(HttpMethod.Post, _url);
                req.Headers.Add("X-Token", _token!);
                req.Content = new StringContent(
                    JsonSerializer.Serialize(new { para, asunto, html }), Encoding.UTF8, "application/json");

                var cliente = _http.CreateClient();
                cliente.Timeout = TimeSpan.FromSeconds(20);
                using var res = await cliente.SendAsync(req);
                if (!res.IsSuccessStatusCode)
                    _log.LogWarning("El envío de correo falló ({Codigo}): {Cuerpo}", (int)res.StatusCode, await res.Content.ReadAsStringAsync());
            }
            catch (Exception e)
            {
                _log.LogWarning(e, "No se pudo enviar el correo: {Asunto}", asunto);
            }
        });
    }
}

/// <summary>Textos de los correos. Todo lo que escribe un usuario pasa por HtmlEncode.</summary>
public static class PlantillasCorreo
{
    private static string H(string? s) => WebUtility.HtmlEncode(s ?? "");
    private static string Q(decimal n) => "Q " + n.ToString("N2", CultureInfo.InvariantCulture);

    public static string Clave(string nombre, string clave) =>
        $"<p>Hola {H(nombre)},</p>" +
        "<p>Tu clave de cliente de SiConJ es:</p>" +
        $"<p style=\"font-size:30px;font-weight:bold;letter-spacing:4px;margin:8px 0\">{H(clave)}</p>" +
        "<p>Guárdala: con ella entras a la tienda y haces tus pedidos. Si no la pediste tú, ignora este correo.</p>";

    public static string NuevoPedido(Pedido p, string clienteNombre, string clienteCorreo,
        IEnumerable<(string Nombre, int Cantidad, decimal Precio)> lineas)
    {
        var sb = new StringBuilder();
        sb.Append($"<h2>Nuevo pedido #{p.Id}</h2>");
        sb.Append($"<p><b>Cliente:</b> {H(clienteNombre)} ({H(clienteCorreo)})</p><ul>");
        foreach (var l in lineas)
            sb.Append($"<li>{l.Cantidad} x {H(l.Nombre)} a {Q(l.Precio)}</li>");
        sb.Append($"</ul><p><b>Total:</b> {Q(p.Total)}</p>");

        if (p.TipoEntrega == TipoEntrega.Domicilio)
        {
            sb.Append("<p><b>Entrega:</b> a domicilio</p>");
            sb.Append($"<p><b>Dirección:</b> {H(p.Direccion)}</p>");
            if (p.EntregaFecha is { } f)
                sb.Append($"<p><b>Cuándo:</b> {f:dd/MM/yyyy}, {H(p.EntregaFranja)}</p>");
            if (p.Latitud is { } lat && p.Longitud is { } lng)
            {
                var url = $"https://www.google.com/maps?q={lat.ToString(CultureInfo.InvariantCulture)},{lng.ToString(CultureInfo.InvariantCulture)}";
                sb.Append($"<p><a href=\"{url}\">Ver el punto en Google Maps</a></p>");
            }
        }
        else
        {
            sb.Append("<p><b>Entrega:</b> el cliente recoge en la tienda aliada.</p>");
        }

        if (!string.IsNullOrWhiteSpace(p.Nota)) sb.Append($"<p><b>Nota del cliente:</b> {H(p.Nota)}</p>");
        sb.Append("<p>Revísalo en el panel de administración, pestaña Pedidos.</p>");
        return sb.ToString();
    }
}
