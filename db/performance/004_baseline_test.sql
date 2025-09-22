-- =========================================
-- Baseline Performance Test - BEFORE Optimization
-- Run this BEFORE adding indexes to establish baseline
-- =========================================

\echo '========================================='
\echo 'BASELINE PERFORMANCE TEST (No Indexes)'
\echo '========================================='
\echo ''

-- Enable timing for all queries
\timing on

\echo 'TEST 1: Barcode Lookup (Equality Search)'
\echo 'Expected: Sequential scan on Barcode table'
\echo '-----------------------------------------'

EXPLAIN ANALYZE
SELECT b.Code, b.IngredientId, i.Name
FROM Barcode b
JOIN Ingredient i ON i.IngredientId = b.IngredientId
WHERE b.Code = '5710000012345';

\echo ''
\echo 'TEST 2: User Recipe Lookup (Foreign Key Join)'
\echo 'Expected: Sequential scan on Recipe table'
\echo '----------------------------------------------'

EXPLAIN ANALYZE
SELECT r.RecipeId, r.Name, r.PortionCount
FROM Recipe r
WHERE r.UserId = 5000
ORDER BY r.Name;

\echo ''
\echo 'TEST 3: Recipe with Ingredients (Complex Join)'
\echo 'Expected: Multiple sequential scans and hash joins'
\echo '--------------------------------------------------'

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
\echo 'BASELINE TEST COMPLETE'
\echo 'Save these results for comparison!'
\echo 'Next: Run 005_optimization.sql'
\echo 'Then: Run 006_comparison_test.sql'
\echo '========================================='

-- Disable timing
\timing off