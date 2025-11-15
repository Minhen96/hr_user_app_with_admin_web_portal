using Microsoft.EntityFrameworkCore;
using React.Core.Interfaces.Repositories;
using React.Data;
using React.Models;

namespace React.Infrastructure.Repositories;

public class AttendanceRepository : IAttendanceRepository
{
    private readonly ApplicationDbContext _context;

    public AttendanceRepository(ApplicationDbContext context)
    {
        _context = context ?? throw new ArgumentNullException(nameof(context));
    }

    public async Task<Attendance> CreateTimeInAsync(Attendance attendance)
    {
        _context.Attendances.Add(attendance);
        await _context.SaveChangesAsync();
        return attendance;
    }

    public async Task<Attendance?> GetByIdAsync(int id)
    {
        return await _context.Attendances.FindAsync(id);
    }

    public async Task<bool> UpdateTimeOutAsync(int id, byte[] timeOutPhoto)
    {
        var attendance = await _context.Attendances.FindAsync(id);
        if (attendance == null)
            return false;

        attendance.time_out = DateTime.Now;
        attendance.time_out_photo = timeOutPhoto;

        _context.Entry(attendance).State = EntityState.Modified;
        await _context.SaveChangesAsync();
        return true;
    }

    public async Task<IEnumerable<Attendance>> GetCurrentDaySubmissionsAsync(int userId)
    {
        var today = DateTime.Today;
        return await _context.Attendances
            .Where(a => a.date_submission.Date == today && a.user_id == userId)
            .ToListAsync();
    }

    public async Task<IEnumerable<Attendance>> GetMonthlyAttendanceAsync(int userId, int month, int year)
    {
        var firstDay = new DateTime(year, month, 1);
        var lastDay = firstDay.AddMonths(1).AddDays(-1);

        return await _context.Attendances
            .Where(a => a.date_submission.Date >= firstDay &&
                       a.date_submission.Date <= lastDay &&
                       a.user_id == userId)
            .OrderBy(a => a.date_submission)
            .ToListAsync();
    }
}
