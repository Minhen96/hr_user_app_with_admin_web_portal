using Microsoft.EntityFrameworkCore;
using React.Core.Interfaces.Repositories;
using React.Data;
using React.Models;

namespace React.Infrastructure.Repositories;

public class UserLeaveRepository : IUserLeaveRepository
{
    private readonly ApplicationDbContext _context;

    public UserLeaveRepository(ApplicationDbContext context)
    {
        _context = context ?? throw new ArgumentNullException(nameof(context));
    }

    public async Task<bool> AnnualLeaveExistsAsync(int annualLeaveId)
    {
        return await _context.AnnualLeaves.AnyAsync(a => a.id == annualLeaveId);
    }

    public async Task<LeaveDetail> AddLeaveDetailAsync(LeaveDetail leaveDetail)
    {
        _context.LeaveDetails.Add(leaveDetail);
        await _context.SaveChangesAsync();
        return leaveDetail;
    }

    public async Task<AnnualLeave?> GetEntitlementByUserIdAsync(int userId)
    {
        return await _context.AnnualLeaves
            .Where(a => a.user_id == userId)
            .FirstOrDefaultAsync();
    }

    public async Task<AnnualLeave> CreateEntitlementAsync(AnnualLeave annualLeave)
    {
        _context.AnnualLeaves.Add(annualLeave);
        await _context.SaveChangesAsync();
        return annualLeave;
    }

    public async Task<IEnumerable<LeaveDetail>> GetPendingLeavesByAnnualLeaveIdAsync(int annualLeaveId)
    {
        return await _context.LeaveDetails
            .Where(leave => leave.status == "Pending" && leave.annual_leave_id == annualLeaveId)
            .OrderByDescending(leave => leave.date_submission)
            .ToListAsync();
    }

    public async Task<IEnumerable<LeaveDetail>> GetApprovedLeavesByAnnualLeaveIdAsync(int annualLeaveId)
    {
        return await _context.LeaveDetails
            .Where(leave => leave.status == "approved" && leave.annual_leave_id == annualLeaveId)
            .OrderByDescending(leave => leave.date_submission)
            .ToListAsync();
    }

    public async Task<IEnumerable<LeaveDetail>> GetAllApprovedLeavesAsync()
    {
        return await _context.LeaveDetails
            .Where(leave => leave.status == "approved")
            .OrderByDescending(leave => leave.date_submission)
            .ToListAsync();
    }

    public async Task<LeaveDetail?> GetPendingLeaveByIdAsync(int id, int annualLeaveId)
    {
        return await _context.LeaveDetails
            .FirstOrDefaultAsync(l => l.annual_leave_id == annualLeaveId && l.status == "Pending" && l.id == id);
    }

    public async Task<bool> UpdateLeaveDetailAsync(LeaveDetail leaveDetail)
    {
        _context.LeaveDetails.Update(leaveDetail);
        await _context.SaveChangesAsync();
        return true;
    }

    public async Task<bool> DeleteLeaveDetailAsync(int id)
    {
        var leaveDetail = await _context.LeaveDetails
            .FirstOrDefaultAsync(l => l.id == id && l.status == "Pending");

        if (leaveDetail == null)
        {
            return false;
        }

        _context.LeaveDetails.Remove(leaveDetail);
        await _context.SaveChangesAsync();
        return true;
    }

    public async Task ResetLeaveDetailsIdentitySeedAsync()
    {
        try
        {
            int maxId = await _context.LeaveDetails
                .MaxAsync(l => (int?)l.id) ?? 0;

            await _context.Database.ExecuteSqlAsync(
                $"DBCC CHECKIDENT ('leave_detail', RESEED, {maxId})");
        }
        catch (Exception ex)
        {
            Console.WriteLine($"Error resetting identity seed: {ex.Message}");
        }
    }
}
