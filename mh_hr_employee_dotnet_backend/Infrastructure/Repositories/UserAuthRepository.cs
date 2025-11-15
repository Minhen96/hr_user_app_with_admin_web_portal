using Microsoft.EntityFrameworkCore;
using React.Core.Interfaces.Repositories;
using React.Data;
using React.Models;

namespace React.Infrastructure.Repositories;

public class UserAuthRepository : IUserAuthRepository
{
    private readonly ApplicationDbContext _context;

    public UserAuthRepository(ApplicationDbContext context)
    {
        _context = context ?? throw new ArgumentNullException(nameof(context));
    }

    public async Task<User?> GetUserByIdAsync(int userId)
    {
        return await _context.Users
            .Include(u => u.Department)
            .FirstOrDefaultAsync(u => u.Id == userId);
    }

    public async Task<User?> GetUserByEmailAsync(string email)
    {
        return await _context.Users
            .Include(u => u.Department)
            .FirstOrDefaultAsync(u => u.Email.ToLower() == email.ToLower());
    }

    public async Task<bool> UserExistsAsync(string email, string nric, string? tin, string? epfNo)
    {
        return await _context.Users
            .AnyAsync(u => u.Email.ToLower() == email.ToLower()
                         || u.NRIC == nric
                         || (!string.IsNullOrEmpty(tin) && u.TIN == tin)
                         || (!string.IsNullOrEmpty(epfNo) && u.EPFNo == epfNo));
    }

    public async Task<bool> DepartmentExistsAsync(int departmentId)
    {
        return await _context.Departments.AnyAsync(d => d.Id == departmentId);
    }

    public async Task<User> AddUserAsync(User user)
    {
        _context.Users.Add(user);
        return user;
    }

    public async Task UpdateUserAsync(User user)
    {
        _context.Users.Update(user);
    }

    public async Task<string?> GetUsernameByAnnualLeaveIdAsync(int annualLeaveId)
    {
        var leaveDetail = await _context.LeaveDetails
            .FirstOrDefaultAsync(ld => ld.annual_leave_id == annualLeaveId);

        if (leaveDetail == null)
        {
            return null;
        }

        var annualLeave = await _context.AnnualLeaves
            .FirstOrDefaultAsync(al => al.id == leaveDetail.annual_leave_id);

        if (annualLeave == null)
        {
            return null;
        }

        var user = await _context.Users
            .FirstOrDefaultAsync(u => u.Id == annualLeave.user_id);

        return user?.FullName;
    }

    public async Task SaveChangesAsync()
    {
        await _context.SaveChangesAsync();
    }
}
