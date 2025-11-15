namespace React.DTOs
{
    public class CreateTrainingCourseDto
    {
        public string Title { get; set; }
        public string Description { get; set; }
        public DateTime CourseDate { get; set; }
        public List<IFormFile> Certificates { get; set; }
    }

    public class TrainingCourseResponseDto
    {
        public int Id { get; set; }
        public string Title { get; set; }
        public string Description { get; set; }
        public DateTime CourseDate { get; set; }
        public string Status { get; set; }
        public DateTime CreatedAt { get; set; }
        public string RejectionReason { get; set; }
        public List<CertificateDto> Certificates { get; set; }
    }

    public class CertificateDto
    {
        public int Id { get; set; }
        public string FileName { get; set; }
        public string FileType { get; set; }
        public long FileSize { get; set; }
        public DateTime UploadedAt { get; set; }
    }

    public class UpdateTrainingCourseDto
    {
        public string Title { get; set; }
        public string Description { get; set; }
        public DateTime CourseDate { get; set; }
        public List<IFormFile> NewCertificates { get; set; }
        public List<int> CertificatesToDelete { get; set; }
    }
}
