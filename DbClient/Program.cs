namespace DbClient;

/// <summary>
/// Simple console application that demonstrates the DatabaseConnectionService.
/// Shows basic connection management, retry logic, and error handling for Issue #7.
/// </summary>
public static class Program
{
    /// <summary>
    /// Application entry point that tests the database connection service.
    /// Creates a direct instance of the service and demonstrates its functionality.
    /// </summary>
    public static void Main(string[] args)
    {
        Console.WriteLine("=== Database Connection Service Demo ===");
        Console.WriteLine();

        try
        {
            // Direct instantiation - demonstrates basic usage without dependency injection
            IDbConnectionService connectionService = new DatabaseConnectionService();

            // Test 1: Basic connection test
            Console.WriteLine("Testing database connection...");
            using (var connection = connectionService.GetConnection())
            {
                Console.WriteLine($"Connection State: {connection.State}");
                Console.WriteLine($"Database: {connection.Database}");
                Console.WriteLine();
                
                // Test 2: Simple query test to verify functionality
                Console.WriteLine("Testing basic query execution...");
                using var command = connection.CreateCommand();
                command.CommandText = "SELECT 1 as test_value";
                var result = command.ExecuteScalar();
                Console.WriteLine($"Query result: {result}");
            }

            Console.WriteLine();
            Console.WriteLine("Database connection service test completed successfully!");
        }
        catch (InvalidOperationException ex)
        {
            Console.WriteLine($"Configuration Error: {ex.Message}");
            Console.WriteLine("Check your appsettings.json connection string and ensure PostgreSQL is running.");
        }
        catch (Exception ex)
        {
            Console.WriteLine($"Unexpected Error: {ex.Message}");
            Console.WriteLine($"Exception Type: {ex.GetType().Name}");
        }

        Console.WriteLine();
        Console.WriteLine("Press any key to exit...");
        Console.ReadKey();
    }
}
