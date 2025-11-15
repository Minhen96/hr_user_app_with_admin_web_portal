using Microsoft.Data.SqlClient;
using Microsoft.Extensions.Configuration;
using React.Core.DTOs.Response;
using React.Core.Interfaces.Repositories;

namespace React.Infrastructure.Repositories;

public class TrainingRepository : ITrainingRepository
{
    private readonly string _connectionString;

    public TrainingRepository(IConfiguration configuration)
    {
        _connectionString = configuration.GetConnectionString("DefaultConnection")
            ?? throw new ArgumentNullException(nameof(configuration));
    }

    public async Task<IEnumerable<TrainingResponseDto>> GetAllTrainingsAsync()
    {
        var trainings = new List<TrainingResponseDto>();

        using var conn = new SqlConnection(_connectionString);
        await conn.OpenAsync();

        string query = @"
            SELECT
                tc.id, u.full_name as UserName, d.name as Department,
                tc.title, tc.description, tc.course_date, tc.status, NULL as rejected_reason
            FROM training_courses tc
            JOIN users u ON tc.user_id = u.id
            JOIN departments d ON u.department_id = d.id
            ORDER BY tc.course_date DESC";

        using var cmd = new SqlCommand(query, conn);
        using var reader = await cmd.ExecuteReaderAsync();

        while (await reader.ReadAsync())
        {
            trainings.Add(new TrainingResponseDto
            {
                Id = reader.GetInt32(0),
                UserName = reader.GetString(1),
                Department = reader.GetString(2),
                Title = reader.GetString(3),
                Description = reader.IsDBNull(4) ? null : reader.GetString(4),
                CourseDate = reader.GetDateTime(5),
                Status = reader.GetString(6),
                RejectedReason = reader.IsDBNull(7) ? null : reader.GetString(7)
            });
        }

        return trainings;
    }

    public async Task<bool> UpdateTrainingStatusAsync(int id, string status, int approverId, DateTime dateApproved)
    {
        using var conn = new SqlConnection(_connectionString);
        await conn.OpenAsync();

        string query = @"
            UPDATE training_courses
            SET status = @Status
            WHERE id = @Id;

            INSERT INTO training_status_audits (training_id, approver_id, status, date_modified)
            VALUES (@Id, @ApproverId, @Status, @DateApproved)";

        using var cmd = new SqlCommand(query, conn);
        cmd.Parameters.AddWithValue("@Id", id);
        cmd.Parameters.AddWithValue("@Status", status);
        cmd.Parameters.AddWithValue("@ApproverId", approverId);
        cmd.Parameters.AddWithValue("@DateApproved", dateApproved);

        return await cmd.ExecuteNonQueryAsync() > 0;
    }
}
