using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using React.Core.Interfaces.Services;
using React.Data;

namespace React.API.Controllers;

/// <summary>
/// Controller for user management operations
/// Note: This is a refactored version of the legacy UsersController
/// </summary>
[Route("admin/api/users")]
[ApiController]
public class UsersController : ControllerBase
{
    private readonly IUserManagementService _userManagementService;
    private readonly ApplicationDbContext _context;

    public UsersController(IUserManagementService userManagementService, ApplicationDbContext context)
    {
        _userManagementService = userManagementService ?? throw new ArgumentNullException(nameof(userManagementService));
        _context = context ?? throw new ArgumentNullException(nameof(context));
    }

    [HttpGet("password-changes")]
    public async Task<IActionResult> GetPendingPasswordChanges()
    {
        var result = await _userManagementService.GetPendingPasswordChangesAsync();
        return result.IsSuccess ? Ok(result.Data) : StatusCode(500, new { message = result.Message });
    }

    [HttpGet("departments")]
    public async Task<IActionResult> GetDepartments()
    {
        try
        {
            var departments = await _context.Departments
                .Select(d => new { d.Id, d.Name })
                .ToListAsync();
            return Ok(departments);
        }
        catch (Exception ex)
        {
            return StatusCode(500, new { message = "Error fetching departments", error = ex.Message });
        }
    }

    [HttpGet("roles")]
    public async Task<IActionResult> GetRoles()
    {
        try
        {
            // Return standard roles for the system
            var roles = new[]
            {
                new { id = 1, name = "user" },
                new { id = 2, name = "department-admin" },
                new { id = 3, name = "super-admin" }
            };
            return Ok(roles);
        }
        catch (Exception ex)
        {
            return StatusCode(500, new { message = "Error fetching roles", error = ex.Message });
        }
    }

    [HttpPut("{userId}/toggle-status")]
    public async Task<IActionResult> ToggleUserStatus(int userId)
    {
        try
        {
            var user = await _context.Users.FindAsync(userId);
            if (user == null)
                return NotFound(new { message = "User not found" });

            // Toggle the active_status
            user.active_status = user.active_status == "active" ? "inactive" : "active";
            await _context.SaveChangesAsync();

            return Ok(new { success = true, message = "User status updated", activeStatus = user.active_status });
        }
        catch (Exception ex)
        {
            return StatusCode(500, new { message = "Error toggling user status", error = ex.Message });
        }
    }

    [HttpPost]
    public async Task<IActionResult> CreateUser([FromBody] CreateUserDto dto)
    {
        try
        {
            // Check if email already exists
            var existingUser = await _context.Users.FirstOrDefaultAsync(u => u.Email == dto.Email);
            if (existingUser != null)
                return BadRequest(new { message = "Email already exists" });

            var user = new React.Models.User
            {
                FullName = dto.FullName,
                Email = dto.Email,
                Password = HashPassword(dto.Password),
                NRIC = dto.NRIC,
                TIN = dto.TIN,
                EPFNo = dto.EPFNo,
                DepartmentId = dto.DepartmentId,
                Role = dto.Role,
                Birthday = dto.Birthday,
                DateJoined = dto.DateJoined,
                active_status = "active",
                Status = "approved",
                contactNumber = dto.ContactNumber
            };

            _context.Users.Add(user);
            await _context.SaveChangesAsync();

            return StatusCode(201, new { success = true, userId = user.Id, message = "User created successfully" });
        }
        catch (Exception ex)
        {
            return StatusCode(500, new { message = "Error creating user", error = ex.Message });
        }
    }

    [HttpPut("{id}")]
    public async Task<IActionResult> UpdateUser(int id, [FromBody] UpdateUserDto dto)
    {
        try
        {
            var user = await _context.Users.FindAsync(id);
            if (user == null)
                return NotFound(new { message = "User not found" });

            user.FullName = dto.FullName;
            user.Email = dto.Email;
            user.NRIC = dto.NRIC;
            user.TIN = dto.TIN;
            user.EPFNo = dto.EPFNo;
            user.DepartmentId = dto.DepartmentId;
            user.Role = dto.Role;
            user.Birthday = dto.Birthday;
            user.DateJoined = dto.DateJoined;
            user.contactNumber = dto.ContactNumber;

            if (!string.IsNullOrEmpty(dto.Password))
            {
                user.Password = HashPassword(dto.Password);
            }

            await _context.SaveChangesAsync();

            return Ok(new { success = true, message = "User updated successfully" });
        }
        catch (Exception ex)
        {
            return StatusCode(500, new { message = "Error updating user", error = ex.Message });
        }
    }

    [HttpDelete("{id}")]
    public async Task<IActionResult> DeleteUser(int id)
    {
        try
        {
            var user = await _context.Users.FindAsync(id);
            if (user == null)
                return NotFound(new { message = "User not found" });

            _context.Users.Remove(user);
            await _context.SaveChangesAsync();

            return Ok(new { success = true, message = "User deleted successfully" });
        }
        catch (Exception ex)
        {
            return StatusCode(500, new { message = "Error deleting user", error = ex.Message });
        }
    }

    private string HashPassword(string password)
    {
        using var sha256 = System.Security.Cryptography.SHA256.Create();
        var hashedBytes = sha256.ComputeHash(System.Text.Encoding.UTF8.GetBytes(password));
        return Convert.ToBase64String(hashedBytes);
    }

    // Note: password-status update is now handled by AuthController
}

public class CreateUserDto
{
    public string FullName { get; set; } = string.Empty;
    public string Email { get; set; } = string.Empty;
    public string Password { get; set; } = string.Empty;
    public string NRIC { get; set; } = string.Empty;
    public string? TIN { get; set; }
    public string? EPFNo { get; set; }
    public int DepartmentId { get; set; }
    public string Role { get; set; } = "user";
    public DateTime Birthday { get; set; }
    public DateTime DateJoined { get; set; }
    public string? ContactNumber { get; set; }
}

public class UpdateUserDto
{
    public string FullName { get; set; } = string.Empty;
    public string Email { get; set; } = string.Empty;
    public string? Password { get; set; }
    public string NRIC { get; set; } = string.Empty;
    public string? TIN { get; set; }
    public string? EPFNo { get; set; }
    public int DepartmentId { get; set; }
    public string Role { get; set; } = "user";
    public DateTime Birthday { get; set; }
    public DateTime DateJoined { get; set; }
    public string? ContactNumber { get; set; }
}
