-- Created in corporation with LLM

-- =========================================
-- Performance Seed for Case 3 Demo
-- Generates realistic data volumes for optimization testing
-- =========================================

BEGIN;

-- Parameters for data generation
DO $
DECLARE
    N_USERS       int := 10000;
    RECIPES_PER_U int := 5;     -- 50k total recipes
    INGS_PER_U    int := 10;    -- 100k total ingredients
    AVG_ITEMS_PER_RECIPE int := 6;  -- ~300k RecipeIngredient rows
    N_STORES      int := 50;
    N_BARCODES    int := 50000;  -- StoreBarcode entries
BEGIN
    RAISE NOTICE 'Performance seeding: users=%, recipes=%, ingredients=%, recipe_items=%, stores=%, barcodes=%',
      N_USERS, N_USERS * RECIPES_PER_U, N_USERS * INGS_PER_U, N_USERS * RECIPES_PER_U * AVG_ITEMS_PER_RECIPE, N_STORES, N_BARCODES;
END $;

-- Generate performance test users
INSERT INTO "User" (UserId, Email, PasswordHash, CreatedAt)
SELECT u,
       'perfuser'||u||'@test.local',
       md5('pwd'||u),
       now() - (u ||' minutes')::interval
FROM generate_series(1001, 11000) u  -- Start from 1001 to avoid conflicts
ON CONFLICT (UserId) DO NOTHING;

-- Generate ingredients per user (100k total)
INSERT INTO Ingredient (IngredientId, UserId, Name, EnergyKcalPer100, ProteinPer100, CarbsPer100, FatPer100, UnitId, CreatedAt)
SELECT row_number() OVER () + 1000 AS IngredientId,  -- Start from 1001
       u                                   AS UserId,
       'Ingredient '||u||'-'||i           AS Name,
       (50 + (random()*250))::int         AS EnergyKcalPer100,
       (random()*30)::real                AS ProteinPer100,
       (random()*60)::real                AS CarbsPer100,
       (random()*30)::real                AS FatPer100,
       1                                   AS UnitId,
       now() - ((u+i) ||' minutes')::interval
FROM generate_series(1001, 11000) u
CROSS JOIN generate_series(1, 10) i
ON CONFLICT (UserId, Name) DO NOTHING;

-- Generate recipes per user (50k total)
INSERT INTO Recipe (RecipeId, UserId, Name, PortionCount, CreatedAt)
SELECT row_number() OVER () + 1000 AS RecipeId,  -- Start from 1001
       u,
       'Recipe '||u||'-'||r,
       1 + (random()*7)::int,
       now() - ((u+r) ||' minutes')::interval
FROM generate_series(1001, 11000) u
CROSS JOIN generate_series(1, 5) r
ON CONFLICT (UserId, Name) DO NOTHING;

-- Generate RecipeIngredient relationships (~300k rows)
INSERT INTO RecipeIngredient (RecipeId, IngredientId, Amount, UnitId)
SELECT r.RecipeId,
       -- Select random ingredient from same user
       1000 + ((r.UserId - 1001) * 10) + (1 + (random()*10)::int) AS IngredientId,
       (10 + (random()*990))::numeric(10,2)                       AS Amount,
       1 AS UnitId
FROM Recipe r
WHERE r.RecipeId > 1000  -- Only new recipes
CROSS JOIN LATERAL generate_series(1, 6)  -- 6 ingredients per recipe
ON CONFLICT (RecipeId, IngredientId) DO NOTHING;

-- Generate additional stores for testing
INSERT INTO Store (StoreId, Name, Chain, Location)
SELECT s + 10 AS StoreId,  -- Start from 11 to avoid conflicts
       'PerfStore '||s,
       'Chain '||((s-1) % 5 + 1),
       'TestCity '||((s-1) % 10 + 1)
FROM generate_series(1, 50) s
ON CONFLICT (StoreId) DO NOTHING;

-- Generate barcodes for ingredients (every other ingredient gets a barcode)
INSERT INTO Barcode (Code, IngredientId)
SELECT '57' || lpad((100000 + row_number() OVER ())::text, 11, '0') AS Code,
       i.IngredientId
FROM Ingredient i
WHERE i.IngredientId > 1000 AND (i.IngredientId % 2) = 0
ON CONFLICT (Code) DO NOTHING;

-- Generate StoreBarcode entries for performance testing (50k rows)
INSERT INTO StoreBarcode (StoreId, Code, Brand, NettoWeightGrams, Price, BoughtOn)
SELECT
    11 + (random()*49)::int AS StoreId,  -- Use performance test stores
    b.Code,
    'Brand ' || ((random()*20)::int + 1),
    50 + (random()*1950)::int        AS NettoWeightGrams,
    (5 + random()*50)::int           AS Price,  -- INTEGER as per schema
    date '2024-01-01' + ((random()*365)::int) * interval '1 day'  -- Random date in 2024
FROM Barcode b
WHERE b.Code LIKE '57%'  -- Only performance test barcodes
ON CONFLICT (StoreId, Code) DO NOTHING;

-- Update statistics for query planner
VACUUM ANALYZE;

-- Report final counts
DO $
DECLARE
    user_count int;
    ingredient_count int;
    recipe_count int;
    recipe_ingredient_count int;
    barcode_count int;
    store_barcode_count int;
BEGIN
    SELECT COUNT(*) INTO user_count FROM "User";
    SELECT COUNT(*) INTO ingredient_count FROM Ingredient;
    SELECT COUNT(*) INTO recipe_count FROM Recipe;
    SELECT COUNT(*) INTO recipe_ingredient_count FROM RecipeIngredient;
    SELECT COUNT(*) INTO barcode_count FROM Barcode;
    SELECT COUNT(*) INTO store_barcode_count FROM StoreBarcode;

    RAISE NOTICE 'Performance seed complete:';
    RAISE NOTICE 'Users: %', user_count;
    RAISE NOTICE 'Ingredients: %', ingredient_count;
    RAISE NOTICE 'Recipes: %', recipe_count;
    RAISE NOTICE 'RecipeIngredients: %', recipe_ingredient_count;
    RAISE NOTICE 'Barcodes: %', barcode_count;
    RAISE NOTICE 'StoreBarcodes: %', store_barcode_count;
END $;

COMMIT;