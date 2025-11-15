using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace React.Migrations
{
    /// <inheritdoc />
    public partial class InitialCreate : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.EnsureSchema(
                name: "dbo");

            migrationBuilder.CreateTable(
                name: "annual_leave",
                columns: table => new
                {
                    id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    user_id = table.Column<int>(type: "int", nullable: false),
                    
                    
                    nt = table.Column<int>(type: "int", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_annual_leave", x => x.id);
                });

            migrationBuilder.CreateTable(
                name: "Attendance",
                columns: table => new
                {
                    id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    name = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    time_in = table.Column<DateTime>(type: "datetime2", nullable: false),
                    time_out = table.Column<DateTime>(type: "datetime2", nullable: true),
                    time_in_photo = table.Column<byte[]>(type: "varbinary(max)", nullable: false),
                    time_out_photo = table.Column<byte[]>(type: "varbinary(max)", nullable: true),
                    date_submission = table.Column<DateTime>(type: "datetime2", nullable: false),
                    placename = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    user_id = table.Column<int>(type: "int", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Attendance", x => x.id);
                });

            migrationBuilder.CreateTable(
                name: "departments",
                columns: table => new
                {
                    id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    name = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    description = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    created_at = table.Column<DateTime>(type: "datetime2", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_departments", x => x.id);
                });

            migrationBuilder.CreateTable(
                name: "Events",
                columns: table => new
                {
                    id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    title = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    description = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    date = table.Column<DateTime>(type: "datetime2", nullable: false),
                    user_id = table.Column<int>(type: "int", nullable: false),
                    created_at = table.Column<DateTime>(type: "datetime2", nullable: false),
                    updated_at = table.Column<DateTime>(type: "datetime2", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Events", x => x.id);
                });

            migrationBuilder.CreateTable(
                name: "fixed_asset_types",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    Code = table.Column<string>(type: "nvarchar(2)", maxLength: 2, nullable: false),
                    Name = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_fixed_asset_types", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "HandbookSections",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    Title = table.Column<string>(type: "nvarchar(max)", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_HandbookSections", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "Holidays",
                columns: table => new
                {
                    HolidayId = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    HolidayDate = table.Column<DateTime>(type: "datetime2", nullable: false),
                    HolidayName = table.Column<string>(type: "nvarchar(max)", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Holidays", x => x.HolidayId);
                });

            migrationBuilder.CreateTable(
                name: "leave_detail",
                columns: table => new
                {
                    id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    leave_date = table.Column<DateTime>(type: "datetime2", nullable: false),
                    leave_end_date = table.Column<DateTime>(type: "datetime2", nullable: false),
                    reason = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    status = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    approved_by = table.Column<int>(type: "int", nullable: true),
                    approval_signature_id = table.Column<int>(type: "int", nullable: true),
                    annual_leave_id = table.Column<int>(type: "int", nullable: false),
                    no_of_days = table.Column<double>(type: "float", nullable: false),
                    date_submission = table.Column<DateTime>(type: "datetime2", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_leave_detail", x => x.id);
                });

            migrationBuilder.CreateTable(
                name: "Mc_Leave_Requests",
                columns: table => new
                {
                    id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    full_name = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    start_date = table.Column<DateTime>(type: "datetime2", nullable: false),
                    end_date = table.Column<DateTime>(type: "datetime2", nullable: false),
                    date_submission = table.Column<DateTime>(type: "datetime2", nullable: false),
                    total_day = table.Column<int>(type: "int", nullable: false),
                    reason = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    status = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    url = table.Column<byte[]>(type: "varbinary(max)", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Mc_Leave_Requests", x => x.id);
                });

            migrationBuilder.CreateTable(
                name: "Quotes",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    Text = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    TextCn = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    LastEditedBy = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    LastEditedDate = table.Column<DateTime>(type: "datetime2", nullable: false),
                    CarouselType = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    ImageUrl = table.Column<string>(type: "nvarchar(max)", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Quotes", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "users",
                columns: table => new
                {
                    id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    full_name = table.Column<string>(type: "nvarchar(200)", maxLength: 200, nullable: false),
                    email = table.Column<string>(type: "nvarchar(255)", maxLength: 255, nullable: false),
                    profile_picture = table.Column<byte[]>(type: "varbinary(max)", nullable: true),
                    birthday = table.Column<DateTime>(type: "datetime2", nullable: false),
                    password = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    department_id = table.Column<int>(type: "int", nullable: false),
                    nric = table.Column<string>(type: "nvarchar(50)", maxLength: 50, nullable: false),
                    tin = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    epf_no = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    role = table.Column<string>(type: "nvarchar(50)", maxLength: 50, nullable: false),
                    status = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    active_status = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    date_joined = table.Column<DateTime>(type: "datetime2", nullable: false),
                    change_password_date = table.Column<DateTime>(type: "datetime2", nullable: true),
                    FCMToken = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    nickname = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    contact_number = table.Column<string>(type: "nvarchar(max)", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_users", x => x.id);
                    table.ForeignKey(
                        name: "FK_users_departments_department_id",
                        column: x => x.department_id,
                        principalTable: "departments",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "HandbookContents",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    HandbookSectionId = table.Column<int>(type: "int", nullable: false),
                    Subtitle = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    Content = table.Column<string>(type: "nvarchar(max)", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_HandbookContents", x => x.Id);
                    table.ForeignKey(
                        name: "FK_HandbookContents_HandbookSections_HandbookSectionId",
                        column: x => x.HandbookSectionId,
                        principalTable: "HandbookSections",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "QuoteReactions",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    QuoteId = table.Column<int>(type: "int", nullable: false),
                    ReactedBy = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    Reaction = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    ReactedAt = table.Column<DateTime>(type: "datetime2", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_QuoteReactions", x => x.Id);
                    table.ForeignKey(
                        name: "FK_QuoteReactions_Quotes_QuoteId",
                        column: x => x.QuoteId,
                        principalTable: "Quotes",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "QuoteViews",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    QuoteId = table.Column<int>(type: "int", nullable: false),
                    ViewedBy = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    ViewedAt = table.Column<DateTime>(type: "datetime2", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_QuoteViews", x => x.Id);
                    table.ForeignKey(
                        name: "FK_QuoteViews_Quotes_QuoteId",
                        column: x => x.QuoteId,
                        principalTable: "Quotes",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "documents",
                schema: "dbo",
                columns: table => new
                {
                    doc_id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    type = table.Column<string>(type: "nvarchar(50)", maxLength: 50, nullable: false),
                    post_date = table.Column<DateTime>(type: "datetime2", nullable: false),
                    post_by = table.Column<int>(type: "int", nullable: false),
                    title = table.Column<string>(type: "nvarchar(50)", maxLength: 50, nullable: false),
                    doc_content = table.Column<string>(type: "varchar(500)", nullable: true),
                    department_id = table.Column<int>(type: "int", nullable: false),
                    doc_upload = table.Column<byte[]>(type: "varbinary(max)", nullable: true),
                    file_type = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_documents", x => x.doc_id);
                    table.ForeignKey(
                        name: "FK_documents_departments_department_id",
                        column: x => x.department_id,
                        principalTable: "departments",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_documents_users_post_by",
                        column: x => x.post_by,
                        principalTable: "users",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "Moments",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    Title = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    Description = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    UserId = table.Column<int>(type: "int", nullable: false),
                    CreatedAt = table.Column<DateTime>(type: "datetime2", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Moments", x => x.Id);
                    table.ForeignKey(
                        name: "FK_Moments_users_UserId",
                        column: x => x.UserId,
                        principalTable: "users",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "Signatures",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    user_id = table.Column<int>(type: "int", nullable: false),
                    points = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    boundary_width = table.Column<double>(type: "float", nullable: false),
                    boundary_height = table.Column<double>(type: "float", nullable: false),
                    created_at = table.Column<DateTime>(type: "datetime2", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Signatures", x => x.Id);
                    table.ForeignKey(
                        name: "FK_Signatures_users_user_id",
                        column: x => x.user_id,
                        principalTable: "users",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "training_courses",
                columns: table => new
                {
                    id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    user_id = table.Column<int>(type: "int", nullable: false),
                    title = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: false),
                    description = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    course_date = table.Column<DateTime>(type: "datetime2", nullable: false),
                    status = table.Column<string>(type: "nvarchar(20)", maxLength: 20, nullable: false),
                    created_at = table.Column<DateTime>(type: "datetime2", nullable: false),
                    updated_at = table.Column<DateTime>(type: "datetime2", nullable: false),
                    rejection_reason = table.Column<string>(type: "nvarchar(max)", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_training_courses", x => x.id);
                    table.ForeignKey(
                        name: "FK_training_courses_users_user_id",
                        column: x => x.user_id,
                        principalTable: "users",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "DocumentReads",
                columns: table => new
                {
                    id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    doc_id = table.Column<int>(type: "int", nullable: false),
                    user_id = table.Column<int>(type: "int", nullable: false),
                    read_date = table.Column<DateTime>(type: "datetime2", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_DocumentReads", x => x.id);
                    table.ForeignKey(
                        name: "FK_DocumentReads_documents_doc_id",
                        column: x => x.doc_id,
                        principalSchema: "dbo",
                        principalTable: "documents",
                        principalColumn: "doc_id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_DocumentReads_users_user_id",
                        column: x => x.user_id,
                        principalTable: "users",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "MomentImages",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    MomentId = table.Column<int>(type: "int", nullable: false),
                    ImageData = table.Column<byte[]>(type: "varbinary(max)", nullable: false),
                    ImagePath = table.Column<string>(type: "nvarchar(max)", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_MomentImages", x => x.Id);
                    table.ForeignKey(
                        name: "FK_MomentImages_Moments_MomentId",
                        column: x => x.MomentId,
                        principalTable: "Moments",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "MomentReactions",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    MomentId = table.Column<int>(type: "int", nullable: false),
                    UserId = table.Column<int>(type: "int", nullable: false),
                    ReactionType = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    CreatedAt = table.Column<DateTime>(type: "datetime2", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_MomentReactions", x => x.Id);
                    table.ForeignKey(
                        name: "FK_MomentReactions_Moments_MomentId",
                        column: x => x.MomentId,
                        principalTable: "Moments",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_MomentReactions_users_UserId",
                        column: x => x.UserId,
                        principalTable: "users",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "ChangeRequests",
                columns: table => new
                {
                    id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    requester_id = table.Column<int>(type: "int", nullable: true),
                    date_requested = table.Column<DateTime>(type: "datetime2", nullable: true),
                    status = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    reason = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    description = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    risk = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    instruction = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    complete_date = table.Column<DateTime>(type: "datetime2", nullable: true),
                    post_review = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    signature_id = table.Column<int>(type: "int", nullable: true),
                    approver_id = table.Column<int>(type: "int", nullable: true),
                    date_approved = table.Column<DateTime>(type: "datetime2", nullable: true),
                    approval_signature_id = table.Column<int>(type: "int", nullable: true),
                    received_details = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    return_status = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    date_returned = table.Column<DateTime>(type: "datetime2", nullable: true),
                    fixed_asset_type_id = table.Column<int>(type: "int", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_ChangeRequests", x => x.id);
                    table.ForeignKey(
                        name: "FK_ChangeRequests_Signatures_approval_signature_id",
                        column: x => x.approval_signature_id,
                        principalTable: "Signatures",
                        principalColumn: "Id");
                    table.ForeignKey(
                        name: "FK_ChangeRequests_Signatures_signature_id",
                        column: x => x.signature_id,
                        principalTable: "Signatures",
                        principalColumn: "Id");
                    table.ForeignKey(
                        name: "FK_ChangeRequests_fixed_asset_types_fixed_asset_type_id",
                        column: x => x.fixed_asset_type_id,
                        principalTable: "fixed_asset_types",
                        principalColumn: "Id");
                    table.ForeignKey(
                        name: "FK_ChangeRequests_users_approver_id",
                        column: x => x.approver_id,
                        principalTable: "users",
                        principalColumn: "id");
                    table.ForeignKey(
                        name: "FK_ChangeRequests_users_requester_id",
                        column: x => x.requester_id,
                        principalTable: "users",
                        principalColumn: "id");
                });

            migrationBuilder.CreateTable(
                name: "equipment_requests",
                schema: "dbo",
                columns: table => new
                {
                    id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    requester_id = table.Column<int>(type: "int", nullable: false),
                    date_requested = table.Column<DateTime>(type: "datetime2", nullable: false),
                    status = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    signature_id = table.Column<int>(type: "int", nullable: false),
                    approver_id = table.Column<int>(type: "int", nullable: true),
                    date_approved = table.Column<DateTime>(type: "datetime2", nullable: true),
                    approval_signature_id = table.Column<int>(type: "int", nullable: true),
                    received_details = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    created_at = table.Column<DateTime>(type: "datetime2", nullable: false),
                    updated_at = table.Column<DateTime>(type: "datetime2", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_equipment_requests", x => x.id);
                    table.ForeignKey(
                        name: "FK_equipment_requests_Signatures_approval_signature_id",
                        column: x => x.approval_signature_id,
                        principalTable: "Signatures",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_equipment_requests_Signatures_signature_id",
                        column: x => x.signature_id,
                        principalTable: "Signatures",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_equipment_requests_users_approver_id",
                        column: x => x.approver_id,
                        principalTable: "users",
                        principalColumn: "id");
                    table.ForeignKey(
                        name: "FK_equipment_requests_users_requester_id",
                        column: x => x.requester_id,
                        principalTable: "users",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "Certificates",
                columns: table => new
                {
                    id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    training_id = table.Column<int>(type: "int", nullable: false),
                    file_name = table.Column<string>(type: "nvarchar(255)", maxLength: 255, nullable: false),
                    certificate_content = table.Column<byte[]>(type: "varbinary(max)", nullable: false),
                    file_type = table.Column<string>(type: "nvarchar(50)", maxLength: 50, nullable: false),
                    file_size = table.Column<long>(type: "bigint", nullable: false),
                    uploaded_at = table.Column<DateTime>(type: "datetime2", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Certificates", x => x.id);
                    table.ForeignKey(
                        name: "FK_Certificates_training_courses_training_id",
                        column: x => x.training_id,
                        principalTable: "training_courses",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "fixed_asset_products",
                columns: table => new
                {
                    id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    product_code = table.Column<string>(type: "nvarchar(20)", maxLength: 20, nullable: true),
                    created_at = table.Column<DateTime>(type: "datetime2", nullable: false),
                    change_request_id = table.Column<int>(type: "int", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_fixed_asset_products", x => x.id);
                    table.ForeignKey(
                        name: "FK_fixed_asset_products_ChangeRequests_change_request_id",
                        column: x => x.change_request_id,
                        principalTable: "ChangeRequests",
                        principalColumn: "id");
                });

            migrationBuilder.CreateTable(
                name: "equipment_items",
                columns: table => new
                {
                    id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    request_id = table.Column<int>(type: "int", nullable: false),
                    title = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    description = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    quantity = table.Column<int>(type: "int", nullable: false),
                    justification = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    created_at = table.Column<DateTime>(type: "datetime2", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_equipment_items", x => x.id);
                    table.ForeignKey(
                        name: "FK_equipment_items_equipment_requests_request_id",
                        column: x => x.request_id,
                        principalSchema: "dbo",
                        principalTable: "equipment_requests",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateIndex(
                name: "IX_Certificates_training_id",
                table: "Certificates",
                column: "training_id");

            migrationBuilder.CreateIndex(
                name: "IX_ChangeRequests_approval_signature_id",
                table: "ChangeRequests",
                column: "approval_signature_id");

            migrationBuilder.CreateIndex(
                name: "IX_ChangeRequests_approver_id",
                table: "ChangeRequests",
                column: "approver_id");

            migrationBuilder.CreateIndex(
                name: "IX_ChangeRequests_fixed_asset_type_id",
                table: "ChangeRequests",
                column: "fixed_asset_type_id");

            migrationBuilder.CreateIndex(
                name: "IX_ChangeRequests_requester_id",
                table: "ChangeRequests",
                column: "requester_id");

            migrationBuilder.CreateIndex(
                name: "IX_ChangeRequests_signature_id",
                table: "ChangeRequests",
                column: "signature_id");

            migrationBuilder.CreateIndex(
                name: "IX_DocumentReads_doc_id",
                table: "DocumentReads",
                column: "doc_id");

            migrationBuilder.CreateIndex(
                name: "IX_DocumentReads_user_id",
                table: "DocumentReads",
                column: "user_id");

            migrationBuilder.CreateIndex(
                name: "IX_documents_department_id",
                schema: "dbo",
                table: "documents",
                column: "department_id");

            migrationBuilder.CreateIndex(
                name: "IX_documents_post_by",
                schema: "dbo",
                table: "documents",
                column: "post_by");

            migrationBuilder.CreateIndex(
                name: "IX_documents_post_date",
                schema: "dbo",
                table: "documents",
                column: "post_date");

            migrationBuilder.CreateIndex(
                name: "IX_documents_type",
                schema: "dbo",
                table: "documents",
                column: "type");

            migrationBuilder.CreateIndex(
                name: "IX_equipment_items_request_id",
                table: "equipment_items",
                column: "request_id");

            migrationBuilder.CreateIndex(
                name: "IX_equipment_requests_approval_signature_id",
                schema: "dbo",
                table: "equipment_requests",
                column: "approval_signature_id");

            migrationBuilder.CreateIndex(
                name: "IX_equipment_requests_approver_id",
                schema: "dbo",
                table: "equipment_requests",
                column: "approver_id");

            migrationBuilder.CreateIndex(
                name: "IX_equipment_requests_requester_id",
                schema: "dbo",
                table: "equipment_requests",
                column: "requester_id");

            migrationBuilder.CreateIndex(
                name: "IX_equipment_requests_signature_id",
                schema: "dbo",
                table: "equipment_requests",
                column: "signature_id");

            migrationBuilder.CreateIndex(
                name: "IX_Events_date",
                table: "Events",
                column: "date");

            migrationBuilder.CreateIndex(
                name: "IX_fixed_asset_products_change_request_id",
                table: "fixed_asset_products",
                column: "change_request_id");

            migrationBuilder.CreateIndex(
                name: "IX_fixed_asset_products_product_code",
                table: "fixed_asset_products",
                column: "product_code",
                unique: true,
                filter: "[product_code] IS NOT NULL");

            migrationBuilder.CreateIndex(
                name: "IX_fixed_asset_types_Code",
                table: "fixed_asset_types",
                column: "Code",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_HandbookContents_HandbookSectionId",
                table: "HandbookContents",
                column: "HandbookSectionId");

            migrationBuilder.CreateIndex(
                name: "IX_Holidays_HolidayDate",
                table: "Holidays",
                column: "HolidayDate");

            migrationBuilder.CreateIndex(
                name: "IX_MomentImages_MomentId",
                table: "MomentImages",
                column: "MomentId");

            migrationBuilder.CreateIndex(
                name: "IX_MomentReactions_MomentId",
                table: "MomentReactions",
                column: "MomentId");

            migrationBuilder.CreateIndex(
                name: "IX_MomentReactions_UserId",
                table: "MomentReactions",
                column: "UserId");

            migrationBuilder.CreateIndex(
                name: "IX_Moments_CreatedAt_Id",
                table: "Moments",
                columns: new[] { "CreatedAt", "Id" });

            migrationBuilder.CreateIndex(
                name: "IX_Moments_UserId",
                table: "Moments",
                column: "UserId");

            migrationBuilder.CreateIndex(
                name: "IX_QuoteReactions_QuoteId",
                table: "QuoteReactions",
                column: "QuoteId");

            migrationBuilder.CreateIndex(
                name: "IX_Quotes_Id",
                table: "Quotes",
                column: "Id",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_QuoteViews_QuoteId",
                table: "QuoteViews",
                column: "QuoteId");

            migrationBuilder.CreateIndex(
                name: "IX_Signatures_user_id",
                table: "Signatures",
                column: "user_id");

            migrationBuilder.CreateIndex(
                name: "IX_training_courses_user_id",
                table: "training_courses",
                column: "user_id");

            migrationBuilder.CreateIndex(
                name: "IX_users_department_id",
                table: "users",
                column: "department_id");

            migrationBuilder.CreateIndex(
                name: "IX_users_email",
                table: "users",
                column: "email",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_users_nric",
                table: "users",
                column: "nric",
                unique: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "annual_leave");

            migrationBuilder.DropTable(
                name: "Attendance");

            migrationBuilder.DropTable(
                name: "Certificates");

            migrationBuilder.DropTable(
                name: "DocumentReads");

            migrationBuilder.DropTable(
                name: "equipment_items");

            migrationBuilder.DropTable(
                name: "Events");

            migrationBuilder.DropTable(
                name: "fixed_asset_products");

            migrationBuilder.DropTable(
                name: "HandbookContents");

            migrationBuilder.DropTable(
                name: "Holidays");

            migrationBuilder.DropTable(
                name: "leave_detail");

            migrationBuilder.DropTable(
                name: "Mc_Leave_Requests");

            migrationBuilder.DropTable(
                name: "MomentImages");

            migrationBuilder.DropTable(
                name: "MomentReactions");

            migrationBuilder.DropTable(
                name: "QuoteReactions");

            migrationBuilder.DropTable(
                name: "QuoteViews");

            migrationBuilder.DropTable(
                name: "training_courses");

            migrationBuilder.DropTable(
                name: "documents",
                schema: "dbo");

            migrationBuilder.DropTable(
                name: "equipment_requests",
                schema: "dbo");

            migrationBuilder.DropTable(
                name: "ChangeRequests");

            migrationBuilder.DropTable(
                name: "HandbookSections");

            migrationBuilder.DropTable(
                name: "Moments");

            migrationBuilder.DropTable(
                name: "Quotes");

            migrationBuilder.DropTable(
                name: "Signatures");

            migrationBuilder.DropTable(
                name: "fixed_asset_types");

            migrationBuilder.DropTable(
                name: "users");

            migrationBuilder.DropTable(
                name: "departments");
        }
    }
}
