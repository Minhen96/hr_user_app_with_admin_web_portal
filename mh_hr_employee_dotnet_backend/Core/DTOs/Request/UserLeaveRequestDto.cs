using System.Text.Json.Serialization;

namespace React.Core.DTOs.Request;

public class SubmitLeaveRequestDto
{
    [JsonPropertyName("annual_leave_id")]
    public int AnnualLeaveId { get; set; }

    [JsonPropertyName("leave_date")]
    public DateTime LeaveDate { get; set; }

    [JsonPropertyName("leave_end_date")]
    public DateTime LeaveEndDate { get; set; }

    [JsonPropertyName("reason")]
    public string Reason { get; set; } = string.Empty;

    [JsonPropertyName("no_of_days")]
    public double NoOfDays { get; set; }
}

public class UpdateLeaveRequestDto
{
    public int Id { get; set; }
    public int LeaveId { get; set; }  // annual_leave_id
    public DateTime LeaveDate { get; set; }
    public DateTime LeaveEndDate { get; set; }
    public double NoOfDays { get; set; }
    public string Reason { get; set; } = string.Empty;
}
