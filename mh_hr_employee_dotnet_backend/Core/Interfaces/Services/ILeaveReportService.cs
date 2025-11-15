using React.Shared.Results;

namespace React.Core.Interfaces.Services;

public interface ILeaveReportService
{
    Task<ServiceResult<byte[]>> GenerateAnnualLeaveReportPdfAsync();
    Task<ServiceResult<byte[]>> GenerateMedicalLeaveReportPdfAsync();
}
