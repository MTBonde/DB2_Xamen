using DbClient.Models;

namespace DbClient.Repositories;

public interface IUserRepository
{
    Task<User> CreateUserAsync(CreateUserRequest request);
}