// Models/Entities.cs - Tablas de la base de datos (nombres reales del SQL).
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace SiconJ.Api.Models;

/// <summary>Ids fijos de ESTADO_DISPONIBILIDAD (los inserta schema.sql).</summary>
public static class EstadoInv
{
    public const int Disponible = 1;
    public const int Reservado = 2;   // pedida por un cliente, venta aún no confirmada
    public const int Agotado = 3;
}

public static class EstadoPedido
{
    public const string Pendiente = "Pendiente";
    public const string Completado = "Completado";
    public const string Cancelado = "Cancelado";
}

[Table("CATEGORIA")]
public class Categoria
{
    [Key, Column("id_categoria")] public int Id { get; set; }
    [Column("nombre_categoria")] public string Nombre { get; set; } = "";
}

[Table("CONDICION")]
public class Condicion
{
    [Key, Column("id_condicion")] public int Id { get; set; }
    [Column("nombre_condicion")] public string Nombre { get; set; } = "";
}

[Table("IMAGEN_ARCHIVO")]
public class ImagenArchivo
{
    [Key, Column("id_imagen")] public int Id { get; set; }
    [Column("contenido")] public byte[] Contenido { get; set; } = Array.Empty<byte>();
    [Column("tipo_mime")] public string TipoMime { get; set; } = "";
    [Column("created_at")] public DateTime Creado { get; set; } = DateTime.UtcNow;
}

/// <summary>La ficha del producto (nombre, descripción, foto, categoría).</summary>
[Table("PRODUCTO_CATALOGO")]
public class ProductoCatalogo
{
    [Key, Column("id_producto_catalogo")] public int Id { get; set; }
    [Column("nombre_producto")] public string Nombre { get; set; } = "";
    [Column("descripcion_corta")] public string? Descripcion { get; set; }
    [Column("imagen_base")] public string ImagenBase { get; set; } = "default.png";
    [Column("fk_categoria")] public int CategoriaId { get; set; }
    public Categoria? Categoria { get; set; }
    public List<Instancia> Instancias { get; set; } = new();
}

/// <summary>Lo que realmente se vende: precio, condición y existencias.</summary>
[Table("INSTANCIA_INVENTARIO")]
public class Instancia
{
    [Key, Column("id_instancia")] public int Id { get; set; }
    [Column("precio_venta", TypeName = "decimal(10,2)")] public decimal Precio { get; set; }
    [Column("cantidad_stock")] public int Stock { get; set; }
    [Column("notas_condicion")] public string? NotasCondicion { get; set; }
    [Column("fk_producto_catalogo")] public int ProductoId { get; set; }
    public ProductoCatalogo? Producto { get; set; }
    [Column("fk_condicion")] public int CondicionId { get; set; }
    public Condicion? Condicion { get; set; }
    [Column("fk_estado_disponibilidad")] public int EstadoId { get; set; }
}

[Table("CLIENTE")]
public class Cliente
{
    [Key, Column("id_cliente")] public int Id { get; set; }
    [Column("nombre")] public string Nombre { get; set; } = "";
    [Column("correo")] public string Correo { get; set; } = "";
    [Column("clave_hash")] public string ClaveHash { get; set; } = "";
    [Column("acepta_ofertas")] public bool AceptaOfertas { get; set; }
    [Column("created_at")] public DateTime Creado { get; set; } = DateTime.UtcNow;
}

/// <summary>Una sola fila (id 1): hash del PIN y de la clave del administrador.</summary>
[Table("ADMIN_ACCESO")]
public class AdminAcceso
{
    [Key, DatabaseGenerated(DatabaseGeneratedOption.None), Column("id_admin")] public int Id { get; set; } = 1;
    [Column("pin_hash")] public string PinHash { get; set; } = "";
    [Column("clave_hash")] public string ClaveHash { get; set; } = "";
    [Column("intentos_fallidos")] public int IntentosFallidos { get; set; }
    [Column("bloqueado_hasta")] public DateTime? BloqueadoHasta { get; set; }
}

[Table("PEDIDO")]
public class Pedido
{
    [Key, Column("id_pedido")] public int Id { get; set; }
    [Column("fk_cliente")] public int ClienteId { get; set; }
    public Cliente? Cliente { get; set; }
    [Column("estado")] public string Estado { get; set; } = EstadoPedido.Pendiente;
    [Column("nota")] public string? Nota { get; set; }
    [Column("total", TypeName = "decimal(10,2)")] public decimal Total { get; set; }
    [Column("created_at")] public DateTime Creado { get; set; } = DateTime.UtcNow;
    public List<PedidoDetalle> Detalles { get; set; } = new();
}

[Table("PEDIDO_DETALLE")]
public class PedidoDetalle
{
    [Key, Column("id_detalle")] public int Id { get; set; }
    [Column("fk_pedido")] public int PedidoId { get; set; }
    [Column("fk_instancia")] public int InstanciaId { get; set; }
    public Instancia? Instancia { get; set; }
    [Column("cantidad")] public int Cantidad { get; set; }
    [Column("precio_unitario", TypeName = "decimal(10,2)")] public decimal PrecioUnitario { get; set; }
}
