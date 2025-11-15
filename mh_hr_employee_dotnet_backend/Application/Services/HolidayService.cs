using Microsoft.Extensions.Logging;
using React.Core.DTOs.Response;
using React.Core.Interfaces.Repositories;
using React.Core.Interfaces.Services;
using React.Shared.Results;

namespace React.Application.Services;

public class HolidayService : IHolidayService
{
    private readonly IHolidayRepository _holidayRepository;
    private readonly ILogger<HolidayService> _logger;

    public HolidayService(
        IHolidayRepository holidayRepository,
        ILogger<HolidayService> logger)
    {
        _holidayRepository = holidayRepository ?? throw new ArgumentNullException(nameof(holidayRepository));
        _logger = logger ?? throw new ArgumentNullException(nameof(logger));
    }

    public async Task<ServiceResult<IEnumerable<HolidayResponseDto>>> GetHolidaysByYearAndMonthAsync(int year, int month)
    {
        try
        {
            if (month < 1 || month > 12)
                return ServiceResult<IEnumerable<HolidayResponseDto>>.Failure("Invalid month. Must be between 1 and 12.");

            if (year < 2000 || year > 2100)
                return ServiceResult<IEnumerable<HolidayResponseDto>>.Failure("Invalid year. Must be between 2000 and 2100.");

            var holidays = await _holidayRepository.GetHolidaysByYearAndMonthAsync(year, month);
            _logger.LogInformation("Found {Count} holidays for {Year}-{Month}", holidays.Count(), year, month);
            return ServiceResult<IEnumerable<HolidayResponseDto>>.Success(holidays);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error retrieving holidays for {Year}-{Month}", year, month);
            return ServiceResult<IEnumerable<HolidayResponseDto>>.Failure("Error retrieving holidays");
        }
    }
}
