using Microsoft.EntityFrameworkCore;
using React.Models;
using React.Data.Configurations;

namespace React.Data;

/// <summary>
/// Main application database context following modern EF Core practices
/// </summary>
public class ApplicationDbContext : DbContext
{
    public ApplicationDbContext(DbContextOptions<ApplicationDbContext> options) : base(options)
    {
    }

    // User Management
    public DbSet<User> Users => Set<User>();
    public DbSet<Department> Departments => Set<Department>();

    // Leave Management
    public DbSet<AnnualLeave> AnnualLeaves => Set<AnnualLeave>();
    public DbSet<LeaveDetail> LeaveDetails => Set<LeaveDetail>();
    public DbSet<LeaveRequest> LeaveRequests => Set<LeaveRequest>();

    // Attendance
    public DbSet<Attendance> Attendances => Set<Attendance>();

    // Documents
    public DbSet<Document> Documents => Set<Document>();
    public DbSet<DocumentRead> DocumentReads => Set<DocumentRead>();

    // Handbook
    public DbSet<HandbookSection> HandbookSections => Set<HandbookSection>();
    public DbSet<HandbookContent> HandbookContents => Set<HandbookContent>();

    // Calendar
    public DbSet<Holiday> Holidays => Set<Holiday>();
    public DbSet<Event> Events => Set<Event>();

    // Equipment Management
    public DbSet<EquipmentRequest> EquipmentRequests => Set<EquipmentRequest>();
    public DbSet<EquipmentItem> EquipmentItems => Set<EquipmentItem>();
    public DbSet<Signature> Signatures => Set<Signature>();

    // Training
    public DbSet<TrainingCourse> TrainingCourses => Set<TrainingCourse>();
    public DbSet<Certificate> Certificates => Set<Certificate>();

    // Social Features
    public DbSet<Moment> Moments => Set<Moment>();
    public DbSet<MomentImage> MomentImages => Set<MomentImage>();
    public DbSet<MomentReaction> MomentReactions => Set<MomentReaction>();
    public DbSet<Quote> Quotes => Set<Quote>();
    public DbSet<QuoteReaction> QuoteReactions => Set<QuoteReaction>();
    public DbSet<QuoteView> QuoteViews => Set<QuoteView>();

    // Asset Management
    public DbSet<ChangeRequest> ChangeRequests => Set<ChangeRequest>();
    public DbSet<FixedAssetProduct> FixedAssetProducts => Set<FixedAssetProduct>();
    public DbSet<FixedAssetType> FixedAssetTypes => Set<FixedAssetType>();

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);

        // Apply all entity configurations from assembly
        modelBuilder.ApplyConfigurationsFromAssembly(typeof(ApplicationDbContext).Assembly);

        // Additional configurations not in separate files
        ConfigureHandbook(modelBuilder);
        ConfigureHolidays(modelBuilder);
        ConfigureEquipment(modelBuilder);
        ConfigureTraining(modelBuilder);
        ConfigureSocial(modelBuilder);
        ConfigureAssets(modelBuilder);
    }

    private void ConfigureHandbook(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<HandbookContent>()
            .HasOne(c => c.HandbookSection)
            .WithMany(s => s.Contents)
            .HasForeignKey(c => c.HandbookSectionId)
            .OnDelete(DeleteBehavior.Cascade);
    }

    private void ConfigureHolidays(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<Holiday>()
            .HasIndex(h => h.HolidayDate);

        modelBuilder.Entity<Event>()
            .HasIndex(e => e.date);
    }

    private void ConfigureEquipment(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<EquipmentRequest>()
            .HasOne(r => r.Signature)
            .WithMany(s => s.RequestSignatures)
            .HasForeignKey(r => r.SignatureId)
            .OnDelete(DeleteBehavior.Restrict);

        modelBuilder.Entity<EquipmentRequest>()
            .HasOne(r => r.ApprovalSignature)
            .WithMany(s => s.ApprovalSignatures)
            .HasForeignKey(r => r.ApprovalSignatureId)
            .OnDelete(DeleteBehavior.Restrict);
    }

    private void ConfigureTraining(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<Certificate>()
            .HasOne(c => c.TrainingCourse)
            .WithMany(t => t.Certificates)
            .HasForeignKey(c => c.TrainingId)
            .OnDelete(DeleteBehavior.Cascade);
    }

    private void ConfigureSocial(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<Moment>()
            .HasIndex(m => new { m.CreatedAt, m.Id });

        // Moment relationships
        modelBuilder.Entity<MomentImage>()
            .HasOne(mi => mi.Moment)
            .WithMany(m => m.Images)
            .HasForeignKey(mi => mi.MomentId)
            .OnDelete(DeleteBehavior.Cascade);

        modelBuilder.Entity<MomentReaction>()
            .HasOne(mr => mr.Moment)
            .WithMany(m => m.Reactions)
            .HasForeignKey(mr => mr.MomentId)
            .OnDelete(DeleteBehavior.Cascade);

        modelBuilder.Entity<MomentReaction>()
            .HasOne(mr => mr.User)
            .WithMany()
            .HasForeignKey(mr => mr.UserId)
            .OnDelete(DeleteBehavior.Restrict);

        // Quote relationships
        modelBuilder.Entity<Quote>()
            .HasIndex(q => q.Id)
            .IsUnique();

        modelBuilder.Entity<QuoteView>()
            .HasOne(qv => qv.Quote)
            .WithMany(q => q.Views)
            .HasForeignKey(qv => qv.QuoteId)
            .OnDelete(DeleteBehavior.Cascade);

        modelBuilder.Entity<QuoteReaction>()
            .HasOne(qr => qr.Quote)
            .WithMany(q => q.Reactions)
            .HasForeignKey(qr => qr.QuoteId)
            .OnDelete(DeleteBehavior.Cascade);
    }

    private void ConfigureAssets(ModelBuilder modelBuilder)
    {
        // Map ChangeRequest to change_requests table
        modelBuilder.Entity<ChangeRequest>()
            .ToTable("change_requests");

        modelBuilder.Entity<FixedAssetProduct>()
            .HasIndex(p => p.ProductCode)
            .IsUnique();

        modelBuilder.Entity<FixedAssetType>()
            .HasIndex(t => t.Code)
            .IsUnique();
    }
}
