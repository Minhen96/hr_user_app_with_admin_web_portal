using React.Core.DTOs.Response;

namespace React.Core.Interfaces.Repositories;

public interface ILeaveRepository
{
    Task<IEnumerable<LeaveResponseDto>> GetAllLeavesAsync();
    Task<IEnumerable<MedicalLeaveResponseDto>> GetAllMedicalLeavesAsync();
    Task<LeaveResponseDto?> GetLeaveByIdAsync(int id);
    Task<MedicalLeaveResponseDto?> GetMedicalLeaveByIdAsync(int id);
    Task<bool> UpdateLeaveStatusAsync(int id, string status, int approvedBy, int? approvalSignatureId);
    Task<bool> UpdateMedicalLeaveStatusAsync(int id, string status, int approvedBy, int? approvalSignatureId);
}
