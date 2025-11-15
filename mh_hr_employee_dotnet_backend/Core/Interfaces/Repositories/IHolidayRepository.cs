using React.Core.DTOs.Response;

namespace React.Core.Interfaces.Repositories;

public interface IHolidayRepository
{
    Task<IEnumerable<HolidayResponseDto>> GetHolidaysByYearAndMonthAsync(int year, int month);
}
