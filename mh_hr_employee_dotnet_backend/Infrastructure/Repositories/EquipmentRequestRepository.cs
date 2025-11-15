using Microsoft.EntityFrameworkCore;
using React.Core.Interfaces.Repositories;
using React.Data;
using React.Models;

namespace React.Infrastructure.Repositories;

public class EquipmentRequestRepository : IEquipmentRequestRepository
{
    private readonly ApplicationDbContext _context;

    public EquipmentRequestRepository(ApplicationDbContext context)
    {
        _context = context ?? throw new ArgumentNullException(nameof(context));
    }

    public async Task<IEnumerable<EquipmentRequest>> GetByUserIdAsync(int userId, string? status)
    {
        var query = _context.EquipmentRequests
            .Include(r => r.Items)
            .Include(r => r.Requester)
                .ThenInclude(u => u.Department)
            .Include(r => r.Signature)
            .Include(r => r.Approver)
            .Include(r => r.ApprovalSignature)
            .Where(r => r.RequesterId == userId)
            .AsQueryable();

        if (!string.IsNullOrEmpty(status))
        {
            query = query.Where(r => r.Status == status);
        }

        return await query.ToListAsync();
    }

    public async Task<IEnumerable<EquipmentRequest>> GetAllAsync(string? status)
    {
        var query = _context.EquipmentRequests
            .Include(r => r.Items)
            .Include(r => r.Requester)
                .ThenInclude(u => u.Department)
            .Include(r => r.Signature)
            .Include(r => r.Approver)
                .ThenInclude(a => a.Department)
            .Include(r => r.ApprovalSignature)
            .AsQueryable();

        if (!string.IsNullOrEmpty(status))
        {
            query = query.Where(r => r.Status == status);
        }

        return await query.OrderByDescending(r => r.DateRequested).ToListAsync();
    }

    public async Task<EquipmentRequest> AddAsync(EquipmentRequest request)
    {
        _context.EquipmentRequests.Add(request);
        await _context.SaveChangesAsync();
        return request;
    }

    public async Task<EquipmentRequest?> GetByIdAsync(int id)
    {
        return await _context.EquipmentRequests.FindAsync(id);
    }

    public async Task<EquipmentRequest?> GetByIdWithDetailsAsync(int id)
    {
        return await _context.EquipmentRequests
            .Include(r => r.Items)
            .Include(r => r.Requester)
                .ThenInclude(u => u.Department)
            .Include(r => r.Signature)
            .Include(r => r.Approver)
                .ThenInclude(a => a.Department)
            .Include(r => r.ApprovalSignature)
            .FirstOrDefaultAsync(r => r.Id == id);
    }

    public async Task UpdateReceivedDetailsAsync(int id, string receivedDetails)
    {
        var request = await _context.EquipmentRequests.FindAsync(id);
        if (request != null)
        {
            request.ReceivedDetails = receivedDetails;
            request.UpdatedAt = DateTime.UtcNow;
            await _context.SaveChangesAsync();
        }
    }

    public async Task UpdateStatusAsync(int id, string status, int? approverId = null)
    {
        var request = await _context.EquipmentRequests.FindAsync(id);
        if (request != null)
        {
            request.Status = status;
            request.UpdatedAt = DateTime.UtcNow;

            if (status == "approved" && approverId.HasValue)
            {
                request.ApproverId = approverId.Value;
                request.DateApproved = DateTime.UtcNow;
            }

            await _context.SaveChangesAsync();
        }
    }
}
