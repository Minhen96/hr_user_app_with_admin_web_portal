using System.ComponentModel.DataAnnotations.Schema;

namespace React.Models
{
    [Table("Attendance")]

    public class Attendance
    {
        public int id { get; set; }
        public string name { get; set; }
        public DateTime time_in { get; set; }
        public DateTime? time_out { get; set; }
        public byte[] time_in_photo { get; set; }
        public byte[]? time_out_photo { get; set; }
        public DateTime date_submission { get; set; }
        public string placename { get; set; }
        public int user_id { get; set; }


    }
    public class AttendanceGet
    {
        public int Id { get; set; }
        public string Name { get; set; }
        public DateTime TimeIn { get; set; }
        public DateTime? TimeOut { get; set; }
        public DateTime DateSubmission { get; set; }
        public string PlaceName { get; set; }
        public int UserId { get; set; }
        public string TimeInPhoto { get; set; }
        public string? TimeOutPhoto { get; set; }
    }
}
