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
ON barcode USING hash (code);

-- Created: ix_barcode_code_hash (hash index)

-- OPTIMIZATION 2: B-tree Index for Recipe-User Foreign Key
-- Justification: Frequent joins between Recipe and User tables
-- B-tree supports both equality and range queries
-- -----------------------------------------------------------

CREATE INDEX IF NOT EXISTS ix_recipe_userid
ON recipe (userid);

-- Created: ix_recipe_userid (B-tree index)

-- OPTIMIZATION 3: B-tree Index for RecipeIngredient-Recipe Foreign Key
-- Justification: Essential for Recipe -> RecipeIngredient joins
-- Most common join pattern in recipe queries
-- ---------------------------------------------------------------------

CREATE INDEX IF NOT EXISTS ix_recipeingredient_recipeid
ON recipeingredient (recipeid);

-- Created: ix_recipeingredient_recipeid (B-tree index)

-- OPTIMIZATION 4: B-tree Index for RecipeIngredient-Ingredient Foreign Key
-- Justification: Supports ingredient-based recipe searches
-- Enables efficient reverse lookups
-- ------------------------------------------------------------------------

CREATE INDEX IF NOT EXISTS ix_recipeingredient_ingredientid
ON recipeingredient (ingredientid);

-- Created: ix_recipeingredient_ingredientid (B-tree index)

-- Update table statistics after index creation
ANALYZE barcode;
ANALYZE recipe;
ANALYZE recipeingredient;

COMMIT;

-- =========================================
-- OPTIMIZATION COMPLETE
--
-- Indexes Created:
-- 1. Hash index on Barcode.Code (equality lookups)
-- 2. B-tree index on Recipe.UserId (FK joins)
-- 3. B-tree index on RecipeIngredient.RecipeId (FK joins)
-- 4. B-tree index on RecipeIngredient.IngredientId (FK joins)
-- =========================================