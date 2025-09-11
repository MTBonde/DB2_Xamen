using DbClient.Models;
using DbClient.Repositories;

namespace DbClient;

/// <summary>
/// Console application demonstrating database operations.
/// Issue #7: Database connection service with retry logic and error handling.
/// Issue #8: User model and CREATE operation using raw SQL.
/// Issue #9: READ operations (GetById, GetByEmail) using raw SQL.
/// Issue #10: UPDATE operation (UpdateUserEmail) using raw SQL.
/// Issue #11: DELETE operation (DeleteUser) using raw SQL.
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
        
        IDbConnectionService connectionService = new DatabaseConnectionService();
        User savedUser = null;

        try
        {
            // Initialize services
            IUserRepository userRepository = new UserRepository(connectionService);

            // Test 1: Database connection test
            Console.WriteLine("Testing database connection...");
            using (var connection = connectionService.GetConnection())
            {
                Console.WriteLine($"Connection State: {connection.State}");
                Console.WriteLine($"Database: {connection.Database}");
                Console.WriteLine();
            }

            Console.WriteLine("Press any key to continue to CREATE demo...");
            Console.ReadKey();
            Console.WriteLine();

            // Test 2: User creation demo
            Console.WriteLine("=== User Creation Demo ===");
            
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
            
            savedUser = createdUser;

            Console.WriteLine("Press any key to test duplicate email handling...");
            Console.ReadKey();
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

            Console.WriteLine("Press any key to test input validation...");
            Console.ReadKey();
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

            Console.WriteLine("Press any key to continue to READ operations demo...");
            Console.ReadKey();
            Console.WriteLine();

            // Test 3: READ operations demo
            Console.WriteLine("=== READ Operations Demo ===");
            
            // Demo GetById
            Console.WriteLine($"Testing GetUserByIdAsync with UserId: {createdUser.UserId}");
            var userById = await userRepository.GetUserByIdAsync(createdUser.UserId);
            if (userById != null)
            {
                Console.WriteLine(" User found by ID:");
                Console.WriteLine($"   UserId: {userById.UserId}");
                Console.WriteLine($"   Email: {userById.Email}");
                Console.WriteLine($"   CreatedAt: {userById.CreatedAt}");
            }
            else
            {
                Console.WriteLine(" User not found by ID");
            }
            Console.WriteLine();

            // Demo GetByEmail
            Console.WriteLine($"Testing GetUserByEmailAsync with Email: {createdUser.Email}");
            var userByEmail = await userRepository.GetUserByEmailAsync(createdUser.Email);
            if (userByEmail != null)
            {
                Console.WriteLine(" User found by Email:");
                Console.WriteLine($"   UserId: {userByEmail.UserId}");
                Console.WriteLine($"   Email: {userByEmail.Email}");
                Console.WriteLine($"   CreatedAt: {userByEmail.CreatedAt}");
            }
            else
            {
                Console.WriteLine(" User not found by Email");
            }
            Console.WriteLine();

            // Demo not found scenarios
            Console.WriteLine("Testing not found scenarios...");
            var nonExistentUser = await userRepository.GetUserByIdAsync(99999);
            Console.WriteLine($"GetUserByIdAsync(99999): {(nonExistentUser == null ? "null (correct)" : "unexpected result")}");
            
            var nonExistentEmail = await userRepository.GetUserByEmailAsync("nonexistent@example.com");
            Console.WriteLine($"GetUserByEmailAsync(nonexistent): {(nonExistentEmail == null ? "null (correct)" : "unexpected result")}");
            Console.WriteLine();

            Console.WriteLine("Press any key to continue to UPDATE operations demo...");
            Console.ReadKey();
            Console.WriteLine();

            // Test 4: UPDATE operation demo
            Console.WriteLine("=== UPDATE Operation Demo ===");
            
            // Show current email
            Console.WriteLine($"Current user email: {createdUser.Email}");
            
            // Update email
            string newEmail = $"updated{DateTime.Now.Ticks}@example.com";
            Console.WriteLine($"Updating email to: {newEmail}");
            
            bool updateResult = await userRepository.UpdateUserEmailAsync(createdUser.UserId, newEmail);
            Console.WriteLine($"Update result: {(updateResult ? "Success" : "Failed - user not found")}");
            
            // Verify update by reading user again
            if (updateResult)
            {
                var updatedUser = await userRepository.GetUserByIdAsync(createdUser.UserId);
                if (updatedUser != null)
                {
                    Console.WriteLine($"Verified updated email: {updatedUser.Email}");
                }
            }
            Console.WriteLine();

            // Test update not found scenario
            Console.WriteLine("Testing update with non-existent user...");
            bool updateNonExistent = await userRepository.UpdateUserEmailAsync(99999, "test@example.com");
            Console.WriteLine($"Update non-existent user: {(updateNonExistent ? "unexpected success" : "false (correct)")}");
            Console.WriteLine();

            Console.WriteLine("Press any key to continue to DELETE operations demo...");
            Console.ReadKey();
            Console.WriteLine();

            /*// Test 5: DELETE operation demo
            Console.WriteLine("=== DELETE Operation Demo ===");
            
            // Verify user exists before deletion
            var userBeforeDelete = await userRepository.GetUserByIdAsync(createdUser.UserId);
            Console.WriteLine($"User exists before delete: {(userBeforeDelete != null ? "Yes" : "No")}");
            
            // Delete the user
            Console.WriteLine($"Deleting user with UserId: {createdUser.UserId}");
            bool deleteResult = await userRepository.DeleteUserAsync(createdUser.UserId);
            Console.WriteLine($"Delete result: {(deleteResult ? "Success" : "Failed - user not found")}");
            
            // Verify user no longer exists
            if (deleteResult)
            {
                var userAfterDelete = await userRepository.GetUserByIdAsync(createdUser.UserId);
                Console.WriteLine($"User exists after delete: {(userAfterDelete != null ? "Yes (unexpected)" : "No (correct)")}");
            }
            Console.WriteLine();

            // Test delete not found scenario
            Console.WriteLine("Testing delete with non-existent user...");
            bool deleteNonExistent = await userRepository.DeleteUserAsync(99999);
            Console.WriteLine($"Delete non-existent user: {(deleteNonExistent ? "unexpected success" : "false (correct)")}");
            Console.WriteLine();*/

            Console.WriteLine("All database operations completed successfully!");
        }
        catch (InvalidOperationException ex)
        {
            Console.WriteLine($"Configuration Error: {ex.Message}");
            Console.WriteLine("Check your appsettings.json connection string and ensure PostgreSQL is running. Did you forget to start DOCKER?");
        }
        catch (Exception ex)
        {
            Console.WriteLine($"Unexpected Error: {ex.Message}");
            Console.WriteLine($"Exception Type: {ex.GetType().Name}");
        }
        
        //---------------------------ORM-------------------------------------

        Console.WriteLine("\nNow ORM operations on 'Ingredient' table:\n");
        
        try
        {
            IngredientRepository ingredientRepository = new IngredientRepository(connectionService);
            Ingredient ingredient = new Ingredient
            {
                Name = "Tomato",
                CarbsPer100 = 0,
                CreatedAt = DateTime.UtcNow,
                EnergyKcalPer100 = 10,
                FatPer100 = 0,
                ProteinPer100 = 0,
                UnitId = 1,
                UserId = savedUser.UserId
            };

            Console.WriteLine("Adding ingredient: Tomato");

            await ingredientRepository.CreateIngredientAsync(ingredient);
            
            Console.WriteLine("Added ingredient!");
            
            Console.WriteLine("Press any key to continue to READ operations demo...");
            Console.ReadKey();
            
            Console.WriteLine();
            
            Console.WriteLine("Looking for ingredient...\n");
            Ingredient? foundIngredient = await ingredientRepository.GetIngredientAsync(ingredient);
            
            if (foundIngredient != null)
                Console.WriteLine("Found ingredient!" + foundIngredient.Name);
        }
        catch (Exception e)
        {
            Console.WriteLine("Something awful! | " + e);
            throw;
        }
        
        //---------------------------Exit-------------------------------------
        
        Console.WriteLine();
        Console.WriteLine("Press any key to exit...");
        Console.ReadKey();
    }
}
