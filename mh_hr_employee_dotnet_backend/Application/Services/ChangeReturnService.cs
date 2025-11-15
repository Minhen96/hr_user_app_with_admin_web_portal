using Microsoft.Extensions.Logging;
using React.Core.DTOs.Request;
using React.Core.DTOs.Response;
using React.Core.Interfaces.Repositories;
using React.Core.Interfaces.Services;
using React.Shared.Results;

namespace React.Application.Services;

public class ChangeReturnService : IChangeReturnService
{
    private readonly IChangeReturnRepository _changeReturnRepository;
    private readonly ILogger<ChangeReturnService> _logger;

    public ChangeReturnService(
        IChangeReturnRepository changeReturnRepository,
        ILogger<ChangeReturnService> logger)
    {
        _changeReturnRepository = changeReturnRepository ?? throw new ArgumentNullException(nameof(changeReturnRepository));
        _logger = logger ?? throw new ArgumentNullException(nameof(logger));
    }

    public async Task<ServiceResult<IEnumerable<ChangeReturnListResponseDto>>> GetAllChangeReturnsAsync()
    {
        try
        {
            var returns = await _changeReturnRepository.GetAllChangeReturnsAsync();
            return ServiceResult<IEnumerable<ChangeReturnListResponseDto>>.Success(returns);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error retrieving change returns");
            return ServiceResult<IEnumerable<ChangeReturnListResponseDto>>.Failure("Error retrieving change returns");
        }
    }

    public async Task<ServiceResult<ChangeReturnDetailsResponseDto>> GetChangeReturnDetailsByIdAsync(int id)
    {
        try
        {
            var details = await _changeReturnRepository.GetChangeReturnDetailsByIdAsync(id);
            if (details == null)
                return ServiceResult<ChangeReturnDetailsResponseDto>.Failure("Change return not found");

            return ServiceResult<ChangeReturnDetailsResponseDto>.Success(details);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error retrieving change return details for ID {ReturnId}", id);
            return ServiceResult<ChangeReturnDetailsResponseDto>.Failure("Error retrieving change return details");
        }
    }

    public async Task<ServiceResult> UpdateChangeReturnStatusAsync(int id, UpdateChangeReturnStatusRequestDto request)
    {
        try
        {
            var currentStatus = await _changeReturnRepository.GetChangeReturnCurrentStatusAsync(id);

            if (currentStatus == null)
                return ServiceResult.Failure("Change return not found");

            if (currentStatus != "pending_return")
                return ServiceResult.Failure("Can only update pending returns");

            var success = await _changeReturnRepository.UpdateChangeReturnStatusAsync(
                id, request.ReturnStatus, request.ApproverId);

            if (success)
            {
                _logger.LogInformation("Change return {ReturnId} status updated to {Status}", id, request.ReturnStatus);
                return ServiceResult.Success($"Change return {request.ReturnStatus} successfully");
            }

            return ServiceResult.Failure("Failed to update return status");
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error updating change return status for ID {ReturnId}", id);
            return ServiceResult.Failure("Error updating change return status");
        }
    }
}
