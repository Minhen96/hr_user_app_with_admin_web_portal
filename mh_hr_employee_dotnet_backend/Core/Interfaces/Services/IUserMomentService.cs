using Microsoft.AspNetCore.Http;
using React.DTOs;
using React.Shared.Results;

namespace React.Core.Interfaces.Services;

public interface IUserMomentService
{
    Task<ServiceResult<PagedMomentsResponse>> GetMomentsAsync(int page, int pageSize, int currentUserId);
    Task<ServiceResult<MomentDto>> CreateMomentAsync(string title, string description, List<IFormFile> media, int userId, string scheme, string host);
    Task<ServiceResult<List<MomentReactionDto>>> AddOrUpdateReactionAsync(int momentId, int userId, string reactionType);
}

public class PagedMomentsResponse
{
    public List<MomentDto> Items { get; set; } = new();
    public int TotalCount { get; set; }
    public int CurrentPage { get; set; }
    public int PageSize { get; set; }
    public int TotalPages { get; set; }
}
