using Microsoft.AspNetCore.Mvc;
using React.Core.Interfaces.Services;

namespace React.API.Controllers;

[Route("admin/api/[controller]")]
[ApiController]
public class BirthdayController : ControllerBase
{
    private readonly IBirthdayService _birthdayService;

    public BirthdayController(IBirthdayService birthdayService)
    {
        _birthdayService = birthdayService ?? throw new ArgumentNullException(nameof(birthdayService));
    }

    [HttpGet]
    public async Task<IActionResult> GetBirthdays([FromQuery] int month)
    {
        var result = await _birthdayService.GetBirthdaysByMonthAsync(month);
        return result.IsSuccess
            ? Ok(result.Data)
            : BadRequest(new { message = result.Message });
    }
}
