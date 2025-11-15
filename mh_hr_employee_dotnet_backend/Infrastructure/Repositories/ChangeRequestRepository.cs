using Microsoft.Data.SqlClient;
using Microsoft.Extensions.Configuration;
using React.Core.DTOs.Response;
using React.Core.Interfaces.Repositories;

namespace React.Infrastructure.Repositories;

public class ChangeRequestRepository : IChangeRequestRepository
{
    private readonly string _connectionString;

    public ChangeRequestRepository(IConfiguration configuration)
    {
        _connectionString = configuration.GetConnectionString("DefaultConnection")
            ?? throw new ArgumentNullException(nameof(configuration));
    }

    public async Task<IEnumerable<ChangeRequestListResponseDto>> GetAllChangeRequestsAsync()
    {
        var changeRequests = new List<ChangeRequestListResponseDto>();
        using var connection = new SqlConnection(_connectionString);
        await connection.OpenAsync();

        string query = @"
            SELECT
                cr.id,
                u.full_name as RequesterName,
                d.name as Department,
                cr.date_requested,
                cr.status,
                fap.product_code as ProductCode,
                cr.reason
            FROM ChangeRequests cr
            JOIN users u ON cr.requester_id = u.id
            JOIN departments d ON u.department_id = d.id
            LEFT JOIN fixed_asset_products fap ON fap.change_request_id = cr.id
            ORDER BY cr.date_requested DESC";

        using var cmd = new SqlCommand(query, connection);
        using var reader = await cmd.ExecuteReaderAsync();

        while (await reader.ReadAsync())
        {
            changeRequests.Add(new ChangeRequestListResponseDto
            {
                Id = reader.GetInt32(reader.GetOrdinal("id")),
                RequesterName = reader.GetString(reader.GetOrdinal("RequesterName")),
                Department = reader.GetString(reader.GetOrdinal("Department")),
                DateRequested = reader.GetDateTime(reader.GetOrdinal("date_requested")),
                Status = reader.GetString(reader.GetOrdinal("status")),
                ProductCode = reader.IsDBNull(reader.GetOrdinal("ProductCode"))
                    ? null : reader.GetString(reader.GetOrdinal("ProductCode")),
                Reason = reader.IsDBNull(reader.GetOrdinal("reason"))
                    ? null : reader.GetString(reader.GetOrdinal("reason"))
            });
        }

        return changeRequests;
    }

    public async Task<IEnumerable<ChangeRequestListResponseDto>> GetApprovedChangeRequestsAsync()
    {
        var changeRequests = new List<ChangeRequestListResponseDto>();
        using var connection = new SqlConnection(_connectionString);
        await connection.OpenAsync();

        string query = @"
            SELECT
                cr.id,
                u.full_name as RequesterName,
                d.name as Department,
                cr.date_requested,
                cr.status,
                fap.product_code as ProductCode,
                cr.reason
            FROM ChangeRequests cr
            JOIN users u ON cr.requester_id = u.id
            JOIN departments d ON u.department_id = d.id
            LEFT JOIN fixed_asset_products fap ON fap.change_request_id = cr.id
            WHERE cr.status = 'approved'
                AND (cr.return_status IS NULL OR cr.return_status != 'approved_return')
            ORDER BY cr.date_requested DESC";

        using var cmd = new SqlCommand(query, connection);
        using var reader = await cmd.ExecuteReaderAsync();

        while (await reader.ReadAsync())
        {
            changeRequests.Add(new ChangeRequestListResponseDto
            {
                Id = reader.GetInt32(reader.GetOrdinal("id")),
                RequesterName = reader.GetString(reader.GetOrdinal("RequesterName")),
                Department = reader.GetString(reader.GetOrdinal("Department")),
                DateRequested = reader.GetDateTime(reader.GetOrdinal("date_requested")),
                Status = reader.GetString(reader.GetOrdinal("status")),
                ProductCode = reader.IsDBNull(reader.GetOrdinal("ProductCode"))
                    ? null : reader.GetString(reader.GetOrdinal("ProductCode")),
                Reason = reader.IsDBNull(reader.GetOrdinal("reason"))
                    ? null : reader.GetString(reader.GetOrdinal("reason"))
            });
        }

        return changeRequests;
    }

