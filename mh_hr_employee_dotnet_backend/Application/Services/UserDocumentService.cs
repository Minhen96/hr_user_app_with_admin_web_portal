using React.Core.Interfaces.Repositories;
using React.Core.Interfaces.Services;
using React.DTOs;
using React.Models;
using React.Shared.Results;

namespace React.Application.Services;

public class UserDocumentService : IUserDocumentService
{
    private readonly IUserDocumentRepository _repository;
    private const int PageSize = 8;

    public UserDocumentService(IUserDocumentRepository repository)
    {
        _repository = repository ?? throw new ArgumentNullException(nameof(repository));
    }

    public async Task<ServiceResult<int>> GetUnreadCountAsync(int userId)
    {
        try
        {
            var count = await _repository.GetUnreadCountAsync(userId);
            return ServiceResult<int>.Success(count);
        }
        catch (Exception ex)
        {
            return ServiceResult<int>.Failure($"Error getting unread count: {ex.Message}");
        }
    }

    public async Task<ServiceResult<bool>> MarkAsReadAsync(int documentId, int userId)
    {
        try
        {
            var document = await _repository.GetDocumentByIdAsync(documentId);
            if (document == null)
            {
                return ServiceResult<bool>.Failure("Document not found");
            }

            var existingRead = await _repository.GetDocumentReadAsync(documentId, userId);
            if (existingRead == null)
            {
                await _repository.AddDocumentReadAsync(new DocumentRead
                {
                    DocId = documentId,
                    UserId = userId,
                    ReadDate = DateTime.UtcNow
                });
                await _repository.SaveChangesAsync();
            }

            return ServiceResult<bool>.Success(true);
        }
        catch (Exception ex)
        {
            return ServiceResult<bool>.Failure($"Error marking document as read: {ex.Message}");
        }
    }

    public async Task<ServiceResult<Dictionary<string, int>>> GetUnreadCountsByTypeAsync(int userId)
    {
        try
        {
            var types = new[] { "MEMO", "SOP", "POLICY", "UserGuide" };
            var result = await _repository.GetUnreadCountsByTypeAsync(userId, types);
            return ServiceResult<Dictionary<string, int>>.Success(result);
        }
        catch (Exception ex)
        {
            return ServiceResult<Dictionary<string, int>>.Failure($"Error getting unread counts: {ex.Message}");
        }
    }

    public async Task<ServiceResult<DocumentReadInfoDto>> GetDocumentReadInfoAsync(int documentId, int userId)
    {
        try
        {
            var document = await _repository.GetDocumentByIdAsync(documentId);
            if (document == null)
            {
                return ServiceResult<DocumentReadInfoDto>.Failure("Document not found");
            }

            // Mark as read if not already
            var existingRead = await _repository.GetDocumentReadAsync(documentId, userId);
            if (existingRead == null)
            {
                await _repository.AddDocumentReadAsync(new DocumentRead
                {
                    DocId = documentId,
                    UserId = userId,
                    ReadDate = DateTime.UtcNow
                });
                await _repository.SaveChangesAsync();
            }

            var allReads = await _repository.GetDocumentReadsAsync(documentId);
            var readInfo = new DocumentReadInfoDto
            {
                ReadCount = allReads.Count,
                Readers = allReads.Select(r => new DocumentReaderDto
                {
                    UserId = r.UserId,
                    Name = (string.IsNullOrEmpty(r.User?.nickname)) ? r.User?.FullName ?? "Unknown" : r.User.nickname,
                    ReadDate = r.ReadDate
                }).ToList()
            };

            return ServiceResult<DocumentReadInfoDto>.Success(readInfo);
        }
        catch (Exception ex)
        {
            return ServiceResult<DocumentReadInfoDto>.Failure($"Error getting document read info: {ex.Message}");
        }
    }

