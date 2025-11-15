using System.Text.Json;
using React.Core.Interfaces.Repositories;
using React.Core.Interfaces.Services;
using React.DTOs;
using React.Models;
using React.Shared.Results;

namespace React.Application.Services;

public class EquipmentRequestService : IEquipmentRequestService
{
    private readonly IEquipmentRequestRepository _repository;

    public EquipmentRequestService(IEquipmentRequestRepository repository)
    {
        _repository = repository ?? throw new ArgumentNullException(nameof(repository));
    }

    public async Task<ServiceResult<IEnumerable<EquipmentRequest>>> GetEquipmentRequestsByUserAsync(int userId, string? status)
    {
        try
        {
            var requests = await _repository.GetByUserIdAsync(userId, status);
            return ServiceResult<IEnumerable<EquipmentRequest>>.Success(requests);
        }
        catch (Exception ex)
        {
            return ServiceResult<IEnumerable<EquipmentRequest>>.Failure($"Error retrieving equipment requests: {ex.Message}");
        }
    }

    public async Task<ServiceResult<IEnumerable<EquipmentRequestListDto>>> GetAllEquipmentRequestsAsync(string? status)
    {
        try
        {
            var requests = await _repository.GetAllAsync(status);
            var dtos = requests.Select(r => new EquipmentRequestListDto
            {
                Id = r.Id,
                RequesterId = r.RequesterId,
                RequesterName = r.Requester?.FullName ?? "Unknown",
                Department = r.Requester?.Department?.Name ?? "Unknown",
                DateRequested = r.DateRequested,
                Status = r.Status,
                ApproverId = r.ApproverId,
                ApproverName = r.Approver?.FullName,
                DateApproved = r.DateApproved,
                ItemCount = r.Items?.Count ?? 0
            }).ToList();

            return ServiceResult<IEnumerable<EquipmentRequestListDto>>.Success(dtos);
        }
        catch (Exception ex)
        {
            return ServiceResult<IEnumerable<EquipmentRequestListDto>>.Failure($"Error retrieving all equipment requests: {ex.Message}");
        }
    }

    public async Task<ServiceResult<EquipmentRequestDetailsDto>> GetEquipmentRequestByIdAsync(int id)
    {
        try
        {
            var request = await _repository.GetByIdWithDetailsAsync(id);
            if (request == null)
            {
                return ServiceResult<EquipmentRequestDetailsDto>.Failure("Equipment request not found");
            }

            var dto = new EquipmentRequestDetailsDto
            {
                Id = request.Id,
                RequesterId = request.RequesterId,
                RequesterName = request.Requester?.FullName ?? "Unknown",
                Department = request.Requester?.Department?.Name ?? "Unknown",
                DateRequested = request.DateRequested,
                Status = request.Status,
                ApproverId = request.ApproverId,
                ApproverName = request.Approver?.FullName,
                DateApproved = request.DateApproved,
                ReceivedDetails = request.ReceivedDetails,
                Items = request.Items?.Select(i => new EquipmentItemDetailsDto
                {
                    Id = i.Id,
                    Title = i.Title,
                    Description = i.Description,
                    Quantity = i.Quantity,
                    Justification = i.Justification
                }).ToList() ?? new List<EquipmentItemDetailsDto>(),
                Signature = request.Signature != null ? new SignatureDetailsDto
                {
                    Id = request.Signature.Id,
                    Points = request.Signature.Points,
                    BoundaryWidth = request.Signature.BoundaryWidth,
                    BoundaryHeight = request.Signature.BoundaryHeight
                } : null,
                ApprovalSignature = request.ApprovalSignature != null ? new SignatureDetailsDto
                {
                    Id = request.ApprovalSignature.Id,
                    Points = request.ApprovalSignature.Points,
                    BoundaryWidth = request.ApprovalSignature.BoundaryWidth,
                    BoundaryHeight = request.ApprovalSignature.BoundaryHeight
                } : null
            };

            return ServiceResult<EquipmentRequestDetailsDto>.Success(dto);
        }
        catch (Exception ex)
        {
            return ServiceResult<EquipmentRequestDetailsDto>.Failure($"Error retrieving equipment request: {ex.Message}");
        }
    }

