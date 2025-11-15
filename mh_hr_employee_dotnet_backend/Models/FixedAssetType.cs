using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

[Table("fixed_asset_types")]
public class FixedAssetType
{
    [Key]
    public int Id { get; set; }

    [Required]
    [StringLength(2)]
    public string Code { get; set; } = string.Empty;

    [Required]
    [StringLength(100)]
    public string Name { get; set; } = string.Empty;
}
