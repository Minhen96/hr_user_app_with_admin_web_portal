using System;

namespace React.DTOs
{
    public class ChangeRequestDTO
    {
        public int RequesterId { get; set; }
        public string Reason { get; set; }
        public string Description { get; set; }
        public string Risk { get; set; }
        public string Instruction { get; set; }
        public string PostReview { get; set; }
        public int SignatureId { get; set; }
        public DateTime? CompleteDate { get; set; }
    }
}