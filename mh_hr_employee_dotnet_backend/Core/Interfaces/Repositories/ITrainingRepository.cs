using React.Core.DTOs.Response;

namespace React.Core.Interfaces.Repositories;

public interface ITrainingRepository
{
    Task<IEnumerable<TrainingResponseDto>> GetAllTrainingsAsync();
    Task<bool> UpdateTrainingStatusAsync(int id, string status, int approverId, DateTime dateApproved);
}