    public async Task<ServiceResult<EquipmentRequest>> CreateEquipmentRequestAsync(int userId, CreateEquipmentRequestDto requestData)
    {
        try
        {
            if (requestData?.Items == null || !requestData.Items.Any())
            {
                return ServiceResult<EquipmentRequest>.Failure("At least one item is required");
            }

            // Validate items
            foreach (var item in requestData.Items)
            {
                if (string.IsNullOrWhiteSpace(item.Title))
                {
                    return ServiceResult<EquipmentRequest>.Failure("All items must have a title");
                }
                if (item.Quantity <= 0)
                {
                    return ServiceResult<EquipmentRequest>.Failure("All items must have a quantity greater than 0");
                }
            }

            var request = new EquipmentRequest
            {
                RequesterId = userId,
                DateRequested = DateTime.UtcNow,
                Status = "pending",
                CreatedAt = DateTime.UtcNow,
                UpdatedAt = DateTime.UtcNow,
                Items = requestData.Items.Select(i => new EquipmentItem
                {
                    Title = i.Title,
                    Description = i.Description,
                    Quantity = i.Quantity,
                    Justification = i.Justification,
                    CreatedAt = DateTime.UtcNow
                }).ToList()
            };

            // Add signature if provided
            if (requestData.Signature != null)
            {
                request.Signature = new Signature
                {
                    UserId = userId,
                    Points = JsonSerializer.Serialize(requestData.Signature.Points),
                    BoundaryWidth = requestData.Signature.BoundaryWidth,
                    BoundaryHeight = requestData.Signature.BoundaryHeight,
                    CreatedAt = DateTime.UtcNow
                };
            }

            var createdRequest = await _repository.AddAsync(request);
            return ServiceResult<EquipmentRequest>.Success(createdRequest);
        }
        catch (Exception ex)
        {
            var innerMessage = ex.InnerException != null ? $" Inner: {ex.InnerException.Message}" : "";
            return ServiceResult<EquipmentRequest>.Failure($"Error creating equipment request: {ex.Message}{innerMessage}");
        }
    }

    public async Task<ServiceResult<bool>> UpdateReceivedDetailsAsync(int id, UpdateReceivedDetailsDto data)
    {
        try
        {
            var request = await _repository.GetByIdAsync(id);
            if (request == null)
            {
                return ServiceResult<bool>.Failure("Equipment request not found");
            }

            if (string.IsNullOrWhiteSpace(data.ReceivedDetails))
            {
                return ServiceResult<bool>.Failure("Received details cannot be empty");
            }

            await _repository.UpdateReceivedDetailsAsync(id, data.ReceivedDetails);
            return ServiceResult<bool>.Success(true);
        }
        catch (Exception ex)
        {
            return ServiceResult<bool>.Failure($"Error updating received details: {ex.Message}");
        }
    }

    public async Task<ServiceResult<bool>> UpdateRequestStatusAsync(int id, string status, int? approverId = null)
    {
        try
        {
            var request = await _repository.GetByIdAsync(id);
            if (request == null)
            {
                return ServiceResult<bool>.Failure("Equipment request not found");
            }

            var validStatuses = new[] { "pending", "approved", "rejected" };
            if (!validStatuses.Contains(status.ToLower()))
            {
                return ServiceResult<bool>.Failure("Invalid status value");
            }

            await _repository.UpdateStatusAsync(id, status, approverId);
            return ServiceResult<bool>.Success(true);
        }
        catch (Exception ex)
        {
            return ServiceResult<bool>.Failure($"Error updating request status: {ex.Message}");
        }
    }
}
