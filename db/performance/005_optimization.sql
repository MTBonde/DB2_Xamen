-- =========================================
-- Database Optimization - Adding Strategic Indexes
-- Run this AFTER baseline testing
-- =========================================

\echo '========================================='
\echo 'APPLYING DATABASE OPTIMIZATIONS'
\echo '========================================='
\echo ''

BEGIN;

\echo 'OPTIMIZATION 1: Hash Index for Barcode Lookup'
\echo 'Justification: Barcode lookups are always equality-based'
\echo 'Hash indexes are optimal for exact matches (no range/sorting needed)'
\echo '--------------------------------------------------------------'

CREATE INDEX IF NOT EXISTS ix_barcode_code_hash
ON Barcode USING hash (Code);

\echo 'Created: ix_barcode_code_hash (hash index)'
\echo ''

\echo 'OPTIMIZATION 2: B-tree Index for Recipe-User Foreign Key'
\echo 'Justification: Frequent joins between Recipe and User tables'
\echo 'B-tree supports both equality and range queries'
\echo '-----------------------------------------------------------'

CREATE INDEX IF NOT EXISTS ix_recipe_userid
ON Recipe (UserId);

\echo 'Created: ix_recipe_userid (B-tree index)'
\echo ''

\echo 'OPTIMIZATION 3: B-tree Index for RecipeIngredient-Recipe Foreign Key'
\echo 'Justification: Essential for Recipe -> RecipeIngredient joins'
\echo 'Most common join pattern in recipe queries'
\echo '---------------------------------------------------------------------'

CREATE INDEX IF NOT EXISTS ix_recipeingredient_recipeid
ON RecipeIngredient (RecipeId);

\echo 'Created: ix_recipeingredient_recipeid (B-tree index)'
\echo ''

\echo 'OPTIMIZATION 4: B-tree Index for RecipeIngredient-Ingredient Foreign Key'
\echo 'Justification: Supports ingredient-based recipe searches'
\echo 'Enables efficient reverse lookups'
\echo '------------------------------------------------------------------------'

CREATE INDEX IF NOT EXISTS ix_recipeingredient_ingredientid
ON RecipeIngredient (IngredientId);

\echo 'Created: ix_recipeingredient_ingredientid (B-tree index)'
\echo ''

-- Update table statistics after index creation
ANALYZE Barcode;
ANALYZE Recipe;
ANALYZE RecipeIngredient;

COMMIT;

\echo '========================================='
\echo 'OPTIMIZATION COMPLETE'
\echo ''
\echo 'Indexes Created:'
\echo '1. Hash index on Barcode.Code (equality lookups)'
\echo '2. B-tree index on Recipe.UserId (FK joins)'
\echo '3. B-tree index on RecipeIngredient.RecipeId (FK joins)'
\echo '4. B-tree index on RecipeIngredient.IngredientId (FK joins)'
\echo ''
\echo 'Next: Run 006_comparison_test.sql to see improvements'
\echo '========================================='