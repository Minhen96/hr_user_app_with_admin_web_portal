using Microsoft.EntityFrameworkCore;
using React.Core.DTOs.Response;
using React.Core.Interfaces.Repositories;
using React.Data;

namespace React.Infrastructure.Repositories;

public class BirthdayRepository : IBirthdayRepository
{
    private readonly ApplicationDbContext _context;

    public BirthdayRepository(ApplicationDbContext context)
    {
        _context = context ?? throw new ArgumentNullException(nameof(context));
    }

    public async Task<IEnumerable<BirthdayResponseDto>> GetBirthdaysByMonthAsync(int month)
    {
        return await _context.Users
            .Where(u => u.Birthday.Month == month && u.active_status == "active")
            .Select(u => new BirthdayResponseDto
            {
                FullName = u.FullName,
                BirthDate = u.Birthday,
                Department = u.Department.Name
            })
            .OrderBy(b => b.BirthDate.Day)
            .ToListAsync();
    }
}
