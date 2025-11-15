using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

// File: ApiDotNet/Models/EquipmentRequest.cs
namespace React.Models
{
    [Table("equipment_return", Schema = "dbo")]
    public class EquipmentReturn
    {
        [Column("id")]
        public int Id { get; set; }

        [Column("returner_id")]
        public int ReturnerId { get; set; }

        [Column("date_return")]
        public DateTime DateReturned { get; set; }

        [Column("status")]
        public string Status { get; set; } = "unchecked";

        [Column("signature_id")]
        public int SignatureId { get; set; }

        [Column("approver_id")]
        public int? ApproverId { get; set; }

        [Column("received_details")]
        public string? ReceivedDetails { get; set; }


        [ForeignKey("ReturnerId")]
        public User Returner { get; set; } = null!;

        [ForeignKey("SignatureId")]
        public Signature Signature { get; set; } = null!;

        [ForeignKey("ApproverId")]
        public User? Approver { get; set; }

        public ICollection<EquipmentReturnItem> Items { get; set; } = new List<EquipmentReturnItem>();
    }

    [Table("equipment_returned_items")]
    public class EquipmentReturnItem
    {
        [Column("id")]
        public int Id { get; set; }

        [Column("return_id")]
        public int ReturnId { get; set; }

        [Column("title")]
        public string Title { get; set; } = string.Empty;

        [Column("description")]
        public string? Description { get; set; }

        [Column("quantity")]
        public int Quantity { get; set; } = 1;

        [Column("justification")]
        public string Justification { get; set; } = "New";

        [Column("created_at")]
        public DateTime CreatedAt { get; set; }

        [ForeignKey("ReturnId")]
        public EquipmentReturn Return { get; set; } = null!;
    }

}