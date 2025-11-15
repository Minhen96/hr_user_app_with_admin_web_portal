namespace ApiDotNet.Models
{
    public class LeaveCalendarDTO
    {
        public int Id { get; set; }
        public DateTime LeaveDate { get; set; }
        public string EmployeeName { get; set; }
        public string Reason { get; set; }
        public int NumberOfDays { get; set; }
        public string Status { get; set; }
        public int? ApprovedBy { get; set; }
        public string LeaveType { get; set; }  // "Annual" or "MC"
    }
}