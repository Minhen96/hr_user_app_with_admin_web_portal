using Microsoft.EntityFrameworkCore;
using React.Core.DTOs.Response;
using React.Core.Interfaces.Repositories;
using React.Data;
using React.Models;

namespace React.Infrastructure.Repositories;

public class MedicalCertificateRepository : IMedicalCertificateRepository
{
    private readonly ApplicationDbContext _context;

    public MedicalCertificateRepository(ApplicationDbContext context)
    {
        _context = context ?? throw new ArgumentNullException(nameof(context));
    }

    public async Task AddLeaveRequestAsync(LeaveRequest leaveRequest)
    {
        _context.LeaveRequests.Add(leaveRequest);
        await _context.SaveChangesAsync();
    }

    public async Task<IEnumerable<McLeaveResponseDto>> GetAllLeavesAsync()
    {
        return await _context.LeaveRequests
            .OrderByDescending(leave => leave.date_submission)
            .Select(leave => new McLeaveResponseDto
            {
                Id = leave.id,
                FullName = leave.full_name,
                StartDate = leave.start_date,
                EndDate = leave.end_date,
                DateSubmission = leave.date_submission,
                TotalDay = leave.total_day,
                Status = leave.status,
                Reason = leave.reason,
                AttachmentUrl = leave.url != null ? Convert.ToBase64String(leave.url) : null
            })
            .ToListAsync();
    }

    public async Task<IEnumerable<McLeaveResponseDto>> GetPendingLeavesByUserIdAsync(int userId)
    {
        return await _context.LeaveRequests
            .Where(leave => leave.status.Equals("Pending") && leave.id == userId)
            .OrderByDescending(leave => leave.date_submission)
            .Select(leave => new McLeaveResponseDto
            {
                Id = leave.id,
                FullName = leave.full_name,
                StartDate = leave.start_date,
                EndDate = leave.end_date,
                DateSubmission = leave.date_submission,
                TotalDay = leave.total_day,
                Status = leave.status,
                Reason = leave.reason,
                AttachmentUrl = leave.url != null ? Convert.ToBase64String(leave.url) : null
            })
            .ToListAsync();
    }

    public async Task<IEnumerable<McLeaveResponseDto>> GetApprovedLeavesByUserIdAsync(int userId)
    {
        return await _context.LeaveRequests
            .Where(leave => !leave.status.Equals("Pending") && leave.id == userId)
            .OrderByDescending(leave => leave.date_submission)
            .Select(leave => new McLeaveResponseDto
            {
                Id = leave.id,
                FullName = leave.full_name,
                StartDate = leave.start_date,
                EndDate = leave.end_date,
                DateSubmission = leave.date_submission,
                TotalDay = leave.total_day,
                Status = leave.status,
                Reason = leave.reason,
                AttachmentUrl = leave.url != null ? Convert.ToBase64String(leave.url) : null
            })
            .ToListAsync();
    }
}
