using React.Application.Helpers;
using React.Core.DTOs.Request;
using React.Core.DTOs.Response;
using React.Core.Interfaces.Repositories;
using React.Core.Interfaces.Services;
using React.Models;
using React.Shared.Results;

namespace React.Application.Services;

public class UserEventService : IUserEventService
{
    private readonly IUserEventRepository _repository;

    public UserEventService(IUserEventRepository repository)
    {
        _repository = repository ?? throw new ArgumentNullException(nameof(repository));
    }

    public async Task<ServiceResult<IEnumerable<UserEventResponseDto>>> GetAllEventsAsync(int userId)
    {
        try
        {
            var events = await _repository.GetAllEventsAsync();
            var response = new List<UserEventResponseDto>();

            foreach (var evt in events)
            {
                var userName = await _repository.GetUserNameByIdAsync(evt.user_id);
                var isRead = await _repository.IsEventReadByUserAsync(evt.id, userId);

                response.Add(new UserEventResponseDto
                {
                    Id = evt.id,
                    Title = evt.title,
                    Description = evt.description,
                    Date = evt.date,
                    UserId = evt.user_id,
                    UserName = userName,
                    CreatedAt = evt.created_at,
                    UpdatedAt = evt.updated_at,
                    IsRead = isRead
                });
            }

            return ServiceResult<IEnumerable<UserEventResponseDto>>.Success(response);
        }
        catch (Exception ex)
        {
            return ServiceResult<IEnumerable<UserEventResponseDto>>.Failure($"Error retrieving events: {ex.Message}");
        }
    }

    public async Task<ServiceResult<IEnumerable<UserEventResponseDto>>> GetEventsByDateAsync(DateTime date, int userId)
    {
        try
        {
            var events = await _repository.GetEventsByDateAsync(date);
            var response = new List<UserEventResponseDto>();

            foreach (var evt in events)
            {
                var userName = await _repository.GetUserNameByIdAsync(evt.user_id);
                var isRead = await _repository.IsEventReadByUserAsync(evt.id, userId);

                response.Add(new UserEventResponseDto
                {
                    Id = evt.id,
                    Title = evt.title,
                    Description = evt.description,
                    Date = evt.date,
                    UserId = evt.user_id,
                    UserName = userName,
                    CreatedAt = evt.created_at,
                    UpdatedAt = evt.updated_at,
                    IsRead = isRead
                });
            }

            return ServiceResult<IEnumerable<UserEventResponseDto>>.Success(response);
        }
        catch (Exception ex)
        {
            return ServiceResult<IEnumerable<UserEventResponseDto>>.Failure($"Error retrieving events by date: {ex.Message}");
        }
    }

    public async Task<ServiceResult<IEnumerable<UserEventResponseDto>>> GetEventsByMonthAsync(int year, int month, int userId)
    {
        try
        {
            var events = await _repository.GetEventsByMonthAsync(year, month);
            var response = new List<UserEventResponseDto>();

            foreach (var evt in events)
            {
                var userName = await _repository.GetUserNameByIdAsync(evt.user_id);
                var isRead = await _repository.IsEventReadByUserAsync(evt.id, userId);

                response.Add(new UserEventResponseDto
                {
                    Id = evt.id,
                    Title = evt.title,
                    Description = evt.description,
                    Date = evt.date,
                    UserId = evt.user_id,
                    UserName = userName,
                    CreatedAt = evt.created_at,
                    UpdatedAt = evt.updated_at,
                    IsRead = isRead
                });
            }

            return ServiceResult<IEnumerable<UserEventResponseDto>>.Success(response);
        }
        catch (Exception ex)
        {
            return ServiceResult<IEnumerable<UserEventResponseDto>>.Failure($"Error retrieving events by month: {ex.Message}");
        }
    }

