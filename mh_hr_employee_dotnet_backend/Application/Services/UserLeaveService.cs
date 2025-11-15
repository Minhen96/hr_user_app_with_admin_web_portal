using React.Core.DTOs.Request;
using React.Core.DTOs.Response;
using React.Core.Interfaces.Repositories;
using React.Core.Interfaces.Services;
using React.Models;
using React.Shared.Results;

namespace React.Application.Services;

public class UserLeaveService : IUserLeaveService
{
    private readonly IUserLeaveRepository _repository;

    public UserLeaveService(IUserLeaveRepository repository)
    {
        _repository = repository ?? throw new ArgumentNullException(nameof(repository));
    }

    public async Task<ServiceResult<LeaveDetail>> SubmitLeaveAsync(SubmitLeaveRequestDto requestDto)
    {
        try
        {
            // Validate annual leave exists
            var annualLeaveExists = await _repository.AnnualLeaveExistsAsync(requestDto.AnnualLeaveId);
            if (!annualLeaveExists)
            {
                return ServiceResult<LeaveDetail>.Failure("Invalid annual_leave_id.");
            }

            var leaveDetail = new LeaveDetail
            {
                annual_leave_id = requestDto.AnnualLeaveId,
                leave_date = requestDto.LeaveDate,
                leave_end_date = requestDto.LeaveEndDate,
                reason = requestDto.Reason,
                no_of_days = requestDto.NoOfDays,
                status = "Pending",
                date_submission = DateTime.UtcNow
            };

            var createdLeave = await _repository.AddLeaveDetailAsync(leaveDetail);
            return ServiceResult<LeaveDetail>.Success(createdLeave, "Leave request submitted successfully");
        }
        catch (Exception ex)
        {
            return ServiceResult<LeaveDetail>.Failure($"Error submitting leave: {ex.Message}");
        }
    }

    public async Task<ServiceResult<LeaveEntitlementResponseDto>> GetEntitlementAsync(int userId)
    {
        try
        {
            var annualLeave = await _repository.GetEntitlementByUserIdAsync(userId);
            if (annualLeave == null)
            {
                // Auto-create entitlement with 14 days if not exists
                annualLeave = new AnnualLeave
                {
                    user_id = userId,
                    entitlement = 14
                };
                annualLeave = await _repository.CreateEntitlementAsync(annualLeave);
            }

            var response = new LeaveEntitlementResponseDto
            {
                Entitlement = annualLeave.entitlement,
                AnnualLeaveId = annualLeave.id
            };

            return ServiceResult<LeaveEntitlementResponseDto>.Success(response);
        }
        catch (Exception ex)
        {
            return ServiceResult<LeaveEntitlementResponseDto>.Failure($"Error retrieving entitlement: {ex.Message}");
        }
    }

    public async Task<ServiceResult<IEnumerable<UserLeaveDetailResponseDto>>> GetPendingLeavesAsync(int annualLeaveId)
    {
        try
        {
            var leaves = await _repository.GetPendingLeavesByAnnualLeaveIdAsync(annualLeaveId);

            if (!leaves.Any())
            {
                return ServiceResult<IEnumerable<UserLeaveDetailResponseDto>>.Failure("No pending leaves found for this user.");
            }

            var response = leaves.Select(leave => new UserLeaveDetailResponseDto
            {
                Id = leave.id,
                LeaveDate = leave.leave_date,
                LeaveEndDate = leave.leave_end_date,
                DateSubmission = leave.date_submission,
                Status = leave.status,
                Reason = leave.reason,
                AnnualLeaveId = leave.annual_leave_id,
                NoOfDays = leave.no_of_days
            });

            return ServiceResult<IEnumerable<UserLeaveDetailResponseDto>>.Success(response);
        }
        catch (Exception ex)
        {
            return ServiceResult<IEnumerable<UserLeaveDetailResponseDto>>.Failure($"Error retrieving pending leaves: {ex.Message}");
        }
    }

