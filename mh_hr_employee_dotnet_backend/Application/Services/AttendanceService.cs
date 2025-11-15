using Microsoft.Extensions.Logging;
using React.Core.DTOs.Request;
using React.Core.DTOs.Response;
using React.Core.Interfaces.Repositories;
using React.Core.Interfaces.Services;
using React.Models;
using React.Shared.Results;

namespace React.Application.Services;

public class AttendanceService : IAttendanceService
{
    private readonly IAttendanceRepository _attendanceRepository;
    private readonly ILogger<AttendanceService> _logger;

    public AttendanceService(IAttendanceRepository attendanceRepository, ILogger<AttendanceService> logger)
    {
        _attendanceRepository = attendanceRepository ?? throw new ArgumentNullException(nameof(attendanceRepository));
        _logger = logger ?? throw new ArgumentNullException(nameof(logger));
    }

    public async Task<ServiceResult<AttendanceResponseDto>> TimeInAsync(AttendanceTimeInRequestDto request)
    {
        try
        {
            if (request.TimeInPhoto == null)
                return ServiceResult<AttendanceResponseDto>.Failure("Time in photo is required");

            var timeInPhotoBytes = await ConvertIFormFileToByteArrayAsync(request.TimeInPhoto);

            var attendance = new Attendance
            {
                name = request.Name,
                time_in = DateTime.Now,
                time_in_photo = timeInPhotoBytes,
                date_submission = DateTime.Now.Date,
                placename = request.PlaceName,
                user_id = request.UserId
            };

            var created = await _attendanceRepository.CreateTimeInAsync(attendance);

            var response = MapToDto(created);
            return ServiceResult<AttendanceResponseDto>.Success(response);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error during time in for user {UserId}", request.UserId);
            return ServiceResult<AttendanceResponseDto>.Failure("Error during time in");
        }
    }

    public async Task<ServiceResult> TimeOutAsync(int id, AttendanceTimeOutRequestDto request)
    {
        try
        {
            if (request.TimeOutPhoto == null)
                return ServiceResult.Failure("Time out photo is required");

            var timeOutPhotoBytes = await ConvertIFormFileToByteArrayAsync(request.TimeOutPhoto);

            var success = await _attendanceRepository.UpdateTimeOutAsync(id, timeOutPhotoBytes);
            if (!success)
                return ServiceResult.Failure("Attendance record not found");

            return ServiceResult.Success("Time out recorded successfully");
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error during time out for attendance {Id}", id);
            return ServiceResult.Failure("Error during time out");
        }
    }

    public async Task<ServiceResult<IEnumerable<AttendanceResponseDto>>> GetCurrentDaySubmissionsAsync(int userId)
    {
        try
        {
            var attendances = await _attendanceRepository.GetCurrentDaySubmissionsAsync(userId);
            var dtos = attendances.Select(MapToDto);
            return ServiceResult<IEnumerable<AttendanceResponseDto>>.Success(dtos);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error retrieving current day submissions for user {UserId}", userId);
            return ServiceResult<IEnumerable<AttendanceResponseDto>>.Failure("Error retrieving attendance");
        }
    }

    public async Task<ServiceResult<IEnumerable<AttendanceResponseDto>>> GetMonthlyAttendanceAsync(int userId, int? month, int? year)
    {
        try
        {
            var targetMonth = month ?? DateTime.Now.Month;
            var targetYear = year ?? DateTime.Now.Year;

            var attendances = await _attendanceRepository.GetMonthlyAttendanceAsync(userId, targetMonth, targetYear);
            var dtos = attendances.Select(MapToDto);
            return ServiceResult<IEnumerable<AttendanceResponseDto>>.Success(dtos);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error retrieving monthly attendance for user {UserId}", userId);
            return ServiceResult<IEnumerable<AttendanceResponseDto>>.Failure("Error retrieving monthly attendance");
        }
    }

    private async Task<byte[]> ConvertIFormFileToByteArrayAsync(Microsoft.AspNetCore.Http.IFormFile file)
    {
        using var memoryStream = new MemoryStream();
        await file.CopyToAsync(memoryStream);
        return memoryStream.ToArray();
    }

    private AttendanceResponseDto MapToDto(Attendance attendance)
    {
        return new AttendanceResponseDto
        {
            Id = attendance.id,
            Name = attendance.name,
            TimeIn = attendance.time_in,
            TimeOut = attendance.time_out,
            DateSubmission = attendance.date_submission,
            PlaceName = attendance.placename,
            UserId = attendance.user_id,
            TimeInPhoto = attendance.time_in_photo != null ? Convert.ToBase64String(attendance.time_in_photo) : null,
            TimeOutPhoto = attendance.time_out_photo != null ? Convert.ToBase64String(attendance.time_out_photo) : null
        };
    }
}
