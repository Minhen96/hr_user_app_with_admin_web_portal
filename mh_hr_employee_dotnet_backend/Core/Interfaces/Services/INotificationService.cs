using React.Core.DTOs.Request;
using React.Core.DTOs.Response;
using React.Shared.Results;

namespace React.Core.Interfaces.Services;

public interface INotificationService
{
    Task<ServiceResult<bool>> UpdateFcmTokenAsync(int userId, UpdateFCMTokenRequestDto request);
    Task<ServiceResult<string>> SendNotificationAsync(SendNotificationRequestDto request);
    Task<ServiceResult<IEnumerable<UserFcmTokenResponseDto>>> GetAllUserFcmTokensAsync();
}
