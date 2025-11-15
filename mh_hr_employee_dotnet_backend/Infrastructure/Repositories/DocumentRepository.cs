using Microsoft.Data.SqlClient;
using Microsoft.Extensions.Configuration;
using React.Core.DTOs.Response;
using React.Core.Interfaces.Repositories;
using System.Data;

namespace React.Infrastructure.Repositories;

public class DocumentRepository : IDocumentRepository
{
    private readonly string _connectionString;

    public DocumentRepository(IConfiguration configuration)
    {
        _connectionString = configuration.GetConnectionString("DefaultConnection")
            ?? throw new ArgumentNullException(nameof(configuration));
    }

    public async Task<int> CreateDocumentAsync(string type, string title, string? docContent, int postBy, int departmentId, byte[]? fileData, string? fileType)
    {
        using var connection = new SqlConnection(_connectionString);
        await connection.OpenAsync();

        string sql = @"
            INSERT INTO documents
            (type, post_date, post_by, title, doc_content, doc_upload, department_id, file_type)
            VALUES
            (@Type, @PostDate, @PostBy, @Title, @DocContent, @DocUpload, @DepartmentId, @FileType);
            SELECT SCOPE_IDENTITY();";

        using var cmd = new SqlCommand(sql, connection);
        cmd.Parameters.Add("@Type", SqlDbType.VarChar, 50).Value = type;
        cmd.Parameters.Add("@PostDate", SqlDbType.Date).Value = DateTime.Now.Date;
        cmd.Parameters.Add("@PostBy", SqlDbType.Int).Value = postBy;
        cmd.Parameters.Add("@Title", SqlDbType.VarChar, 200).Value = title;
        cmd.Parameters.Add("@DocContent", SqlDbType.VarChar, 500).Value = (object?)docContent ?? DBNull.Value;
        cmd.Parameters.Add("@DocUpload", SqlDbType.VarBinary, -1).Value = (object?)fileData ?? DBNull.Value;
        cmd.Parameters.Add("@DepartmentId", SqlDbType.Int).Value = departmentId;
        cmd.Parameters.Add("@FileType", SqlDbType.VarChar, 100).Value = (object?)fileType ?? DBNull.Value;

        var result = await cmd.ExecuteScalarAsync();
        return Convert.ToInt32(result);
    }

    public async Task<DocumentResponseDto?> GetDocumentByIdAsync(int id)
    {
        using var connection = new SqlConnection(_connectionString);
        await connection.OpenAsync();

        string sql = @"
            SELECT id, type, post_date, title, doc_content, doc_upload, file_type, post_by, department_id
            FROM documents
            WHERE id = @Id";

        using var cmd = new SqlCommand(sql, connection);
        cmd.Parameters.AddWithValue("@Id", id);

        using var reader = await cmd.ExecuteReaderAsync();
        if (await reader.ReadAsync())
        {
            return new DocumentResponseDto
            {
                Id = reader.GetInt32(0),
                Type = reader.GetString(1),
                PostDate = reader.GetDateTime(2),
                Title = reader.GetString(3),
                DocContent = reader.IsDBNull(4) ? null : reader.GetString(4),
                DocUpload = reader.IsDBNull(5) ? null : (byte[])reader[5],
                FileType = reader.IsDBNull(6) ? null : reader.GetString(6),
                PostBy = reader.GetInt32(7),
                DepartmentId = reader.GetInt32(8)
            };
        }

        return null;
    }

    public async Task<IEnumerable<DocumentResponseDto>> GetAllDocumentsAsync()
    {
        var documents = new List<DocumentResponseDto>();
        using var connection = new SqlConnection(_connectionString);
        await connection.OpenAsync();

        string sql = @"
            SELECT id, type, post_date, title, doc_content, file_type, post_by, department_id
            FROM documents
            ORDER BY post_date DESC";

        using var cmd = new SqlCommand(sql, connection);
        using var reader = await cmd.ExecuteReaderAsync();

        while (await reader.ReadAsync())
        {
            documents.Add(new DocumentResponseDto
            {
                Id = reader.GetInt32(0),
                Type = reader.GetString(1),
                PostDate = reader.GetDateTime(2),
                Title = reader.GetString(3),
                DocContent = reader.IsDBNull(4) ? null : reader.GetString(4),
                FileType = reader.IsDBNull(5) ? null : reader.GetString(5),
                PostBy = reader.GetInt32(6),
                DepartmentId = reader.GetInt32(7)
            });
        }

        return documents;
    }
}
