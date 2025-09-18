using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using DomainLayer.Entities;
using Microsoft.EntityFrameworkCore;

namespace InfrastructureLayer.Data
{
    public class LabDbContext : DbContext
    {
        public LabDbContext(DbContextOptions<LabDbContext> options) : base(options) { }

        //Khai báo các Dbset tương ứng với entity 
        public DbSet<Roles> Roles { get; set; }

        public DbSet<Users> Users { get; set; }

        //Cấu hình mô hình dữ liệu (nếu cần) bằng cách override phương thức OnModelCreating
        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            base.OnModelCreating(modelBuilder);

            modelBuilder.Entity<Users>()
                .HasMany(u => u.Roles)
                .WithMany(r => r.Users)
                .UsingEntity<Dictionary<string, object>>(
                    "tbl_users_roles",
                    j => j
                        .HasOne<Roles>()
                        .WithMany()
                        .HasForeignKey("RoleId")
                        .HasConstraintName("FK_tbl_users_roles_roles")
                        .OnDelete(DeleteBehavior.Cascade),
                    j => j
                        .HasOne<Users>()
                        .WithMany()
                        .HasForeignKey("UserId")
                        .HasConstraintName("FK_tbl_users_roles_users")
                        .OnDelete(DeleteBehavior.Cascade)
                );
        }

    }
}