    public async Task<ServiceResult<PaginatedDocumentsResponse>> GetDocumentsAsync(string? type, int page, int userId)
    {
        try
        {
            var (documents, totalCount) = await _repository.GetDocumentsAsync(type, page, PageSize, userId);
            var totalPages = (int)Math.Ceiling(totalCount / (double)PageSize);

            var documentDtos = documents.Select(d => new DocumentDto
            {
                Id = d.Id,
                Type = d.Type,
                PostDate = d.PostDate,
                PosterName = d.Poster?.FullName ?? string.Empty,
                Title = d.Title,
                Content = d.Content,
                DocumentUpload = d.DocumentUpload != null ? Convert.ToBase64String(d.DocumentUpload) : null,
                DepartmentName = d.Department?.Name ?? string.Empty,
                FileType = d.FileType,
                IsRead = d.PostBy == userId || d.DocumentReads.Any(),
                userid = d.PostBy,
            }).ToList();

            var response = new PaginatedDocumentsResponse
            {
                Items = documentDtos,
                CurrentPage = page,
                TotalPages = totalPages,
                TotalCount = totalCount
            };

            return ServiceResult<PaginatedDocumentsResponse>.Success(response);
        }
        catch (Exception ex)
        {
            return ServiceResult<PaginatedDocumentsResponse>.Failure($"Error fetching documents: {ex.Message}");
        }
    }

    public async Task<ServiceResult<PaginatedDocumentsResponse>> GetUpdatesDocumentsAsync(int page, int userId)
    {
        try
        {
            var (documents, totalCount) = await _repository.GetUpdatesDocumentsAsync(page, PageSize, userId);
            var totalPages = (int)Math.Ceiling(totalCount / (double)PageSize);

            var documentDtos = documents.Select(d => new DocumentDto
            {
                Id = d.Id,
                Type = d.Type ?? string.Empty,
                PostDate = d.PostDate.ToUniversalTime(),
                PosterName = d.Poster?.FullName ?? "Unknown Author",
                Title = d.Title ?? string.Empty,
                Content = d.Content ?? string.Empty,
                IsRead = d.PostBy == userId || d.DocumentReads.Any(),
                userid = d.PostBy
            }).ToList();

            var response = new PaginatedDocumentsResponse
            {
                Items = documentDtos,
                CurrentPage = page,
                TotalPages = totalPages,
                TotalCount = totalCount
            };

            return ServiceResult<PaginatedDocumentsResponse>.Success(response);
        }
        catch (Exception ex)
        {
            return ServiceResult<PaginatedDocumentsResponse>.Failure($"Error fetching updates documents: {ex.Message}");
        }
    }

    public async Task<ServiceResult<DocumentDto>> AddUpdateDocumentAsync(DocumentDto documentDto, int userId)
    {
        try
        {
            var currentUser = await _repository.GetUserByIdAsync(userId);
            if (currentUser == null)
            {
                return ServiceResult<DocumentDto>.Failure("User not found");
            }

            var document = new Document
            {
                Type = "UPDATES",
                Title = documentDto.Title,
                Content = documentDto.Content,
                PostDate = DateTime.UtcNow,
                PostBy = userId,
                DepartmentId = currentUser.DepartmentId,
            };

            await _repository.AddDocumentAsync(document);
            await _repository.SaveChangesAsync();

            var dto = new DocumentDto
            {
                Id = document.Id,
                Type = document.Type,
                Title = document.Title,
                Content = document.Content,
                PostDate = document.PostDate,
                PosterName = currentUser.FullName ?? "Unknown Author",
                DepartmentName = currentUser.Department?.Name ?? "Unknown Department",
                IsRead = true
            };

            return ServiceResult<DocumentDto>.Success(dto, "Update document created successfully");
        }
        catch (Exception ex)
        {
            return ServiceResult<DocumentDto>.Failure($"Error adding update document: {ex.Message}");
        }
    }

