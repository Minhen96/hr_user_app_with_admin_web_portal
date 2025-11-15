using React.Core.DTOs.Response;
using React.Shared.Results;

namespace React.Core.Interfaces.Services;

public interface IBirthdayService
{
    Task<ServiceResult<IEnumerable<BirthdayResponseDto>>> GetBirthdaysByMonthAsync(int month);
}
