namespace React.Models
{
    public class Event
    {
        public int id { get; set; }
        public string title { get; set; }
        public string? description { get; set; }
        public DateTime date { get; set; }
        public int user_id { get; set; }
        public DateTime created_at { get; set; }
        public DateTime updated_at { get; set; }
    }
}
