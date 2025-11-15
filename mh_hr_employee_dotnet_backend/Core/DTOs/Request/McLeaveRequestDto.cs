using Microsoft.AspNetCore.Http;
using System.ComponentModel.DataAnnotations;

namespace React.Core.DTOs.Request;

public class McLeaveRequestDto
{
    public int? Userid { get; set; }

    public string? FullName { get; set; }

    public string? StartDate { get; set; } // Accept as string to avoid date parsing issues

    public string? EndDate { get; set; } // Accept as string to avoid date parsing issues

    public string? Reason { get; set; }

    public IFormFile? PdfFile { get; set; } // Optional - not all submissions may have a file

    // Additional optional fields sent by Flutter app
    public string? Date_Submission { get; set; }
    public string? Total_Day { get; set; }
    public string? Status { get; set; }
}
