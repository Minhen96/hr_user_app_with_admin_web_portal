using Microsoft.Extensions.Logging;
using React.Core.DTOs.Request;
using React.Core.DTOs.Response;
using React.Core.Interfaces.Repositories;
using React.Core.Interfaces.Services;
using React.Shared.Results;

namespace React.Application.Services;

public class ChangeRequestService : IChangeRequestService
{
    private readonly IChangeRequestRepository _changeRequestRepository;
    private readonly ILogger<ChangeRequestService> _logger;

    public ChangeRequestService(
        IChangeRequestRepository changeRequestRepository,
        ILogger<ChangeRequestService> logger)
    {
        _changeRequestRepository = changeRequestRepository ?? throw new ArgumentNullException(nameof(changeRequestRepository));
        _logger = logger ?? throw new ArgumentNullException(nameof(logger));
    }

    public async Task<ServiceResult<IEnumerable<ChangeRequestListResponseDto>>> GetAllChangeRequestsAsync()
    {
        try
        {
            var requests = await _changeRequestRepository.GetAllChangeRequestsAsync();
            return ServiceResult<IEnumerable<ChangeRequestListResponseDto>>.Success(requests);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error retrieving change requests");
            return ServiceResult<IEnumerable<ChangeRequestListResponseDto>>.Failure("Error retrieving change requests");
        }
    }

    public async Task<ServiceResult<IEnumerable<ChangeRequestListResponseDto>>> GetApprovedChangeRequestsAsync()
    {
        try
        {
            var requests = await _changeRequestRepository.GetApprovedChangeRequestsAsync();
            return ServiceResult<IEnumerable<ChangeRequestListResponseDto>>.Success(requests);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error retrieving approved change requests");
            return ServiceResult<IEnumerable<ChangeRequestListResponseDto>>.Failure("Error retrieving approved change requests");
        }
    }

    public async Task<ServiceResult<ChangeRequestDetailsResponseDto>> GetChangeRequestDetailsByIdAsync(int id)
    {
        try
        {
            var details = await _changeRequestRepository.GetChangeRequestDetailsByIdAsync(id);
            if (details == null)
                return ServiceResult<ChangeRequestDetailsResponseDto>.Failure("Change request not found");

            return ServiceResult<ChangeRequestDetailsResponseDto>.Success(details);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error retrieving change request details for ID {RequestId}", id);
            return ServiceResult<ChangeRequestDetailsResponseDto>.Failure("Error retrieving change request details");
        }
    }

    public async Task<ServiceResult<IEnumerable<ChangeRequestListResponseDto>>> GetPendingChangeRequestsAsync()
    {
        try
        {
            var requests = await _changeRequestRepository.GetPendingChangeRequestsAsync();
            return ServiceResult<IEnumerable<ChangeRequestListResponseDto>>.Success(requests);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error retrieving pending change requests");
            return ServiceResult<IEnumerable<ChangeRequestListResponseDto>>.Failure("Error retrieving pending change requests");
        }
    }

    public async Task<ServiceResult<IEnumerable<FixedAssetTypeResponseDto>>> GetFixedAssetTypesAsync()
    {
        try
        {
            var types = await _changeRequestRepository.GetFixedAssetTypesAsync();
            return ServiceResult<IEnumerable<FixedAssetTypeResponseDto>>.Success(types);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error retrieving fixed asset types");
            return ServiceResult<IEnumerable<FixedAssetTypeResponseDto>>.Failure("Error retrieving fixed asset types");
        }
    }

    public async Task<ServiceResult<string>> UpdateChangeRequestStatusAsync(int id, UpdateChangeRequestStatusRequestDto request)
    {
        try
        {
            var currentStatus = await _changeRequestRepository.GetChangeRequestCurrentStatusAsync(id);

            if (currentStatus == null)
                return ServiceResult<string>.Failure("Change request not found");

            if (currentStatus != "pending")
                return ServiceResult<string>.Failure("Can only update pending change requests");

            // Pad running code to 3 digits
            request.RunningCode = request.RunningCode.PadLeft(3, '0');

            // Create approval signature if provided
            int? approvalSignatureId = null;
            if (request.Status == "approved" && request.ApprovalSignature != null)
            {
                approvalSignatureId = await _changeRequestRepository.CreateSignatureAsync(
                    request.ApproverId,
                    request.ApprovalSignature.Points,
                    request.ApprovalSignature.BoundaryWidth,
                    request.ApprovalSignature.BoundaryHeight);
            }

            // Create fixed asset product if approved and fixed asset type provided
            string? productCode = null;
            if (request.Status == "approved" && request.FixedAssetTypeId.HasValue)
            {
                string fixedAssetTypeCode = await _changeRequestRepository.GetFixedAssetTypeCodeAsync(request.FixedAssetTypeId.Value);
                productCode = $"{fixedAssetTypeCode}/{DateTime.Now.Year}/{request.RunningCode}";
                await _changeRequestRepository.CreateFixedAssetProductAsync(productCode, id);
            }

            // Update change request status
            var success = await _changeRequestRepository.UpdateChangeRequestStatusAsync(
                id, request.Status, request.ApproverId, request.DateApproved, approvalSignatureId, request.FixedAssetTypeId);

            if (success)
            {
                _logger.LogInformation("Change request {RequestId} status updated to {Status}", id, request.Status);
                return ServiceResult<string>.Success(productCode ?? string.Empty, $"Change request {request.Status} successfully");
            }

            return ServiceResult<string>.Failure("Failed to update change request status");
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error updating change request status for ID {RequestId}", id);
            return ServiceResult<string>.Failure("Error updating change request status");
        }
    }

    public async Task<ServiceResult> ChangeRequestStatusAsync(int id, ChangeStatusRequestDto request)
    {
        try
        {
            var currentStatus = await _changeRequestRepository.GetChangeRequestCurrentStatusAsync(id);

            if (currentStatus == null)
                return ServiceResult.Failure("Change request not found");

            if (currentStatus != "pending")
                return ServiceResult.Failure("Can only change status of pending requests");

            if (request.Status != "approved" && request.Status != "rejected")
                return ServiceResult.Failure("Invalid status. Must be 'approved' or 'rejected'");

            var success = await _changeRequestRepository.ChangeRequestStatusSimpleAsync(id, request.Status, request.ApproverId);

            if (success)
            {
                _logger.LogInformation("Change request {RequestId} status changed to {Status}", id, request.Status);
                return ServiceResult.Success($"Change request {request.Status} successfully");
            }

            return ServiceResult.Failure("Failed to change request status");
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error changing request status for ID {RequestId}", id);
            return ServiceResult.Failure("Error changing request status");
        }
    }
}
