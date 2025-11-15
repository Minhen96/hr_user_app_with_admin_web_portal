using System.ComponentModel.DataAnnotations.Schema;

namespace React.Models
{
    [Table("Mc_Leave_Requests")]
    public class LeaveRequest
{
    public int id { get; set; }
    public string full_name { get; set; }
    public DateTime start_date { get; set; }
    public DateTime end_date { get; set; }
    public DateTime date_submission { get; set; } = DateTime.Now;
    public int total_day { get; set; }
    public string reason { get; set; }
    public string status { get; set; } = "Pending";
    public byte[] url { get; set; }
}

}
