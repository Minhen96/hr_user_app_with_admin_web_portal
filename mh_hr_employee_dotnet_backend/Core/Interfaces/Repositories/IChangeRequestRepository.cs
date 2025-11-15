using React.Core.DTOs.Response;

namespace React.Core.Interfaces.Repositories;

public interface IChangeRequestRepository
{
    Task<IEnumerable<ChangeRequestListResponseDto>> GetAllChangeRequestsAsync();
    Task<IEnumerable<ChangeRequestListResponseDto>> GetApprovedChangeRequestsAsync();
    Task<ChangeRequestDetailsResponseDto?> GetChangeRequestDetailsByIdAsync(int id);
    Task<IEnumerable<ChangeRequestListResponseDto>> GetPendingChangeRequestsAsync();
    Task<IEnumerable<FixedAssetTypeResponseDto>> GetFixedAssetTypesAsync();
    Task<string?> GetChangeRequestCurrentStatusAsync(int id);
    Task<int> CreateSignatureAsync(int userId, string points, float boundaryWidth, float boundaryHeight);
    Task<string> GetFixedAssetTypeCodeAsync(int fixedAssetTypeId);
    Task<int> CreateFixedAssetProductAsync(string productCode, int changeRequestId);
    Task<bool> UpdateChangeRequestStatusAsync(int id, string status, int approverId, DateTime? dateApproved, int? approvalSignatureId, int? fixedAssetTypeId);
    Task<bool> ChangeRequestStatusSimpleAsync(int id, string status, int approverId);
}
