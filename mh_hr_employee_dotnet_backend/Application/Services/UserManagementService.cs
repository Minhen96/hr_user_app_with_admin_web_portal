using Microsoft.Extensions.Logging;
using React.Core.DTOs.Response;
using React.Core.Interfaces.Repositories;
using React.Core.Interfaces.Services;
using React.Shared.Results;

namespace React.Application.Services;

public class UserManagementService : IUserManagementService
{
    private readonly IUserRepository _userRepository;
    private readonly ILogger<UserManagementService> _logger;

    public UserManagementService(IUserRepository userRepository, ILogger<UserManagementService> logger)
    {
        _userRepository = userRepository ?? throw new ArgumentNullException(nameof(userRepository));
        _logger = logger ?? throw new ArgumentNullException(nameof(logger));
    }

    public async Task<ServiceResult<IEnumerable<PasswordChangeResponseDto>>> GetPendingPasswordChangesAsync()
    {
        try
        {
            var pendingChanges = await _userRepository.GetPendingPasswordChangesAsync();
            return ServiceResult<IEnumerable<PasswordChangeResponseDto>>.Success(pendingChanges);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error retrieving pending password changes");
            return ServiceResult<IEnumerable<PasswordChangeResponseDto>>.Failure("Error retrieving pending password changes");
        }
    }
}
