using Microsoft.Extensions.Logging;
using React.Core.DTOs.Request;
using React.Core.DTOs.Response;
using React.Core.Interfaces.Repositories;
using React.Core.Interfaces.Services;
using React.Shared.Results;

namespace React.Application.Services;

public class DocumentService : IDocumentService
{
    private readonly IDocumentRepository _documentRepository;
    private readonly ILogger<DocumentService> _logger;
    private static readonly string[] AllowedFileTypes = {
        "application/pdf", "application/msword",
        "application/vnd.openxmlformats-officedocument.wordprocessingml.document",
        "application/vnd.ms-excel", "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
        "application/vnd.ms-powerpoint", "application/vnd.openxmlformats-officedocument.presentationml.presentation",
        "image/jpeg", "image/png", "text/plain", "application/zip", "application/x-zip-compressed"
    };
    private const long MaxFileSize = 25 * 1024 * 1024; // 25MB

    public DocumentService(IDocumentRepository documentRepository, ILogger<DocumentService> logger)
    {
        _documentRepository = documentRepository ?? throw new ArgumentNullException(nameof(documentRepository));
        _logger = logger ?? throw new ArgumentNullException(nameof(logger));
    }

    public async Task<ServiceResult<int>> CreateDocumentAsync(CreateDocumentRequestDto request)
    {
        try
        {
            byte[]? fileData = null;
            string? fileType = null;

            if (request.File != null)
            {
                if (!AllowedFileTypes.Contains(request.File.ContentType.ToLower()))
                    return ServiceResult<int>.Failure("Unsupported file type");

                if (request.File.Length > MaxFileSize)
                    return ServiceResult<int>.Failure("File size exceeds 25MB limit");

                using var ms = new MemoryStream();
                await request.File.CopyToAsync(ms);
                fileData = ms.ToArray();
                fileType = request.File.ContentType;
            }

            var documentId = await _documentRepository.CreateDocumentAsync(
                request.Type, request.Title, request.DocContent,
                request.PostBy, request.DepartmentId, fileData, fileType);

            _logger.LogInformation("Document created with ID {DocumentId}", documentId);
            return ServiceResult<int>.Success(documentId, "Document created successfully");
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error creating document");
            return ServiceResult<int>.Failure("Error creating document");
        }
    }

    public async Task<ServiceResult<DocumentResponseDto>> GetDocumentByIdAsync(int id)
    {
        try
        {
            var document = await _documentRepository.GetDocumentByIdAsync(id);
            if (document == null)
                return ServiceResult<DocumentResponseDto>.Failure("Document not found");

            return ServiceResult<DocumentResponseDto>.Success(document);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error retrieving document {Id}", id);
            return ServiceResult<DocumentResponseDto>.Failure("Error retrieving document");
        }
    }

    public async Task<ServiceResult<IEnumerable<DocumentResponseDto>>> GetAllDocumentsAsync()
    {
        try
        {
            var documents = await _documentRepository.GetAllDocumentsAsync();
            return ServiceResult<IEnumerable<DocumentResponseDto>>.Success(documents);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error retrieving documents");
            return ServiceResult<IEnumerable<DocumentResponseDto>>.Failure("Error retrieving documents");
        }
    }
}
