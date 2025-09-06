using System.Data;

namespace DbClient;

/// <summary>
/// Interface for database connection management service.
/// Follows the Dependency Inversion Principle by providing an abstraction
/// that allows for different implementations and easy testing.
/// </summary>
public interface IDbConnectionService
{
    /// <summary>
    /// Creates and returns an open database connection with retry logic and error handling.
    /// The connection is managed by the connection pool configured in the connection string.
    /// </summary>
    /// <returns>An open database connection ready for use.</returns>
    /// <exception cref="InvalidOperationException">Thrown when connection cannot be established after retries.</exception>
    IDbConnection GetConnection();
}