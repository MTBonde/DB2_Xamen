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
SELECT b.Code, b.IngredientId, i.Name
FROM Barcode b
JOIN Ingredient i ON i.IngredientId = b.IngredientId
WHERE b.Code = '5710000012345';

-- TEST 2: User Recipe Lookup (Foreign Key Join)
-- Expected: Index scan using B-tree index on UserId
-- Should show dramatic improvement from baseline
-- ------------------------------------------------

EXPLAIN ANALYZE
SELECT r.RecipeId, r.Name, r.PortionCount
FROM Recipe r
WHERE r.UserId = 5000
ORDER BY r.Name;

-- TEST 3: Recipe with Ingredients (Complex Join)
-- Expected: Multiple index scans instead of sequential scans
-- Join algorithms should be more efficient
-- ----------------------------------------------------------

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
-- COMPARISON TEST COMPLETE
--
-- Compare these results with baseline:
-- 1. Execution times should be significantly lower
-- 2. Query plans should show index scans vs seq scans
-- 3. Cost estimates should be lower
--
-- Key improvements to highlight:
-- - Hash index enables O(1) barcode lookups
-- - B-tree indexes eliminate full table scans
-- - Foreign key indexes make joins efficient
-- =========================================

-- Show current index usage statistics
-- Index Usage Summary:
-- -------------------

SELECT
    schemaname,
    tablename,
    indexname,
    idx_scan,
    idx_tup_read,
    idx_tup_fetch
FROM pg_stat_user_indexes
WHERE schemaname = 'public'
    AND indexname LIKE 'ix_%'
ORDER BY tablename, indexname;