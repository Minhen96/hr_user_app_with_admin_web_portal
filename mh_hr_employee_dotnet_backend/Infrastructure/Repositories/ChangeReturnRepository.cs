using Microsoft.Data.SqlClient;
using Microsoft.Extensions.Configuration;
using React.Core.DTOs.Response;
using React.Core.Interfaces.Repositories;

namespace React.Infrastructure.Repositories;

public class ChangeReturnRepository : IChangeReturnRepository
{
    private readonly string _connectionString;

    public ChangeReturnRepository(IConfiguration configuration)
    {
        _connectionString = configuration.GetConnectionString("DefaultConnection")
            ?? throw new ArgumentNullException(nameof(configuration));
    }

    public async Task<IEnumerable<ChangeReturnListResponseDto>> GetAllChangeReturnsAsync()
    {
        var changeReturns = new List<ChangeReturnListResponseDto>();
        using var connection = new SqlConnection(_connectionString);
        await connection.OpenAsync();

        string query = @"
            SELECT
                cr.id,
                u.full_name as RequesterName,
                d.name as Department,
                cr.date_returned,
                cr.return_status,
                cr.reason
            FROM ChangeRequests cr
            JOIN users u ON cr.requester_id = u.id
            JOIN departments d ON u.department_id = d.id
            WHERE cr.return_status IS NOT NULL AND cr.return_status != 'in_use'
            ORDER BY cr.date_returned DESC";

        using var cmd = new SqlCommand(query, connection);
        using var reader = await cmd.ExecuteReaderAsync();

        while (await reader.ReadAsync())
        {
            changeReturns.Add(new ChangeReturnListResponseDto
            {
                Id = reader.GetInt32(reader.GetOrdinal("id")),
                RequesterName = reader.GetString(reader.GetOrdinal("RequesterName")),
                Department = reader.GetString(reader.GetOrdinal("Department")),
                DateReturned = reader.GetDateTime(reader.GetOrdinal("date_returned")),
                ReturnStatus = reader.GetString(reader.GetOrdinal("return_status")),
                Reason = reader.IsDBNull(reader.GetOrdinal("reason"))
                    ? null : reader.GetString(reader.GetOrdinal("reason"))
            });
        }

        return changeReturns;
    }

    public async Task<ChangeReturnDetailsResponseDto?> GetChangeReturnDetailsByIdAsync(int id)
    {
        using var connection = new SqlConnection(_connectionString);
        await connection.OpenAsync();

        string query = @"
            SELECT
                cr.id,
                u.full_name as RequesterName,
                d.name as Department,
                cr.date_returned,
                cr.return_status,
                cr.received_details,
                cr.reason,
                fap.product_code as ProductCode
            FROM ChangeRequests cr
            JOIN users u ON cr.requester_id = u.id
            JOIN departments d ON u.department_id = d.id
            LEFT JOIN fixed_asset_products fap ON fap.change_request_id = cr.id
            WHERE cr.id = @RequestId";

        using var cmd = new SqlCommand(query, connection);
        cmd.Parameters.AddWithValue("@RequestId", id);

        using var reader = await cmd.ExecuteReaderAsync();
        if (await reader.ReadAsync())
        {
            return new ChangeReturnDetailsResponseDto
            {
                Id = reader.GetInt32(reader.GetOrdinal("id")),
                RequesterName = reader.GetString(reader.GetOrdinal("RequesterName")),
                Department = reader.GetString(reader.GetOrdinal("Department")),
                DateReturned = reader.GetDateTime(reader.GetOrdinal("date_returned")),
                ReturnStatus = reader.GetString(reader.GetOrdinal("return_status")),
                ReceivedDetails = reader.IsDBNull(reader.GetOrdinal("received_details"))
                    ? null : reader.GetString(reader.GetOrdinal("received_details")),
                Reason = reader.IsDBNull(reader.GetOrdinal("reason"))
                    ? null : reader.GetString(reader.GetOrdinal("reason")),
                ProductCode = reader.IsDBNull(reader.GetOrdinal("ProductCode"))
                    ? null : reader.GetString(reader.GetOrdinal("ProductCode"))
            };
        }

        return null;
    }

    public async Task<bool> UpdateChangeReturnStatusAsync(int id, string returnStatus, int approverId)
    {
        using var connection = new SqlConnection(_connectionString);
        await connection.OpenAsync();

        string updateQuery = @"
            UPDATE ChangeRequests
            SET
                return_status = @ReturnStatus,
                approver_id = @ApproverId
            WHERE id = @RequestId";

        using var cmd = new SqlCommand(updateQuery, connection);
        cmd.Parameters.AddWithValue("@RequestId", id);
        cmd.Parameters.AddWithValue("@ReturnStatus", returnStatus);
        cmd.Parameters.AddWithValue("@ApproverId", approverId);

        int rowsAffected = await cmd.ExecuteNonQueryAsync();
        return rowsAffected > 0;
    }

    public async Task<string?> GetChangeReturnCurrentStatusAsync(int id)
    {
        using var connection = new SqlConnection(_connectionString);
        await connection.OpenAsync();

        string checkQuery = "SELECT return_status FROM ChangeRequests WHERE id = @RequestId";

        using var cmd = new SqlCommand(checkQuery, connection);
        cmd.Parameters.AddWithValue("@RequestId", id);

        var result = await cmd.ExecuteScalarAsync();
        return result?.ToString();
    }
}
