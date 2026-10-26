// Models/Dtos.cs - Lo que entra y sale por la API (lo que ve el Vue).
using System.ComponentModel.DataAnnotations;

namespace SiconJ.Api.Models;

// ---------- Catálogo ----------
public record ProductoDto(
    int Id,                 // id de la unidad (INSTANCIA_INVENTARIO): es lo que se pide
    string Nombre, string Descripcion,
    int CategoriaId, string Categoria,
    int CondicionId, string Condicion, string? NotasCondicion,
    decimal Precio, int Stock, bool Disponible, bool Oculto, string? ImagenUrl);

public class ProductoForm
{
    [Required, StringLength(120)] public string Nombre { get; set; } = "";
    [StringLength(255)] public string? Descripcion { get; set; }
    [Range(1, int.MaxValue)] public int CategoriaId { get; set; }
    [Range(1, int.MaxValue)] public int CondicionId { get; set; }
    [Range(0.01, 1_000_000)] public decimal Precio { get; set; }
    [Range(0, 100_000)] public int Stock { get; set; }
    [StringLength(500)] public string? NotasCondicion { get; set; }
    public IFormFile? Imagen { get; set; }
}

// ---------- Acceso ----------
public class ClaveReq
{
    [Required, StringLength(100)] public string Clave { get; set; } = "";
}

public class RegistroReq
{
    [Required, StringLength(80)] public string Nombre { get; set; } = "";
    [Required, EmailAddress, StringLength(120)] public string Correo { get; set; } = "";
    public bool AceptaOfertas { get; set; }
}

public class RecuperarReq
{
    [Required, EmailAddress, StringLength(120)] public string Correo { get; set; } = "";
}

/// <summary>Tipo: "cliente", "admin-paso1" (PIN correcto, falta la clave) o "admin".</summary>
public record AccesoResp(string Tipo, string Token, string Nombre, DateTime Expira);
public record RegistroResp(string Clave, AccesoResp Sesion, bool CorreoEnviado);

// ---------- Pedidos ----------
public class ItemReq
{
    [Range(1, int.MaxValue)] public int InstanciaId { get; set; }
    [Range(1, 100)] public int Cantidad { get; set; }
}

public class PedidoReq
{
    [Required, MinLength(1), MaxLength(30)] public List<ItemReq> Items { get; set; } = new();
    [StringLength(300)] public string? Nota { get; set; }

    /// <summary>"Recoger" (en la tienda aliada) o "Domicilio". Es obligatorio elegir una.</summary>
    [Required, StringLength(10)] public string TipoEntrega { get; set; } = "";

    // Solo para Domicilio:
    [StringLength(300)] public string? Direccion { get; set; }
    public decimal? Latitud { get; set; }
    public decimal? Longitud { get; set; }
    [StringLength(10)] public string? Fecha { get; set; }   // yyyy-MM-dd
    [StringLength(11)] public string? Franja { get; set; }  // HH:mm-HH:mm
}

public class EstadoReq { [Required] public string Estado { get; set; } = ""; }

public record DetalleDto(int InstanciaId, string Nombre, int Cantidad, decimal PrecioUnitario);
public record PedidoDto(int Id, DateTime Creado, string Estado, decimal Total, string? Nota,
    string Cliente, string Correo,
    string TipoEntrega, string? Direccion, decimal? Latitud, decimal? Longitud, string? EntregaFecha, string? EntregaFranja,
    List<DetalleDto> Detalles);

public record ClienteDto(int Id, string Nombre, string Correo, bool AceptaOfertas, DateTime Creado, int Pedidos);

// ---------- Entrega (punto de recogida y horarios) ----------
public record HorarioDto(int Id, int DiaSemana, string Inicio, string Fin, bool Activo);
public record RecogidaDto(string Nombre, string Direccion, string Indicaciones, string Horario);
public record EntregaInfoDto(RecogidaDto Recogida, List<HorarioDto> Horarios);

public class RecogidaReq
{
    [Required, StringLength(100)] public string Nombre { get; set; } = "";
    [StringLength(300)] public string? Direccion { get; set; }
    [StringLength(500)] public string? Indicaciones { get; set; }
    [StringLength(200)] public string? Horario { get; set; }
}

public class HorarioReq
{
    [Range(0, 6)] public int DiaSemana { get; set; }
    [Required, RegularExpression(@"^([01]\d|2[0-3]):[0-5]\d$", ErrorMessage = "Hora de inicio inválida.")] public string Inicio { get; set; } = "";
    [Required, RegularExpression(@"^([01]\d|2[0-3]):[0-5]\d$", ErrorMessage = "Hora de fin inválida.")] public string Fin { get; set; } = "";
    public bool Activo { get; set; } = true;
}
