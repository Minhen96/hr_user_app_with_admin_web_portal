using React.Core.DTOs.Response;
using React.Shared.Results;

namespace React.Core.Interfaces.Services;

public interface IHolidayService
{
    Task<ServiceResult<IEnumerable<HolidayResponseDto>>> GetHolidaysByYearAndMonthAsync(int year, int month);
}
