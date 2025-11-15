using System.Text.Json.Serialization;

namespace React.Models
{
    public class HandbookSection
    {
        public int Id { get; set; }
        public string Title { get; set; }
        public List<HandbookContent> Contents { get; set; }
    }

    public class HandbookContent
    {
        public int Id { get; set; }
        public int HandbookSectionId { get; set; }
        public string Subtitle { get; set; }
        public string Content { get; set; }

        [JsonIgnore]
        public HandbookSection HandbookSection { get; set; }
    }
}