using Microsoft.Data.SqlClient;
using Microsoft.Extensions.Configuration;
using React.Core.DTOs.Response;
using React.Core.Interfaces.Repositories;

namespace React.Infrastructure.Repositories;

public class LeaveRepository : ILeaveRepository
{
    private readonly string _connectionString;

    public LeaveRepository(IConfiguration configuration)
    {
        _connectionString = configuration.GetConnectionString("DefaultConnection")
            ?? throw new ArgumentNullException(nameof(configuration));
    }

    public async Task<IEnumerable<LeaveResponseDto>> GetAllLeavesAsync()
    {
        var leaves = new List<LeaveResponseDto>();
        using var conn = new SqlConnection(_connectionString);
        await conn.OpenAsync();

        string query = @"
            SELECT
                l.id, l.leave_date, l.no_of_days, l.reason, l.status,
                l.approved_by, l.approval_signature_id,
                u.id as user_id, u.full_name, u.nric,
                d.id as department_id, d.name as department_name
            FROM leave_detail l
            JOIN annual_leave al ON l.annual_leave_id = al.id
            JOIN users u ON al.user_id = u.id
            JOIN departments d ON u.department_id = d.id
            WHERE l.status IS NOT NULL";

        using var cmd = new SqlCommand(query, conn);
        using var reader = await cmd.ExecuteReaderAsync();

        while (await reader.ReadAsync())
        {
            leaves.Add(new LeaveResponseDto
            {
                Id = reader.GetInt32(0),
                LeaveDate = reader.GetDateTime(1),
                NumberOfDays = reader.GetDouble(2),
                Reason = reader.GetString(3),
                Status = reader.GetString(4),
                ApprovedBy = reader.IsDBNull(5) ? null : reader.GetInt32(5),
                ApprovalSignatureId = reader.IsDBNull(6) ? null : reader.GetInt32(6),
                User = new UserInfoDto
                {
                    Id = reader.GetInt32(7),
                    FullName = reader.GetString(8),
                    NRIC = reader.GetString(9),
                    Department = new DepartmentInfoDto
                    {
                        Id = reader.GetInt32(10),
                        Name = reader.GetString(11)
                    }
                }
            });
        }

        return leaves;
    }

    public async Task<IEnumerable<MedicalLeaveResponseDto>> GetAllMedicalLeavesAsync()
    {
        var leaves = new List<MedicalLeaveResponseDto>();
        using var conn = new SqlConnection(_connectionString);
        await conn.OpenAsync();

        string query = @"
            SELECT
                ml.id, ml.start_date, ml.end_date, ml.date_submission,
                ml.total_day, ml.reason, ml.status, NULL as approved_by,
                NULL as approval_signature_id, ml.url,
                u.id as user_id, u.full_name, u.nric,
                d.id as department_id, d.name as department_name
            FROM MC_Leave_Requests ml
            JOIN users u ON ml.id = u.id
            JOIN departments d ON u.department_id = d.id
            WHERE ml.status IS NOT NULL";

        using var cmd = new SqlCommand(query, conn);
        using var reader = await cmd.ExecuteReaderAsync();

        while (await reader.ReadAsync())
        {
            var urlBytes = reader["url"] as byte[];
            leaves.Add(new MedicalLeaveResponseDto
            {
                Id = reader.GetInt32(0),
                LeaveDate = reader.GetDateTime(1),
                EndDate = reader.GetDateTime(2),
                DateSubmission = reader.IsDBNull(3) ? null : reader.GetDateTime(3),
                NumberOfDays = reader.GetInt32(4),
                Reason = reader.GetString(5),
                Status = reader.GetString(6),
                ApprovedBy = reader.IsDBNull(7) ? null : reader.GetInt32(7),
                ApprovalSignatureId = reader.IsDBNull(8) ? null : reader.GetInt32(8),
                DocumentUrl = urlBytes != null ? Convert.ToBase64String(urlBytes) : null,
                User = new UserInfoDto
                {
                    Id = reader.GetInt32(10),
                    FullName = reader.GetString(11),
                    NRIC = reader.GetString(12),
                    Department = new DepartmentInfoDto
                    {
                        Id = reader.GetInt32(13),
                        Name = reader.GetString(14)
                    }
                }
            });
        }

        return leaves;
    }

