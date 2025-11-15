using React.Core.DTOs.Response;
using React.Models;

namespace React.Core.Interfaces.Repositories;

public interface INotificationRepository
{
    Task<User?> GetUserByIdAsync(int userId);
    Task UpdateUserFcmTokenAsync(int userId, string fcmToken);
    Task<IEnumerable<UserFcmTokenResponseDto>> GetAllUserFcmTokensAsync();
}
