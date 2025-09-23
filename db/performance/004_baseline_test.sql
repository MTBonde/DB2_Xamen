-- =========================================
-- Baseline Performance Test - BEFORE Optimization
-- Run this BEFORE adding indexes to establish baseline
-- pgAdmin Compatible Version
-- =========================================

-- =========================================
-- BASELINE PERFORMANCE TEST (No Indexes)
-- =========================================

-- TEST 1: Barcode Lookup (Equality Search)
-- Expected: Sequential scan on Barcode table
-- -----------------------------------------

EXPLAIN ANALYZE
SELECT b.Code, b.IngredientId, i.Name
FROM Barcode b
JOIN Ingredient i ON i.IngredientId = b.IngredientId
WHERE b.Code = '5710000012345';

-- TEST 2: User Recipe Lookup (Foreign Key Join)
-- Expected: Sequential scan on Recipe table
-- ----------------------------------------------

EXPLAIN ANALYZE
SELECT r.RecipeId, r.Name, r.PortionCount
FROM Recipe r
WHERE r.UserId = 5000
ORDER BY r.Name;

-- TEST 3: Recipe with Ingredients (Complex Join)
-- Expected: Multiple sequential scans and hash joins
-- --------------------------------------------------

EXPLAIN ANALYZE
SELECT r.Name AS RecipeName,
       i.Name AS IngredientName,
       ri.Amount,
       u.Code AS UnitCode
FROM Recipe r
JOIN RecipeIngredient ri ON ri.RecipeId = r.RecipeId
JOIN Ingredient i ON i.IngredientId = ri.IngredientId
JOIN Unit u ON u.UnitId = ri.UnitId
WHERE r.UserId = 5000
ORDER BY r.Name, i.Name;

-- =========================================
-- BASELINE TEST COMPLETE
-- Save these results for comparison!
-- Next: Run 005_optimization.sql
-- Then: Run 006_comparison_test.sql
-- =========================================