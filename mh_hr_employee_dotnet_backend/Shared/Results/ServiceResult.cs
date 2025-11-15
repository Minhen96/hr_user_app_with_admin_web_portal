namespace React.Shared.Results;

/// <summary>
/// Represents the result of a service operation with data
/// </summary>
public class ServiceResult<T>
{
    public bool IsSuccess { get; set; }
    public string Message { get; set; } = string.Empty;
    public T? Data { get; set; }
    public List<string> Errors { get; set; } = new();

    public static ServiceResult<T> Success(T data, string message = "Operation successful")
    {
        return new ServiceResult<T>
        {
            IsSuccess = true,
            Message = message,
            Data = data
        };
    }

    public static ServiceResult<T> Failure(string message, List<string>? errors = null)
    {
        return new ServiceResult<T>
        {
            IsSuccess = false,
            Message = message,
            Errors = errors ?? new List<string>()
        };
    }
}

/// <summary>
/// Represents the result of a service operation without data
/// </summary>
public class ServiceResult
{
    public bool IsSuccess { get; set; }
    public string Message { get; set; } = string.Empty;
    public List<string> Errors { get; set; } = new();

    public static ServiceResult Success(string message = "Operation successful")
    {
        return new ServiceResult
        {
            IsSuccess = true,
            Message = message
        };
    }

    public static ServiceResult Failure(string message, List<string>? errors = null)
    {
        return new ServiceResult
        {
            IsSuccess = false,
            Message = message,
            Errors = errors ?? new List<string>()
        };
    }
}
