namespace React.Models
{
    public class Moment
    {
        public int Id { get; set; }
        public string Title { get; set; }
        public string Description { get; set; }
        public int UserId { get; set; }
        public User User { get; set; }
        public ICollection<MomentImage> Images { get; set; }
        public ICollection<MomentReaction> Reactions { get; set; }
        public DateTime CreatedAt { get; set; }
    }

    public class MomentImage
    {
        public int Id { get; set; }
        public int MomentId { get; set; }
        public Moment Moment { get; set; }
        public byte[] ImageData { get; set; }
        public string ImagePath { get; set; }
    }

    public class MomentReaction
    {
        public int Id { get; set; }
        public int MomentId { get; set; }
        public Moment Moment { get; set; }
        public int UserId { get; set; }
        public User User { get; set; }
        public string ReactionType { get; set; }
        public DateTime CreatedAt { get; set; }
    }
}