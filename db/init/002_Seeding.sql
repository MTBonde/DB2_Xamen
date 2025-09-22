-- PostgreSQL Seeding

BEGIN;

-- Units 
INSERT INTO Unit (Code, Kind, ToBaseFactor)
SELECT 'g', 'mass', 1
WHERE NOT EXISTS (SELECT 1 FROM Unit WHERE Code='g' AND Kind='mass');

INSERT INTO Unit (Code, Kind, ToBaseFactor)
SELECT 'kg', 'mass', 1000
WHERE NOT EXISTS (SELECT 1 FROM Unit WHERE Code='kg' AND Kind='mass');

INSERT INTO Unit (Code, Kind, ToBaseFactor)
SELECT 'mg', 'mass', 0.001
WHERE NOT EXISTS (SELECT 1 FROM Unit WHERE Code='mg' AND Kind='mass');

INSERT INTO Unit (Code, Kind, ToBaseFactor)
SELECT 'ml', 'volume', 1
WHERE NOT EXISTS (SELECT 1 FROM Unit WHERE Code='ml' AND Kind='volume');

INSERT INTO Unit (Code, Kind, ToBaseFactor)
SELECT 'l', 'volume', 1000
WHERE NOT EXISTS (SELECT 1 FROM Unit WHERE Code='l' AND Kind='volume');

INSERT INTO Unit (Code, Kind, ToBaseFactor)
SELECT 'stk', 'count', 1
WHERE NOT EXISTS (SELECT 1 FROM Unit WHERE Code='stk' AND Kind='count');

-- Stores 
INSERT INTO Store (Name, Chain, Location)
SELECT 'Netto', 'Salling Group', 'København'
WHERE NOT EXISTS (
  SELECT 1 FROM Store WHERE Name='Netto' AND COALESCE(Chain,'')='Salling Group' AND COALESCE(Location,'')='København'
);

INSERT INTO Store (Name, Chain, Location)
SELECT 'Lidl', 'Lidl', 'Grenaa'
WHERE NOT EXISTS (
  SELECT 1 FROM Store WHERE Name='Lidl' AND COALESCE(Chain,'')='Lidl' AND COALESCE(Location,'')='Grenaa'
);

-- Users are created in 003_performance_seed.sql

COMMIT;