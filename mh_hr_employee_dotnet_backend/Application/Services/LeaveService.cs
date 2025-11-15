using Microsoft.Extensions.Logging;
using React.Core.DTOs.Request;
using React.Core.DTOs.Response;
using React.Core.Interfaces.Repositories;
using React.Core.Interfaces.Services;
using React.Shared.Results;

namespace React.Application.Services;

public class LeaveService : ILeaveService
{
    private readonly ILeaveRepository _leaveRepository;
    private readonly ILogger<LeaveService> _logger;

    public LeaveService(ILeaveRepository leaveRepository, ILogger<LeaveService> logger)
    {
        _leaveRepository = leaveRepository ?? throw new ArgumentNullException(nameof(leaveRepository));
        _logger = logger ?? throw new ArgumentNullException(nameof(logger));
    }

    public async Task<ServiceResult<IEnumerable<LeaveResponseDto>>> GetAllLeavesAsync()
    {
        try
        {
            var leaves = await _leaveRepository.GetAllLeavesAsync();
            return ServiceResult<IEnumerable<LeaveResponseDto>>.Success(leaves);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error retrieving leaves");
            return ServiceResult<IEnumerable<LeaveResponseDto>>.Failure("Error retrieving leaves");
        }
    }

    public async Task<ServiceResult<IEnumerable<MedicalLeaveResponseDto>>> GetAllMedicalLeavesAsync()
    {
        try
        {
            var leaves = await _leaveRepository.GetAllMedicalLeavesAsync();
            return ServiceResult<IEnumerable<MedicalLeaveResponseDto>>.Success(leaves);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error retrieving medical leaves");
            return ServiceResult<IEnumerable<MedicalLeaveResponseDto>>.Failure("Error retrieving medical leaves");
        }
    }

    public async Task<ServiceResult<LeaveResponseDto>> UpdateLeaveStatusAsync(int id, LeaveStatusUpdateDto updateDto)
    {
        try
        {
            var success = await _leaveRepository.UpdateLeaveStatusAsync(
                id, updateDto.Status, updateDto.ApprovedBy, updateDto.ApprovalSignatureId);

            if (!success)
                return ServiceResult<LeaveResponseDto>.Failure("Leave not found");

            var updatedLeave = await _leaveRepository.GetLeaveByIdAsync(id);
            if (updatedLeave == null)
                return ServiceResult<LeaveResponseDto>.Failure("Leave not found after update");

            return ServiceResult<LeaveResponseDto>.Success(updatedLeave);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error updating leave status for ID {Id}", id);
            return ServiceResult<LeaveResponseDto>.Failure("Error updating leave status");
        }
    }

    public async Task<ServiceResult<MedicalLeaveResponseDto>> UpdateMedicalLeaveStatusAsync(int id, LeaveStatusUpdateDto updateDto)
    {
        try
        {
            var success = await _leaveRepository.UpdateMedicalLeaveStatusAsync(
                id, updateDto.Status, updateDto.ApprovedBy, updateDto.ApprovalSignatureId);

            if (!success)
                return ServiceResult<MedicalLeaveResponseDto>.Failure("Medical leave not found");

            var updatedLeave = await _leaveRepository.GetMedicalLeaveByIdAsync(id);
            if (updatedLeave == null)
                return ServiceResult<MedicalLeaveResponseDto>.Failure("Medical leave not found after update");

            return ServiceResult<MedicalLeaveResponseDto>.Success(updatedLeave);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error updating medical leave status for ID {Id}", id);
            return ServiceResult<MedicalLeaveResponseDto>.Failure("Error updating medical leave status");
        }
    }
}
