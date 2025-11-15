using React.Models;

namespace React.Core.Interfaces.Repositories;

public interface IUserChangeRequestRepository
{
    Task<Signature> CreateSignatureAsync(Signature signature);
    Task<ChangeRequest> CreateChangeRequestAsync(ChangeRequest changeRequest);
    Task<ChangeRequest?> GetChangeRequestByIdAsync(int id);
    Task<IEnumerable<ChangeRequest>> GetUserChangeRequestsAsync(int userId);
    Task<bool> UpdateReturnStatusAsync(int id);
}
