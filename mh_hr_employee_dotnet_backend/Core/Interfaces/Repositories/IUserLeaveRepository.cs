using React.Models;

namespace React.Core.Interfaces.Repositories;

public interface IUserLeaveRepository
{
    Task<bool> AnnualLeaveExistsAsync(int annualLeaveId);
    Task<LeaveDetail> AddLeaveDetailAsync(LeaveDetail leaveDetail);
    Task<AnnualLeave?> GetEntitlementByUserIdAsync(int userId);
    Task<AnnualLeave> CreateEntitlementAsync(AnnualLeave annualLeave);
    Task<IEnumerable<LeaveDetail>> GetPendingLeavesByAnnualLeaveIdAsync(int annualLeaveId);
    Task<IEnumerable<LeaveDetail>> GetApprovedLeavesByAnnualLeaveIdAsync(int annualLeaveId);
    Task<IEnumerable<LeaveDetail>> GetAllApprovedLeavesAsync();
    Task<LeaveDetail?> GetPendingLeaveByIdAsync(int id, int annualLeaveId);
    Task<bool> UpdateLeaveDetailAsync(LeaveDetail leaveDetail);
    Task<bool> DeleteLeaveDetailAsync(int id);
    Task ResetLeaveDetailsIdentitySeedAsync();
}
