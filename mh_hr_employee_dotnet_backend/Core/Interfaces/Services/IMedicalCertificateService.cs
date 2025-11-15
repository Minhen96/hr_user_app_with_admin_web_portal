using React.Core.DTOs.Request;
using React.Core.DTOs.Response;
using React.Shared.Results;

namespace React.Core.Interfaces.Services;

public interface IMedicalCertificateService
{
    Task<ServiceResult<bool>> SubmitLeaveRequestAsync(McLeaveRequestDto request);
    Task<ServiceResult<IEnumerable<McLeaveResponseDto>>> GetAllLeavesAsync();
    Task<ServiceResult<IEnumerable<McLeaveResponseDto>>> GetPendingLeavesByUserIdAsync(int userId);
    Task<ServiceResult<IEnumerable<McLeaveResponseDto>>> GetApprovedLeavesByUserIdAsync(int userId);
}
