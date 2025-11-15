using React.Core.DTOs.Request;
using React.Core.DTOs.Response;
using React.Shared.Results;

namespace React.Core.Interfaces.Services;

public interface IEquipmentReturnService
{
    Task<ServiceResult<IEnumerable<EquipmentReturnListResponseDto>>> GetAllReturnsAsync();
    Task<ServiceResult<EquipmentReturnDetailsResponseDto>> GetReturnDetailsByIdAsync(int id);
    Task<ServiceResult<IEnumerable<EquipmentReturnListResponseDto>>> GetUncheckedReturnsAsync();
    Task<ServiceResult> UpdateReturnStatusAsync(int id, UpdateEquipmentReturnStatusRequestDto request);
}
