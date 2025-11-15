using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using React.Data;
using React.Models;

namespace React.API.Controllers;

[Route("admin/api/[controller]")]
[ApiController]
public class DepartmentController : ControllerBase
{
    private readonly ApplicationDbContext _context;

    public DepartmentController(ApplicationDbContext context)
    {
        _context = context ?? throw new ArgumentNullException(nameof(context));
    }

    [HttpGet]
    public async Task<IActionResult> GetAllDepartments()
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

    [HttpGet("{id}")]
    public async Task<IActionResult> GetDepartment(int id)
    {
        try
        {
            var department = await _context.Departments.FindAsync(id);
            if (department == null)
                return NotFound(new { message = "Department not found" });

            return Ok(department);
        }
        catch (Exception ex)
        {
            return StatusCode(500, new { message = "Error fetching department", error = ex.Message });
        }
    }

    [HttpPost]
    public async Task<IActionResult> CreateDepartment([FromBody] DepartmentDto dto)
    {
        try
        {
            var department = new Department
            {
                Name = dto.Name
            };

            _context.Departments.Add(department);
            await _context.SaveChangesAsync();

            return Ok(new { success = true, departmentId = department.Id, message = "Department created successfully" });
        }
        catch (Exception ex)
        {
            return StatusCode(500, new { message = "Error creating department", error = ex.Message });
        }
    }

    [HttpPut("{id}")]
    public async Task<IActionResult> UpdateDepartment(int id, [FromBody] DepartmentDto dto)
    {
        try
        {
            var department = await _context.Departments.FindAsync(id);
            if (department == null)
                return NotFound(new { message = "Department not found" });

            department.Name = dto.Name;
            await _context.SaveChangesAsync();

            return Ok(new { success = true, message = "Department updated successfully" });
        }
        catch (Exception ex)
        {
            return StatusCode(500, new { message = "Error updating department", error = ex.Message });
        }
    }

    [HttpDelete("{id}")]
    public async Task<IActionResult> DeleteDepartment(int id)
    {
        try
        {
            var department = await _context.Departments.FindAsync(id);
            if (department == null)
                return NotFound(new { message = "Department not found" });

            _context.Departments.Remove(department);
            await _context.SaveChangesAsync();

            return Ok(new { success = true, message = "Department deleted successfully" });
        }
        catch (Exception ex)
        {
            return StatusCode(500, new { message = "Error deleting department", error = ex.Message });
        }
    }
}

public class DepartmentDto
{
    public string Name { get; set; } = string.Empty;
}
