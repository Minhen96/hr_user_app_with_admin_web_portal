using Microsoft.Extensions.Logging;
using React.Core.DTOs.Response;
using React.Core.Interfaces.Repositories;
using React.Core.Interfaces.Services;
using React.Shared.Results;

namespace React.Application.Services;

public class BirthdayService : IBirthdayService
{
    private readonly IBirthdayRepository _birthdayRepository;
    private readonly ILogger<BirthdayService> _logger;

    public BirthdayService(
        IBirthdayRepository birthdayRepository,
        ILogger<BirthdayService> logger)
    {
        _birthdayRepository = birthdayRepository ?? throw new ArgumentNullException(nameof(birthdayRepository));
        _logger = logger ?? throw new ArgumentNullException(nameof(logger));
    }

    public async Task<ServiceResult<IEnumerable<BirthdayResponseDto>>> GetBirthdaysByMonthAsync(int month)
    {
        try
        {
            if (month < 1 || month > 12)
                return ServiceResult<IEnumerable<BirthdayResponseDto>>.Failure("Invalid month. Must be between 1 and 12.");

            var birthdays = await _birthdayRepository.GetBirthdaysByMonthAsync(month);
            _logger.LogInformation("Found {Count} birthdays for month {Month}", birthdays.Count(), month);
            return ServiceResult<IEnumerable<BirthdayResponseDto>>.Success(birthdays);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error retrieving birthdays for month {Month}", month);
            return ServiceResult<IEnumerable<BirthdayResponseDto>>.Failure("Error retrieving birthdays");
        }
    }
}
