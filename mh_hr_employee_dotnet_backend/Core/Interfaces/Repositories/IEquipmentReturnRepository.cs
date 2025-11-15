using React.Core.DTOs.Response;

namespace React.Core.Interfaces.Repositories;

public interface IEquipmentReturnRepository
{
    Task<IEnumerable<EquipmentReturnListResponseDto>> GetAllReturnsAsync();
    Task<EquipmentReturnDetailsResponseDto?> GetReturnDetailsByIdAsync(int id);
    Task<IEnumerable<EquipmentReturnListResponseDto>> GetUncheckedReturnsAsync();
    Task<bool> UpdateReturnStatusAsync(int id, string status, int approverId, DateTime dateApproved);
    Task<string?> GetReturnCurrentStatusAsync(int id);
}
