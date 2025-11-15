using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

// File: ApiDotNet/Models/EquipmentRequest.cs
namespace React.Models
{
    [Table("equipment_requests", Schema = "dbo")]
    public class EquipmentRequest
    {
        [Column("id")]
        public int Id { get; set; }

        [Column("requester_id")]
        public int RequesterId { get; set; }

        [Column("date_requested")]
        public DateTime DateRequested { get; set; }

        [Column("status")]
        public string Status { get; set; } = "pending";

        [Column("signature_id")]
        public int? SignatureId { get; set; }

        [Column("approver_id")]
        public int? ApproverId { get; set; }

        [Column("date_approved")]
        public DateTime? DateApproved { get; set; }

        [Column("approval_signature_id")]
        public int? ApprovalSignatureId { get; set; }

        [Column("received_details")]
        public string? ReceivedDetails { get; set; }

        [Column("created_at")]
        public DateTime CreatedAt { get; set; }

        [Column("updated_at")]
        public DateTime UpdatedAt { get; set; }


        [ForeignKey("RequesterId")]
        public User Requester { get; set; } = null!;

        [ForeignKey("SignatureId")]
        public Signature? Signature { get; set; }

        [ForeignKey("ApproverId")]
        public User? Approver { get; set; }

        [ForeignKey("ApprovalSignatureId")]
        public Signature? ApprovalSignature { get; set; }

        public ICollection<EquipmentItem> Items { get; set; } = new List<EquipmentItem>();
    }

    [Table("equipment_items")]
    public class EquipmentItem
    {
        [Column("id")]
        public int Id { get; set; }

        [Column("request_id")]
        public int RequestId { get; set; }

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

        [ForeignKey("RequestId")]
        public EquipmentRequest Request { get; set; } = null!;
    }

}