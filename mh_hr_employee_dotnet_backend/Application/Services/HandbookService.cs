using Microsoft.Extensions.Logging;
using React.Core.DTOs.Response;
using React.Core.Interfaces.Repositories;
using React.Core.Interfaces.Services;
using React.Shared.Results;

namespace React.Application.Services;

public class HandbookService : IHandbookService
{
    private readonly IHandbookRepository _handbookRepository;
    private readonly ILogger<HandbookService> _logger;

    public HandbookService(
        IHandbookRepository handbookRepository,
        ILogger<HandbookService> logger)
    {
        _handbookRepository = handbookRepository ?? throw new ArgumentNullException(nameof(handbookRepository));
        _logger = logger ?? throw new ArgumentNullException(nameof(logger));
    }

    public async Task<ServiceResult<IEnumerable<HandbookSectionResponseDto>>> GetAllSectionsAsync()
    {
        try
        {
            var sections = await _handbookRepository.GetAllSectionsAsync();
            var response = sections.Select(s => new HandbookSectionResponseDto
            {
                Id = s.Id,
                Title = s.Title,
                Contents = s.Contents.Select(c => new HandbookContentResponseDto
                {
                    Id = c.Id,
                    HandbookSectionId = c.HandbookSectionId,
                    Subtitle = c.Subtitle,
                    Content = c.Content
                }).ToList()
            });

            _logger.LogInformation("Retrieved {Count} handbook sections", response.Count());
            return ServiceResult<IEnumerable<HandbookSectionResponseDto>>.Success(response);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error retrieving handbook sections");
            return ServiceResult<IEnumerable<HandbookSectionResponseDto>>.Failure("Error retrieving handbook sections");
        }
    }

    public async Task<ServiceResult<HandbookSectionResponseDto>> GetSectionByIdAsync(int id)
    {
        try
        {
            var section = await _handbookRepository.GetSectionByIdAsync(id);
            if (section == null)
            {
                _logger.LogWarning("Handbook section {Id} not found", id);
                return ServiceResult<HandbookSectionResponseDto>.Failure("Section not found");
            }

            var response = new HandbookSectionResponseDto
            {
                Id = section.Id,
                Title = section.Title,
                Contents = section.Contents.Select(c => new HandbookContentResponseDto
                {
                    Id = c.Id,
                    HandbookSectionId = c.HandbookSectionId,
                    Subtitle = c.Subtitle,
                    Content = c.Content
                }).ToList()
            };

            return ServiceResult<HandbookSectionResponseDto>.Success(response);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error retrieving handbook section {Id}", id);
            return ServiceResult<HandbookSectionResponseDto>.Failure("Error retrieving handbook section");
        }
    }

    public async Task<ServiceResult<IEnumerable<HandbookContentResponseDto>>> GetSectionContentsAsync(int sectionId)
    {
        try
        {
            var contents = await _handbookRepository.GetSectionContentsAsync(sectionId);
            var response = contents.Select(c => new HandbookContentResponseDto
            {
                Id = c.Id,
                HandbookSectionId = c.HandbookSectionId,
                Subtitle = c.Subtitle,
                Content = c.Content
            });

            _logger.LogInformation("Retrieved {Count} contents for section {SectionId}", response.Count(), sectionId);
            return ServiceResult<IEnumerable<HandbookContentResponseDto>>.Success(response);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error retrieving contents for section {SectionId}", sectionId);
            return ServiceResult<IEnumerable<HandbookContentResponseDto>>.Failure("Error retrieving section contents");
        }
    }

    public async Task<ServiceResult<byte[]>> GetUserGuidePdfAsync()
    {
        try
        {
            string filePath = Path.Combine("wwwroot", "mhhr", "Mobile User Guide.pdf");

            if (!File.Exists(filePath))
            {
                _logger.LogWarning("User guide PDF not found at {Path}", filePath);
                return ServiceResult<byte[]>.Failure("User guide not found");
            }

            byte[] fileBytes = await File.ReadAllBytesAsync(filePath);
            _logger.LogInformation("Retrieved user guide PDF");
            return ServiceResult<byte[]>.Success(fileBytes);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error retrieving user guide PDF");
            return ServiceResult<byte[]>.Failure("Error retrieving user guide");
        }
    }
}
