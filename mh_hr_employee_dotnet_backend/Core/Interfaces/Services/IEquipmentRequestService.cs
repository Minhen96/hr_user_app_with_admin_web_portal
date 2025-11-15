using React.DTOs;
using React.Models;
using React.Shared.Results;

namespace React.Core.Interfaces.Services;

public interface IEquipmentRequestService
{
    Task<ServiceResult<IEnumerable<EquipmentRequest>>> GetEquipmentRequestsByUserAsync(int userId, string? status);
    Task<ServiceResult<IEnumerable<EquipmentRequestListDto>>> GetAllEquipmentRequestsAsync(string? status);
    Task<ServiceResult<EquipmentRequestDetailsDto>> GetEquipmentRequestByIdAsync(int id);
    Task<ServiceResult<EquipmentRequest>> CreateEquipmentRequestAsync(int userId, CreateEquipmentRequestDto requestData);
    Task<ServiceResult<bool>> UpdateReceivedDetailsAsync(int id, UpdateReceivedDetailsDto data);
    Task<ServiceResult<bool>> UpdateRequestStatusAsync(int id, string status, int? approverId = null);
}