    public async Task<ServiceResult<IEnumerable<ApprovedLeaveResponseDto>>> GetApprovedLeavesByIdAsync(int annualLeaveId)
    {
        try
        {
            var leaves = await _repository.GetApprovedLeavesByAnnualLeaveIdAsync(annualLeaveId);

            if (!leaves.Any())
            {
                return ServiceResult<IEnumerable<ApprovedLeaveResponseDto>>.Failure("No approved leaves found for this user.");
            }

            var response = leaves.Select(leave => new ApprovedLeaveResponseDto
            {
                LeaveDate = leave.leave_date,
                LeaveEndDate = leave.leave_end_date,
                DateSubmission = leave.date_submission,
                Status = leave.status,
                Reason = leave.reason,
                AnnualLeaveId = leave.annual_leave_id,
                NoOfDays = leave.no_of_days
            });

            return ServiceResult<IEnumerable<ApprovedLeaveResponseDto>>.Success(response);
        }
        catch (Exception ex)
        {
            return ServiceResult<IEnumerable<ApprovedLeaveResponseDto>>.Failure($"Error retrieving approved leaves: {ex.Message}");
        }
    }

    public async Task<ServiceResult<IEnumerable<ApprovedLeaveResponseDto>>> GetAllApprovedLeavesAsync()
    {
        try
        {
            var leaves = await _repository.GetAllApprovedLeavesAsync();

            if (!leaves.Any())
            {
                return ServiceResult<IEnumerable<ApprovedLeaveResponseDto>>.Failure("No approved leaves found.");
            }

            var response = leaves.Select(leave => new ApprovedLeaveResponseDto
            {
                LeaveDate = leave.leave_date,
                LeaveEndDate = leave.leave_end_date,
                DateSubmission = leave.date_submission,
                Status = leave.status,
                Reason = leave.reason,
                AnnualLeaveId = leave.annual_leave_id,
                NoOfDays = leave.no_of_days
            });

            return ServiceResult<IEnumerable<ApprovedLeaveResponseDto>>.Success(response);
        }
        catch (Exception ex)
        {
            return ServiceResult<IEnumerable<ApprovedLeaveResponseDto>>.Failure($"Error retrieving all approved leaves: {ex.Message}");
        }
    }

    public async Task<ServiceResult<bool>> UpdateLeaveRequestAsync(UpdateLeaveRequestDto requestDto)
    {
        try
        {
            var existingLeave = await _repository.GetPendingLeaveByIdAsync(requestDto.Id, requestDto.LeaveId);
            if (existingLeave == null)
            {
                return ServiceResult<bool>.Failure("Leave request not found or cannot be modified.");
            }

            existingLeave.leave_date = requestDto.LeaveDate;
            existingLeave.leave_end_date = requestDto.LeaveEndDate;
            existingLeave.no_of_days = requestDto.NoOfDays;
            existingLeave.reason = requestDto.Reason;

            await _repository.UpdateLeaveDetailAsync(existingLeave);
            return ServiceResult<bool>.Success(true, "Leave request updated successfully.");
        }
        catch (Exception ex)
        {
            return ServiceResult<bool>.Failure($"Error updating leave request: {ex.Message}");
        }
    }

    public async Task<ServiceResult<bool>> DeleteLeaveRequestAsync(int id)
    {
        try
        {
            var success = await _repository.DeleteLeaveDetailAsync(id);
            if (!success)
            {
                return ServiceResult<bool>.Failure("Leave request not found or cannot be deleted.");
            }

            await _repository.ResetLeaveDetailsIdentitySeedAsync();
            return ServiceResult<bool>.Success(true, "Leave request deleted successfully.");
        }
        catch (Exception ex)
        {
            return ServiceResult<bool>.Failure($"Error deleting leave request: {ex.Message}");
        }
    }
}