    public async Task<ChangeRequestDetailsResponseDto?> GetChangeRequestDetailsByIdAsync(int id)
    {
        using var connection = new SqlConnection(_connectionString);
        await connection.OpenAsync();

        string query = @"
            SELECT
                cr.id,
                u.full_name as RequesterName,
                d.name as Department,
                cr.date_requested,
                cr.status,
                cr.description,
                cr.reason,
                cr.risk,
                cr.instruction,
                cr.complete_date,
                cr.post_review,
                s.points,
                s.boundary_width,
                s.boundary_height,
                approver.full_name as ApproverName,
                cr.date_approved as DateApproved,
                approval_sig.points as ApprovalPoints,
                approval_sig.boundary_width as ApprovalBoundaryWidth,
                approval_sig.boundary_height as ApprovalBoundaryHeight
            FROM ChangeRequests cr
            JOIN users u ON cr.requester_id = u.id
            JOIN departments d ON u.department_id = d.id
            JOIN signatures s ON cr.signature_id = s.id
            LEFT JOIN users approver ON cr.approver_id = approver.id
            LEFT JOIN signatures approval_sig ON cr.approval_signature_id = approval_sig.id
            WHERE cr.id = @RequestId";

        using var cmd = new SqlCommand(query, connection);
        cmd.Parameters.AddWithValue("@RequestId", id);

        using var reader = await cmd.ExecuteReaderAsync();
        if (await reader.ReadAsync())
        {
            var details = new ChangeRequestDetailsResponseDto
            {
                Id = reader.GetInt32(reader.GetOrdinal("id")),
                RequesterName = reader.GetString(reader.GetOrdinal("RequesterName")),
                Department = reader.GetString(reader.GetOrdinal("Department")),
                DateRequested = reader.GetDateTime(reader.GetOrdinal("date_requested")),
                Status = reader.GetString(reader.GetOrdinal("status")),
                Description = reader.IsDBNull(reader.GetOrdinal("description"))
                    ? null : reader.GetString(reader.GetOrdinal("description")),
                Reason = reader.IsDBNull(reader.GetOrdinal("reason"))
                    ? null : reader.GetString(reader.GetOrdinal("reason")),
                Risk = reader.IsDBNull(reader.GetOrdinal("risk"))
                    ? null : reader.GetString(reader.GetOrdinal("risk")),
                Instruction = reader.IsDBNull(reader.GetOrdinal("instruction"))
                    ? null : reader.GetString(reader.GetOrdinal("instruction")),
                CompleteDate = reader.IsDBNull(reader.GetOrdinal("complete_date"))
                    ? null : reader.GetDateTime(reader.GetOrdinal("complete_date")),
                PostReview = reader.IsDBNull(reader.GetOrdinal("post_review"))
                    ? null : reader.GetString(reader.GetOrdinal("post_review")),
                Signature = new SignatureResponseDto
                {
                    Points = reader.GetString(reader.GetOrdinal("points")),
                    BoundaryWidth = (float)reader.GetDouble(reader.GetOrdinal("boundary_width")),
                    BoundaryHeight = (float)reader.GetDouble(reader.GetOrdinal("boundary_height"))
                }
            };

            if (!reader.IsDBNull(reader.GetOrdinal("ApproverName")))
            {
                details.ApproverName = reader.GetString(reader.GetOrdinal("ApproverName"));
            }

            if (!reader.IsDBNull(reader.GetOrdinal("DateApproved")))
            {
                details.DateApproved = reader.GetDateTime(reader.GetOrdinal("DateApproved"));
            }

            if (!reader.IsDBNull(reader.GetOrdinal("ApprovalPoints")))
            {
                details.ApprovalSignature = new SignatureResponseDto
                {
                    Points = reader.GetString(reader.GetOrdinal("ApprovalPoints")),
                    BoundaryWidth = (float)reader.GetDouble(reader.GetOrdinal("ApprovalBoundaryWidth")),
                    BoundaryHeight = (float)reader.GetDouble(reader.GetOrdinal("ApprovalBoundaryHeight"))
                };
            }

            return details;
        }

        return null;
    }

    public async Task<IEnumerable<ChangeRequestListResponseDto>> GetPendingChangeRequestsAsync()
    {
        var changeRequests = new List<ChangeRequestListResponseDto>();
        using var connection = new SqlConnection(_connectionString);
        await connection.OpenAsync();

        string query = @"
            SELECT
                cr.id,
                u.full_name as RequesterName,
                d.name as Department,
                cr.date_requested,
                cr.status
            FROM ChangeRequests cr
            JOIN users u ON cr.requester_id = u.id
            JOIN departments d ON u.department_id = d.id
            WHERE cr.status = 'pending'
            ORDER BY cr.date_requested DESC";

        using var cmd = new SqlCommand(query, connection);
        using var reader = await cmd.ExecuteReaderAsync();

        while (await reader.ReadAsync())
        {
            changeRequests.Add(new ChangeRequestListResponseDto
            {
                Id = reader.GetInt32(reader.GetOrdinal("id")),
                RequesterName = reader.GetString(reader.GetOrdinal("RequesterName")),
                Department = reader.GetString(reader.GetOrdinal("Department")),
                DateRequested = reader.GetDateTime(reader.GetOrdinal("date_requested")),
                Status = reader.GetString(reader.GetOrdinal("status"))
            });
        }

        return changeRequests;
    }

    public async Task<IEnumerable<FixedAssetTypeResponseDto>> GetFixedAssetTypesAsync()
    {
        var fixedAssetTypes = new List<FixedAssetTypeResponseDto>();
        using var connection = new SqlConnection(_connectionString);
        await connection.OpenAsync();

        string query = "SELECT id, code, name FROM fixed_asset_types";

        using var cmd = new SqlCommand(query, connection);
        using var reader = await cmd.ExecuteReaderAsync();

        while (await reader.ReadAsync())
        {
            fixedAssetTypes.Add(new FixedAssetTypeResponseDto
            {
                Id = reader.GetInt32(reader.GetOrdinal("id")),
                Code = reader.GetString(reader.GetOrdinal("code")),
                Name = reader.GetString(reader.GetOrdinal("name"))
            });
        }

        return fixedAssetTypes;
    }

