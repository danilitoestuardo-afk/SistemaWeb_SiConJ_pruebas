// Data/SiconJDb.cs - Conexión de Entity Framework con las tablas.
using Microsoft.EntityFrameworkCore;
using SiconJ.Api.Models;

namespace SiconJ.Api.Data;

public class SiconJDb : DbContext
{
    public SiconJDb(DbContextOptions<SiconJDb> options) : base(options) { }

    public DbSet<Categoria> Categorias => Set<Categoria>();
    public DbSet<Condicion> Condiciones => Set<Condicion>();
    public DbSet<ImagenArchivo> Imagenes => Set<ImagenArchivo>();
    public DbSet<ProductoCatalogo> Productos => Set<ProductoCatalogo>();
    public DbSet<Instancia> Instancias => Set<Instancia>();
    public DbSet<Cliente> Clientes => Set<Cliente>();
    public DbSet<AdminAcceso> Admin => Set<AdminAcceso>();
    public DbSet<Pedido> Pedidos => Set<Pedido>();
    public DbSet<PedidoDetalle> PedidoDetalles => Set<PedidoDetalle>();

    protected override void OnModelCreating(ModelBuilder mb)
    {
        // Igual que el SQL: no se puede borrar un cliente ni una unidad que ya tiene pedidos.
        mb.Entity<Pedido>().HasOne(p => p.Cliente).WithMany()
            .HasForeignKey(p => p.ClienteId).OnDelete(DeleteBehavior.Restrict);
        mb.Entity<PedidoDetalle>().HasOne(d => d.Instancia).WithMany()
            .HasForeignKey(d => d.InstanciaId).OnDelete(DeleteBehavior.Restrict);
    }
}
