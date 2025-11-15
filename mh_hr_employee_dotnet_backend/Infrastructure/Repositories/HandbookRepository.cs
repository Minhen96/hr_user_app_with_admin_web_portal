using Microsoft.EntityFrameworkCore;
using React.Core.Interfaces.Repositories;
using React.Data;
using React.Models;

namespace React.Infrastructure.Repositories;

public class HandbookRepository : IHandbookRepository
{
    private readonly ApplicationDbContext _context;

    public HandbookRepository(ApplicationDbContext context)
    {
        _context = context ?? throw new ArgumentNullException(nameof(context));
    }

    public async Task<IEnumerable<HandbookSection>> GetAllSectionsAsync()
    {
        return await _context.HandbookSections
            .Include(s => s.Contents)
            .ToListAsync();
    }

    public async Task<HandbookSection?> GetSectionByIdAsync(int id)
    {
        return await _context.HandbookSections
            .Include(s => s.Contents)
            .FirstOrDefaultAsync(s => s.Id == id);
    }

    public async Task<IEnumerable<HandbookContent>> GetSectionContentsAsync(int sectionId)
    {
        return await _context.HandbookContents
            .Where(c => c.HandbookSectionId == sectionId)
            .ToListAsync();
    }
}
