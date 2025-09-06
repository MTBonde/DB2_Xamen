# Posgresql DDL

CREATE TABLE "User" (
UserId SERIAL PRIMARY KEY,
Email VARCHAR(255) NOT NULL UNIQUE,
PasswordHash TEXT NOT NULL,
CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE Unit (
UnitId SERIAL PRIMARY KEY,
Code VARCHAR(10) NOT NULL,
Kind VARCHAR(10) CHECK (Kind IN ('mass', 'volume', 'count')),
ToBaseFactor NUMERIC(10, 4) NOT NULL CHECK (ToBaseFactor > 0)
);

CREATE TABLE Ingredient (
IngredientId SERIAL PRIMARY KEY,
UserId INTEGER NOT NULL,
Name VARCHAR(100) NOT NULL,
EnergyKcalPer100 NUMERIC(5, 2) CHECK (EnergyKcalPer100 >= 0),
ProteinPer100 NUMERIC(5, 2) CHECK (ProteinPer100 >= 0),
CarbsPer100 NUMERIC(5, 2) CHECK (CarbsPer100 >= 0),
FatPer100 NUMERIC(5, 2) CHECK (FatPer100 >= 0),
UnitId INTEGER NOT NULL,
CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
FOREIGN KEY (UserId) REFERENCES "User"(UserId),
FOREIGN KEY (UnitId) REFERENCES Unit(UnitId),
UNIQUE (UserId, Name)
);

CREATE TABLE Recipe (
RecipeId SERIAL PRIMARY KEY,
UserId INTEGER NOT NULL,
Name VARCHAR(100) NOT NULL,
PortionCount INTEGER CHECK (PortionCount > 0),
CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
FOREIGN KEY (UserId) REFERENCES "User"(UserId),
UNIQUE (UserId, Name)
);

CREATE TABLE RecipeIngredient (
RecipeId INTEGER NOT NULL,
IngredientId INTEGER NOT NULL,
Amount NUMERIC(10, 2) CHECK (Amount >= 0),
UnitId INTEGER NOT NULL,
PRIMARY KEY (RecipeId, IngredientId),
FOREIGN KEY (RecipeId) REFERENCES Recipe(RecipeId),
FOREIGN KEY (IngredientId) REFERENCES Ingredient(IngredientId),
FOREIGN KEY (UnitId) REFERENCES Unit(UnitId)
);

CREATE TABLE Store (
StoreId SERIAL PRIMARY KEY,
Name VARCHAR(100) NOT NULL,
Chain VARCHAR(100),
Location TEXT
);

CREATE TABLE StoreIngredient (
StoreId INTEGER NOT NULL,
IngredientId INTEGER NOT NULL,
Brand VARCHAR(100),
Price INTEGER CHECK (Price >= 0), -- fx i øre
NetWeightGrams INTEGER CHECK (NetWeightGrams >= 0),
UnitPricePerKg NUMERIC GENERATED ALWAYS AS (Price / (NetWeightGrams / 1000.0)) STORED,
BoughtOn DATE,
PRIMARY KEY (StoreId, IngredientId),
FOREIGN KEY (StoreId) REFERENCES Store(StoreId),
FOREIGN KEY (IngredientId) REFERENCES Ingredient(IngredientId)
);

CREATE TABLE Barcode (
StoreId INTEGER NOT NULL,
IngredientId INTEGER NOT NULL,
Code VARCHAR(20),
PRIMARY KEY (StoreId, IngredientId),
FOREIGN KEY (StoreId, IngredientId) REFERENCES StoreIngredient(StoreId, IngredientId),
UNIQUE (Code)
);