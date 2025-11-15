using React.Core.DTOs.Response;
using React.Models;

namespace React.Core.Interfaces.Repositories;

public interface IHandbookRepository
{
    Task<IEnumerable<HandbookSection>> GetAllSectionsAsync();
    Task<HandbookSection?> GetSectionByIdAsync(int id);
    Task<IEnumerable<HandbookContent>> GetSectionContentsAsync(int sectionId);
}
