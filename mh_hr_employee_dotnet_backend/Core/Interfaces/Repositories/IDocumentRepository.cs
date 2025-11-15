using React.Core.DTOs.Response;

namespace React.Core.Interfaces.Repositories;

public interface IDocumentRepository
{
    Task<int> CreateDocumentAsync(string type, string title, string? docContent, int postBy, int departmentId, byte[]? fileData, string? fileType);
    Task<DocumentResponseDto?> GetDocumentByIdAsync(int id);
    Task<IEnumerable<DocumentResponseDto>> GetAllDocumentsAsync();
}
