// Models/Dtos.cs - Lo que entra y sale por la API (lo que ve el Vue).
using System.ComponentModel.DataAnnotations;

namespace SiconJ.Api.Models;

// ---------- Catálogo ----------
public record ProductoDto(
    int Id,                 // id de la unidad (INSTANCIA_INVENTARIO): es lo que se pide
    string Nombre, string Descripcion,
    int CategoriaId, string Categoria,
    int CondicionId, string Condicion, string? NotasCondicion,
    decimal Precio, int Stock, bool Disponible, string? ImagenUrl);

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

/// <summary>Tipo: "cliente", "admin-paso1" (PIN correcto, falta la clave) o "admin".</summary>
public record AccesoResp(string Tipo, string Token, string Nombre, DateTime Expira);
public record RegistroResp(string Clave, AccesoResp Sesion);

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
}

public class EstadoReq { [Required] public string Estado { get; set; } = ""; }

public record DetalleDto(int InstanciaId, string Nombre, int Cantidad, decimal PrecioUnitario);
public record PedidoDto(int Id, DateTime Creado, string Estado, decimal Total, string? Nota,
    string Cliente, string Correo, List<DetalleDto> Detalles);

public record ClienteDto(int Id, string Nombre, string Correo, bool AceptaOfertas, DateTime Creado, int Pedidos);
