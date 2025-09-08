using DbClient.Models;

namespace DbClient.Repositories;

public interface IUserRepository
{
    Task<User> CreateUserAsync(CreateUserRequest request);
    Task<User?> GetUserByIdAsync(int userId);
    Task<User?> GetUserByEmailAsync(string email);
    Task<bool> UpdateUserEmailAsync(int userId, string newEmail);
}