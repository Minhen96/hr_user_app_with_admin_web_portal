using Microsoft.Data.SqlClient;
using Microsoft.Extensions.Configuration;
using React.Core.DTOs.Response;
using React.Core.Interfaces.Repositories;

namespace React.Infrastructure.Repositories;

public class LeaveReportRepository : ILeaveReportRepository
{
    private readonly string _connectionString;

    public LeaveReportRepository(IConfiguration configuration)
    {
        _connectionString = configuration.GetConnectionString("DefaultConnection")
            ?? throw new ArgumentNullException(nameof(configuration));
    }

    public async Task<IEnumerable<AnnualLeaveReportDataDto>> GetAnnualLeaveReportDataAsync(int year)
    {
        var reportData = new List<AnnualLeaveReportDataDto>();
        using var connection = new SqlConnection(_connectionString);
        await connection.OpenAsync();

        string query = @"
            WITH MonthlyLeave AS (
                SELECT
                    u.id,
                    u.full_name,
                    ISNULL(al.entitlement, 0) as entitlement,
                    MONTH(ld.leave_date) as month,
                    SUM(ISNULL(ld.no_of_days, 0)) as days_taken
                FROM users u
                LEFT JOIN annual_leave al ON u.id = al.user_id AND al.year = @Year
                LEFT JOIN leave_detail ld ON al.id = ld.annual_leave_id
                    AND ld.status = 'approved'
                    AND YEAR(ld.leave_date) = @Year
                GROUP BY u.id, u.full_name, al.entitlement, MONTH(ld.leave_date)
            )
            SELECT
                id,
                full_name,
                ISNULL(entitlement, 0) as entitlement,
                ISNULL(SUM(CASE WHEN month = 1 THEN days_taken ELSE 0 END), 0) as Jan,
                ISNULL(SUM(CASE WHEN month = 2 THEN days_taken ELSE 0 END), 0) as Feb,
                ISNULL(SUM(CASE WHEN month = 3 THEN days_taken ELSE 0 END), 0) as Mar,
                ISNULL(SUM(CASE WHEN month = 4 THEN days_taken ELSE 0 END), 0) as Apr,
                ISNULL(SUM(CASE WHEN month = 5 THEN days_taken ELSE 0 END), 0) as May,
                ISNULL(SUM(CASE WHEN month = 6 THEN days_taken ELSE 0 END), 0) as Jun,
                ISNULL(SUM(CASE WHEN month = 7 THEN days_taken ELSE 0 END), 0) as Jul,
                ISNULL(SUM(CASE WHEN month = 8 THEN days_taken ELSE 0 END), 0) as Aug,
                ISNULL(SUM(CASE WHEN month = 9 THEN days_taken ELSE 0 END), 0) as Sep,
                ISNULL(SUM(CASE WHEN month = 10 THEN days_taken ELSE 0 END), 0) as Oct,
                ISNULL(SUM(CASE WHEN month = 11 THEN days_taken ELSE 0 END), 0) as Nov,
                ISNULL(SUM(CASE WHEN month = 12 THEN days_taken ELSE 0 END), 0) as Dec,
                ISNULL(SUM(days_taken), 0) as total_taken,
                ISNULL(entitlement, 0) - ISNULL(SUM(days_taken), 0) as balance
            FROM MonthlyLeave
            GROUP BY id, full_name, entitlement";

        using var cmd = new SqlCommand(query, connection);
        cmd.Parameters.AddWithValue("@Year", year);

        using var reader = await cmd.ExecuteReaderAsync();
        while (await reader.ReadAsync())
        {
            reportData.Add(new AnnualLeaveReportDataDto
            {
                FullName = reader.GetString(reader.GetOrdinal("full_name")),
                Entitlement = reader.GetInt32(reader.GetOrdinal("entitlement")),
                Jan = reader.GetDouble(reader.GetOrdinal("Jan")),
                Feb = reader.GetDouble(reader.GetOrdinal("Feb")),
                Mar = reader.GetDouble(reader.GetOrdinal("Mar")),
                Apr = reader.GetDouble(reader.GetOrdinal("Apr")),
                May = reader.GetDouble(reader.GetOrdinal("May")),
                Jun = reader.GetDouble(reader.GetOrdinal("Jun")),
                Jul = reader.GetDouble(reader.GetOrdinal("Jul")),
                Aug = reader.GetDouble(reader.GetOrdinal("Aug")),
                Sep = reader.GetDouble(reader.GetOrdinal("Sep")),
                Oct = reader.GetDouble(reader.GetOrdinal("Oct")),
                Nov = reader.GetDouble(reader.GetOrdinal("Nov")),
                Dec = reader.GetDouble(reader.GetOrdinal("Dec")),
                TotalTaken = reader.GetDouble(reader.GetOrdinal("total_taken")),
                Balance = reader.GetDouble(reader.GetOrdinal("balance"))
            });
        }

        return reportData;
    }

