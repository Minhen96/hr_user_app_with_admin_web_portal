using System.Text.Json;
using React.Core.DTOs.Request;
using React.Core.DTOs.Response;
using React.Core.Interfaces.Repositories;
using React.Core.Interfaces.Services;
using React.Models;
using React.Shared.Results;

namespace React.Application.Services;

public class UserChangeRequestService : IUserChangeRequestService
{
    private readonly IUserChangeRequestRepository _repository;
    private readonly IUserRepository _userRepository;

    public UserChangeRequestService(
        IUserChangeRequestRepository repository,
        IUserRepository userRepository)
    {
        _repository = repository ?? throw new ArgumentNullException(nameof(repository));
        _userRepository = userRepository ?? throw new ArgumentNullException(nameof(userRepository));
    }

    public async Task<ServiceResult<Signature>> CreateSignatureAsync(int userId, CreateSignatureRequestDto signatureDto)
    {
        try
        {
            var signature = new Signature
            {
                Points = JsonSerializer.Serialize(signatureDto.Points),
                BoundaryWidth = signatureDto.BoundaryWidth,
                BoundaryHeight = signatureDto.BoundaryHeight,
                UserId = userId,
                CreatedAt = DateTime.UtcNow
            };

            var createdSignature = await _repository.CreateSignatureAsync(signature);
            return ServiceResult<Signature>.Success(createdSignature, "Signature created successfully");
        }
        catch (Exception ex)
        {
            return ServiceResult<Signature>.Failure($"Error creating signature: {ex.Message}");
        }
    }

    public async Task<ServiceResult<ChangeRequest>> CreateChangeRequestAsync(CreateUserChangeRequestDto requestDto)
    {
        try
        {
            // Validate user exists
            var user = await _userRepository.GetByIdAsync(requestDto.RequesterId);
            if (user == null)
            {
                return ServiceResult<ChangeRequest>.Failure("Invalid requester ID");
            }

            var changeRequest = new ChangeRequest
            {
                RequesterId = requestDto.RequesterId,
                DateRequested = DateTime.UtcNow,
                Status = "pending",
                Reason = requestDto.Reason,
                Description = requestDto.Description,
                Risk = requestDto.Risk,
                Instruction = requestDto.Instruction,
                PostReview = requestDto.PostReview,
                SignatureId = requestDto.SignatureId,
                CompleteDate = requestDto.CompleteDate,
                ReturnStatus = "in_use"
            };

            var createdRequest = await _repository.CreateChangeRequestAsync(changeRequest);
            return ServiceResult<ChangeRequest>.Success(createdRequest, "Change request created successfully");
        }
        catch (Exception ex)
        {
            return ServiceResult<ChangeRequest>.Failure($"Error creating change request: {ex.Message}");
        }
    }

    public async Task<ServiceResult<UserChangeRequestDetailResponseDto>> GetChangeRequestByIdAsync(int id)
    {
        try
        {
            var changeRequest = await _repository.GetChangeRequestByIdAsync(id);
            if (changeRequest == null)
            {
                return ServiceResult<UserChangeRequestDetailResponseDto>.Failure("Change request not found");
            }

            var response = new UserChangeRequestDetailResponseDto
            {
                Id = changeRequest.Id,
                RequesterName = changeRequest.Requester.FullName,
                DateRequested = changeRequest.DateRequested,
                Status = changeRequest.Status,
                Reason = changeRequest.Reason,
                Description = changeRequest.Description,
                Risk = changeRequest.Risk,
                Instruction = changeRequest.Instruction,
                PostReview = changeRequest.PostReview,
                CompleteDate = changeRequest.CompleteDate,
                SignatureData = new SignatureDataDto
                {
                    Points = changeRequest.Signature?.Points ?? string.Empty,
                    BoundaryWidth = changeRequest.Signature?.BoundaryWidth ?? 0,
                    BoundaryHeight = changeRequest.Signature?.BoundaryHeight ?? 0
                },
                ApproverName = changeRequest.Approver?.FullName,
                DateApproved = changeRequest.DateApproved,
                ApprovalSignatureData = changeRequest.ApprovalSignature != null ? new SignatureDataDto
                {
                    Points = changeRequest.ApprovalSignature.Points ?? string.Empty,
                    BoundaryWidth = changeRequest.ApprovalSignature.BoundaryWidth,
                    BoundaryHeight = changeRequest.ApprovalSignature.BoundaryHeight
                } : null,
                FixedAssetTypeName = changeRequest.FixedAssetType?.Name,
                ProductCodes = changeRequest.FixedAssetProducts?.Select(p => p.ProductCode).ToList() ?? new List<string>()
            };

            return ServiceResult<UserChangeRequestDetailResponseDto>.Success(response);
        }
        catch (Exception ex)
        {
            return ServiceResult<UserChangeRequestDetailResponseDto>.Failure($"Error retrieving change request: {ex.Message}");
        }
    }

    public async Task<ServiceResult<IEnumerable<UserChangeRequestBriefResponseDto>>> GetUserChangeRequestsAsync(int userId)
    {
        try
        {
            var changeRequests = await _repository.GetUserChangeRequestsAsync(userId);

            var response = changeRequests.Select(cr => new UserChangeRequestBriefResponseDto
            {
                Id = cr.Id,
                DateRequested = cr.DateRequested,
                Status = cr.Status,
                Reason = cr.Reason,
                ReturnStatus = cr.ReturnStatus,
                ProductCode = cr.FixedAssetProducts.FirstOrDefault()?.ProductCode
            });

            return ServiceResult<IEnumerable<UserChangeRequestBriefResponseDto>>.Success(response);
        }
        catch (Exception ex)
        {
            return ServiceResult<IEnumerable<UserChangeRequestBriefResponseDto>>.Failure($"Error retrieving user change requests: {ex.Message}");
        }
    }

    public async Task<ServiceResult<bool>> RequestReturnAsync(int id)
    {
        try
        {
            var success = await _repository.UpdateReturnStatusAsync(id);
            if (!success)
            {
                return ServiceResult<bool>.Failure("Cannot request return at this time");
            }

            return ServiceResult<bool>.Success(true, "Return request submitted");
        }
        catch (Exception ex)
        {
            return ServiceResult<bool>.Failure($"Error requesting return: {ex.Message}");
        }
    }

    public async Task<ServiceResult<IEnumerable<UserChangeRequestFullResponseDto>>> GetAllUserChangeRequestsAsync(int userId)
    {
        try
        {
            var changeRequests = await _repository.GetUserChangeRequestsAsync(userId);

            var response = changeRequests.Select(cr => new UserChangeRequestFullResponseDto
            {
                Id = cr.Id,
                DateRequested = cr.DateRequested,
                Status = cr.Status,
                Reason = cr.Reason,
                Description = cr.Description,
                Risk = cr.Risk,
                Instruction = cr.Instruction,
                CompleteDate = cr.CompleteDate,
                ReturnStatus = cr.ReturnStatus,
                PostReview = cr.PostReview,
                ProductCode = cr.FixedAssetProducts.FirstOrDefault()?.ProductCode
            });

            return ServiceResult<IEnumerable<UserChangeRequestFullResponseDto>>.Success(response);
        }
        catch (Exception ex)
        {
            return ServiceResult<IEnumerable<UserChangeRequestFullResponseDto>>.Failure($"Error retrieving all user change requests: {ex.Message}");
        }
    }
}
