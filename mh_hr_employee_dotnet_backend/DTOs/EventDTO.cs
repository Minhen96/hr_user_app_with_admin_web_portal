namespace React.DTOs
{
    public class EventDTO
    {
        public int id { get; set; }
        public string title { get; set; }
        public string? description { get; set; }
        public DateTime date { get; set; }
        public int user_id { get; set; }
        public string? user_name { get; set; }
        public DateTime created_at { get; set; }
        public DateTime updated_at { get; set; }
        public bool is_read { get; set; }
    }
}
