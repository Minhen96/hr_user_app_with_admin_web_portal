using React.DTOs;
using React.Shared.Results;

namespace React.Core.Interfaces.Services;

/// <summary>
/// Service interface for user-facing document operations including read tracking
/// </summary>
public interface IUserDocumentService
{
    /// <summary>
    /// Gets unread document count for updates (last 30 days)
    /// </summary>
    Task<ServiceResult<int>> GetUnreadCountAsync(int userId);

    /// <summary>
    /// Marks a document as read by the user
    /// </summary>
    Task<ServiceResult<bool>> MarkAsReadAsync(int documentId, int userId);

    /// <summary>
    /// Gets unread counts by document type (MEMO, SOP, POLICY, UserGuide)
    /// </summary>
    Task<ServiceResult<Dictionary<string, int>>> GetUnreadCountsByTypeAsync(int userId);

    /// <summary>
    /// Gets document read information including read count and readers list
    /// </summary>
    Task<ServiceResult<DocumentReadInfoDto>> GetDocumentReadInfoAsync(int documentId, int userId);

    /// <summary>
    /// Gets paginated documents with optional type filter
    /// </summary>
    Task<ServiceResult<PaginatedDocumentsResponse>> GetDocumentsAsync(string? type, int page, int userId);

    /// <summary>
    /// Gets paginated updates documents (last 30 days)
    /// </summary>
    Task<ServiceResult<PaginatedDocumentsResponse>> GetUpdatesDocumentsAsync(int page, int userId);

    /// <summary>
    /// Creates a new update document
    /// </summary>
    Task<ServiceResult<DocumentDto>> AddUpdateDocumentAsync(DocumentDto documentDto, int userId);

    /// <summary>
    /// Updates an existing update document
    /// </summary>
    Task<ServiceResult<DocumentDto>> EditUpdateDocumentAsync(int id, DocumentDto documentDto);

    /// <summary>
    /// Deletes an update document
    /// </summary>
    Task<ServiceResult<bool>> DeleteUpdateDocumentAsync(int id);

    /// <summary>
    /// Gets history documents by year and month
    /// </summary>
    Task<ServiceResult<PaginatedDocumentsResponse>> GetHistoryDocumentsAsync(int year, int month, int page);

    /// <summary>
    /// Gets a single document by ID
    /// </summary>
    Task<ServiceResult<DocumentDto>> GetDocumentByIdAsync(int id);

    /// <summary>
    /// Gets document file data for preview/download
    /// </summary>
    Task<ServiceResult<DocumentFileDto>> GetDocumentFileAsync(int id);
}

public class PaginatedDocumentsResponse
{
    public List<DocumentDto> Items { get; set; } = new();
    public int CurrentPage { get; set; }
    public int TotalPages { get; set; }
    public int TotalCount { get; set; }
}

public class DocumentReadInfoDto
{
    public int ReadCount { get; set; }
    public List<DocumentReaderDto> Readers { get; set; } = new();
}

public class DocumentReaderDto
{
    public int UserId { get; set; }
    public string Name { get; set; } = string.Empty;
    public DateTime ReadDate { get; set; }
}

public class DocumentFileDto
{
    public byte[] FileData { get; set; } = Array.Empty<byte>();
    public string FileType { get; set; } = string.Empty;
    public string Title { get; set; } = string.Empty;
}
