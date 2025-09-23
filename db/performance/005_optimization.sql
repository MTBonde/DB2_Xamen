-- =========================================
-- Database Optimization - Adding Strategic Indexes
-- Run this AFTER baseline testing
-- pgAdmin Compatible Version
-- =========================================

-- =========================================
-- APPLYING DATABASE OPTIMIZATIONS
-- =========================================

BEGIN;

-- OPTIMIZATION 1: Hash Index for Barcode Lookup
-- Justification: Barcode lookups are always equality-based
-- Hash indexes are optimal for exact matches (no range/sorting needed)
-- --------------------------------------------------------------

CREATE INDEX IF NOT EXISTS ix_barcode_code_hash
ON Barcode USING hash (Code);

-- Created: ix_barcode_code_hash (hash index)

-- OPTIMIZATION 2: B-tree Index for Recipe-User Foreign Key
-- Justification: Frequent joins between Recipe and User tables
-- B-tree supports both equality and range queries
-- -----------------------------------------------------------

CREATE INDEX IF NOT EXISTS ix_recipe_userid
ON Recipe (UserId);

-- Created: ix_recipe_userid (B-tree index)

-- OPTIMIZATION 3: B-tree Index for RecipeIngredient-Recipe Foreign Key
-- Justification: Essential for Recipe -> RecipeIngredient joins
-- Most common join pattern in recipe queries
-- ---------------------------------------------------------------------

CREATE INDEX IF NOT EXISTS ix_recipeingredient_recipeid
ON RecipeIngredient (RecipeId);

-- Created: ix_recipeingredient_recipeid (B-tree index)

-- OPTIMIZATION 4: B-tree Index for RecipeIngredient-Ingredient Foreign Key
-- Justification: Supports ingredient-based recipe searches
-- Enables efficient reverse lookups
-- ------------------------------------------------------------------------

CREATE INDEX IF NOT EXISTS ix_recipeingredient_ingredientid
ON RecipeIngredient (IngredientId);

-- Created: ix_recipeingredient_ingredientid (B-tree index)

-- Update table statistics after index creation
ANALYZE Barcode;
ANALYZE Recipe;
ANALYZE RecipeIngredient;

COMMIT;

-- =========================================
-- OPTIMIZATION COMPLETE
--
-- Indexes Created:
-- 1. Hash index on Barcode.Code (equality lookups)
-- 2. B-tree index on Recipe.UserId (FK joins)
-- 3. B-tree index on RecipeIngredient.RecipeId (FK joins)
-- 4. B-tree index on RecipeIngredient.IngredientId (FK joins)
--
-- Next: Run 006_comparison_test.sql to see improvements
-- =========================================