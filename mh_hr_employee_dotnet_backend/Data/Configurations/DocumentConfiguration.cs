using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using React.Models;

namespace React.Data.Configurations;

/// <summary>
/// Entity configuration for Document model
/// </summary>
public class DocumentConfiguration : IEntityTypeConfiguration<Document>
{
    public void Configure(EntityTypeBuilder<Document> builder)
    {
        builder.ToTable("documents", "dbo");

        builder.HasKey(d => d.Id);

        builder.Property(d => d.Type)
            .HasMaxLength(50);

        builder.Property(d => d.Title)
            .HasMaxLength(50);

        builder.Property(d => d.Content)
            .HasColumnType("varchar(500)");

        builder.Property(d => d.DocumentUpload)
            .HasColumnType("varbinary(max)");

        builder.Property(d => d.FileType)
            .HasMaxLength(100);

        builder.HasOne(d => d.Department)
            .WithMany()
            .HasForeignKey(d => d.DepartmentId)
            .OnDelete(DeleteBehavior.Restrict);

        builder.HasOne(d => d.Poster)
            .WithMany()
            .HasForeignKey(d => d.PostBy)
            .OnDelete(DeleteBehavior.Restrict);

        builder.HasMany(d => d.DocumentReads)
            .WithOne(dr => dr.Document)
            .HasForeignKey(dr => dr.DocId)
            .OnDelete(DeleteBehavior.Cascade);

        builder.HasIndex(d => d.PostDate);
        builder.HasIndex(d => d.Type);
    }
}
