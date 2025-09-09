using System.ComponentModel.DataAnnotations.Schema;
using Microsoft.EntityFrameworkCore.Metadata.Internal;

namespace DbClient.Models;

public class Ingredient
{
    public int IngredientId { get; set; }
    
    public int UserId { get; set; }
    
    public string Name { get; set; } = string.Empty;
    
    public float EnergyKcalPer100 { get; set; }
    
    public float ProteinPer100 { get; set; }
    
    public float CarbsPer100 { get; set; }
    
    public float FatPer100 { get; set; }
    
    public int UnitId { get; set; }
    
    public DateTime CreatedAt { get; set; }
}