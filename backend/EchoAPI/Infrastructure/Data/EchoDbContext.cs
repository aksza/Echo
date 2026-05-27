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

        public DbSet<PracticeSession> PracticeSessions { get; set; }
        public DbSet<PracticeSessionItem> PracticeSessionItems { get; set; }

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            base.OnModelCreating(modelBuilder);

            modelBuilder.Entity<UserSettings>()
                .HasOne(us => us.User)
                .WithOne(u => u.Settings)
                .HasForeignKey<UserSettings>(us => us.UserId)
                .OnDelete(DeleteBehavior.Cascade);

            modelBuilder.Entity<Session>()
                .HasOne(s => s.User)
                .WithMany(u => u.Sessions)
                .HasForeignKey(s => s.UserId)
                .OnDelete(DeleteBehavior.Cascade);

            modelBuilder.Entity<Mistake>()
                .HasOne(m => m.User)
                .WithMany(u => u.Mistakes)
                .HasForeignKey(m => m.UserId)
                .OnDelete(DeleteBehavior.Cascade);

            modelBuilder.Entity<Mistake>()
                .HasOne(m => m.MistakeCategory)
                .WithMany(c => c.Mistakes)
                .HasForeignKey(m => m.MistakeCategoryId)
                .OnDelete(DeleteBehavior.Restrict);

            modelBuilder.Entity<Vocabulary>()
                .HasOne(v => v.User)
                .WithMany(u => u.Vocabulary)
                .HasForeignKey(v => v.UserId)
                .OnDelete(DeleteBehavior.Cascade);

            modelBuilder.Entity<VocabularyPracticeHistory>()
                .HasOne(p => p.Vocabulary)
                .WithMany(v => v.PracticeHistory)
                .HasForeignKey(p => p.VocabularyId)
                .OnDelete(DeleteBehavior.Cascade);

            modelBuilder.Entity<PracticeSession>()
                .HasOne(ps => ps.User)
                .WithMany()
                .HasForeignKey(ps => ps.UserId)
                .OnDelete(DeleteBehavior.Cascade);

            modelBuilder.Entity<PracticeSessionItem>()
                .HasOne(item => item.PracticeSession)
                .WithMany(session => session.Items)
                .HasForeignKey(item => item.PracticeSessionId)
                .OnDelete(DeleteBehavior.Cascade);

            modelBuilder.Entity<PracticeSessionItem>()
                .HasOne(item => item.Mistake)
                .WithMany()
                .HasForeignKey(item => item.MistakeId)
                .OnDelete(DeleteBehavior.Restrict);

            foreach (var entityType in modelBuilder.Model.GetEntityTypes())
            {
                if (typeof(ISoftDeletable).IsAssignableFrom(entityType.ClrType))
                {
                    var filter = CreateIsDeletedFilter(entityType.ClrType);
                    modelBuilder.Entity(entityType.ClrType).HasQueryFilter(filter);
                }
            }

            modelBuilder.Entity<User>()
                .HasIndex(u => u.Email)
                .IsUnique();
        }

        private static LambdaExpression CreateIsDeletedFilter(Type type)
        {
            var param = Expression.Parameter(type, "e");
            var prop = Expression.Property(param, nameof(ISoftDeletable.IsDeleted));
            var filter = Expression.Lambda(Expression.Equal(prop, Expression.Constant(false)), param);
            return filter;
        }
    }
}