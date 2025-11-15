using iTextSharp.text;
using iTextSharp.text.pdf;
using Microsoft.Extensions.Logging;
using React.Core.Interfaces.Repositories;
using React.Core.Interfaces.Services;
using React.Shared.Results;

namespace React.Application.Services;

public class LeaveReportService : ILeaveReportService
{
    private readonly ILeaveReportRepository _leaveReportRepository;
    private readonly ILogger<LeaveReportService> _logger;

    public LeaveReportService(
        ILeaveReportRepository leaveReportRepository,
        ILogger<LeaveReportService> logger)
    {
        _leaveReportRepository = leaveReportRepository ?? throw new ArgumentNullException(nameof(leaveReportRepository));
        _logger = logger ?? throw new ArgumentNullException(nameof(logger));
    }

    public async Task<ServiceResult<byte[]>> GenerateAnnualLeaveReportPdfAsync()
    {
        try
        {
            int currentYear = DateTime.Now.Year;
            var reportData = await _leaveReportRepository.GetAnnualLeaveReportDataAsync(currentYear);

            using var ms = new MemoryStream();
            using (var document = new Document(PageSize.A4.Rotate()))
            {
                PdfWriter.GetInstance(document, ms);
                document.Open();

                // Add title
                document.Add(new Paragraph($"Annual Leave Report {currentYear}"));
                document.Add(new Paragraph($"Generated on: {DateTime.Now:dd/MM/yyyy}"));
                document.Add(new Paragraph(" ")); // Spacing

                // Create table
                var table = new PdfPTable(16); // 16 columns
                table.SetWidths(new float[] { 3, 1.5f, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1.5f, 1.5f });

                // Add headers
                string[] headers = { "Name", "Entitlement", "Jan", "Feb", "Mar", "Apr", "May", "Jun",
                                   "Jul", "Aug", "Sep", "Oct", "Nov", "Dec", "Total", "Balance" };
                foreach (string header in headers)
                {
                    table.AddCell(new PdfPCell(new Phrase(header)) { BackgroundColor = BaseColor.LIGHT_GRAY });
                }

                // Add data
                foreach (var row in reportData)
                {
                    table.AddCell(row.FullName);
                    table.AddCell(row.Entitlement.ToString());
                    table.AddCell(row.Jan.ToString("0.#"));
                    table.AddCell(row.Feb.ToString("0.#"));
                    table.AddCell(row.Mar.ToString("0.#"));
                    table.AddCell(row.Apr.ToString("0.#"));
                    table.AddCell(row.May.ToString("0.#"));
                    table.AddCell(row.Jun.ToString("0.#"));
                    table.AddCell(row.Jul.ToString("0.#"));
                    table.AddCell(row.Aug.ToString("0.#"));
                    table.AddCell(row.Sep.ToString("0.#"));
                    table.AddCell(row.Oct.ToString("0.#"));
                    table.AddCell(row.Nov.ToString("0.#"));
                    table.AddCell(row.Dec.ToString("0.#"));
                    table.AddCell(row.TotalTaken.ToString("0.#"));
                    table.AddCell(row.Balance.ToString("0.#"));
                }

                document.Add(table);
                document.Close();
            }

            _logger.LogInformation("Annual leave report generated successfully");
            return ServiceResult<byte[]>.Success(ms.ToArray(), "Report generated successfully");
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error generating annual leave report");
            return ServiceResult<byte[]>.Failure("Error generating report");
        }
    }

    public async Task<ServiceResult<byte[]>> GenerateMedicalLeaveReportPdfAsync()
    {
        try
        {
            int currentYear = DateTime.Now.Year;
            var reportData = await _leaveReportRepository.GetMedicalLeaveReportDataAsync(currentYear);

            using var ms = new MemoryStream();
            using (var document = new Document(PageSize.A4.Rotate()))
            {
                PdfWriter.GetInstance(document, ms);
                document.Open();

                // Add title
                document.Add(new Paragraph($"Medical Leave Report {currentYear}"));
                document.Add(new Paragraph($"Generated on: {DateTime.Now:dd/MM/yyyy}"));
                document.Add(new Paragraph(" ")); // Spacing

                // Create table
                var table = new PdfPTable(14); // 14 columns
                table.SetWidths(new float[] { 3, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1.5f });

                // Add headers
                string[] headers = { "Name", "Jan", "Feb", "Mar", "Apr", "May", "Jun",
                               "Jul", "Aug", "Sep", "Oct", "Nov", "Dec", "Total" };
                foreach (string header in headers)
                {
                    table.AddCell(new PdfPCell(new Phrase(header)) { BackgroundColor = BaseColor.LIGHT_GRAY });
                }

                // Add data
                foreach (var row in reportData)
                {
                    table.AddCell(row.FullName);
                    table.AddCell(row.Jan.ToString());
                    table.AddCell(row.Feb.ToString());
                    table.AddCell(row.Mar.ToString());
                    table.AddCell(row.Apr.ToString());
                    table.AddCell(row.May.ToString());
                    table.AddCell(row.Jun.ToString());
                    table.AddCell(row.Jul.ToString());
                    table.AddCell(row.Aug.ToString());
                    table.AddCell(row.Sep.ToString());
                    table.AddCell(row.Oct.ToString());
                    table.AddCell(row.Nov.ToString());
                    table.AddCell(row.Dec.ToString());
                    table.AddCell(row.TotalTaken.ToString());
                }

                document.Add(table);
                document.Close();
            }

            _logger.LogInformation("Medical leave report generated successfully");
            return ServiceResult<byte[]>.Success(ms.ToArray(), "Report generated successfully");
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error generating medical leave report");
            return ServiceResult<byte[]>.Failure("Error generating report");
        }
    }
}
