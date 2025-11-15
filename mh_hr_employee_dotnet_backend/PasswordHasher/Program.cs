using System;
using System.Security.Cryptography;
using System.Text;

Console.WriteLine("=== Password Hash Tester ===");
Console.WriteLine("Testing password hashing and comparison\n");

// Test passwords
string inputPassword = "Admin@123";
string storedHash = "e86f78a8a3caf0b60d8e74e5942aa6d86dc150cd3c03338aef25b7d2d7e3acc7";

Console.WriteLine($"Input Password: '{inputPassword}'");
Console.WriteLine($"Stored Hash:    {storedHash}");
Console.WriteLine();

// Generate hash from input
string generatedHash = HashPassword(inputPassword);
Console.WriteLine($"Generated Hash: {generatedHash}");
Console.WriteLine();

// Compare hashes
bool match1 = string.Equals(generatedHash, storedHash, StringComparison.OrdinalIgnoreCase);
bool match2 = generatedHash == storedHash;
bool match3 = string.Equals(generatedHash, storedHash, StringComparison.Ordinal);

Console.WriteLine("Comparison Results:");
Console.WriteLine($"  OrdinalIgnoreCase: {match1}");
Console.WriteLine($"  Exact (==):        {match2}");
Console.WriteLine($"  Ordinal:           {match3}");
Console.WriteLine();

// Show byte-by-byte comparison
Console.WriteLine("Character comparison:");
if (generatedHash.Length != storedHash.Length)
{
    Console.WriteLine($"  LENGTH MISMATCH! Generated: {generatedHash.Length}, Stored: {storedHash.Length}");
}
else
{
    bool allMatch = true;
    for (int i = 0; i < generatedHash.Length; i++)
    {
        if (generatedHash[i] != storedHash[i])
        {
            Console.WriteLine($"  Mismatch at position {i}: '{generatedHash[i]}' vs '{storedHash[i]}'");
            allMatch = false;
        }
    }
    if (allMatch)
    {
        Console.WriteLine("  All characters match!");
    }
}

Console.WriteLine();
Console.WriteLine("=== Interactive Testing ===");
Console.WriteLine("Enter password to test (or press Enter to exit):");

while (true)
{
    Console.Write("> ");
    string? input = Console.ReadLine();

    if (string.IsNullOrWhiteSpace(input))
    {
        break;
    }

    string hash = HashPassword(input);
    Console.WriteLine($"Hash: {hash}");
    Console.WriteLine($"Match with stored: {string.Equals(hash, storedHash, StringComparison.OrdinalIgnoreCase)}");
    Console.WriteLine();
}

static string HashPassword(string password)
{
    using var sha256 = SHA256.Create();
    byte[] passwordBytes = Encoding.UTF8.GetBytes(password);
    byte[] hashBytes = sha256.ComputeHash(passwordBytes);
    return string.Concat(hashBytes.Select(b => b.ToString("x2")));
}
