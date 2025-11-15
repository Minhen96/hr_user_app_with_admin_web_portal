using Microsoft.EntityFrameworkCore;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace React.Models
{
    public class Quote
    {
        [Key]
        public int Id { get; set; }

        [Required]
        public string Text { get; set; }

        [Required]
        public string TextCn { get; set; }

        [Required]
        public string LastEditedBy { get; set; }

        [Required]
        public DateTime LastEditedDate { get; set; }
        public string? CarouselType { get; set; }
        public string? ImageUrl { get; set; }

        public virtual ICollection<QuoteView> Views { get; set; }
        public virtual ICollection<QuoteReaction> Reactions { get; set; }
    }

    public class QuoteView
    {
        [Key]
        public int Id { get; set; }

        public int QuoteId { get; set; }

        [Required]
        public string ViewedBy { get; set; }

        [Required]
        public DateTime ViewedAt { get; set; }

        public virtual Quote Quote { get; set; }
    }

    public class QuoteReaction
    {
        [Key]
        public int Id { get; set; }

        public int QuoteId { get; set; }

        [Required]
        public string ReactedBy { get; set; }

        [Required]
        public string Reaction { get; set; }

        [Required]
        public DateTime ReactedAt { get; set; }

        public virtual Quote Quote { get; set; }
    }
}