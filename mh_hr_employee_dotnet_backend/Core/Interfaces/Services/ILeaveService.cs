using React.Core.DTOs.Request;
using React.Core.DTOs.Response;
using React.Shared.Results;

namespace React.Core.Interfaces.Services;

public interface ILeaveService
{
    Task<ServiceResult<IEnumerable<LeaveResponseDto>>> GetAllLeavesAsync();
    Task<ServiceResult<IEnumerable<MedicalLeaveResponseDto>>> GetAllMedicalLeavesAsync();
    Task<ServiceResult<LeaveResponseDto>> UpdateLeaveStatusAsync(int id, LeaveStatusUpdateDto updateDto);
    Task<ServiceResult<MedicalLeaveResponseDto>> UpdateMedicalLeaveStatusAsync(int id, LeaveStatusUpdateDto updateDto);
}
