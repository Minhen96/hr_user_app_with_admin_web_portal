using Microsoft.Extensions.Logging;
using React.Core.DTOs.Request;
using React.Core.DTOs.Response;
using React.Core.Interfaces.Repositories;
using React.Core.Interfaces.Services;
using React.Shared.Results;

namespace React.Application.Services;

public class TrainingService : ITrainingService
{
    private readonly ITrainingRepository _trainingRepository;
    private readonly ILogger<TrainingService> _logger;

    public TrainingService(ITrainingRepository trainingRepository, ILogger<TrainingService> logger)
    {
        _trainingRepository = trainingRepository ?? throw new ArgumentNullException(nameof(trainingRepository));
        _logger = logger ?? throw new ArgumentNullException(nameof(logger));
    }

    public async Task<ServiceResult<IEnumerable<TrainingResponseDto>>> GetAllTrainingsAsync()
    {
        try
        {
            var trainings = await _trainingRepository.GetAllTrainingsAsync();
            return ServiceResult<IEnumerable<TrainingResponseDto>>.Success(trainings);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error retrieving trainings");
            return ServiceResult<IEnumerable<TrainingResponseDto>>.Failure("Error retrieving trainings");
        }
    }

    public async Task<ServiceResult> UpdateTrainingStatusAsync(int id, TrainingStatusUpdateDto request)
    {
        try
        {
            var success = await _trainingRepository.UpdateTrainingStatusAsync(
                id, request.Status, request.ApproverId, request.DateApproved);

            if (!success)
                return ServiceResult.Failure("Training not found");

            _logger.LogInformation("Training {Id} status updated to {Status}", id, request.Status);
            return ServiceResult.Success($"Training status updated to {request.Status}");
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error updating training status for ID {Id}", id);
            return ServiceResult.Failure("Error updating training status");
        }
    }
}
