using Microsoft.AspNetCore.Http;
using React.Core.Interfaces.Repositories;
using React.Core.Interfaces.Services;
using React.DTOs;
using React.Models;
using React.Shared.Results;

namespace React.Application.Services;

public class UserMomentService : IUserMomentService
{
    private readonly IUserMomentRepository _repository;

    public UserMomentService(IUserMomentRepository repository)
    {
        _repository = repository ?? throw new ArgumentNullException(nameof(repository));
    }

    public async Task<ServiceResult<PagedMomentsResponse>> GetMomentsAsync(int page, int pageSize, int currentUserId)
    {
        try
        {
            var moments = await _repository.GetMomentsAsync(page, pageSize);
            var totalCount = await _repository.GetTotalMomentsCountAsync();

            var momentDtos = moments.Select(m => new MomentDto
            {
                Id = m.Id,
                Title = m.Title,
                Description = m.Description,
                UserId = m.UserId,
                UserName = m.User?.FullName ?? string.Empty,
                nickname = m.User?.nickname ?? string.Empty,
                ImagePath = m.Images.Select(i => new MomentImageDto
                {
                    Id = i.Id,
                    ImagePath = i.ImagePath
                }).ToList(),
                Reactions = m.Reactions.Select(r => new MomentReactionDto
                {
                    Id = r.Id,
                    UserId = r.UserId,
                    UserName = r.User?.FullName ?? string.Empty,
                    ReactionType = r.ReactionType,
                    CreatedAt = r.CreatedAt,
                    nickname = r.User?.nickname ?? string.Empty
                }).ToList(),
                CreatedAt = m.CreatedAt
            }).ToList();

            var response = new PagedMomentsResponse
            {
                Items = momentDtos,
                TotalCount = totalCount,
                CurrentPage = page,
                PageSize = pageSize,
                TotalPages = (int)Math.Ceiling(totalCount / (double)pageSize)
            };

            return ServiceResult<PagedMomentsResponse>.Success(response);
        }
        catch (Exception ex)
        {
            return ServiceResult<PagedMomentsResponse>.Failure($"Error retrieving moments: {ex.Message}");
        }
    }

    public async Task<ServiceResult<MomentDto>> CreateMomentAsync(
        string title,
        string description,
        List<IFormFile> media,
        int userId,
        string scheme,
        string host)
    {
        try
        {
            // Create moment
            var moment = new Moment
            {
                Title = title,
                Description = description,
                UserId = userId,
                CreatedAt = DateTime.Now
            };

            var createdMoment = await _repository.AddMomentAsync(moment);

            // Process media files
            if (media != null && media.Any())
            {
                foreach (var mediaFile in media)
                {
                    if (mediaFile == null || mediaFile.Length == 0)
                    {
                        return ServiceResult<MomentDto>.Failure("No file provided.");
                    }

                    var fileExtension = Path.GetExtension(mediaFile.FileName).ToLowerInvariant();

                    if (!IsValidFileType(fileExtension))
                    {
                        return ServiceResult<MomentDto>.Failure("Invalid file type. Only JPG, JPEG, PNG, GIF, MP4, MOV, AVI are allowed.");
                    }

                    var isVideo = IsVideoFile(fileExtension);
                    string subfolder = isVideo ? "moment-videos" : "moment-images";
                    var uploadPath = Path.Combine(Directory.GetCurrentDirectory(), "wwwroot", "mhhr", subfolder);

                    if (!Directory.Exists(uploadPath))
                    {
                        Directory.CreateDirectory(uploadPath);
                    }

                    var fileName = $"{userId}_{Guid.NewGuid()}{fileExtension}";
                    var filePath = Path.Combine(uploadPath, fileName);

                    using (var stream = new FileStream(filePath, FileMode.Create))
                    {
                        await mediaFile.CopyToAsync(stream);
                    }

                    var mediaUrl = $"{scheme}://{host}/mhhr/{subfolder}/{Path.GetFileName(fileName)}";

                    using (var memoryStream = new MemoryStream())
                    {
                        await mediaFile.CopyToAsync(memoryStream);
                        var mediaBytes = memoryStream.ToArray();

                        var momentImage = new MomentImage
                        {
                            MomentId = createdMoment.Id,
                            ImageData = mediaBytes,
                            ImagePath = mediaUrl
                        };
                        await _repository.AddMomentImageAsync(momentImage);
                    }
                }
                await _repository.SaveChangesAsync();
            }

            // Push notifications disabled - Firebase removed
            Console.WriteLine("WARNING: Push notifications disabled - Firebase removed");

            // Return created moment DTO
            var momentDto = new MomentDto
            {
                Id = createdMoment.Id,
                Title = createdMoment.Title,
                Description = createdMoment.Description,
                UserId = createdMoment.UserId,
                CreatedAt = createdMoment.CreatedAt,
                ImagePath = new List<MomentImageDto>(),
                Reactions = new List<MomentReactionDto>()
            };

            return ServiceResult<MomentDto>.Success(momentDto, "Moment created successfully");
        }
        catch (Exception ex)
        {
            return ServiceResult<MomentDto>.Failure($"Error creating moment: {ex.Message}");
        }
    }

    public async Task<ServiceResult<List<MomentReactionDto>>> AddOrUpdateReactionAsync(int momentId, int userId, string reactionType)
    {
        try
        {
            var moment = await _repository.GetMomentByIdAsync(momentId);
            if (moment == null)
            {
                return ServiceResult<List<MomentReactionDto>>.Failure("Moment not found");
            }

            var existingReaction = await _repository.GetExistingReactionAsync(momentId, userId);

            if (existingReaction != null)
            {
                existingReaction.ReactionType = reactionType;
                existingReaction.CreatedAt = DateTime.UtcNow;
                await _repository.UpdateReactionAsync(existingReaction);
            }
            else
            {
                var reaction = new MomentReaction
                {
                    MomentId = momentId,
                    UserId = userId,
                    ReactionType = reactionType,
                    CreatedAt = DateTime.UtcNow
                };
                await _repository.AddReactionAsync(reaction);
            }

            await _repository.SaveChangesAsync();

            // Get updated moment with reactions
            var updatedMoment = await _repository.GetMomentWithReactionsAsync(momentId);

            var reactionDtos = updatedMoment!.Reactions.Select(r => new MomentReactionDto
            {
                Id = r.Id,
                UserId = r.UserId,
                UserName = r.User?.FullName ?? string.Empty,
                ReactionType = r.ReactionType,
                CreatedAt = r.CreatedAt,
                nickname = r.User?.nickname ?? string.Empty
            }).ToList();

            return ServiceResult<List<MomentReactionDto>>.Success(reactionDtos);
        }
        catch (Exception ex)
        {
            return ServiceResult<List<MomentReactionDto>>.Failure($"Error adding reaction: {ex.Message}");
        }
    }

    private bool IsVideoFile(string extension)
    {
        var videoExtensions = new[] { ".mp4", ".mov", ".avi" };
        return videoExtensions.Contains(extension);
    }

    private bool IsValidFileType(string extension)
    {
        var allowedExtensions = new[] { ".jpg", ".jpeg", ".png", ".gif", ".mp4", ".mov", ".avi" };
        return allowedExtensions.Contains(extension);
    }
}
