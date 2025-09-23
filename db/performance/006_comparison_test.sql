-- =========================================
-- Performance Comparison - AFTER Optimization
-- Run this AFTER applying indexes to see improvements
-- =========================================

\echo '========================================='
\echo 'OPTIMIZED PERFORMANCE TEST (With Indexes)'
\echo '========================================='
\echo ''

-- Enable timing for all queries
\timing on

\echo 'TEST 1: Barcode Lookup (Equality Search)'
\echo 'Expected: Index scan using hash index'
\echo 'Should be significantly faster than baseline'
\echo '--------------------------------------------'

EXPLAIN ANALYZE
SELECT b.Code, b.IngredientId, i.Name
FROM Barcode b
JOIN Ingredient i ON i.IngredientId = b.IngredientId
WHERE b.Code = '5710000012345';

\echo ''
\echo 'TEST 2: User Recipe Lookup (Foreign Key Join)'
\echo 'Expected: Index scan using B-tree index on UserId'
\echo 'Should show dramatic improvement from baseline'
\echo '------------------------------------------------'

EXPLAIN ANALYZE
SELECT r.RecipeId, r.Name, r.PortionCount
FROM Recipe r
WHERE r.UserId = 5000
ORDER BY r.Name;

\echo ''
\echo 'TEST 3: Recipe with Ingredients (Complex Join)'
\echo 'Expected: Multiple index scans instead of sequential scans'
\echo 'Join algorithms should be more efficient'
\echo '----------------------------------------------------------'

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

\echo ''
\echo '========================================='
\echo 'COMPARISON TEST COMPLETE'
\echo ''
\echo 'Compare these results with baseline:'
\echo '1. Execution times should be significantly lower'
\echo '2. Query plans should show index scans vs seq scans'
\echo '3. Cost estimates should be lower'
\echo ''
\echo 'Key improvements to highlight:'
\echo '- Hash index enables O(1) barcode lookups'
\echo '- B-tree indexes eliminate full table scans'
\echo '- Foreign key indexes make joins efficient'
\echo '========================================='

-- Show current index usage statistics
\echo ''
\echo 'Index Usage Summary:'
\echo '-------------------'

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

-- Disable timing
\timing off