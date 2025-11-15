using React.Core.DTOs.Response;

namespace React.Core.Interfaces.Repositories;

public interface ILeaveReportRepository
{
    Task<IEnumerable<AnnualLeaveReportDataDto>> GetAnnualLeaveReportDataAsync(int year);
    Task<IEnumerable<MedicalLeaveReportDataDto>> GetMedicalLeaveReportDataAsync(int year);
}
