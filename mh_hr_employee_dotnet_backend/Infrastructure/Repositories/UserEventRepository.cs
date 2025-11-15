using Microsoft.EntityFrameworkCore;
using React.Core.Interfaces.Repositories;
using React.Data;
using React.Models;

namespace React.Infrastructure.Repositories;

public class UserEventRepository : IUserEventRepository
{
    private readonly ApplicationDbContext _context;

    public UserEventRepository(ApplicationDbContext context)
    {
        _context = context ?? throw new ArgumentNullException(nameof(context));
    }

    public async Task<IEnumerable<Event>> GetAllEventsAsync()
    {
        return await _context.Events
            .OrderByDescending(e => e.date)
            .ToListAsync();
    }

    public async Task<IEnumerable<Event>> GetEventsByDateAsync(DateTime date)
    {
        return await _context.Events
            .Where(e => e.date.Date == date.Date)
            .OrderBy(e => e.date)
            .ToListAsync();
    }

    public async Task<IEnumerable<Event>> GetEventsByMonthAsync(int year, int month)
    {
        return await _context.Events
            .Where(e => e.date.Year == year && e.date.Month == month)
            .OrderBy(e => e.date)
            .ToListAsync();
    }

    public async Task<Event?> GetEventByIdAsync(int id)
    {
        return await _context.Events.FindAsync(id);
    }

    public async Task<Event> AddEventAsync(Event eventModel)
    {
        _context.Events.Add(eventModel);
        await _context.SaveChangesAsync();
        return eventModel;
    }

    public async Task<Event> UpdateEventAsync(Event eventModel)
    {
        _context.Events.Update(eventModel);
        await _context.SaveChangesAsync();
        return eventModel;
    }

    public async Task<bool> DeleteEventAsync(int id)
    {
        var eventModel = await _context.Events.FindAsync(id);
        if (eventModel == null)
            return false;

        _context.Events.Remove(eventModel);
        await _context.SaveChangesAsync();
        return true;
    }

    public async Task<bool> EventExistsAsync(int id)
    {
        return await _context.Events.AnyAsync(e => e.id == id);
    }

    public async Task<string?> GetUserNameByIdAsync(int userId)
    {
        var user = await _context.Users.FirstOrDefaultAsync(u => u.Id == userId);
        return user?.FullName;
    }

    public async Task<string?> GetUserFcmTokenByIdAsync(int userId)
    {
        var user = await _context.Users.FirstOrDefaultAsync(u => u.Id == userId);
        return user?.FcmToken;
    }

    public async Task<bool> IsEventReadByUserAsync(int eventId, int userId)
    {
        return await _context.DocumentReads
            .AnyAsync(r => r.DocId == eventId && r.UserId == userId);
    }

    public async Task<bool> MarkEventAsReadAsync(int eventId, int userId)
    {
        var documentRead = new DocumentRead
        {
            DocId = eventId,
            UserId = userId,
            ReadDate = DateTime.UtcNow
        };

        _context.DocumentReads.Add(documentRead);
        await _context.SaveChangesAsync();
        return true;
    }

    public async Task<bool> ReadRecordExistsAsync(int eventId, int userId)
    {
        return await _context.DocumentReads
            .AnyAsync(r => r.DocId == eventId && r.UserId == userId);
    }
}
