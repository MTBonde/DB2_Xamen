using System.Data;
using Microsoft.Extensions.Configuration;
using Npgsql;

namespace DbClient;

/// <summary>
/// Database connection service that manages PostgreSQL connections with retry logic,
/// connection pooling, and configuration management from appsettings.json.
/// Implements the Single Responsibility Principle by focusing solely on connection management.
/// </summary>
public class DatabaseConnectionService : IDbConnectionService
{
    private readonly string _connectionString;
    private const int MaxRetryAttempts = 3;
    private const int BaseDelayMs = 1000;

    /// <summary>
    /// Initializes a new instance of the DatabaseConnectionService.
    /// Reads the connection string from appsettings.json and validates it.
    /// </summary>
    /// <exception cref="InvalidOperationException">Thrown when connection string is not configured.</exception>
    public DatabaseConnectionService()
    {
        // Build configuration to read from appsettings.json
        var configuration = new ConfigurationBuilder()
            .AddJsonFile("appsettings.json", optional: false, reloadOnChange: true)
            .Build();

        // Get connection string from configuration
        _connectionString = configuration.GetConnectionString("Postgres") 
            ?? throw new InvalidOperationException("Connection string 'Postgres' not found in appsettings.json");

        // Validate connection string is not empty
        if (string.IsNullOrWhiteSpace(_connectionString))
        {
            throw new InvalidOperationException("Connection string 'Postgres' is empty in appsettings.json");
        }

        Console.WriteLine("DatabaseConnectionService initialized with connection pooling enabled");
    }

    /// <summary>
    /// Creates and returns an open database connection with retry logic.
    /// Implements exponential backoff for transient failures and comprehensive error handling.
    /// Connection pooling is handled automatically by Npgsql via the connection string configuration.
    /// </summary>
    /// <returns>An open NpgsqlConnection ready for database operations.</returns>
    /// <exception cref="InvalidOperationException">
    /// Thrown when connection cannot be established after all retry attempts.
    /// </exception>
    public IDbConnection GetConnection()
    {
        Exception? lastException = null;

        // Implement retry logic with exponential backoff
        for (int attempt = 1; attempt <= MaxRetryAttempts; attempt++)
        {
            try
            {
                Console.WriteLine($"Connection attempt {attempt}/{MaxRetryAttempts}");

                // Create and open connection - pooling is handled by Npgsql
                var connection = new NpgsqlConnection(_connectionString);
                connection.Open();

                Console.WriteLine("Database connection established successfully");
                return connection;
            }
            catch (Exception ex) when (IsTransientException(ex))
            {
                lastException = ex;
                Console.WriteLine($"Connection attempt {attempt} failed: {ex.Message}");

                // Don't delay after the last attempt
                if (attempt < MaxRetryAttempts)
                {
                    // Exponential backoff: 1s, 2s, 4s
                    var delay = BaseDelayMs * (int)Math.Pow(2, attempt - 1);
                    Console.WriteLine($"Waiting {delay}ms before retry...");
                    Thread.Sleep(delay);
                }
            }
            catch (Exception ex)
            {
                // Non-transient exceptions should not be retried
                Console.WriteLine($"Non-retryable error: {ex.Message}");
                throw new InvalidOperationException($"Database connection failed: {ex.Message}", ex);
            }
        }

        // All retry attempts failed
        var errorMessage = $"Failed to establish database connection after {MaxRetryAttempts} attempts. " +
                          $"Last error: {lastException?.Message}";
        Console.WriteLine($"FATAL: {errorMessage}");
        throw new InvalidOperationException(errorMessage, lastException);
    }

    /// <summary>
    /// Determines if an exception is transient and should be retried.
    /// Transient exceptions are temporary issues that might resolve with retry.
    /// </summary>
    /// <param name="exception">The exception to evaluate.</param>
    /// <returns>True if the exception is transient and should be retried.</returns>
    private static bool IsTransientException(Exception exception)
    {
        // Check for common transient PostgreSQL exceptions
        if (exception is NpgsqlException npgsqlEx)
        {
            // These are common transient error codes that may resolve with retry
            var transientSqlStates = new[]
            {
                "53300", // Too many connections
                "57P03", // Cannot connect now (server starting up)
                "08006", // Connection failure
                "08001", // Unable to connect
                "08004"  // Server rejected connection
            };

            return transientSqlStates.Contains(npgsqlEx.SqlState);
        }

        // Network-related exceptions are typically transient
        if (exception is System.Net.Sockets.SocketException ||
            exception is TimeoutException)
        {
            return true;
        }

        // Default to non-transient for unknown exceptions
        return false;
    }
}