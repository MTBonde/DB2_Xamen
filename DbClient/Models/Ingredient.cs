namespace DbClient.Models;

public class Ingredient
{
    public int IngredientId { get; set; }
    
    public int UserID { get; set; }
    
    public string Name { get; set; } = string.Empty;
    
    public float EnergyKcalPer100 { get; set; }
    
    public float ProteinPer100 { get; set; }
    
    public float CarbsPer100 { get; set; }
    
    public float FatPer100 { get; set; }
    
    public int UnitID { get; set; }
    
    public DateTime CreatedAt { get; set; }
}