using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using React.Core.DTOs.Request;
using React.Core.Interfaces.Services;
using React.Data;
using React.Models;

namespace React.API.Controllers;

[Route("admin/api/[controller]")]
[ApiController]
public class TrainingsController : ControllerBase
{
    private readonly ITrainingService _trainingService;
    private readonly ApplicationDbContext _context;

    public TrainingsController(ITrainingService trainingService, ApplicationDbContext context)
    {
        _trainingService = trainingService ?? throw new ArgumentNullException(nameof(trainingService));
        _context = context ?? throw new ArgumentNullException(nameof(context));
    }

    [HttpGet]
    public async Task<IActionResult> GetTrainings()
    {
        var result = await _trainingService.GetAllTrainingsAsync();
        return result.IsSuccess ? Ok(result.Data) : StatusCode(500, new { message = result.Message });
    }

    [HttpPost]
    public async Task<IActionResult> CreateTraining([FromForm] int userId, [FromForm] string title, [FromForm] string description, [FromForm] DateTime courseDate, [FromForm] List<IFormFile>? certificates)
    {
        try
        {
            // Validate required fields
            if (string.IsNullOrWhiteSpace(title))
            {
                return BadRequest(new { message = "Title is required" });
            }

            // Validate that user exists
            var userExists = await _context.Users.AnyAsync(u => u.Id == userId);
            if (!userExists)
            {
                return BadRequest(new { message = $"User with ID {userId} does not exist" });
            }

            var training = new TrainingCourse
            {
                UserId = userId,
                Title = title,
                Description = description ?? string.Empty,
                CourseDate = courseDate,
                Status = "Pending",
                CreatedAt = DateTime.Now,
                UpdatedAt = DateTime.Now
            };

            _context.TrainingCourses.Add(training);
            await _context.SaveChangesAsync();

            // Save certificates
            if (certificates != null && certificates.Any())
            {
                foreach (var cert in certificates)
                {
                    if (cert.Length > 0)
                    {
                        using var memoryStream = new MemoryStream();
                        await cert.CopyToAsync(memoryStream);

                        var certificate = new Certificate
                        {
                            TrainingId = training.Id,
                            FileName = cert.FileName,
                            FileType = Path.GetExtension(cert.FileName).TrimStart('.'),
                            CertificateContent = memoryStream.ToArray(),
                            FileSize = memoryStream.Length,
                            UploadedAt = DateTime.Now
                        };

                        _context.Certificates.Add(certificate);
                    }
                }
                await _context.SaveChangesAsync();
            }

            return StatusCode(201, new { message = "Training created successfully", data = training });
        }
        catch (Exception ex)
        {
            return StatusCode(500, new { message = "Error creating training course", error = ex.Message, stackTrace = ex.StackTrace });
        }
    }

    [HttpPut("{id}/status")]
    public async Task<IActionResult> UpdateTrainingStatus(int id, [FromBody] TrainingStatusUpdateDto request)
    {
        if (!ModelState.IsValid)
            return BadRequest(ModelState);

        var result = await _trainingService.UpdateTrainingStatusAsync(id, request);
        return result.IsSuccess ? Ok(new { message = result.Message }) : BadRequest(new { message = result.Message });
    }
}
