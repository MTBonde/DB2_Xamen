-- =========================================
-- Performance Comparison - AFTER Optimization
-- Run this AFTER applying indexes to see improvements
-- pgAdmin Compatible Version
-- =========================================

-- =========================================
-- OPTIMIZED PERFORMANCE TEST (With Indexes)
-- =========================================

-- TEST 1: Barcode Lookup (Equality Search)
-- Expected: Index scan using hash index
-- Should be significantly faster than baseline
-- --------------------------------------------

EXPLAIN ANALYZE
SELECT b.code, b.ingredientid, i.name
FROM barcode b
JOIN ingredient i ON i.ingredientid = b.ingredientid
WHERE b.code = '5710000012345';

-- TEST 2: User Recipe Lookup (Foreign Key Join)
-- Expected: Index scan using B-tree index on UserId
-- Should show dramatic improvement from baseline
-- ------------------------------------------------

EXPLAIN ANALYZE
SELECT r.recipeid, r.name, r.portioncount
FROM recipe r
WHERE r.userid = 5000
ORDER BY r.name;

-- TEST 3: Recipe with Ingredients (Complex Join)
-- Expected: Multiple index scans instead of sequential scans
-- Join algorithms should be more efficient
-- ----------------------------------------------------------

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
-- COMPARISON TEST COMPLETE
-- =========================================
