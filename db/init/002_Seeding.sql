-- PostgreSQL Seeding
-- Pre-populating basic data for the application

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

-- Test users with simple hash for testing

INSERT INTO "User" (Email, PasswordHash)
SELECT 'user1@example.com', 'secrethash'
WHERE NOT EXISTS (SELECT 1 FROM "User" WHERE Email='user1@example.com');

INSERT INTO "User" (Email, PasswordHash)
SELECT 'user2@example.com', 'secrethash'
WHERE NOT EXISTS (SELECT 1 FROM "User" WHERE Email='user2@example.com');

INSERT INTO "User" (Email, PasswordHash)
SELECT 'user3@example.com', 'secrethash'
WHERE NOT EXISTS (SELECT 1 FROM "User" WHERE Email='user3@example.com');

INSERT INTO "User" (Email, PasswordHash)
SELECT 'user4@example.com', 'secrethash'
WHERE NOT EXISTS (SELECT 1 FROM "User" WHERE Email='user4@example.com');

INSERT INTO "User" (Email, PasswordHash)
SELECT 'user5@example.com', 'secrethash'
WHERE NOT EXISTS (SELECT 1 FROM "User" WHERE Email='user5@example.com');

INSERT INTO "User" (Email, PasswordHash)
SELECT 'user6@example.com', 'secrethash'
WHERE NOT EXISTS (SELECT 1 FROM "User" WHERE Email='user6@example.com');

INSERT INTO "User" (Email, PasswordHash)
SELECT 'user7@example.com', 'secrethash'
WHERE NOT EXISTS (SELECT 1 FROM "User" WHERE Email='user7@example.com');

INSERT INTO "User" (Email, PasswordHash)
SELECT 'user8@example.com', 'secrethash'
WHERE NOT EXISTS (SELECT 1 FROM "User" WHERE Email='user8@example.com');

INSERT INTO "User" (Email, PasswordHash)
SELECT 'user9@example.com', 'secrethash'
WHERE NOT EXISTS (SELECT 1 FROM "User" WHERE Email='user9@example.com');

COMMIT;