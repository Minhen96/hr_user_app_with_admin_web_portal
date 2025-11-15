using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace React.Models
{
    public class Signature
    {
        public int Id { get; set; }

        [Column("user_id")]
        public int? UserId { get; set; } // Nullable to avoid FK constraint errors

        [Column("points")]
        public string Points { get; set; }

        [Column("boundary_width")]
        public double BoundaryWidth { get; set; }  // Changed from float to double

        [Column("boundary_height")]
        public double BoundaryHeight { get; set; }  // Changed from float to double

        [Column("created_at")]
        public DateTime CreatedAt { get; set; }

        public User User { get; set; }
        public ICollection<EquipmentRequest> RequestSignatures { get; set; }
        public ICollection<EquipmentRequest> ApprovalSignatures { get; set; }
    }
}