    public async Task<ServiceResult<UserEventResponseDto>> CreateEventAsync(CreateEventRequestDto requestDto, int userId)
    {
        try
        {
            // Validate input
            if (string.IsNullOrWhiteSpace(requestDto.Title))
            {
                return ServiceResult<UserEventResponseDto>.Failure("Event title is required");
            }

            // Create event
            var eventModel = new Event
            {
                title = requestDto.Title,
                description = requestDto.Description,
                date = requestDto.Date,
                user_id = userId,
                created_at = DateTime.UtcNow,
                updated_at = DateTime.UtcNow
            };

            var createdEvent = await _repository.AddEventAsync(eventModel);

            // Get user details
            var userName = await _repository.GetUserNameByIdAsync(userId);

            // Push notifications disabled - Firebase removed
            Console.WriteLine("WARNING: Push notifications disabled - Firebase removed");

            var response = new UserEventResponseDto
            {
                Id = createdEvent.id,
                Title = createdEvent.title,
                Description = createdEvent.description,
                Date = createdEvent.date,
                UserId = createdEvent.user_id,
                UserName = userName,
                CreatedAt = createdEvent.created_at,
                UpdatedAt = createdEvent.updated_at,
                IsRead = false
            };

            return ServiceResult<UserEventResponseDto>.Success(response, "Event created successfully");
        }
        catch (Exception ex)
        {
            return ServiceResult<UserEventResponseDto>.Failure($"Error creating event: {ex.Message}");
        }
    }

    public async Task<ServiceResult<UserEventResponseDto>> UpdateEventAsync(UpdateEventRequestDto requestDto)
    {
        try
        {
            var existingEvent = await _repository.GetEventByIdAsync(requestDto.Id);
            if (existingEvent == null)
            {
                return ServiceResult<UserEventResponseDto>.Failure("Event not found");
            }

            // Update fields
            existingEvent.title = requestDto.Title;
            existingEvent.description = requestDto.Description;
            existingEvent.date = requestDto.Date;
            existingEvent.updated_at = DateTime.UtcNow;

            var updatedEvent = await _repository.UpdateEventAsync(existingEvent);
            var userName = await _repository.GetUserNameByIdAsync(updatedEvent.user_id);

            var response = new UserEventResponseDto
            {
                Id = updatedEvent.id,
                Title = updatedEvent.title,
                Description = updatedEvent.description,
                Date = updatedEvent.date,
                UserId = updatedEvent.user_id,
                UserName = userName,
                CreatedAt = updatedEvent.created_at,
                UpdatedAt = updatedEvent.updated_at,
                IsRead = false
            };

            return ServiceResult<UserEventResponseDto>.Success(response, "Event updated successfully");
        }
        catch (Exception ex)
        {
            return ServiceResult<UserEventResponseDto>.Failure($"Error updating event: {ex.Message}");
        }
    }

    public async Task<ServiceResult<bool>> DeleteEventAsync(int id)
    {
        try
        {
            var success = await _repository.DeleteEventAsync(id);
            if (!success)
            {
                return ServiceResult<bool>.Failure("Event not found");
            }

            return ServiceResult<bool>.Success(true, "Event deleted successfully");
        }
        catch (Exception ex)
        {
            return ServiceResult<bool>.Failure($"Error deleting event: {ex.Message}");
        }
    }

    public async Task<ServiceResult<bool>> MarkEventAsReadAsync(int eventId, int userId)
    {
        try
        {
            // Check if event exists
            var eventExists = await _repository.EventExistsAsync(eventId);
            if (!eventExists)
            {
                return ServiceResult<bool>.Failure("Event not found");
            }

            // Check if already marked as read
            var recordExists = await _repository.ReadRecordExistsAsync(eventId, userId);
            if (recordExists)
            {
                return ServiceResult<bool>.Success(true, "Event already marked as read");
            }

            // Mark as read
            await _repository.MarkEventAsReadAsync(eventId, userId);
            return ServiceResult<bool>.Success(true, "Event marked as read");
        }
        catch (Exception ex)
        {
            return ServiceResult<bool>.Failure($"Error marking event as read: {ex.Message}");
        }
    }

    public async Task<ServiceResult<EventReadStatusResponseDto>> GetEventReadStatusAsync(int eventId, int userId)
    {
        try
        {
            // Check if event exists
            var eventExists = await _repository.EventExistsAsync(eventId);
            if (!eventExists)
            {
                return ServiceResult<EventReadStatusResponseDto>.Failure("Event not found");
            }

            var isRead = await _repository.IsEventReadByUserAsync(eventId, userId);
            var response = new EventReadStatusResponseDto { IsRead = isRead };

            return ServiceResult<EventReadStatusResponseDto>.Success(response);
        }
        catch (Exception ex)
        {
            return ServiceResult<EventReadStatusResponseDto>.Failure($"Error getting read status: {ex.Message}");
        }
    }
}
