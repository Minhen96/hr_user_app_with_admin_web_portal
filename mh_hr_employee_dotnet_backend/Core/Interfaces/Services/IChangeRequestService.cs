using React.Core.DTOs.Request;
using React.Core.DTOs.Response;
using React.Shared.Results;

namespace React.Core.Interfaces.Services;

public interface IChangeRequestService
{
    Task<ServiceResult<IEnumerable<ChangeRequestListResponseDto>>> GetAllChangeRequestsAsync();
    Task<ServiceResult<IEnumerable<ChangeRequestListResponseDto>>> GetApprovedChangeRequestsAsync();
    Task<ServiceResult<ChangeRequestDetailsResponseDto>> GetChangeRequestDetailsByIdAsync(int id);
    Task<ServiceResult<IEnumerable<ChangeRequestListResponseDto>>> GetPendingChangeRequestsAsync();
    Task<ServiceResult<IEnumerable<FixedAssetTypeResponseDto>>> GetFixedAssetTypesAsync();
    Task<ServiceResult<string>> UpdateChangeRequestStatusAsync(int id, UpdateChangeRequestStatusRequestDto request);
    Task<ServiceResult> ChangeRequestStatusAsync(int id, ChangeStatusRequestDto request);
}
