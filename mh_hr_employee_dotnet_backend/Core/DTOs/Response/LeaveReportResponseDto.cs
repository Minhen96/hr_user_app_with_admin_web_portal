namespace React.Core.DTOs.Response;

public class AnnualLeaveReportDataDto
{
    public string FullName { get; set; } = string.Empty;
    public int Entitlement { get; set; }
    public double Jan { get; set; }
    public double Feb { get; set; }
    public double Mar { get; set; }
    public double Apr { get; set; }
    public double May { get; set; }
    public double Jun { get; set; }
    public double Jul { get; set; }
    public double Aug { get; set; }
    public double Sep { get; set; }
    public double Oct { get; set; }
    public double Nov { get; set; }
    public double Dec { get; set; }
    public double TotalTaken { get; set; }
    public double Balance { get; set; }
}

public class MedicalLeaveReportDataDto
{
    public string FullName { get; set; } = string.Empty;
    public int Jan { get; set; }
    public int Feb { get; set; }
    public int Mar { get; set; }
    public int Apr { get; set; }
    public int May { get; set; }
    public int Jun { get; set; }
    public int Jul { get; set; }
    public int Aug { get; set; }
    public int Sep { get; set; }
    public int Oct { get; set; }
    public int Nov { get; set; }
    public int Dec { get; set; }
    public int TotalTaken { get; set; }
}
