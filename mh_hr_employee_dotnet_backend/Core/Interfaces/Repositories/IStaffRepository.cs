using React.Core.DTOs.Response;

namespace React.Core.Interfaces.Repositories;

public interface IStaffRepository
{
    Task<IEnumerable<StaffResponseDto>> GetAllStaffAsync();
    Task<StaffLeaveDetailsDto?> GetStaffLeaveDetailsAsync(int userId);
}
