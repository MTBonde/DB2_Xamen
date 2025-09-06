using DbClient.Models;
using DbClient.Repositories;

namespace DbClient;

/// <summary>
/// Console application demonstrating database operations.
/// Issue #7: Database connection service with retry logic and error handling.
/// Issue #8: User model and CREATE operation using raw SQL.
/// </summary>
public static class Program
{
    /// <summary>
    /// Application entry point that demonstrates database functionality.
    /// </summary>
    public static async Task Main(string[] args)
    {
        Console.WriteLine("=== Database Operations Demo ===");
        Console.WriteLine();

        try
        {
            // Initialize services
            IDbConnectionService connectionService = new DatabaseConnectionService();
            IUserRepository userRepository = new UserRepository(connectionService);

            // Test 1: Database connection test
            Console.WriteLine("Testing database connection...");
            using (var connection = connectionService.GetConnection())
            {
                Console.WriteLine($"Connection State: {connection.State}");
                Console.WriteLine($"Database: {connection.Database}");
                Console.WriteLine();
            }

            // Test 2: User creation demo
            Console.WriteLine("=== User Creation Demo (Issue #8) ===");
            
            // Demo 1: Successful user creation
            var newUser = new CreateUserRequest
            {
                Email = $"testuser{DateTime.Now.Ticks}@example.com",
                Password = "testpassword123"
            };

            Console.WriteLine($"Creating user with email: {newUser.Email}");
            var createdUser = await userRepository.CreateUserAsync(newUser);
            Console.WriteLine($" User created successfully!");
            Console.WriteLine($"   UserId: {createdUser.UserId}");
            Console.WriteLine($"   Email: {createdUser.Email}");
            Console.WriteLine($"   CreatedAt: {createdUser.CreatedAt}");
            Console.WriteLine();

            // Demo 2: Duplicate email error handling
            Console.WriteLine("Testing duplicate email handling...");
            try
            {
                await userRepository.CreateUserAsync(newUser);
            }
            catch (InvalidOperationException ex)
            {
                Console.WriteLine($"Duplicate email correctly handled: {ex.Message}");
            }
            Console.WriteLine();

            // Demo 3: Input validation error handling
            Console.WriteLine("Testing input validation...");
            try
            {
                var invalidUser = new CreateUserRequest
                {
                    Email = "invalid-email",
                    Password = "123"
                };
                await userRepository.CreateUserAsync(invalidUser);
            }
            catch (ArgumentException ex)
            {
                Console.WriteLine($"Input validation working: {ex.Message}");
            }

            Console.WriteLine();
            Console.WriteLine("All database operations completed successfully!");
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
