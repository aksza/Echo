using EchoAPI.Core.Entities;
using EchoAPI.Core.Interfaces.Entities;
using Microsoft.EntityFrameworkCore;
using System.Linq.Expressions;

namespace EchoAPI.Infrastructure.Data
{
    public class EchoDbContext : DbContext
    {
        public EchoDbContext(DbContextOptions<EchoDbContext> options) : base(options)
        {
        }

        public DbSet<User> Users { get; set; }
        public DbSet<UserSettings> UserSettings { get; set; }
        public DbSet<Session> Sessions { get; set; }
        public DbSet<Mistake> Mistakes { get; set; }
        public DbSet<MistakeCategory> MistakeCategories { get; set; }
        public DbSet<Vocabulary> Vocabulary { get; set; }
        public DbSet<VocabularyPracticeHistory> VocabularyPracticeHistories { get; set; }

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            base.OnModelCreating(modelBuilder);
            
            // Fluent API kapcsolatok

            // UserSettings -> User (1:1)
            modelBuilder.Entity<UserSettings>()
                .HasOne(us => us.User)
                .WithOne(u => u.Settings)
                .HasForeignKey<UserSettings>(us => us.UserId)
                .OnDelete(DeleteBehavior.Cascade);

            // Session -> User (many:1)
            modelBuilder.Entity<Session>()
                .HasOne(s => s.User)
                .WithMany(u => u.Sessions)
                .HasForeignKey(s => s.UserId)
                .OnDelete(DeleteBehavior.Cascade);

            // Mistake -> User (many:1)
            modelBuilder.Entity<Mistake>()
                .HasOne(m => m.User)
                .WithMany(u => u.Mistakes)
                .HasForeignKey(m => m.UserId)
                .OnDelete(DeleteBehavior.Cascade);

            // Mistake -> MistakeCategory (many:1)
            modelBuilder.Entity<Mistake>()
                .HasOne(m => m.MistakeCategory)
                .WithMany(c => c.Mistakes)
                .HasForeignKey(m => m.MistakeCategoryId)
                .OnDelete(DeleteBehavior.Restrict);

            // Vocabulary -> User (many:1)
            modelBuilder.Entity<Vocabulary>()
                .HasOne(v => v.User)
                .WithMany(u => u.Vocabulary)
                .HasForeignKey(v => v.UserId)
                .OnDelete(DeleteBehavior.Cascade);

            // VocabularyPracticeHistory -> Vocabulary (many:1)
            modelBuilder.Entity<VocabularyPracticeHistory>()
                .HasOne(p => p.Vocabulary)
                .WithMany(v => v.PracticeHistory)
                .HasForeignKey(p => p.VocabularyId)
                .OnDelete(DeleteBehavior.Cascade);

            // Soft delete global filter

            foreach (var entityType in modelBuilder.Model.GetEntityTypes())
            {
                if (typeof(ISoftDeletable).IsAssignableFrom(entityType.ClrType))
                {
                    var filter = CreateIsDeletedFilter(entityType.ClrType);
                    modelBuilder.Entity(entityType.ClrType).HasQueryFilter(filter);
                }
            }

            // Indexek és egyéb konfigurációk

            modelBuilder.Entity<User>()
                .HasIndex(u => u.Email)
                .IsUnique();
        }

        // LambdaExpression készítése a soft delete filterhez
        private static LambdaExpression CreateIsDeletedFilter(Type type)
        {
            var param = Expression.Parameter(type, "e");
            var prop = Expression.Property(param, nameof(ISoftDeletable.IsDeleted));
            var filter = Expression.Lambda(Expression.Equal(prop, Expression.Constant(false)), param);
            return filter;
        }
    }
}
