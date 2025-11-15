using Microsoft.Extensions.Logging;
using React.Core.DTOs.Request;
using React.Core.DTOs.Response;
using React.Core.Interfaces.Repositories;
using React.Core.Interfaces.Services;
using React.Shared.Results;

namespace React.Application.Services;

public class EquipmentReturnService : IEquipmentReturnService
{
    private readonly IEquipmentReturnRepository _equipmentReturnRepository;
    private readonly ILogger<EquipmentReturnService> _logger;

    public EquipmentReturnService(
        IEquipmentReturnRepository equipmentReturnRepository,
        ILogger<EquipmentReturnService> logger)
    {
        _equipmentReturnRepository = equipmentReturnRepository ?? throw new ArgumentNullException(nameof(equipmentReturnRepository));
        _logger = logger ?? throw new ArgumentNullException(nameof(logger));
    }

    public async Task<ServiceResult<IEnumerable<EquipmentReturnListResponseDto>>> GetAllReturnsAsync()
    {
        try
        {
            var returns = await _equipmentReturnRepository.GetAllReturnsAsync();
            return ServiceResult<IEnumerable<EquipmentReturnListResponseDto>>.Success(returns);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error retrieving equipment returns");
            return ServiceResult<IEnumerable<EquipmentReturnListResponseDto>>.Failure("Error retrieving equipment returns");
        }
    }

    public async Task<ServiceResult<EquipmentReturnDetailsResponseDto>> GetReturnDetailsByIdAsync(int id)
    {
        try
        {
            var details = await _equipmentReturnRepository.GetReturnDetailsByIdAsync(id);
            if (details == null)
                return ServiceResult<EquipmentReturnDetailsResponseDto>.Failure("Equipment return not found");

            return ServiceResult<EquipmentReturnDetailsResponseDto>.Success(details);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error retrieving equipment return details for ID {ReturnId}", id);
            return ServiceResult<EquipmentReturnDetailsResponseDto>.Failure("Error retrieving equipment return details");
        }
    }

    public async Task<ServiceResult<IEnumerable<EquipmentReturnListResponseDto>>> GetUncheckedReturnsAsync()
    {
        try
        {
            var returns = await _equipmentReturnRepository.GetUncheckedReturnsAsync();
            return ServiceResult<IEnumerable<EquipmentReturnListResponseDto>>.Success(returns);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error retrieving unchecked equipment returns");
            return ServiceResult<IEnumerable<EquipmentReturnListResponseDto>>.Failure("Error retrieving unchecked equipment returns");
        }
    }

    public async Task<ServiceResult> UpdateReturnStatusAsync(int id, UpdateEquipmentReturnStatusRequestDto request)
    {
        try
        {
            var currentStatus = await _equipmentReturnRepository.GetReturnCurrentStatusAsync(id);

            if (currentStatus == null)
                return ServiceResult.Failure("Equipment return not found");

            if (currentStatus != "unchecked")
                return ServiceResult.Failure("Can only update unchecked returns");

            var success = await _equipmentReturnRepository.UpdateReturnStatusAsync(
                id, request.Status, request.ApproverId, request.DateApproved);

            if (success)
            {
                _logger.LogInformation("Equipment return {ReturnId} status updated to {Status}", id, request.Status);
                return ServiceResult.Success("Return status updated successfully");
            }

            return ServiceResult.Failure("Failed to update return status");
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error updating equipment return status for ID {ReturnId}", id);
            return ServiceResult.Failure("Error updating equipment return status");
        }
    }
}
