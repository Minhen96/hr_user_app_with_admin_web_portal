using Microsoft.EntityFrameworkCore;
using React.Core.Interfaces.Repositories;
using React.Data;
using React.Models;

namespace React.Infrastructure.Repositories;

public class UserDocumentRepository : IUserDocumentRepository
{
    private readonly ApplicationDbContext _context;
    private const int PageSize = 8;

    public UserDocumentRepository(ApplicationDbContext context)
    {
        _context = context ?? throw new ArgumentNullException(nameof(context));
    }

    public async Task<int> GetUnreadCountAsync(int userId)
    {
        var thirtyDaysAgo = DateTime.UtcNow.AddDays(-30);
        return await _context.Documents
            .Where(d => d.Type.ToLower() == "updates"
                && d.PostDate >= thirtyDaysAgo
                && d.PostBy != userId
                && !d.DocumentReads.Any(r => r.UserId == userId))
            .CountAsync();
    }

    public async Task<DocumentRead?> GetDocumentReadAsync(int documentId, int userId)
    {
        return await _context.DocumentReads
            .FirstOrDefaultAsync(r => r.DocId == documentId && r.UserId == userId);
    }

    public async Task<DocumentRead> AddDocumentReadAsync(DocumentRead documentRead)
    {
        _context.DocumentReads.Add(documentRead);
        return documentRead;
    }

    public async Task<Dictionary<string, int>> GetUnreadCountsByTypeAsync(int userId, string[] types)
    {
        var result = new Dictionary<string, int>();

        foreach (var type in types)
        {
            var unreadCount = await _context.Documents
                .Where(d => d.Type.ToUpper() == type.ToUpper()
                    && d.PostBy != userId
                    && !d.DocumentReads.Any(r => r.UserId == userId))
                .CountAsync();

            result[type] = unreadCount;
        }

        return result;
    }

    public async Task<List<DocumentRead>> GetDocumentReadsAsync(int documentId)
    {
        return await _context.DocumentReads
            .Where(r => r.DocId == documentId)
            .Include(r => r.User)
            .ToListAsync();
    }

    public async Task<(List<Document> Documents, int TotalCount)> GetDocumentsAsync(string? type, int page, int pageSize, int userId)
    {
        var query = _context.Documents
            .Include(d => d.Department)
            .Include(d => d.Poster)
            .Include(d => d.DocumentReads.Where(r => r.UserId == userId))
            .AsQueryable();

        if (!string.IsNullOrEmpty(type))
        {
            query = query.Where(d => d.Type.ToLower() == type.ToLower());
        }

        var totalCount = await query.CountAsync();

        var documents = await query
            .OrderByDescending(d => d.PostDate)
            .Skip((page - 1) * pageSize)
            .Take(pageSize)
            .ToListAsync();

        return (documents, totalCount);
    }

    public async Task<(List<Document> Documents, int TotalCount)> GetUpdatesDocumentsAsync(int page, int pageSize, int userId)
    {
        var thirtyDaysAgo = DateTime.UtcNow.AddDays(-30);

        var query = _context.Documents
            .Include(d => d.Poster)
            .Include(d => d.DocumentReads.Where(r => r.UserId == userId))
            .Where(d =>
                d.PostDate >= thirtyDaysAgo &&
                d.Type.ToLower() == "updates".ToLower())
            .OrderByDescending(d => d.PostDate);

        var totalCount = await query.CountAsync();

        var documents = await query
            .Skip((page - 1) * pageSize)
            .Take(pageSize)
            .ToListAsync();

        return (documents, totalCount);
    }

    public async Task<Document> AddDocumentAsync(Document document)
    {
        _context.Documents.Add(document);
        return document;
    }

    public async Task<Document?> GetDocumentByIdAsync(int id)
    {
        return await _context.Documents
            .Include(d => d.Department)
            .Include(d => d.Poster)
            .Include(d => d.DocumentReads)
            .FirstOrDefaultAsync(d => d.Id == id);
    }

    public async Task UpdateDocumentAsync(Document document)
    {
        _context.Documents.Update(document);
    }

    public async Task DeleteDocumentAsync(Document document)
    {
        _context.Documents.Remove(document);
    }

    public async Task<(List<Document> Documents, int TotalCount)> GetHistoryDocumentsAsync(int year, int month, int page, int pageSize)
    {
        var startDate = new DateTime(year, month, 1);
        var endDate = startDate.AddMonths(1);

        var query = _context.Documents
            .Include(d => d.Poster)
            .Where(d => d.PostDate >= startDate && d.PostDate < endDate && d.Type.ToLower() == "updates");

        var totalCount = await query.CountAsync();

        var documents = await query
            .OrderByDescending(d => d.PostDate)
            .Skip((page - 1) * pageSize)
            .Take(pageSize)
            .ToListAsync();

        return (documents, totalCount);
    }

    public async Task<User?> GetUserByIdAsync(int userId)
    {
        return await _context.Users
            .Include(u => u.Department)
            .FirstOrDefaultAsync(u => u.Id == userId);
    }

    public async Task SaveChangesAsync()
    {
        await _context.SaveChangesAsync();
    }
}
