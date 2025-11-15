using React.Core.DTOs.Response;
using React.Shared.Results;

namespace React.Core.Interfaces.Services;

public interface IStaffService
{
    Task<ServiceResult<IEnumerable<StaffResponseDto>>> GetAllStaffAsync();
    Task<ServiceResult<StaffLeaveDetailsDto>> GetStaffLeaveDetailsAsync(int userId);
}
