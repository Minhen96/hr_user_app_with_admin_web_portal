using Microsoft.Data.SqlClient;
using Microsoft.Extensions.Configuration;
using React.Core.DTOs.Response;
using React.Core.Interfaces.Repositories;
using System.Data;

namespace React.Infrastructure.Repositories;

public class EquipmentReturnRepository : IEquipmentReturnRepository
{
    private readonly string _connectionString;

    public EquipmentReturnRepository(IConfiguration configuration)
    {
        _connectionString = configuration.GetConnectionString("DefaultConnection")
            ?? throw new ArgumentNullException(nameof(configuration));
    }

    public async Task<IEnumerable<EquipmentReturnListResponseDto>> GetAllReturnsAsync()
    {
        var returns = new List<EquipmentReturnListResponseDto>();
        using var connection = new SqlConnection(_connectionString);
        await connection.OpenAsync();

        string query = @"
            SELECT
                er.id,
                u.full_name as ReturnerName,
                d.name as Department,
                er.date_return,
                er.status
            FROM equipment_return er
            JOIN users u ON er.returner_id = u.id
            JOIN departments d ON u.department_id = d.id
            ORDER BY er.date_return DESC";

        using var cmd = new SqlCommand(query, connection);
        using var reader = await cmd.ExecuteReaderAsync();

        while (await reader.ReadAsync())
        {
            returns.Add(new EquipmentReturnListResponseDto
            {
                Id = reader.GetInt32(reader.GetOrdinal("id")),
                ReturnerName = reader.GetString(reader.GetOrdinal("ReturnerName")),
                Department = reader.GetString(reader.GetOrdinal("Department")),
                DateReturn = reader.GetDateTime(reader.GetOrdinal("date_return")),
                Status = reader.GetString(reader.GetOrdinal("status"))
            });
        }

        return returns;
    }

    public async Task<EquipmentReturnDetailsResponseDto?> GetReturnDetailsByIdAsync(int id)
    {
        using var connection = new SqlConnection(_connectionString);
        await connection.OpenAsync();

        EquipmentReturnDetailsResponseDto? details = null;

        string returnQuery = @"
            SELECT
                er.id,
                u.full_name as ReturnerName,
                d.name as Department,
                er.date_return,
                er.status,
                s.points,
                s.boundary_width,
                s.boundary_height
            FROM equipment_return er
            JOIN users u ON er.returner_id = u.id
            JOIN departments d ON u.department_id = d.id
            JOIN signatures s ON er.signature_id = s.id
            WHERE er.id = @ReturnId";

        using var cmd = new SqlCommand(returnQuery, connection);
        cmd.Parameters.AddWithValue("@ReturnId", id);

        using var reader = await cmd.ExecuteReaderAsync();
        if (await reader.ReadAsync())
        {
            details = new EquipmentReturnDetailsResponseDto
            {
                Id = reader.GetInt32(reader.GetOrdinal("id")),
                ReturnerName = reader.GetString(reader.GetOrdinal("ReturnerName")),
                Department = reader.GetString(reader.GetOrdinal("Department")),
                DateReturn = reader.GetDateTime(reader.GetOrdinal("date_return")),
                Status = reader.GetString(reader.GetOrdinal("status")),
                EquipmentItems = new List<ReturnedItemDto>(),
                Signature = new SignatureDto
                {
                    Points = reader.GetString(reader.GetOrdinal("points")),
                    BoundaryWidth = (float)reader.GetDouble(reader.GetOrdinal("boundary_width")),
                    BoundaryHeight = (float)reader.GetDouble(reader.GetOrdinal("boundary_height"))
                }
            };
        }
        else
        {
            return null;
        }

        await reader.CloseAsync();

        string itemsQuery = @"
            SELECT id, title, description, quantity, justification
            FROM equipment_returned_items
            WHERE return_id = @ReturnId";

        using var itemsCmd = new SqlCommand(itemsQuery, connection);
        itemsCmd.Parameters.AddWithValue("@ReturnId", id);

        using var itemsReader = await itemsCmd.ExecuteReaderAsync();
        while (await itemsReader.ReadAsync())
        {
            details.EquipmentItems.Add(new ReturnedItemDto
            {
                Id = itemsReader.GetInt32(itemsReader.GetOrdinal("id")),
                Title = itemsReader.GetString(itemsReader.GetOrdinal("title")),
                Description = itemsReader.GetString(itemsReader.GetOrdinal("description")),
                Quantity = itemsReader.GetInt32(itemsReader.GetOrdinal("quantity")),
                Justification = itemsReader.GetString(itemsReader.GetOrdinal("justification"))
            });
        }

        return details;
    }

    public async Task<IEnumerable<EquipmentReturnListResponseDto>> GetUncheckedReturnsAsync()
    {
        var returns = new List<EquipmentReturnListResponseDto>();
        using var connection = new SqlConnection(_connectionString);
        await connection.OpenAsync();

        string query = @"
            SELECT
                er.id,
                u.full_name as ReturnerName,
                d.name as Department,
                er.date_return,
                er.status
            FROM equipment_return er
            JOIN users u ON er.returner_id = u.id
            JOIN departments d ON u.department_id = d.id
            WHERE er.status = 'unchecked'
            ORDER BY er.date_return DESC";

        using var cmd = new SqlCommand(query, connection);
        using var reader = await cmd.ExecuteReaderAsync();

        while (await reader.ReadAsync())
        {
            returns.Add(new EquipmentReturnListResponseDto
            {
                Id = reader.GetInt32(reader.GetOrdinal("id")),
                ReturnerName = reader.GetString(reader.GetOrdinal("ReturnerName")),
                Department = reader.GetString(reader.GetOrdinal("Department")),
                DateReturn = reader.GetDateTime(reader.GetOrdinal("date_return")),
                Status = reader.GetString(reader.GetOrdinal("status"))
            });
        }

        return returns;
    }

    public async Task<bool> UpdateReturnStatusAsync(int id, string status, int approverId, DateTime dateApproved)
    {
        using var connection = new SqlConnection(_connectionString);
        await connection.OpenAsync();

        string updateQuery = @"
            UPDATE equipment_return
            SET
                status = @Status,
                approver_id = @ApproverId,
                date_approved = @DateApproved
            WHERE id = @ReturnId";

        using var cmd = new SqlCommand(updateQuery, connection);
        cmd.Parameters.AddWithValue("@ReturnId", id);
        cmd.Parameters.AddWithValue("@Status", status);
        cmd.Parameters.AddWithValue("@ApproverId", approverId);
        cmd.Parameters.AddWithValue("@DateApproved", dateApproved);

        int rowsAffected = await cmd.ExecuteNonQueryAsync();
        return rowsAffected > 0;
    }

    public async Task<string?> GetReturnCurrentStatusAsync(int id)
    {
        using var connection = new SqlConnection(_connectionString);
        await connection.OpenAsync();

        string checkQuery = "SELECT status FROM equipment_return WHERE id = @ReturnId";

        using var cmd = new SqlCommand(checkQuery, connection);
        cmd.Parameters.AddWithValue("@ReturnId", id);

        var result = await cmd.ExecuteScalarAsync();
        return result?.ToString();
    }
}
