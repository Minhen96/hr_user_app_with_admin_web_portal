using React.Core.DTOs.Response;

namespace React.Core.Interfaces.Repositories;

public interface IChangeReturnRepository
{
    Task<IEnumerable<ChangeReturnListResponseDto>> GetAllChangeReturnsAsync();
    Task<ChangeReturnDetailsResponseDto?> GetChangeReturnDetailsByIdAsync(int id);
    Task<bool> UpdateChangeReturnStatusAsync(int id, string returnStatus, int approverId);
    Task<string?> GetChangeReturnCurrentStatusAsync(int id);
}
