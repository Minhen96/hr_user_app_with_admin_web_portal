using React.Core.DTOs.Request;
using React.Core.DTOs.Response;
using React.Shared.Results;

namespace React.Core.Interfaces.Services;

public interface IAttendanceService
{
    Task<ServiceResult<AttendanceResponseDto>> TimeInAsync(AttendanceTimeInRequestDto request);
    Task<ServiceResult> TimeOutAsync(int id, AttendanceTimeOutRequestDto request);
    Task<ServiceResult<IEnumerable<AttendanceResponseDto>>> GetCurrentDaySubmissionsAsync(int userId);
    Task<ServiceResult<IEnumerable<AttendanceResponseDto>>> GetMonthlyAttendanceAsync(int userId, int? month, int? year);
}
