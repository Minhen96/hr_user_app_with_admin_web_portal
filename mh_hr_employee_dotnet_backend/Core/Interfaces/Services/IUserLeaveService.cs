using React.Core.DTOs.Request;
using React.Core.DTOs.Response;
using React.Models;
using React.Shared.Results;

namespace React.Core.Interfaces.Services;

public interface IUserLeaveService
{
    Task<ServiceResult<LeaveDetail>> SubmitLeaveAsync(SubmitLeaveRequestDto requestDto);
    Task<ServiceResult<LeaveEntitlementResponseDto>> GetEntitlementAsync(int userId);
    Task<ServiceResult<IEnumerable<UserLeaveDetailResponseDto>>> GetPendingLeavesAsync(int annualLeaveId);
    Task<ServiceResult<IEnumerable<ApprovedLeaveResponseDto>>> GetApprovedLeavesByIdAsync(int annualLeaveId);
    Task<ServiceResult<IEnumerable<ApprovedLeaveResponseDto>>> GetAllApprovedLeavesAsync();
    Task<ServiceResult<bool>> UpdateLeaveRequestAsync(UpdateLeaveRequestDto requestDto);
    Task<ServiceResult<bool>> DeleteLeaveRequestAsync(int id);
}
