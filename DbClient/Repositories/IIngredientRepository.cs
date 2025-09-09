using DbClient.Models;

namespace DbClient.Repositories;

public interface IIngredientRepository
{
    Task<Ingredient> CreateIngredientAsync(Ingredient ingredient);
    
    Task<Ingredient?> GetIngredientByIDAsync(int ingredientID);
    
    Task<Ingredient?> GetIngredientByNameAsync(string name);
    
    Task<bool> UpdateIngredientAsync(int ingredientID, Ingredient ingredient);
    
    Task<bool> DeleteIngredientAsync(int ingredientID);
}