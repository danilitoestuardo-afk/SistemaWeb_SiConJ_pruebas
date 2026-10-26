// Envío directo desde Gmail para las pruebas locales de SiConJ.
// Las credenciales se leen desde user-secrets; nunca se escriben aquí.
using System.Net;
using System.Net.Mail;
using System.Text;

namespace SiconJ.Api.Services;

public sealed class CorreoGmail : ICorreo
{
    private readonly string? _usuario;
    private readonly string? _clave;
    private readonly ILogger<CorreoGmail> _log;

    public string? CorreoAdmin { get; }
    public bool Activo => !string.IsNullOrWhiteSpace(_usuario) && !string.IsNullOrWhiteSpace(_clave);

    public CorreoGmail(IConfiguration cfg, ILogger<CorreoGmail> log)
    {
        _usuario = cfg["Correo:Gmail:Usuario"]?.Trim();
        _clave = cfg["Correo:Gmail:ClaveAplicacion"]?.Replace(" ", "").Trim();
        CorreoAdmin = cfg["Correo:AvisoPedidos"];
        _log = log;
    }

    public void Enviar(string para, string asunto, string html)
    {
        if (!Activo)
        {
            _log.LogWarning("Gmail desactivado: faltan Usuario o ClaveAplicacion en la configuración local.");
            return;
        }

        // Conserva el comportamiento existente: un fallo de correo no deshace el pedido o registro.
        _ = Task.Run(async () =>
        {
            try
            {
                using var mensaje = new MailMessage
                {
                    From = new MailAddress(_usuario!, "SiConJ", Encoding.UTF8),
                    Subject = asunto,
                    SubjectEncoding = Encoding.UTF8,
                    Body = html,
                    BodyEncoding = Encoding.UTF8,
                    IsBodyHtml = true,
                };
                mensaje.To.Add(new MailAddress(para));

                using var smtp = new SmtpClient("smtp.gmail.com", 587)
                {
                    EnableSsl = true, // STARTTLS; validación normal del certificado.
                    UseDefaultCredentials = false,
                    Credentials = new NetworkCredential(_usuario!, _clave!),
                    DeliveryMethod = SmtpDeliveryMethod.Network,
                };
                using var limite = new CancellationTokenSource(TimeSpan.FromSeconds(30));
                await smtp.SendMailAsync(mensaje, limite.Token);
                _log.LogInformation("Gmail aceptó un correo para envío. Comprueba su recepción en el buzón destinatario.");
            }
            catch (Exception e)
            {
                _log.LogWarning(e, "No se pudo enviar el correo mediante Gmail.");
            }
        });
    }
}
