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

    public async Task<User?> GetUserByIdAsync(int userId)
    {
        // Basic input validation
        if (userId <= 0)
        {
            throw new ArgumentException("User ID must be a positive integer");
        }

        // Raw SQL SELECT with parameterized query
        const string sql = @"
            SELECT UserId, Email, PasswordHash, CreatedAt 
            FROM ""User"" 
            WHERE UserId = @UserId";

        try
        {
            using var connection = _connectionService.GetConnection();
            using var command = connection.CreateCommand();
            
            command.CommandText = sql;
            command.Parameters.Add(new NpgsqlParameter("@UserId", userId));

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

            return null; // User not found
        }
        catch (NpgsqlException ex)
        {
            throw new InvalidOperationException($"Database error occurred while retrieving user: {ex.Message}");
        }
    }

    public async Task<User?> GetUserByEmailAsync(string email)
    {
        // Basic input validation
        if (string.IsNullOrWhiteSpace(email))
        {
            throw new ArgumentException("Email address is required");
        }

        // Raw SQL SELECT with parameterized query
        const string sql = @"
            SELECT UserId, Email, PasswordHash, CreatedAt 
            FROM ""User"" 
            WHERE Email = @Email";

        try
        {
            using var connection = _connectionService.GetConnection();
            using var command = connection.CreateCommand();
            
            command.CommandText = sql;
            command.Parameters.Add(new NpgsqlParameter("@Email", email));

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

            return null; // User not found
        }
        catch (NpgsqlException ex)
        {
            throw new InvalidOperationException($"Database error occurred while retrieving user: {ex.Message}");
        }
    }

    public async Task<bool> UpdateUserEmailAsync(int userId, string newEmail)
    {
        // Basic input validation
        if (userId <= 0)
        {
            throw new ArgumentException("User ID must be a positive integer");
        }

        if (string.IsNullOrWhiteSpace(newEmail) || !newEmail.Contains("@"))
        {
            throw new ArgumentException("Valid email address is required");
        }

        // Raw SQL UPDATE with parameterized query
        const string sql = @"
            UPDATE ""User"" 
            SET Email = @Email 
            WHERE UserId = @UserId";

        try
        {
            using var connection = _connectionService.GetConnection();
            using var command = connection.CreateCommand();
            
            command.CommandText = sql;
            command.Parameters.Add(new NpgsqlParameter("@Email", newEmail));
            command.Parameters.Add(new NpgsqlParameter("@UserId", userId));

            int rowsAffected = await ((NpgsqlCommand)command).ExecuteNonQueryAsync();
            
            return rowsAffected > 0; // True if user was found and updated
        }
        catch (NpgsqlException ex) when (ex.SqlState == "23505") // Unique constraint violation
        {
            throw new InvalidOperationException($"A user with email '{newEmail}' already exists");
        }
        catch (NpgsqlException ex)
        {
            throw new InvalidOperationException($"Database error occurred while updating user: {ex.Message}");
        }
    }
}