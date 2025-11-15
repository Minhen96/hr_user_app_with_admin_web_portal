using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace React.Models
{
    [Table("leave_detail")]

    public class LeaveDetail
    {
        [Key]
        [DatabaseGenerated(DatabaseGeneratedOption.Identity)]
        public int id { get; set; }
        public DateTime leave_date { get; set; }
        public DateTime leave_end_date { get; set; }
        public string reason { get; set; }
        public string status { get; set; } = "Pending";
        public int? approved_by { get; set; }
        public int? approval_signature_id { get; set; }
        public int annual_leave_id { get; set; }
        public double no_of_days { get; set; }
        public DateTime date_submission { get; set; }


    }

}