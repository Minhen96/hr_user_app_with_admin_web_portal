using React.Core.DTOs.Response;
using React.Shared.Results;

namespace React.Core.Interfaces.Services;

public interface IUserManagementService
{
    Task<ServiceResult<IEnumerable<PasswordChangeResponseDto>>> GetPendingPasswordChangesAsync();
}
