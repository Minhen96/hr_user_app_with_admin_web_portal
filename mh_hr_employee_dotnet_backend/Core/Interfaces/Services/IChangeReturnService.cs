using React.Core.DTOs.Request;
using React.Core.DTOs.Response;
using React.Shared.Results;

namespace React.Core.Interfaces.Services;

public interface IChangeReturnService
{
    Task<ServiceResult<IEnumerable<ChangeReturnListResponseDto>>> GetAllChangeReturnsAsync();
    Task<ServiceResult<ChangeReturnDetailsResponseDto>> GetChangeReturnDetailsByIdAsync(int id);
    Task<ServiceResult> UpdateChangeReturnStatusAsync(int id, UpdateChangeReturnStatusRequestDto request);
}
