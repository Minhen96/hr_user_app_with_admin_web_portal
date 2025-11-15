using Microsoft.AspNetCore.Http;

namespace React.Core.DTOs.Request;

public class AttendanceTimeInRequestDto
{
    public string Name { get; set; } = string.Empty;
    public IFormFile? TimeInPhoto { get; set; }
    public string PlaceName { get; set; } = string.Empty;
    public int UserId { get; set; }
}

public class AttendanceTimeOutRequestDto
{
    public IFormFile? TimeOutPhoto { get; set; }
}
