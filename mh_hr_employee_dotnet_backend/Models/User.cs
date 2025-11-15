using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace React.Models
{
    [Table("users")]
    public class User
    {
        [Column("id")]
        public int Id { get; set; }

        [Column("full_name")]
        public string FullName { get; set; }

        [Column("email")]
        public string Email { get; set; }

        [Column("profile_picture")]
        public byte[]? profile_picture { get; set; }

        [Column("birthday")]
        public DateTime Birthday { get; set; }

        [Column("password")]
        public string Password { get; set; }

        [Column("department_id")]
        public int DepartmentId { get; set; }

        [Column("nric")]
        public string NRIC { get; set; }

        [Column("tin")]
        public string? TIN { get; set; }

        [Column("epf_no")]
        public string? EPFNo { get; set; }

        [Column("role")]
        public string Role { get; set; } = "user";

        [Column("status")]
        public string Status { get; set; } = "pending";

        [Column("active_status")]
        public string active_status { get; set; } = "inactive";

        [Column("date_joined")]
        public DateTime DateJoined { get; set; } = DateTime.UtcNow;

        [Column("change_password_date")]
        public DateTime? ChangePasswordDate { get; set; }

        [Column("FCMToken")]
        public string? FcmToken { get; set; }

        [ForeignKey("DepartmentId")]
        public Department? Department { get; set; }

        [Column("nickname")]
        public string? nickname { get; set; }

        [Column("contact_number")]
        public string? contactNumber { get; set; }
    }
}