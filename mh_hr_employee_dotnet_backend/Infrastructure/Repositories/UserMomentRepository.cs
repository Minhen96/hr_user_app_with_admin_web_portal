using Microsoft.EntityFrameworkCore;
using React.Core.Interfaces.Repositories;
using React.Data;
using React.Models;

namespace React.Infrastructure.Repositories;

public class UserMomentRepository : IUserMomentRepository
{
    private readonly ApplicationDbContext _context;

    public UserMomentRepository(ApplicationDbContext context)
    {
        _context = context ?? throw new ArgumentNullException(nameof(context));
    }

    public async Task<IEnumerable<Moment>> GetMomentsAsync(int page, int pageSize)
    {
        return await _context.Moments
            .AsNoTracking()
            .Include(m => m.User)
            .Include(m => m.Images)
            .Include(m => m.Reactions)
                .ThenInclude(r => r.User)
            .OrderByDescending(m => m.CreatedAt)
            .Skip((page - 1) * pageSize)
            .Take(pageSize)
            .ToListAsync();
    }

    public async Task<int> GetTotalMomentsCountAsync()
    {
        return await _context.Moments.CountAsync();
    }

    public async Task<Moment?> GetMomentByIdAsync(int momentId)
    {
        return await _context.Moments.FindAsync(momentId);
    }

    public async Task<Moment> AddMomentAsync(Moment moment)
    {
        _context.Moments.Add(moment);
        await _context.SaveChangesAsync();
        return moment;
    }

    public async Task<MomentImage> AddMomentImageAsync(MomentImage momentImage)
    {
        _context.MomentImages.Add(momentImage);
        return momentImage;
    }

    public async Task<MomentReaction?> GetExistingReactionAsync(int momentId, int userId)
    {
        return await _context.MomentReactions
            .FirstOrDefaultAsync(r => r.MomentId == momentId && r.UserId == userId);
    }

    public async Task UpdateReactionAsync(MomentReaction reaction)
    {
        _context.MomentReactions.Update(reaction);
    }

    public async Task<MomentReaction> AddReactionAsync(MomentReaction reaction)
    {
        _context.MomentReactions.Add(reaction);
        return reaction;
    }

    public async Task<Moment?> GetMomentWithReactionsAsync(int momentId)
    {
        return await _context.Moments
            .Include(m => m.Reactions)
                .ThenInclude(r => r.User)
            .FirstOrDefaultAsync(m => m.Id == momentId);
    }

    public async Task<List<User>> GetUsersWithFcmTokensExcludingAsync(int excludedUserId)
    {
        return await _context.Users
            .Where(u => u.Id != excludedUserId && !string.IsNullOrEmpty(u.FcmToken))
            .Select(u => new User { Id = u.Id, FcmToken = u.FcmToken })
            .ToListAsync();
    }

    public async Task SaveChangesAsync()
    {
        await _context.SaveChangesAsync();
    }
}
