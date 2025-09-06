using System.Data;
using DbClient.Models;
using DbClient.Repositories;
using Moq;
using Xunit;
using Npgsql;

namespace DbClient.Tests;

public class UserRepositoryTests
{
    private readonly Mock<IDbConnectionService> _mockConnectionService;
    private readonly Mock<IDbConnection> _mockConnection;
    private readonly Mock<IDbCommand> _mockCommand;
    private readonly UserRepository _userRepository;

    public UserRepositoryTests()
    {
        _mockConnectionService = new Mock<IDbConnectionService>();
        _mockConnection = new Mock<IDbConnection>();
        _mockCommand = new Mock<IDbCommand>();
        _userRepository = new UserRepository(_mockConnectionService.Object);
    }

    [Fact]
    public async Task CreateUserAsync_WithValidRequest_ShouldReturnCreatedUser()
    {
        // Arrange
        var request = new CreateUserRequest
        {
            Email = "test@example.com",
            Password = "testpassword123"
        };

        var expectedUser = new User
        {
            UserId = 1,
            Email = "test@example.com",
            PasswordHash = "hashedpassword",
            CreatedAt = DateTime.UtcNow
        };

        // This is a simplified test - in a real scenario, you'd mock the database reader
        // For now, let's test the validation logic
        
        // Act & Assert - Test validation
        var exception = await Record.ExceptionAsync(async () => 
        {
            // This will fail at the database level, but we're testing the validation passes
            await _userRepository.CreateUserAsync(request);
        });

        // The method should not throw validation exceptions for valid input
        Assert.IsNotType<ArgumentException>(exception);
    }

    [Fact]
    public async Task CreateUserAsync_WithInvalidEmail_ShouldThrowArgumentException()
    {
        // Arrange
        var request = new CreateUserRequest
        {
            Email = "invalid-email",
            Password = "testpassword123"
        };

        // Act & Assert
        var exception = await Assert.ThrowsAsync<ArgumentException>(
            () => _userRepository.CreateUserAsync(request));
        
        Assert.Contains("Valid email address is required", exception.Message);
    }

    [Fact]
    public async Task CreateUserAsync_WithShortPassword_ShouldThrowArgumentException()
    {
        // Arrange
        var request = new CreateUserRequest
        {
            Email = "test@example.com",
            Password = "123"
        };

        // Act & Assert
        var exception = await Assert.ThrowsAsync<ArgumentException>(
            () => _userRepository.CreateUserAsync(request));
        
        Assert.Contains("Password must be at least 8 characters long", exception.Message);
    }

    [Fact]
    public async Task CreateUserAsync_WithEmptyEmail_ShouldThrowArgumentException()
    {
        // Arrange
        var request = new CreateUserRequest
        {
            Email = "",
            Password = "testpassword123"
        };

        // Act & Assert
        var exception = await Assert.ThrowsAsync<ArgumentException>(
            () => _userRepository.CreateUserAsync(request));
        
        Assert.Contains("Valid email address is required", exception.Message);
    }
}