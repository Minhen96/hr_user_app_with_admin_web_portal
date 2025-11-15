namespace React.DTOs
{
    public class DocumentDto
    {
        public int Id { get; set; }
        public string Type { get; set; } = string.Empty;
        public DateTime PostDate { get; set; }
        public string PosterName { get; set; } = string.Empty;
        public string Title { get; set; } = string.Empty;
        public string? Content { get; set; }
        public string DepartmentName { get; set; } = string.Empty;
        public string? DocumentUpload { get; set; }  // Will store base64 string
        public string FileType { get; set; } = string.Empty;
        public bool IsRead { get; set; }
        public int userid { get; set; }
    }
}