namespace React.Core.DTOs.Response;

public class StaffResponseDto
{
    public int Id { get; set; }
    public string FullName { get; set; } = string.Empty;
    public string Nric { get; set; } = string.Empty;
    public string? Tin { get; set; }
    public string? Epf { get; set; }
    public string Department { get; set; } = string.Empty;
    public string Email { get; set; } = string.Empty;
    public string Role { get; set; } = string.Empty;
    public DateTime DateJoined { get; set; }
    public DateOnly Birthday { get; set; }
    public string ActiveStatus { get; set; } = string.Empty;
}

public class StaffLeaveDetailsDto
{
    public int Entitlement { get; set; }
    public float Taken { get; set; }
    public float Balance { get; set; }
    public List<StaffLeaveRecordDto> Leaves { get; set; } = new();
    public List<StaffLeaveRecordDto> MedicalLeaves { get; set; } = new();
}

public class StaffLeaveRecordDto
{
    public int Id { get; set; }
    public DateTime LeaveDate { get; set; }
    public DateTime EndDate { get; set; }
    public float NumberOfDays { get; set; }
    public string Reason { get; set; } = string.Empty;
    public string Status { get; set; } = string.Empty;
}
