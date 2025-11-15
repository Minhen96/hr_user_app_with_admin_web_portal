using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace React.Models
{
    public class ChangeRequest
    {
        [Key]
        [Column("id")] // Maps to the 'id' column in the database
        public int? Id { get; set; }

        [ForeignKey("Requester")]
        [Column("requester_id")] // Maps to the 'requester_id' column in the database
        public int? RequesterId { get; set; }
        public User? Requester { get; set; }

        [Column("date_requested")] // Maps to the 'date_requested' column in the database
        public DateTime? DateRequested { get; set; }

        [Column("status")] // Maps to the 'status' column in the database
        public string? Status { get; set; } = "pending";

        [Column("reason")]
        public string? Reason { get; set; }

        [Column("description")]
        public string? Description { get; set; }

        [Column("risk")]
        public string? Risk { get; set; }

        [Column("instruction")]
        public string? Instruction { get; set; }

        [Column("complete_date")] // Maps to the 'complete_date' column in the database
        public DateTime? CompleteDate { get; set; }

        [Column("post_review")]
        public string? PostReview { get; set; }

        [ForeignKey("Signature")]
        [Column("signature_id")] // Maps to the 'signature_id' column in the database
        public int? SignatureId { get; set; }
        public Signature? Signature { get; set; }

        [ForeignKey("Approver")]
        [Column("approver_id")] // Maps to the 'approver_id' column in the database
        public int? ApproverId { get; set; }
        public User? Approver { get; set; }

        [Column("date_approved")] // Maps to the 'date_approved' column in the database
        public DateTime? DateApproved { get; set; }

        [ForeignKey("ApprovalSignature")]
        [Column("approval_signature_id")] // Maps to the 'approval_signature_id' column in the database
        public int? ApprovalSignatureId { get; set; }
        public Signature? ApprovalSignature { get; set; }

        [Column("received_details")]
        public string? ReceivedDetails { get; set; }

        [Column("return_status")] // Maps to the 'return_status' column in the database
        public string? ReturnStatus { get; set; } = "in_use";

        [Column("date_returned")]
        public DateTime? DateReturned { get; set; }

        [ForeignKey("FixedAssetType")]
        [Column("fixed_asset_type_id")] // Maps to the 'fixed_asset_type_id' column in the database
        public int? FixedAssetTypeId { get; set; }
        public FixedAssetType? FixedAssetType { get; set; }

        public ICollection<FixedAssetProduct> FixedAssetProducts { get; set; }
    }
}
