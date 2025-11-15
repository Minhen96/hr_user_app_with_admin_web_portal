using React.Models;

namespace React.Core.Interfaces.Repositories;

public interface IUserMomentRepository
{
    Task<IEnumerable<Moment>> GetMomentsAsync(int page, int pageSize);
    Task<int> GetTotalMomentsCountAsync();
    Task<Moment?> GetMomentByIdAsync(int momentId);
    Task<Moment> AddMomentAsync(Moment moment);
    Task<MomentImage> AddMomentImageAsync(MomentImage momentImage);
    Task<MomentReaction?> GetExistingReactionAsync(int momentId, int userId);
    Task UpdateReactionAsync(MomentReaction reaction);
    Task<MomentReaction> AddReactionAsync(MomentReaction reaction);
    Task<Moment?> GetMomentWithReactionsAsync(int momentId);
    Task<List<User>> GetUsersWithFcmTokensExcludingAsync(int excludedUserId);
    Task SaveChangesAsync();
}
