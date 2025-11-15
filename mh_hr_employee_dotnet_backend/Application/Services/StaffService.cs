using Microsoft.Extensions.Logging;
using React.Core.DTOs.Response;
using React.Core.Interfaces.Repositories;
using React.Core.Interfaces.Services;
using React.Shared.Results;

namespace React.Application.Services;

public class StaffService : IStaffService
{
    private readonly IStaffRepository _staffRepository;
    private readonly ILogger<StaffService> _logger;

    public StaffService(IStaffRepository staffRepository, ILogger<StaffService> logger)
    {
        _staffRepository = staffRepository ?? throw new ArgumentNullException(nameof(staffRepository));
        _logger = logger ?? throw new ArgumentNullException(nameof(logger));
    }

    public async Task<ServiceResult<IEnumerable<StaffResponseDto>>> GetAllStaffAsync()
    {
        try
        {
            var staff = await _staffRepository.GetAllStaffAsync();
            return ServiceResult<IEnumerable<StaffResponseDto>>.Success(staff);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error retrieving staff");
            return ServiceResult<IEnumerable<StaffResponseDto>>.Failure("Error retrieving staff");
        }
    }

    public async Task<ServiceResult<StaffLeaveDetailsDto>> GetStaffLeaveDetailsAsync(int userId)
    {
        try
        {
            var details = await _staffRepository.GetStaffLeaveDetailsAsync(userId);
            if (details == null)
                return ServiceResult<StaffLeaveDetailsDto>.Failure("Staff leave details not found");

            return ServiceResult<StaffLeaveDetailsDto>.Success(details);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error retrieving staff leave details for user {UserId}", userId);
            return ServiceResult<StaffLeaveDetailsDto>.Failure("Error retrieving leave details");
        }
    }
}