    public async Task<IEnumerable<MedicalLeaveReportDataDto>> GetMedicalLeaveReportDataAsync(int year)
    {
        var reportData = new List<MedicalLeaveReportDataDto>();
        using var connection = new SqlConnection(_connectionString);
        await connection.OpenAsync();

        string query = @"
            WITH MonthlyMC AS (
                SELECT
                    u.id,
                    u.full_name,
                    MONTH(mc.start_date) as month,
                    SUM(ISNULL(mc.total_day, 0)) as days_taken
                FROM users u
                LEFT JOIN MC_Leave_Requests mc ON u.id = mc.id
                    AND mc.status = 'approved'
                    AND YEAR(mc.start_date) = @Year
                GROUP BY u.id, u.full_name, MONTH(mc.start_date)
            )
            SELECT
                id,
                full_name,
                ISNULL(SUM(CASE WHEN month = 1 THEN days_taken ELSE 0 END), 0) as Jan,
                ISNULL(SUM(CASE WHEN month = 2 THEN days_taken ELSE 0 END), 0) as Feb,
                ISNULL(SUM(CASE WHEN month = 3 THEN days_taken ELSE 0 END), 0) as Mar,
                ISNULL(SUM(CASE WHEN month = 4 THEN days_taken ELSE 0 END), 0) as Apr,
                ISNULL(SUM(CASE WHEN month = 5 THEN days_taken ELSE 0 END), 0) as May,
                ISNULL(SUM(CASE WHEN month = 6 THEN days_taken ELSE 0 END), 0) as Jun,
                ISNULL(SUM(CASE WHEN month = 7 THEN days_taken ELSE 0 END), 0) as Jul,
                ISNULL(SUM(CASE WHEN month = 8 THEN days_taken ELSE 0 END), 0) as Aug,
                ISNULL(SUM(CASE WHEN month = 9 THEN days_taken ELSE 0 END), 0) as Sep,
                ISNULL(SUM(CASE WHEN month = 10 THEN days_taken ELSE 0 END), 0) as Oct,
                ISNULL(SUM(CASE WHEN month = 11 THEN days_taken ELSE 0 END), 0) as Nov,
                ISNULL(SUM(CASE WHEN month = 12 THEN days_taken ELSE 0 END), 0) as Dec,
                ISNULL(SUM(days_taken), 0) as total_taken
            FROM MonthlyMC
            GROUP BY id, full_name";

        using var cmd = new SqlCommand(query, connection);
        cmd.Parameters.AddWithValue("@Year", year);

        using var reader = await cmd.ExecuteReaderAsync();
        while (await reader.ReadAsync())
        {
            reportData.Add(new MedicalLeaveReportDataDto
            {
                FullName = reader.GetString(reader.GetOrdinal("full_name")),
                Jan = reader.GetInt32(reader.GetOrdinal("Jan")),
                Feb = reader.GetInt32(reader.GetOrdinal("Feb")),
                Mar = reader.GetInt32(reader.GetOrdinal("Mar")),
                Apr = reader.GetInt32(reader.GetOrdinal("Apr")),
                May = reader.GetInt32(reader.GetOrdinal("May")),
                Jun = reader.GetInt32(reader.GetOrdinal("Jun")),
                Jul = reader.GetInt32(reader.GetOrdinal("Jul")),
                Aug = reader.GetInt32(reader.GetOrdinal("Aug")),
                Sep = reader.GetInt32(reader.GetOrdinal("Sep")),
                Oct = reader.GetInt32(reader.GetOrdinal("Oct")),
                Nov = reader.GetInt32(reader.GetOrdinal("Nov")),
                Dec = reader.GetInt32(reader.GetOrdinal("Dec")),
                TotalTaken = reader.GetInt32(reader.GetOrdinal("total_taken"))
            });
        }

        return reportData;
    }
}
