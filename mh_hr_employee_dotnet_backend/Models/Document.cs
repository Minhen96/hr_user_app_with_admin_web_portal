using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace React.Models
{
    public class Document
    {
        [Column("doc_id")]
        public int Id { get; set; }

        [Column("type")]
        [Required]
        [MaxLength(50)]
        public string Type { get; set; } = string.Empty;

        [Column("post_date")]
        public DateTime PostDate { get; set; }

        [Column("post_by")]
        public int PostBy { get; set; }

        [Column("title")]
        [MaxLength(50)]
        public string Title { get; set; } = string.Empty;

        [Column("doc_content")]
        public string? Content { get; set; }

        [Column("department_id")]
        public int DepartmentId { get; set; }

        [Column("doc_upload")]
        public byte[]? DocumentUpload { get; set; }  // Matches varbinary(MAX)

        [Column("file_type")]
        [MaxLength(100)]
        public string? FileType { get; set; } = string.Empty;

        [ForeignKey("DepartmentId")]
        public Department? Department { get; set; }

        [ForeignKey("PostBy")]
        public User? Poster { get; set; }

        public ICollection<DocumentRead> DocumentReads { get; set; } = new List<DocumentRead>();
    }


    public class DocumentRead
    {
        [Column("id")]
        public int Id { get; set; }

        [Column("doc_id")]
        public int DocId { get; set; }

        [Column("user_id")]
        public int UserId { get; set; }

        [Column("read_date")]
        public DateTime ReadDate { get; set; }

        // Navigation properties
        [ForeignKey("DocId")]
        public Document? Document { get; set; }

        [ForeignKey("UserId")]
        public User? User { get; set; }
    }
}