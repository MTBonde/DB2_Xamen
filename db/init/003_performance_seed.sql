-- Created in corporation with LLM

-- =========================================
-- Performance Seed for Case 3 Demo
-- Generates realistic data volumes for optimization testing
-- =========================================

BEGIN;

-- Generate test users (basic + performance users)
-- Basic test users
INSERT INTO "User" (Email, PasswordHash)
SELECT 'user'||u||'@example.com', 'secrethash'
FROM generate_series(1, 9) u
ON CONFLICT (Email) DO NOTHING;

-- Performance test users
INSERT INTO "User" (Email, PasswordHash, CreatedAt)
SELECT 'perfuser'||u||'@test.local',
       md5('pwd'||u),
       now() - (u ||' minutes')::interval
FROM generate_series(10, 5009) u
ON CONFLICT (Email) DO NOTHING;

-- Generate ingredients for all users (including existing ones)
INSERT INTO Ingredient (UserId, Name, EnergyKcalPer100, ProteinPer100, CarbsPer100, FatPer100, UnitId, CreatedAt)
SELECT u.UserId,
       'PerfIngredient-' || u.UserId || '-' || i,
       (50 + (random()*250))::int,
       (random()*30)::real,
       (random()*60)::real,
       (random()*30)::real,
       1,
       now() - i * interval '1 minute'
FROM "User" u,
     generate_series(1, 50) i  -- 50 ingredients per user
WHERE u.UserId >= 1
ON CONFLICT (UserId, Name) DO NOTHING;

-- Generate recipes for all users
INSERT INTO Recipe (UserId, Name, PortionCount, CreatedAt)
SELECT u.UserId,
       'PerfRecipe-' || u.UserId || '-' || r,
       1 + (random()*7)::int,
       now() - r * interval '1 minute'
FROM "User" u,
     generate_series(1, 10) r  -- 10 recipes per user
WHERE u.UserId >= 1
ON CONFLICT (UserId, Name) DO NOTHING;

-- Generate RecipeIngredient relationships
INSERT INTO RecipeIngredient (RecipeId, IngredientId, Amount, UnitId)
SELECT r.RecipeId,
       i.IngredientId,
       (10 + (random()*990))::numeric(10,2),
       1
FROM Recipe r
JOIN "User" u ON u.UserId = r.UserId
JOIN Ingredient i ON i.UserId = u.UserId
WHERE r.Name LIKE 'PerfRecipe%'
  AND i.Name LIKE 'PerfIngredient%'
  AND (i.IngredientId % 10) = (r.RecipeId % 10)  -- Distribute evenly
ON CONFLICT (RecipeId, IngredientId) DO NOTHING;

-- Generate additional stores for testing
INSERT INTO Store (Name, Chain, Location)
SELECT 'PerfStore '||s,
       'Chain '||((s-1) % 5 + 1),
       'TestCity '||((s-1) % 10 + 1)
FROM generate_series(1, 50) s;

-- Generate barcodes (3-5 per ingredient)
INSERT INTO Barcode (Code, IngredientId)
SELECT CASE
         WHEN (b % 5) = 0 THEN '57' || lpad((i.IngredientId * 100 + b)::text, 12, '0')
         WHEN (b % 5) = 1 THEN '73' || lpad((i.IngredientId * 100 + b)::text, 12, '0')
         WHEN (b % 5) = 2 THEN '89' || lpad((i.IngredientId * 100 + b)::text, 12, '0')
         WHEN (b % 5) = 3 THEN '62' || lpad((i.IngredientId * 100 + b)::text, 12, '0')
         ELSE '84' || lpad((i.IngredientId * 100 + b)::text, 12, '0')
       END,
       i.IngredientId
FROM Ingredient i,
     generate_series(1, 3 + (i.IngredientId % 3)) b  -- 3-5 barcodes per ingredient
WHERE i.Name LIKE 'PerfIngredient%'
ON CONFLICT (Code) DO NOTHING;

-- Insert the specific barcode used in performance tests
INSERT INTO Barcode (Code, IngredientId)
SELECT '5710000012345', MIN(IngredientId)
FROM Ingredient
WHERE Name LIKE 'PerfIngredient%'
ON CONFLICT (Code) DO NOTHING;

-- Generate StoreBarcode entries
INSERT INTO StoreBarcode (StoreId, Code, Brand, NettoWeightGrams, Price, BoughtOn)
SELECT
    s.StoreId,
    b.Code,
    'Brand-' || ((random()*10)::int + 1),
    100 + (random()*1900)::int,
    (10 + random()*40)::int,
    date '2024-01-01' + ((random()*300)::int) * interval '1 day'
FROM Barcode b
CROSS JOIN Store s
WHERE b.Code LIKE '57%'
  AND s.Name LIKE 'PerfStore%'
  AND random() < 0.1  -- Only 10% get entries to keep it manageable
ON CONFLICT (StoreId, Code) DO NOTHING;

COMMIT;

-- Update statistics for query planner (must be outside transaction)
VACUUM ANALYZE;