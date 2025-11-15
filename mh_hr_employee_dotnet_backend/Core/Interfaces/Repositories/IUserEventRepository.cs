using React.Models;

namespace React.Core.Interfaces.Repositories;

public interface IUserEventRepository
{
    Task<IEnumerable<Event>> GetAllEventsAsync();
    Task<IEnumerable<Event>> GetEventsByDateAsync(DateTime date);
    Task<IEnumerable<Event>> GetEventsByMonthAsync(int year, int month);
    Task<Event?> GetEventByIdAsync(int id);
    Task<Event> AddEventAsync(Event eventModel);
    Task<Event> UpdateEventAsync(Event eventModel);
    Task<bool> DeleteEventAsync(int id);
    Task<bool> EventExistsAsync(int id);
    Task<string?> GetUserNameByIdAsync(int userId);
    Task<string?> GetUserFcmTokenByIdAsync(int userId);
    Task<bool> IsEventReadByUserAsync(int eventId, int userId);
    Task<bool> MarkEventAsReadAsync(int eventId, int userId);
    Task<bool> ReadRecordExistsAsync(int eventId, int userId);
}
