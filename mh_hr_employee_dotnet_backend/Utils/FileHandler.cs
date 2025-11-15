public static class FileExtensions
{
    // Allowed file extensions
    public static readonly string[] AllowedExtensions = new[]
    {
        // Images
        ".jpg", ".jpeg", ".png", ".gif", ".bmp",
        // Documents
        ".pdf", ".doc", ".docx",
        // Others
        ".zip", ".rar"
    };

    public static readonly Dictionary<string, string> MimeTypes = new()
    {
        // Images
        { ".jpg", "image/jpeg" },
        { ".jpeg", "image/jpeg" },
        { ".png", "image/png" },
        { ".gif", "image/gif" },
        { ".bmp", "image/bmp" },
        // Documents
        { ".pdf", "application/pdf" },
        { ".doc", "application/msword" },
        { ".docx", "application/vnd.openxmlformats-officedocument.wordprocessingml.document" },
        // Others
        { ".zip", "application/zip" },
        { ".rar", "application/x-rar-compressed" }
    };
}

public class FileHandler
{
    private readonly IWebHostEnvironment _environment;
    private readonly ILogger<FileHandler> _logger;
    private const long MaxFileSize = 10 * 1024 * 1024; // 10MB

    public FileHandler(IWebHostEnvironment environment, ILogger<FileHandler> logger)
    {
        _environment = environment;
        _logger = logger;
    }

    public async Task<(bool success, string path, string error)> SaveCertificateFile(IFormFile file)
    {
        try
        {
            if (file.Length > MaxFileSize)
            {
                return (false, string.Empty, "File size exceeds 10MB limit");
            }

            var extension = Path.GetExtension(file.FileName).ToLowerInvariant();
            if (!FileExtensions.AllowedExtensions.Contains(extension))
            {
                return (false, string.Empty, "File type not allowed");
            }

            var uploadsFolder = Path.Combine(_environment.WebRootPath, "uploads", "certificates");
            Directory.CreateDirectory(uploadsFolder);

            // Create unique filename
            var uniqueFileName = $"{Guid.NewGuid()}{extension}";
            var filePath = Path.Combine(uploadsFolder, uniqueFileName);

            using (var stream = new FileStream(filePath, FileMode.Create))
            {
                await file.CopyToAsync(stream);
            }

            return (true, $"/uploads/certificates/{uniqueFileName}", null);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error saving certificate file");
            return (false, string.Empty, "Error saving file");
        }
    }

    public void DeleteFile(string filePath)
    {
        try
        {
            var fullPath = Path.Combine(_environment.WebRootPath, filePath.TrimStart('/'));
            if (File.Exists(fullPath))
            {
                File.Delete(fullPath);
            }
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error deleting file: {FilePath}", filePath);
        }
    }
}