    public async Task<LeaveResponseDto?> GetLeaveByIdAsync(int id)
    {
        using var conn = new SqlConnection(_connectionString);
        await conn.OpenAsync();

        string query = @"
            SELECT
                l.id, l.leave_date, l.no_of_days, l.reason, l.status,
                l.approved_by, l.approval_signature_id,
                u.id as user_id, u.full_name, u.nric,
                d.id as department_id, d.name as department_name
            FROM leave_detail l
            JOIN annual_leave al ON l.annual_leave_id = al.id
            JOIN users u ON al.user_id = u.id
            JOIN departments d ON u.department_id = d.id
            WHERE l.id = @Id";

        using var cmd = new SqlCommand(query, conn);
        cmd.Parameters.AddWithValue("@Id", id);
        using var reader = await cmd.ExecuteReaderAsync();

        if (await reader.ReadAsync())
        {
            return new LeaveResponseDto
            {
                Id = reader.GetInt32(0),
                LeaveDate = reader.GetDateTime(1),
                NumberOfDays = reader.GetDouble(2),
                Reason = reader.GetString(3),
                Status = reader.GetString(4),
                ApprovedBy = reader.IsDBNull(5) ? null : reader.GetInt32(5),
                ApprovalSignatureId = reader.IsDBNull(6) ? null : reader.GetInt32(6),
                User = new UserInfoDto
                {
                    Id = reader.GetInt32(7),
                    FullName = reader.GetString(8),
                    NRIC = reader.GetString(9),
                    Department = new DepartmentInfoDto
                    {
                        Id = reader.GetInt32(10),
                        Name = reader.GetString(11)
                    }
                }
            };
        }

        return null;
    }

    public async Task<MedicalLeaveResponseDto?> GetMedicalLeaveByIdAsync(int id)
    {
        using var conn = new SqlConnection(_connectionString);
        await conn.OpenAsync();

        string query = @"
            SELECT
                ml.MC_RequestId, ml.start_date, ml.end_date, ml.date_submission,
                ml.total_day, ml.reason, ml.status, ml.approved_by,
                ml.approval_signature_id, ml.url,
                u.id as user_id, u.full_name, u.nric,
                d.id as department_id, d.name as department_name
            FROM MC_Leave_Requests ml
            JOIN users u ON ml.id = u.id
            JOIN departments d ON u.department_id = d.id
            WHERE ml.MC_RequestId = @Id";

        using var cmd = new SqlCommand(query, conn);
        cmd.Parameters.AddWithValue("@Id", id);
        using var reader = await cmd.ExecuteReaderAsync();

        if (await reader.ReadAsync())
        {
            var urlBytes = reader["url"] as byte[];
            return new MedicalLeaveResponseDto
            {
                Id = reader.GetInt32(0),
                LeaveDate = reader.GetDateTime(1),
                EndDate = reader.GetDateTime(2),
                DateSubmission = reader.IsDBNull(3) ? null : reader.GetDateTime(3),
                NumberOfDays = reader.GetInt32(4),
                Reason = reader.GetString(5),
                Status = reader.GetString(6),
                ApprovedBy = reader.IsDBNull(7) ? null : reader.GetInt32(7),
                ApprovalSignatureId = reader.IsDBNull(8) ? null : reader.GetInt32(8),
                DocumentUrl = urlBytes != null ? Convert.ToBase64String(urlBytes) : null,
                User = new UserInfoDto
                {
                    Id = reader.GetInt32(10),
                    FullName = reader.GetString(11),
                    NRIC = reader.GetString(12),
                    Department = new DepartmentInfoDto
                    {
                        Id = reader.GetInt32(13),
                        Name = reader.GetString(14)
                    }
                }
            };
        }

        return null;
    }

    public async Task<bool> UpdateLeaveStatusAsync(int id, string status, int approvedBy, int? approvalSignatureId)
    {
        using var conn = new SqlConnection(_connectionString);
        await conn.OpenAsync();

        string query = @"
            UPDATE leave_detail
            SET status = @Status, approved_by = @ApprovedBy, approval_signature_id = @ApprovalSignatureId
            WHERE id = @Id";

        using var cmd = new SqlCommand(query, conn);
        cmd.Parameters.AddWithValue("@Id", id);
        cmd.Parameters.AddWithValue("@Status", status);
        cmd.Parameters.AddWithValue("@ApprovedBy", approvedBy);
        cmd.Parameters.AddWithValue("@ApprovalSignatureId", approvalSignatureId ?? (object)DBNull.Value);

        return await cmd.ExecuteNonQueryAsync() > 0;
    }

    public async Task<bool> UpdateMedicalLeaveStatusAsync(int id, string status, int approvedBy, int? approvalSignatureId)
    {
        using var conn = new SqlConnection(_connectionString);
        await conn.OpenAsync();

        string query = @"
            UPDATE MC_Leave_Requests
            SET status = @Status, approved_by = @ApprovedBy, approval_signature_id = @ApprovalSignatureId
            WHERE MC_RequestId = @Id";

        using var cmd = new SqlCommand(query, conn);
        cmd.Parameters.AddWithValue("@Id", id);
        cmd.Parameters.AddWithValue("@Status", status);
        cmd.Parameters.AddWithValue("@ApprovedBy", approvedBy);
        cmd.Parameters.AddWithValue("@ApprovalSignatureId", approvalSignatureId ?? (object)DBNull.Value);

        return await cmd.ExecuteNonQueryAsync() > 0;
    }
}
