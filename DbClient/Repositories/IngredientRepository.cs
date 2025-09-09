using DbClient.Models;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Migrations;
using Npgsql.EntityFrameworkCore.PostgreSQL.Metadata;
using Npgsql.EntityFrameworkCore.PostgreSQL.Metadata.Conventions;

namespace DbClient.Repositories;

public class Context : DbContext
{
    public DbSet<Ingredient> Ingredient { get; set; }
    private readonly IDbConnectionService _connectionService;

    public Context(IDbConnectionService connectionService)
    {
        _connectionService = connectionService;
    }

    protected override void OnConfiguring(DbContextOptionsBuilder optionsBuilder)
    {
        string connectionString = _connectionService.GetConnection().ConnectionString;
        connectionString += ";Password=mfb_pwd";
        
        Console.WriteLine("Configuring...");
        Console.WriteLine("Using: " + connectionString);
        optionsBuilder.UseNpgsql(connectionString);
    }
}

public class IngredientRepository : IIngredientRepository
{
    // private readonly IDbConnectionService _connectionService;
    private Context _context;

    public IngredientRepository(IDbConnectionService connectionService)
    {
        // _connectionService = connectionService;
        _context = new Context(connectionService);
    }
    
    public Task<Ingredient> CreateIngredientAsync(Ingredient ingredient)
    {
        _context.Ingredient.Add(ingredient);
        _context.SaveChanges();
        return Task.FromResult(ingredient);
    }

    public Task<Ingredient?> GetIngredientByIDAsync(int ingredientID)
    {
        throw new NotImplementedException();
    }

    public Task<Ingredient?> GetIngredientByNameAsync(string name)
    {
        throw new NotImplementedException();
    }

    public Task<bool> UpdateIngredientAsync(int ingredientID, Ingredient ingredient)
    {
        _context.Ingredient.Update(ingredient);
        _context.SaveChanges();
        return Task.FromResult(true);
    }

    public Task<bool> DeleteIngredientAsync(int ingredientID)
    {
        throw new NotImplementedException();
    }
}

public partial class InitialCreate : Migration
{
    protected override void Up(MigrationBuilder migrationBuilder)
    {
        
    }

    protected override void Down(MigrationBuilder migrationBuilder)
    {
        
    }
}