using React.Core.DTOs.Response;

namespace React.Core.Interfaces.Repositories;

public interface IBirthdayRepository
{
    Task<IEnumerable<BirthdayResponseDto>> GetBirthdaysByMonthAsync(int month);
}
