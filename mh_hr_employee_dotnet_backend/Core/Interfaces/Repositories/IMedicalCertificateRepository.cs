using React.Core.DTOs.Response;
using React.Models;

namespace React.Core.Interfaces.Repositories;

public interface IMedicalCertificateRepository
{
    Task AddLeaveRequestAsync(LeaveRequest leaveRequest);
    Task<IEnumerable<McLeaveResponseDto>> GetAllLeavesAsync();
    Task<IEnumerable<McLeaveResponseDto>> GetPendingLeavesByUserIdAsync(int userId);
    Task<IEnumerable<McLeaveResponseDto>> GetApprovedLeavesByUserIdAsync(int userId);
}
