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
SELECT b.code, b.ingredientid, i.name
FROM barcode b
JOIN ingredient i ON i.ingredientid = b.ingredientid
WHERE b.code = '5710000012345';

-- TEST 2: User Recipe Lookup (Foreign Key Join)
-- Expected: Sequential scan on Recipe table
-- ----------------------------------------------

EXPLAIN ANALYZE
SELECT r.recipeid, r.name, r.portioncount
FROM recipe r
WHERE r.userid = 5000
ORDER BY r.name;

-- TEST 3: Recipe with Ingredients (Complex Join)
-- Expected: Multiple sequential scans and hash joins
-- --------------------------------------------------

EXPLAIN ANALYZE
SELECT r.name AS RecipeName,
       i.name AS IngredientName,
       ri.amount,
       u.code AS UnitCode
FROM recipe r
JOIN recipeingredient ri ON ri.recipeid = r.recipeid
JOIN ingredient i ON i.ingredientid = ri.ingredientid
JOIN unit u ON u.unitid = ri.unitid
WHERE r.userid = 5000
ORDER BY r.name, i.name;

-- =========================================
-- BASELINE TEST COMPLETE
-- =========================================