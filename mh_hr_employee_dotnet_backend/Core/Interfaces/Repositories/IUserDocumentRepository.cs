using React.Models;

namespace React.Core.Interfaces.Repositories;

/// <summary>
/// Repository interface for user-facing document data access operations
/// </summary>
public interface IUserDocumentRepository
{
    /// <summary>
    /// Gets unread document count for updates (last 30 days) for a specific user
    /// </summary>
    Task<int> GetUnreadCountAsync(int userId);

    /// <summary>
    /// Checks if a document read record exists for a user
    /// </summary>
    Task<DocumentRead?> GetDocumentReadAsync(int documentId, int userId);

    /// <summary>
    /// Creates a new document read record
    /// </summary>
    Task<DocumentRead> AddDocumentReadAsync(DocumentRead documentRead);

    /// <summary>
    /// Gets unread counts by document type for a specific user
    /// </summary>
    Task<Dictionary<string, int>> GetUnreadCountsByTypeAsync(int userId, string[] types);

    /// <summary>
    /// Gets all document reads for a specific document
    /// </summary>
    Task<List<DocumentRead>> GetDocumentReadsAsync(int documentId);

    /// <summary>
    /// Gets documents with pagination and optional type filter
    /// </summary>
    Task<(List<Document> Documents, int TotalCount)> GetDocumentsAsync(string? type, int page, int pageSize, int userId);

    /// <summary>
    /// Gets update documents from last 30 days with pagination
    /// </summary>
    Task<(List<Document> Documents, int TotalCount)> GetUpdatesDocumentsAsync(int page, int pageSize, int userId);

    /// <summary>
    /// Creates a new document
    /// </summary>
    Task<Document> AddDocumentAsync(Document document);

    /// <summary>
    /// Gets a document by ID
    /// </summary>
    Task<Document?> GetDocumentByIdAsync(int id);

    /// <summary>
    /// Updates an existing document
    /// </summary>
    Task UpdateDocumentAsync(Document document);

    /// <summary>
    /// Deletes a document with its related reads
    /// </summary>
    Task DeleteDocumentAsync(Document document);

    /// <summary>
    /// Gets history documents by year/month with pagination
    /// </summary>
    Task<(List<Document> Documents, int TotalCount)> GetHistoryDocumentsAsync(int year, int month, int page, int pageSize);

    /// <summary>
    /// Gets user by ID
    /// </summary>
    Task<User?> GetUserByIdAsync(int userId);

    /// <summary>
    /// Saves changes to the database
    /// </summary>
    Task SaveChangesAsync();
}