    public async Task<string?> GetChangeRequestCurrentStatusAsync(int id)
    {
        using var connection = new SqlConnection(_connectionString);
        await connection.OpenAsync();

        string checkQuery = "SELECT status FROM ChangeRequests WHERE id = @RequestId";

        using var cmd = new SqlCommand(checkQuery, connection);
        cmd.Parameters.AddWithValue("@RequestId", id);

        var result = await cmd.ExecuteScalarAsync();
        return result?.ToString();
    }

    public async Task<int> CreateSignatureAsync(int userId, string points, float boundaryWidth, float boundaryHeight)
    {
        using var connection = new SqlConnection(_connectionString);
        await connection.OpenAsync();

        string signatureQuery = @"
            INSERT INTO signatures (user_id, points, boundary_width, boundary_height)
            VALUES (@UserId, @Points, @Width, @Height);
            SELECT SCOPE_IDENTITY();";

        using var cmd = new SqlCommand(signatureQuery, connection);
        cmd.Parameters.AddWithValue("@UserId", userId);
        cmd.Parameters.AddWithValue("@Points", points);
        cmd.Parameters.AddWithValue("@Width", boundaryWidth);
        cmd.Parameters.AddWithValue("@Height", boundaryHeight);

        return Convert.ToInt32(await cmd.ExecuteScalarAsync());
    }

    public async Task<string> GetFixedAssetTypeCodeAsync(int fixedAssetTypeId)
    {
        using var connection = new SqlConnection(_connectionString);
        await connection.OpenAsync();

        string query = "SELECT code FROM fixed_asset_types WHERE id = @FixedAssetTypeId";

        using var cmd = new SqlCommand(query, connection);
        cmd.Parameters.AddWithValue("@FixedAssetTypeId", fixedAssetTypeId);

        return (string)await cmd.ExecuteScalarAsync();
    }

    public async Task<int> CreateFixedAssetProductAsync(string productCode, int changeRequestId)
    {
        using var connection = new SqlConnection(_connectionString);
        await connection.OpenAsync();

        string insertProductQuery = @"
            INSERT INTO fixed_asset_products (product_code, change_request_id)
            VALUES (@ProductCode, @ChangeRequestId);
            SELECT SCOPE_IDENTITY();";

        using var cmd = new SqlCommand(insertProductQuery, connection);
        cmd.Parameters.AddWithValue("@ProductCode", productCode);
        cmd.Parameters.AddWithValue("@ChangeRequestId", changeRequestId);

        return Convert.ToInt32(await cmd.ExecuteScalarAsync());
    }

    public async Task<bool> UpdateChangeRequestStatusAsync(int id, string status, int approverId, DateTime? dateApproved, int? approvalSignatureId, int? fixedAssetTypeId)
    {
        using var connection = new SqlConnection(_connectionString);
        await connection.OpenAsync();

        string updateQuery = @"
            UPDATE ChangeRequests
            SET
                status = @Status,
                approver_id = @ApproverId,
                date_approved = @DateApproved,
                approval_signature_id = @ApprovalSignatureId,
                fixed_asset_type_id = @FixedAssetTypeId
            WHERE id = @RequestId";

        using var cmd = new SqlCommand(updateQuery, connection);
        cmd.Parameters.AddWithValue("@RequestId", id);
        cmd.Parameters.AddWithValue("@Status", status);
        cmd.Parameters.AddWithValue("@ApproverId", approverId);
        cmd.Parameters.AddWithValue("@DateApproved", dateApproved ?? (object)DBNull.Value);
        cmd.Parameters.AddWithValue("@ApprovalSignatureId", approvalSignatureId.HasValue ? (object)approvalSignatureId.Value : DBNull.Value);
        cmd.Parameters.AddWithValue("@FixedAssetTypeId", fixedAssetTypeId.HasValue ? (object)fixedAssetTypeId.Value : DBNull.Value);

        int rowsAffected = await cmd.ExecuteNonQueryAsync();
        return rowsAffected > 0;
    }

    public async Task<bool> ChangeRequestStatusSimpleAsync(int id, string status, int approverId)
    {
        using var connection = new SqlConnection(_connectionString);
        await connection.OpenAsync();

        string updateQuery = @"
            UPDATE ChangeRequests
            SET
                status = @Status,
                approver_id = @ApproverId,
                date_approved = @DateApproved
            WHERE id = @RequestId";

        using var cmd = new SqlCommand(updateQuery, connection);
        cmd.Parameters.AddWithValue("@RequestId", id);
        cmd.Parameters.AddWithValue("@Status", status);
        cmd.Parameters.AddWithValue("@ApproverId", approverId);
        cmd.Parameters.AddWithValue("@DateApproved", DateTime.Now);

        int rowsAffected = await cmd.ExecuteNonQueryAsync();
        return rowsAffected > 0;
    }
}
