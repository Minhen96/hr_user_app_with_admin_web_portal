using Microsoft.EntityFrameworkCore;
using React.Core.DTOs.Response;
using React.Core.Interfaces.Repositories;
using React.Data;
using React.Models;

namespace React.Infrastructure.Repositories;

public class NotificationRepository : INotificationRepository
{
    private readonly ApplicationDbContext _context;

    public NotificationRepository(ApplicationDbContext context)
    {
        _context = context ?? throw new ArgumentNullException(nameof(context));
    }

    public async Task<User?> GetUserByIdAsync(int userId)
    {
        return await _context.Users.FindAsync(userId);
    }

    public async Task UpdateUserFcmTokenAsync(int userId, string fcmToken)
    {
        var user = await _context.Users.FindAsync(userId);
        if (user != null)
        {
            user.FcmToken = fcmToken;
            await _context.SaveChangesAsync();
        }
    }

    public async Task<IEnumerable<UserFcmTokenResponseDto>> GetAllUserFcmTokensAsync()
    {
        return await _context.Users
            .Select(u => new UserFcmTokenResponseDto
            {
                Id = u.Id,
                FcmToken = u.FcmToken
            })
            .ToListAsync();
    }
}
