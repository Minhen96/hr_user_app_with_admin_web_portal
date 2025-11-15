using React.Core.DTOs.Request;
using React.Core.DTOs.Response;
using React.Shared.Results;

namespace React.Core.Interfaces.Services;

public interface ITrainingService
{
    Task<ServiceResult<IEnumerable<TrainingResponseDto>>> GetAllTrainingsAsync();
    Task<ServiceResult> UpdateTrainingStatusAsync(int id, TrainingStatusUpdateDto request);
}
