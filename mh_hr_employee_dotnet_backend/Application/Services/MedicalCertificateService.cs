using Microsoft.Extensions.Logging;
using React.Core.DTOs.Request;
using React.Core.DTOs.Response;
using React.Core.Interfaces.Repositories;
using React.Core.Interfaces.Services;
using React.Models;
using React.Shared.Results;

namespace React.Application.Services;

public class MedicalCertificateService : IMedicalCertificateService
{
    private readonly IMedicalCertificateRepository _repository;
    private readonly ILogger<MedicalCertificateService> _logger;

    public MedicalCertificateService(
        IMedicalCertificateRepository repository,
        ILogger<MedicalCertificateService> logger)
    {
        _repository = repository ?? throw new ArgumentNullException(nameof(repository));
        _logger = logger ?? throw new ArgumentNullException(nameof(logger));
    }

    public async Task<ServiceResult<bool>> SubmitLeaveRequestAsync(McLeaveRequestDto request)
    {
        try
        {
            // Validate required fields
            if (!request.Userid.HasValue)
                return ServiceResult<bool>.Failure("User ID is required");

            if (string.IsNullOrWhiteSpace(request.FullName))
                return ServiceResult<bool>.Failure("Full name is required");

            if (string.IsNullOrWhiteSpace(request.StartDate))
                return ServiceResult<bool>.Failure("Start date is required");

            if (string.IsNullOrWhiteSpace(request.EndDate))
                return ServiceResult<bool>.Failure("End date is required");

            if (string.IsNullOrWhiteSpace(request.Reason))
                return ServiceResult<bool>.Failure("Reason is required");

            _logger.LogInformation("Submitting MC leave request for user {UserId}", request.Userid);

            // Parse dates
            if (!DateTime.TryParse(request.StartDate, out DateTime startDate))
                return ServiceResult<bool>.Failure("Invalid start date format");

            if (!DateTime.TryParse(request.EndDate, out DateTime endDate))
                return ServiceResult<bool>.Failure("Invalid end date format");

            if (startDate > endDate)
                return ServiceResult<bool>.Failure("Start date cannot be later than end date");

            var totalDays = (endDate - startDate).Days + 1;

            byte[]? pdfBytes = null;
            if (request.PdfFile != null)
            {
                using var memoryStream = new MemoryStream();
                await request.PdfFile.CopyToAsync(memoryStream);
                pdfBytes = memoryStream.ToArray();
            }

            var leaveRequest = new LeaveRequest
            {
                id = request.Userid.Value,
                full_name = request.FullName,
                start_date = startDate,
                end_date = endDate,
                total_day = totalDays,
                reason = request.Reason,
                url = pdfBytes
            };

            await _repository.AddLeaveRequestAsync(leaveRequest);

            _logger.LogInformation("MC leave request submitted successfully for user {UserId}", request.Userid);
            return ServiceResult<bool>.Success(true);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error submitting MC leave request for user {UserId}", request.Userid);
            return ServiceResult<bool>.Failure($"Error submitting leave request: {ex.Message}");
        }
    }


    public async Task<ServiceResult<IEnumerable<McLeaveResponseDto>>> GetAllLeavesAsync()
    {
        try
        {
            _logger.LogInformation("Retrieving all MC leaves");

            var leaves = await _repository.GetAllLeavesAsync();

            if (!leaves.Any())
            {
                _logger.LogInformation("No MC leaves found");
                return ServiceResult<IEnumerable<McLeaveResponseDto>>.Failure("No leaves found");
            }

            _logger.LogInformation("Retrieved {Count} MC leaves", leaves.Count());
            return ServiceResult<IEnumerable<McLeaveResponseDto>>.Success(leaves);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error retrieving all MC leaves");
            return ServiceResult<IEnumerable<McLeaveResponseDto>>.Failure(
                $"Error retrieving leaves: {ex.Message}");
        }
    }

    public async Task<ServiceResult<IEnumerable<McLeaveResponseDto>>> GetPendingLeavesByUserIdAsync(int userId)
    {
        try
        {
            _logger.LogInformation("Retrieving pending MC leaves for user {UserId}", userId);

            var leaves = await _repository.GetPendingLeavesByUserIdAsync(userId);

            if (!leaves.Any())
            {
                _logger.LogInformation("No pending MC leaves found for user {UserId}", userId);
                // Return empty array instead of failure - better UX
                return ServiceResult<IEnumerable<McLeaveResponseDto>>.Success(new List<McLeaveResponseDto>());
            }

            _logger.LogInformation("Retrieved {Count} pending MC leaves for user {UserId}",
                leaves.Count(), userId);
            return ServiceResult<IEnumerable<McLeaveResponseDto>>.Success(leaves);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error retrieving pending MC leaves for user {UserId}", userId);
            return ServiceResult<IEnumerable<McLeaveResponseDto>>.Failure(
                $"Error retrieving pending leaves: {ex.Message}");
        }
    }

    public async Task<ServiceResult<IEnumerable<McLeaveResponseDto>>> GetApprovedLeavesByUserIdAsync(int userId)
    {
        try
        {
            _logger.LogInformation("Retrieving approved/rejected MC leaves for user {UserId}", userId);

            var leaves = await _repository.GetApprovedLeavesByUserIdAsync(userId);

            if (!leaves.Any())
            {
                _logger.LogInformation("No approved/rejected MC leaves found for user {UserId}", userId);
                // Return empty array instead of failure - better UX
                return ServiceResult<IEnumerable<McLeaveResponseDto>>.Success(new List<McLeaveResponseDto>());
            }

            _logger.LogInformation("Retrieved {Count} approved/rejected MC leaves for user {UserId}",
                leaves.Count(), userId);
            return ServiceResult<IEnumerable<McLeaveResponseDto>>.Success(leaves);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error retrieving approved/rejected MC leaves for user {UserId}", userId);
            return ServiceResult<IEnumerable<McLeaveResponseDto>>.Failure(
                $"Error retrieving approved/rejected leaves: {ex.Message}");
        }
    }

    private byte[]? ConvertToByteArray(Microsoft.AspNetCore.Http.IFormFile? file)
    {
        if (file == null) return null;

        using var ms = new MemoryStream();
        file.CopyTo(ms);
        return ms.ToArray();
    }
}
