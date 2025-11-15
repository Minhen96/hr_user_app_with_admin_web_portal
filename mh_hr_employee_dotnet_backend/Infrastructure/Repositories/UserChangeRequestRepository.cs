using Microsoft.EntityFrameworkCore;
using React.Core.Interfaces.Repositories;
using React.Data;
using React.Models;

namespace React.Infrastructure.Repositories;

public class UserChangeRequestRepository : IUserChangeRequestRepository
{
    private readonly ApplicationDbContext _context;

    public UserChangeRequestRepository(ApplicationDbContext context)
    {
        _context = context ?? throw new ArgumentNullException(nameof(context));
    }

    public async Task<Signature> CreateSignatureAsync(Signature signature)
    {
        _context.Signatures.Add(signature);
        await _context.SaveChangesAsync();
        return signature;
    }

    public async Task<ChangeRequest> CreateChangeRequestAsync(ChangeRequest changeRequest)
    {
        _context.ChangeRequests.Add(changeRequest);
        await _context.SaveChangesAsync();
        return changeRequest;
    }

    public async Task<ChangeRequest?> GetChangeRequestByIdAsync(int id)
    {
        return await _context.ChangeRequests
            .Include(cr => cr.Requester)
            .Include(cr => cr.Signature)
            .Include(cr => cr.Approver)
            .Include(cr => cr.ApprovalSignature)
            .Include(cr => cr.FixedAssetType)
            .Include(cr => cr.FixedAssetProducts)
            .FirstOrDefaultAsync(cr => cr.Id == id);
    }

    public async Task<IEnumerable<ChangeRequest>> GetUserChangeRequestsAsync(int userId)
    {
        return await _context.ChangeRequests
            .Include(cr => cr.FixedAssetProducts)
            .Where(cr => cr.RequesterId == userId)
            .ToListAsync();
    }

    public async Task<bool> UpdateReturnStatusAsync(int id)
    {
        var changeRequest = await _context.ChangeRequests.FindAsync(id);
        if (changeRequest == null || changeRequest.ReturnStatus != "in_use")
        {
            return false;
        }

        changeRequest.ReturnStatus = "pending_return";
        changeRequest.DateReturned = DateTime.Now;
        await _context.SaveChangesAsync();
        return true;
    }
}
