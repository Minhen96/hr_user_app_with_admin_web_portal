namespace React.DTOs
{
    public class QuoteDto
    {
        public int Id { get; set; }
        public string? Text { get; set; }
        public string? TextCn { get; set; }
        public string LastEditedBy { get; set; }
        public DateTime LastEditedDate { get; set; }
        public string CarouselType { get; set; }  // "Quote", "Vision", "Mission", "Values", "Target"
        public string ImageUrl { get; set; }
        public List<QuoteViewDto> Views { get; set; }
        public List<QuoteReactionDto> Reactions { get; set; }
    }

    // Add new DTO for carousel content updates
    public class UpdateCarouselContentDto
    {
        public string? Text { get; set; }
        public string? TextCn { get; set; }
        public string? CarouselType { get; set; }
        public IFormFile? Image { get; set; }
        public string EditorUsername { get; set; } = string.Empty;
    }

    public class QuoteViewDto
    {
        public string ViewedBy { get; set; }
        public DateTime ViewedAt { get; set; }
    }

    public class QuoteReactionDto
    {
        public string ReactedBy { get; set; }
        public string Reaction { get; set; }
        public DateTime ReactedAt { get; set; }
    }

    public class UpdateQuoteDto
    {
        public string? Text { get; set; }
        public string? TextCn { get; set; }
        public string EditorUsername { get; set; }
    }

    public class AddReactionDto
    {
        public string Username { get; set; }
        public string Reaction { get; set; }
    }
}
