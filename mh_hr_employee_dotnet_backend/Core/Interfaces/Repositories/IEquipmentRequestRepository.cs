using React.Models;

namespace React.Core.Interfaces.Repositories;

public interface IEquipmentRequestRepository
{
    Task<IEnumerable<EquipmentRequest>> GetByUserIdAsync(int userId, string? status);
    Task<IEnumerable<EquipmentRequest>> GetAllAsync(string? status);
    Task<EquipmentRequest> AddAsync(EquipmentRequest request);
    Task<EquipmentRequest?> GetByIdAsync(int id);
    Task<EquipmentRequest?> GetByIdWithDetailsAsync(int id);
    Task UpdateReceivedDetailsAsync(int id, string receivedDetails);
    Task UpdateStatusAsync(int id, string status, int? approverId = null);
}
