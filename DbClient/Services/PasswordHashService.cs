using System.Security.Cryptography;
using System.Text;

namespace DbClient.Services;

public class PasswordHashService
{
    private const string Salt = "cheese";

    public string HashPassword(string password)
    {
        string saltedPassword = password + Salt;
        byte[] hash = SHA256.HashData(Encoding.UTF8.GetBytes(saltedPassword));
        return Convert.ToBase64String(hash);
    }
}