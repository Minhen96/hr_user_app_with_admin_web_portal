using React.Models;

namespace React.Core.Interfaces.Repositories;

public interface IAttendanceRepository
{
    Task<Attendance> CreateTimeInAsync(Attendance attendance);
    Task<Attendance?> GetByIdAsync(int id);
    Task<bool> UpdateTimeOutAsync(int id, byte[] timeOutPhoto);
    Task<IEnumerable<Attendance>> GetCurrentDaySubmissionsAsync(int userId);
    Task<IEnumerable<Attendance>> GetMonthlyAttendanceAsync(int userId, int month, int year);
}
