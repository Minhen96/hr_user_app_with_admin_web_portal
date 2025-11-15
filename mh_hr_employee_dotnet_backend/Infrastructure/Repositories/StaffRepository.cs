using Microsoft.Data.SqlClient;
using Microsoft.Extensions.Configuration;
using React.Core.DTOs.Response;
using React.Core.Interfaces.Repositories;

namespace React.Infrastructure.Repositories;

public class StaffRepository : IStaffRepository
{
    private readonly string _connectionString;

    public StaffRepository(IConfiguration configuration)
    {
        _connectionString = configuration.GetConnectionString("DefaultConnection")
            ?? throw new ArgumentNullException(nameof(configuration));
    }

    public async Task<IEnumerable<StaffResponseDto>> GetAllStaffAsync()
    {
        var staff = new List<StaffResponseDto>();
        using var conn = new SqlConnection(_connectionString);
        await conn.OpenAsync();

        string query = @"
            SELECT u.id, u.full_name, u.nric, u.tin, u.epf_no,
                   d.name as department, u.email, u.role, u.date_joined,
                   u.active_status, u.birthday
            FROM users u
            JOIN departments d ON u.department_id = d.id
            ORDER BY u.date_joined DESC";

        using var cmd = new SqlCommand(query, conn);
        using var reader = await cmd.ExecuteReaderAsync();

        while (await reader.ReadAsync())
        {
            staff.Add(new StaffResponseDto
            {
                Id = reader.GetInt32(0),
                FullName = reader.GetString(1),
                Nric = reader.GetString(2),
                Tin = reader.IsDBNull(3) ? null : reader.GetString(3),
                Epf = reader.IsDBNull(4) ? null : reader.GetString(4),
                Department = reader.GetString(5),
                Email = reader.GetString(6),
                Role = reader.GetString(7),
                DateJoined = reader.GetDateTime(8),
                ActiveStatus = reader.IsDBNull(9) ? "active" : reader.GetString(9),
                Birthday = reader.IsDBNull(10) ? DateOnly.MinValue : DateOnly.FromDateTime(reader.GetDateTime(10))
            });
        }

        return staff;
    }

    public async Task<StaffLeaveDetailsDto?> GetStaffLeaveDetailsAsync(int userId)
    {
        using var conn = new SqlConnection(_connectionString);
        await conn.OpenAsync();

        string entitlementQuery = @"
        SELECT
            al.entitlement,
            ISNULL(SUM(CASE WHEN ld.status = 'Approved' THEN ld.no_of_days ELSE 0 END), 0) AS taken,
            al.entitlement - ISNULL(SUM(CASE WHEN ld.status = 'Approved' THEN ld.no_of_days ELSE 0 END), 0) AS balance
        FROM annual_leave al
        LEFT JOIN leave_detail ld ON al.id = ld.annual_leave_id
        WHERE al.user_id = @UserId
        GROUP BY al.id, al.entitlement";

        using var cmd = new SqlCommand(entitlementQuery, conn);
        cmd.Parameters.AddWithValue("@UserId", userId);

        using var reader = await cmd.ExecuteReaderAsync();

        if (await reader.ReadAsync())
        {
            return new StaffLeaveDetailsDto
            {
                Entitlement = reader.GetInt32(0),
                Taken = (float)reader.GetDouble(1),
                Balance = (float)reader.GetDouble(2)
            };
        }

        // ? No record found — handle gracefully
        return new StaffLeaveDetailsDto
        {
            Entitlement = 0,
            Taken = 0,
            Balance = 14
        };
    }

}
