using React.Core.DTOs.Response;
using React.Shared.Results;

namespace React.Core.Interfaces.Services;

public interface IHandbookService
{
    Task<ServiceResult<IEnumerable<HandbookSectionResponseDto>>> GetAllSectionsAsync();
    Task<ServiceResult<HandbookSectionResponseDto>> GetSectionByIdAsync(int id);
    Task<ServiceResult<IEnumerable<HandbookContentResponseDto>>> GetSectionContentsAsync(int sectionId);
    Task<ServiceResult<byte[]>> GetUserGuidePdfAsync();
}
