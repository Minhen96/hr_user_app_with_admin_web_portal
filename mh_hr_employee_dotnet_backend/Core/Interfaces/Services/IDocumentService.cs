using React.Core.DTOs.Request;
using React.Core.DTOs.Response;
using React.Shared.Results;

namespace React.Core.Interfaces.Services;

public interface IDocumentService
{
    Task<ServiceResult<int>> CreateDocumentAsync(CreateDocumentRequestDto request);
    Task<ServiceResult<DocumentResponseDto>> GetDocumentByIdAsync(int id);
    Task<ServiceResult<IEnumerable<DocumentResponseDto>>> GetAllDocumentsAsync();
}
