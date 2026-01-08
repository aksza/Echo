//using System.Linq.Expressions;

//namespace EchoAPI.Core.Interfaces.Repositories
//{
//    public interface IBaseRepository<TEntity> where TEntity : class
//    {
//        Task<TEntity?> GetByIdAsync(Guid id);
//        Task<IEnumerable<TEntity>> GetAllAsync();
//        Task<IEnumerable<TEntity>> FindAsync(Expression<Func<TEntity, bool>> predicate);

//        Task AddAsync(TEntity entity);
//        Task AddRangeAsync(IEnumerable<TEntity> entities);

//        void Update(TEntity entity);
//        void Remove(TEntity entity);
//        void RemoveRange(IEnumerable<TEntity> entities);

//        Task<int> SaveChangesAsync();
//    }
//}
