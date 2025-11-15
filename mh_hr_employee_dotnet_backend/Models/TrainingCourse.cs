using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace React.Models
{
    [Table("training_courses")]
    public class TrainingCourse
    {
        [Key]
        [Column("id")]
        public int Id { get; set; }

        [Column("user_id")]
        public int UserId { get; set; }

        [Column("title")]
        [Required]
        [StringLength(100)]
        public string Title { get; set; }

        [Column("description")]
        public string Description { get; set; }

        [Column("course_date")]
        public DateTime CourseDate { get; set; }

        [Column("status")]
        [StringLength(20)]
        public string Status { get; set; } = "pending";

        [Column("created_at")]
        public DateTime CreatedAt { get; set; }

        [Column("updated_at")]
        public DateTime UpdatedAt { get; set; }

        [NotMapped] // Column doesn't exist in database
        public string? RejectionReason { get; set; }

        // Navigation properties
        public virtual User User { get; set; }
        public virtual ICollection<Certificate> Certificates { get; set; }
    }


    public class Certificate
    {
        [Key]
        [Column("id")]
        public int Id { get; set; }

        [Column("training_id")]
        public int TrainingId { get; set; }

        [Column("file_name")]
        [Required]
        [StringLength(255)]
        public string FileName { get; set; }

        [Column("certificate_content")]
        public byte[] CertificateContent { get; set; }

        [Column("file_type")]
        [StringLength(50)]
        public string FileType { get; set; }

        [Column("file_size")]
        public long FileSize { get; set; }

        [Column("uploaded_at")]
        public DateTime UploadedAt { get; set; }

        // Navigation property with explicit foreign key
        [ForeignKey("TrainingId")]
        public virtual TrainingCourse TrainingCourse { get; set; }
    }
}