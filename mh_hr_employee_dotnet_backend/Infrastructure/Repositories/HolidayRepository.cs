using Microsoft.EntityFrameworkCore;
using React.Core.DTOs.Response;
using React.Core.Interfaces.Repositories;
using React.Data;

namespace React.Infrastructure.Repositories;

public class HolidayRepository : IHolidayRepository
{
    private readonly ApplicationDbContext _context;

    public HolidayRepository(ApplicationDbContext context)
    {
        _context = context ?? throw new ArgumentNullException(nameof(context));
    }

    public async Task<IEnumerable<HolidayResponseDto>> GetHolidaysByYearAndMonthAsync(int year, int month)
    {
        return await _context.Holidays
            .Where(h => h.HolidayDate.Year == year && h.HolidayDate.Month == month)
            .Select(h => new HolidayResponseDto
            {
                HolidayDate = h.HolidayDate,
                HolidayName = h.HolidayName
            })
            .ToListAsync();
    }
}
