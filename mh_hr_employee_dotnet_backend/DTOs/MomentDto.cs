namespace React.DTOs
{
    public class MomentDto
    {
        public int Id { get; set; }
        public string Title { get; set; }
        public string Description { get; set; }
        public int UserId { get; set; }
        public string UserName { get; set; }
        public List<string> Images { get; set; }
        public List<MomentImageDto> ImagePath { get; set; }
        public List<MomentReactionDto> Reactions { get; set; }
        public DateTime CreatedAt { get; set; }
        public string nickname { get; set; }
    }

    public class MomentImageDto
    {
        public int Id { get; set; }
        public string ImagePath { get; set; }
    }

    public class CreateMomentDto
    {
        public string Title { get; set; }
        public string Description { get; set; }
        public List<IFormFile> Media { get; set; }
    }

    public class CreateMomentReactionDto
    {
        public string ReactionType { get; set; }
    }

    public class MomentReactionDto
    {
        public int Id { get; set; }
        public int UserId { get; set; }
        public string ReactionType { get; set; }
        public DateTime CreatedAt { get; set; }
        public string UserName { get; internal set; }
        public string nickname { get; set; }//20250120
    }
}