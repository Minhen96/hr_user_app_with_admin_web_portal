using React.Models;
using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

[Table("fixed_asset_products")]
public class FixedAssetProduct
{
    [Key]
    [Column("id")]
    public int Id { get; set; }

    [StringLength(20)]
    [Column("product_code")]
    public string? ProductCode { get; set; }

    [Column("created_at")]
    public DateTime CreatedAt { get; set; } = DateTime.Now;

    [Column("change_request_id")]
    public int? ChangeRequestId { get; set; }

    [ForeignKey(nameof(ChangeRequestId))]
    public virtual ChangeRequest? ChangeRequest { get; set; }
}

