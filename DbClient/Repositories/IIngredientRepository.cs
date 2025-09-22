using DbClient.Models;

namespace DbClient.Repositories;

public interface IIngredientRepository
{
    Task<Ingredient> CreateIngredientAsync(Ingredient ingredient);

    public Task<Ingredient?> GetIngredientAsync(Ingredient ingredientToFind);
    
    Task<Ingredient?> GetIngredientByNameAsync(string name);
    
    Task<bool> UpdateIngredientAsync(int ingredientID, Ingredient ingredient);
    
    Task<bool> DeleteIngredientAsync(int ingredientID);
}