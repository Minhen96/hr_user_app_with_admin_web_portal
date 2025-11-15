using System.ComponentModel.DataAnnotations.Schema;

namespace React.Models
{
    [Table("annual_leave")]//set si table
    public class AnnualLeave
    {
        public int id { get; set; }
        public int user_id { get; set; }
        public int entitlement { get; set; }

    }
}
