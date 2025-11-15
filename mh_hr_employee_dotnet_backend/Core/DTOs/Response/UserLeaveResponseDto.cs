namespace React.Core.DTOs.Response;

public class LeaveEntitlementResponseDto
{
    public int Entitlement { get; set; }
    public int AnnualLeaveId { get; set; }
}

public class UserLeaveDetailResponseDto
{
    public int Id { get; set; }
    public DateTime LeaveDate { get; set; }
    public DateTime LeaveEndDate { get; set; }
    public DateTime DateSubmission { get; set; }
    public string Status { get; set; } = string.Empty;
    public string Reason { get; set; } = string.Empty;
    public int AnnualLeaveId { get; set; }
    public double NoOfDays { get; set; }
}

public class ApprovedLeaveResponseDto
{
    public DateTime LeaveDate { get; set; }
    public DateTime LeaveEndDate { get; set; }
    public DateTime DateSubmission { get; set; }
    public string Status { get; set; } = string.Empty;
    public string Reason { get; set; } = string.Empty;
    public int AnnualLeaveId { get; set; }
    public double NoOfDays { get; set; }
}
