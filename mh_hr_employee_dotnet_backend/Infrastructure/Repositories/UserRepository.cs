using Microsoft.Data.SqlClient;
using Microsoft.Extensions.Configuration;
using React.Core.DTOs.Response;
using React.Core.Interfaces.Repositories;
using React.Models;

namespace React.Infrastructure.Repositories;

/// <summary>
/// Repository implementation for User entity using ADO.NET
/// </summary>
public class UserRepository : IUserRepository
{
    private readonly string _connectionString;

    public UserRepository(IConfiguration configuration)
    {
        _connectionString = configuration.GetConnectionString("DefaultConnection")
            ?? throw new ArgumentNullException(nameof(configuration), "Connection string not found");
    }

    public async Task<User?> GetByEmailAsync(string email)
    {
        try
        {
            using var connection = new SqlConnection(_connectionString);
            await connection.OpenAsync();

            string query = @"
                SELECT u.id, u.full_name, u.nric, u.tin, u.epf_no, u.email,
                       u.department_id, d.name as department_name, u.role, u.status, u.password
                FROM users u
                LEFT JOIN departments d ON u.department_id = d.id
                WHERE u.email = @Email";

            using var command = new SqlCommand(query, connection);
            command.Parameters.AddWithValue("@Email", email);

            using var reader = await command.ExecuteReaderAsync();
            if (await reader.ReadAsync())
            {
                return new User
                {
                    Id = reader.GetInt32(reader.GetOrdinal("id")),
                    FullName = reader.GetString(reader.GetOrdinal("full_name")),
                    NRIC = reader.GetString(reader.GetOrdinal("nric")),
                    TIN = reader.IsDBNull(reader.GetOrdinal("tin")) ? null : reader.GetString(reader.GetOrdinal("tin")),
                    EPFNo = reader.IsDBNull(reader.GetOrdinal("epf_no")) ? null : reader.GetString(reader.GetOrdinal("epf_no")),
                    Email = reader.GetString(reader.GetOrdinal("email")),
                    DepartmentId = reader.GetInt32(reader.GetOrdinal("department_id")),
                    Role = reader.GetString(reader.GetOrdinal("role")),
                    Status = reader.GetString(reader.GetOrdinal("status")),
                    Password = reader.GetString(reader.GetOrdinal("password"))
                };
            }

            return null;
        }
        catch (Exception ex)
        {
            throw new Exception($"Error retrieving user by email: {ex.Message}", ex);
        }
    }

    public async Task<User?> GetByIdAsync(int id)
    {
        try
        {
            using var connection = new SqlConnection(_connectionString);
            await connection.OpenAsync();

            string query = @"
                SELECT u.id, u.full_name, u.nric, u.tin, u.epf_no, u.email,
                       u.department_id, d.name as department_name, u.role, u.status, u.password
                FROM users u
                LEFT JOIN departments d ON u.department_id = d.id
                WHERE u.id = @Id";

            using var command = new SqlCommand(query, connection);
            command.Parameters.AddWithValue("@Id", id);

            using var reader = await command.ExecuteReaderAsync();
            if (await reader.ReadAsync())
            {
                return new User
                {
                    Id = reader.GetInt32(reader.GetOrdinal("id")),
                    FullName = reader.GetString(reader.GetOrdinal("full_name")),
                    NRIC = reader.GetString(reader.GetOrdinal("nric")),
                    TIN = reader.IsDBNull(reader.GetOrdinal("tin")) ? null : reader.GetString(reader.GetOrdinal("tin")),
                    EPFNo = reader.IsDBNull(reader.GetOrdinal("epf_no")) ? null : reader.GetString(reader.GetOrdinal("epf_no")),
                    Email = reader.GetString(reader.GetOrdinal("email")),
                    DepartmentId = reader.GetInt32(reader.GetOrdinal("department_id")),
                    Role = reader.GetString(reader.GetOrdinal("role")),
                    Status = reader.GetString(reader.GetOrdinal("status")),
                    Password = reader.GetString(reader.GetOrdinal("password"))
                };
            }

            return null;
        }
        catch (Exception ex)
        {
            throw new Exception($"Error retrieving user by ID: {ex.Message}", ex);
        }
    }

