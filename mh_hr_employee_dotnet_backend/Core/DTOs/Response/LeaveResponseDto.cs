namespace React.Core.DTOs.Response;

public class LeaveResponseDto
{
    public int Id { get; set; }
    public DateTime LeaveDate { get; set; }
    public double NumberOfDays { get; set; }
    public string Reason { get; set; } = string.Empty;
    public string Status { get; set; } = string.Empty;
    public int? ApprovedBy { get; set; }
    public int? ApprovalSignatureId { get; set; }
    public UserInfoDto User { get; set; } = new();
}

public class MedicalLeaveResponseDto
{
    public int Id { get; set; }
    public DateTime LeaveDate { get; set; }
    public DateTime EndDate { get; set; }
    public DateTime? DateSubmission { get; set; }
    public int NumberOfDays { get; set; }
    public string Reason { get; set; } = string.Empty;
    public string Status { get; set; } = string.Empty;
    public int? ApprovedBy { get; set; }
    public int? ApprovalSignatureId { get; set; }
    public string? DocumentUrl { get; set; }
    public UserInfoDto User { get; set; } = new();
}

public class UserInfoDto
{
    public int Id { get; set; }
    public string FullName { get; set; } = string.Empty;
    public string NRIC { get; set; } = string.Empty;
    public DepartmentInfoDto Department { get; set; } = new();
}

public class DepartmentInfoDto
{
    public int Id { get; set; }
    public string Name { get; set; } = string.Empty;
}
