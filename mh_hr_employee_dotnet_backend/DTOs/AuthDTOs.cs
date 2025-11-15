namespace React.DTOs
{
    public class RegisterModel
    {
        public required string FullName { get; set; }
        public required string Email { get; set; }
        public required string Password { get; set; }
        public required string NRIC { get; set; }
        public required int DepartmentId { get; set; }
        public DateTime Birthday { get; set; }
        public string? TIN { get; set; }
        public string? EPFNo { get; set; }
        public string? contactNumber { get; set; }
    }

    public class LoginModel
    {
        public required string Email { get; set; }
        public required string Password { get; set; }
    }

    public class ChangePasswordDTO
    {
        public required string CurrentPassword { get; set; } = string.Empty;
        public required string NewPassword { get; set; } = string.Empty;
    }
}