    public async Task<IEnumerable<PasswordChangeResponseDto>> GetPendingPasswordChangesAsync()
    {
        var results = new List<PasswordChangeResponseDto>();

        try
        {
            using var connection = new SqlConnection(_connectionString);
            await connection.OpenAsync();

            string query = @"
                SELECT
                    u.id,
                    u.full_name as FullName,
                    d.name as Department,
                    u.change_password_date,
                    u.status
                FROM users u
                JOIN departments d ON u.department_id = d.id
                WHERE u.status = 'pending'
                ORDER BY
                    CASE
                        WHEN u.status = 'pending' THEN 1
                        WHEN u.status = 'approved' THEN 2
                        WHEN u.status = 'rejected' THEN 3
                        ELSE 4
                    END,
                    u.change_password_date DESC";

            using var command = new SqlCommand(query, connection);
            using var reader = await command.ExecuteReaderAsync();

            while (await reader.ReadAsync())
            {
                results.Add(new PasswordChangeResponseDto
                {
                    Id = reader.GetInt32(reader.GetOrdinal("id")),
                    FullName = reader.GetString(reader.GetOrdinal("FullName")),
                    Department = reader.GetString(reader.GetOrdinal("Department")),
                    ChangePasswordDate = reader.IsDBNull(reader.GetOrdinal("change_password_date"))
                        ? null
                        : reader.GetDateTime(reader.GetOrdinal("change_password_date")),
                    Status = reader.GetString(reader.GetOrdinal("status"))
                });
            }

            return results;
        }
        catch (Exception ex)
        {
            throw new Exception($"Error retrieving pending password changes: {ex.Message}", ex);
        }
    }

    public async Task<bool> UpdatePasswordStatusAsync(int userId, string status, int approverId, DateTime dateApproved)
    {
        try
        {
            using var connection = new SqlConnection(_connectionString);
            await connection.OpenAsync();

            string updateQuery = @"
                UPDATE users
                SET status = @Status
                WHERE id = @UserId;

                INSERT INTO user_status_audits (
                    user_id,
                    approver_id,
                    status,
                    date_modified
                )
                VALUES (
                    @UserId,
                    @ApproverId,
                    @Status,
                    @DateApproved
                )";

            using var command = new SqlCommand(updateQuery, connection);
            command.Parameters.AddWithValue("@UserId", userId);
            command.Parameters.AddWithValue("@Status", status);
            command.Parameters.AddWithValue("@ApproverId", approverId);
            command.Parameters.AddWithValue("@DateApproved", dateApproved);

            int rowsAffected = await command.ExecuteNonQueryAsync();
            return rowsAffected > 0;
        }
        catch (Exception ex)
        {
            throw new Exception($"Error updating password status: {ex.Message}", ex);
        }
    }

    public async Task<string?> GetUserPasswordStatusAsync(int userId)
    {
        try
        {
            using var connection = new SqlConnection(_connectionString);
            await connection.OpenAsync();

            string query = "SELECT status FROM users WHERE id = @UserId";

            using var command = new SqlCommand(query, connection);
            command.Parameters.AddWithValue("@UserId", userId);

            var result = await command.ExecuteScalarAsync();
            return result?.ToString();
        }
        catch (Exception ex)
        {
            throw new Exception($"Error retrieving user status: {ex.Message}", ex);
        }
    }

    public async Task<bool> UpdatePasswordAsync(int userId, string hashedPassword)
    {
        try
        {
            using var connection = new SqlConnection(_connectionString);
            await connection.OpenAsync();

            string query = @"
                UPDATE users
                SET password = @Password, change_password_date = @ChangeDate
                WHERE id = @UserId";

            using var command = new SqlCommand(query, connection);
            command.Parameters.AddWithValue("@UserId", userId);
            command.Parameters.AddWithValue("@Password", hashedPassword);
            command.Parameters.AddWithValue("@ChangeDate", DateTime.UtcNow);

            int rowsAffected = await command.ExecuteNonQueryAsync();
            return rowsAffected > 0;
        }
        catch (Exception ex)
        {
            throw new Exception($"Error updating password: {ex.Message}", ex);
        }
    }
}
