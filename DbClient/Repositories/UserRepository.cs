using System.Data;
using DbClient.Models;
using DbClient.Services;
using Npgsql;

namespace DbClient.Repositories;

public class UserRepository : IUserRepository
{
    private readonly IDbConnectionService _connectionService;
    private readonly PasswordHashService _passwordHashService;

    public UserRepository(IDbConnectionService connectionService)
    {
        _connectionService = connectionService;
        _passwordHashService = new PasswordHashService();
    }

    public async Task<User> CreateUserAsync(CreateUserRequest request)
    {
        // Basic input validation
        if (string.IsNullOrWhiteSpace(request.Email) || !request.Email.Contains("@"))
        {
            throw new ArgumentException("Valid email address is required");
        }

        if (string.IsNullOrWhiteSpace(request.Password) || request.Password.Length < 8)
        {
            throw new ArgumentException("Password must be at least 8 characters long");
        }

        // Hash the password
        string passwordHash = _passwordHashService.HashPassword(request.Password);

        // Raw SQL INSERT with parameterized query and RETURNING clause
        const string sql = @"
            INSERT INTO ""User"" (Email, PasswordHash) 
            VALUES (@Email, @PasswordHash)
            RETURNING UserId, Email, PasswordHash, CreatedAt";

        try
        {
            using var connection = _connectionService.GetConnection();
            using var command = connection.CreateCommand();
            
            command.CommandText = sql;
            command.Parameters.Add(new NpgsqlParameter("@Email", request.Email));
            command.Parameters.Add(new NpgsqlParameter("@PasswordHash", passwordHash));

            using var reader = await ((NpgsqlCommand)command).ExecuteReaderAsync();
            
            if (await reader.ReadAsync())
            {
                return new User
                {
                    UserId = reader.GetInt32("UserId"),
                    Email = reader.GetString("Email"),
                    PasswordHash = reader.GetString("PasswordHash"),
                    CreatedAt = reader.GetDateTime("CreatedAt")
                };
            }

            throw new InvalidOperationException("Failed to create user - no data returned");
        }
        catch (NpgsqlException ex) when (ex.SqlState == "23505") // Unique constraint violation
        {
            throw new InvalidOperationException($"A user with email '{request.Email}' already exists");
        }
    }
}