using React.Core.DTOs.Request;
using React.Core.DTOs.Response;
using React.Shared.Results;

namespace React.Core.Interfaces.Services;

public interface IUserEventService
{
    Task<ServiceResult<IEnumerable<UserEventResponseDto>>> GetAllEventsAsync(int userId);
    Task<ServiceResult<IEnumerable<UserEventResponseDto>>> GetEventsByDateAsync(DateTime date, int userId);
    Task<ServiceResult<IEnumerable<UserEventResponseDto>>> GetEventsByMonthAsync(int year, int month, int userId);
    Task<ServiceResult<UserEventResponseDto>> CreateEventAsync(CreateEventRequestDto requestDto, int userId);
    Task<ServiceResult<UserEventResponseDto>> UpdateEventAsync(UpdateEventRequestDto requestDto);
    Task<ServiceResult<bool>> DeleteEventAsync(int id);
    Task<ServiceResult<bool>> MarkEventAsReadAsync(int eventId, int userId);
    Task<ServiceResult<EventReadStatusResponseDto>> GetEventReadStatusAsync(int eventId, int userId);
}