    public async Task<ServiceResult<DocumentDto>> EditUpdateDocumentAsync(int id, DocumentDto documentDto)
    {
        try
        {
            var document = await _repository.GetDocumentByIdAsync(id);
            if (document == null)
            {
                return ServiceResult<DocumentDto>.Failure("Document not found");
            }

            document.Title = documentDto.Title;
            document.Content = documentDto.Content;

            await _repository.UpdateDocumentAsync(document);
            await _repository.SaveChangesAsync();

            return ServiceResult<DocumentDto>.Success(documentDto, "Update document edited successfully");
        }
        catch (Exception ex)
        {
            return ServiceResult<DocumentDto>.Failure($"Error editing update document: {ex.Message}");
        }
    }

    public async Task<ServiceResult<bool>> DeleteUpdateDocumentAsync(int id)
    {
        try
        {
            var document = await _repository.GetDocumentByIdAsync(id);
            if (document == null)
            {
                return ServiceResult<bool>.Failure("Document not found");
            }

            await _repository.DeleteDocumentAsync(document);
            await _repository.SaveChangesAsync();

            return ServiceResult<bool>.Success(true, "Update document deleted successfully");
        }
        catch (Exception ex)
        {
            return ServiceResult<bool>.Failure($"Error deleting update document: {ex.Message}");
        }
    }

    public async Task<ServiceResult<PaginatedDocumentsResponse>> GetHistoryDocumentsAsync(int year, int month, int page)
    {
        try
        {
            var (documents, totalCount) = await _repository.GetHistoryDocumentsAsync(year, month, page, PageSize);
            var totalPages = (int)Math.Ceiling(totalCount / (double)PageSize);

            var documentDtos = documents.Select(d => new DocumentDto
            {
                Id = d.Id,
                Type = d.Type ?? string.Empty,
                PostDate = d.PostDate,
                PosterName = d.Poster?.FullName ?? "Unknown Author",
                Title = d.Title ?? string.Empty,
                Content = d.Content ?? string.Empty,
            }).ToList();

            var response = new PaginatedDocumentsResponse
            {
                Items = documentDtos,
                CurrentPage = page,
                TotalPages = totalPages,
                TotalCount = totalCount
            };

            return ServiceResult<PaginatedDocumentsResponse>.Success(response);
        }
        catch (Exception ex)
        {
            return ServiceResult<PaginatedDocumentsResponse>.Failure($"Error fetching history documents: {ex.Message}");
        }
    }

    public async Task<ServiceResult<DocumentDto>> GetDocumentByIdAsync(int id)
    {
        try
        {
            var document = await _repository.GetDocumentByIdAsync(id);
            if (document == null)
            {
                return ServiceResult<DocumentDto>.Failure("Document not found");
            }

            var documentDto = new DocumentDto
            {
                Id = document.Id,
                Type = document.Type,
                PostDate = document.PostDate,
                PosterName = document.Poster?.FullName ?? string.Empty,
                Title = document.Title,
                Content = document.Content,
                DepartmentName = document.Department?.Name ?? string.Empty,
                DocumentUpload = document.DocumentUpload != null ? Convert.ToBase64String(document.DocumentUpload) : null,
                FileType = document.FileType,
                userid = document.PostBy,
            };

            return ServiceResult<DocumentDto>.Success(documentDto);
        }
        catch (Exception ex)
        {
            return ServiceResult<DocumentDto>.Failure($"Error fetching document: {ex.Message}");
        }
    }

    public async Task<ServiceResult<DocumentFileDto>> GetDocumentFileAsync(int id)
    {
        try
        {
            var document = await _repository.GetDocumentByIdAsync(id);
            if (document == null || document.DocumentUpload == null)
            {
                return ServiceResult<DocumentFileDto>.Failure("Document not found");
            }

            var fileDto = new DocumentFileDto
            {
                FileData = document.DocumentUpload,
                FileType = document.FileType,
                Title = document.Title
            };

            return ServiceResult<DocumentFileDto>.Success(fileDto);
        }
        catch (Exception ex)
        {
            return ServiceResult<DocumentFileDto>.Failure($"Error fetching document file: {ex.Message}");
        }
    }
}
