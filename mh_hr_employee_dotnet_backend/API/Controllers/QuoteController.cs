using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using React.Data;
using React.Models;

namespace React.API.Controllers;

[ApiController]
[Route("api/[controller]")]
public class QuoteController : ControllerBase
{
    private readonly ApplicationDbContext _context;
    private readonly ILogger<QuoteController> _logger;

    public QuoteController(ApplicationDbContext context, ILogger<QuoteController> logger)
    {
        _context = context ?? throw new ArgumentNullException(nameof(context));
        _logger = logger ?? throw new ArgumentNullException(nameof(logger));
    }

    /// <summary>
    /// Get the latest quote or a random quote
    /// </summary>
    [HttpGet]
    [Authorize]
    public async Task<IActionResult> GetQuote()
    {
        try
        {
            // Get the most recently edited quote
            var quote = await _context.Quotes
                .OrderByDescending(q => q.LastEditedDate)
                .FirstOrDefaultAsync();

            if (quote == null)
            {
                // Return empty list instead of 404
                return Ok(new List<object>());
            }

            return Ok(new
            {
                id = quote.Id,
                text = quote.Text,
                textCn = quote.TextCn,
                lastEditedBy = quote.LastEditedBy,
                lastEditedDate = quote.LastEditedDate,
                carouselType = quote.CarouselType ?? "Quote",
                imageUrl = quote.ImageUrl
            });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error fetching quote");
            return StatusCode(500, new { message = "Internal server error" });
        }
    }

    /// <summary>
    /// Get carousel content (all quotes with carousel type)
    /// </summary>
    [HttpGet("carousel-content")]
    [Authorize]
    public async Task<IActionResult> GetCarouselContent()
    {
        try
        {
            var carouselItems = await _context.Quotes
                .Where(q => q.CarouselType != null)
                .OrderByDescending(q => q.LastEditedDate)
                .Select(q => new
                {
                    id = q.Id,
                    text = q.Text,
                    textCn = q.TextCn,
                    lastEditedBy = q.LastEditedBy,
                    lastEditedDate = q.LastEditedDate,
                    carouselType = q.CarouselType,
                    imageUrl = q.ImageUrl
                })
                .ToListAsync();

            // If no carousel items found, return a default item
            if (!carouselItems.Any())
            {
                var defaultItem = new[]
                {
                    new
                    {
                        id = 0,
                        text = "Welcome to MH HR",
                        textCn = "欢迎来到 MH HR",
                        lastEditedBy = "System",
                        lastEditedDate = DateTime.Now,
                        carouselType = "Default",
                        imageUrl = "/assets/images/company-logo.jpg"
                    }
                };
                return Ok(defaultItem);
            }

            return Ok(carouselItems);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error fetching carousel content");
            return StatusCode(500, new { message = "Internal server error" });
        }
    }

    /// <summary>
    /// Get views for a specific quote
    /// </summary>
    [HttpGet("{quoteId}/views")]
    [Authorize]
    public async Task<IActionResult> GetQuoteViews(int quoteId)
    {
        try
        {
            var views = await _context.QuoteViews
                .Where(v => v.QuoteId == quoteId)
                .Select(v => new
                {
                    id = v.Id,
                    quoteId = v.QuoteId,
                    viewedBy = v.ViewedBy,
                    viewedAt = v.ViewedAt
                })
                .ToListAsync();

            return Ok(views);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error fetching quote views");
            return StatusCode(500, new { message = "Internal server error" });
        }
    }

    /// <summary>
    /// Get reactions for a specific quote
    /// </summary>
    [HttpGet("{quoteId}/reactions")]
    [Authorize]
    public async Task<IActionResult> GetQuoteReactions(int quoteId)
    {
        try
        {
            var reactions = await _context.QuoteReactions
                .Where(r => r.QuoteId == quoteId)
                .Select(r => new
                {
                    id = r.Id,
                    quoteId = r.QuoteId,
                    reactedBy = r.ReactedBy,
                    reaction = r.Reaction,
                    reactedAt = r.ReactedAt
                })
                .ToListAsync();

            return Ok(reactions);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error fetching quote reactions");
            return StatusCode(500, new { message = "Internal server error" });
        }
    }
}
