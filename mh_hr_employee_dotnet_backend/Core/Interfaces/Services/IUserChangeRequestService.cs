using React.Core.DTOs.Request;
using React.Core.DTOs.Response;
using React.Models;
using React.Shared.Results;

namespace React.Core.Interfaces.Services;

public interface IUserChangeRequestService
{
    Task<ServiceResult<Signature>> CreateSignatureAsync(int userId, CreateSignatureRequestDto signatureDto);
    Task<ServiceResult<ChangeRequest>> CreateChangeRequestAsync(CreateUserChangeRequestDto requestDto);
    Task<ServiceResult<UserChangeRequestDetailResponseDto>> GetChangeRequestByIdAsync(int id);
    Task<ServiceResult<IEnumerable<UserChangeRequestBriefResponseDto>>> GetUserChangeRequestsAsync(int userId);
    Task<ServiceResult<bool>> RequestReturnAsync(int id);
    Task<ServiceResult<IEnumerable<UserChangeRequestFullResponseDto>>> GetAllUserChangeRequestsAsync(int userId);
}
