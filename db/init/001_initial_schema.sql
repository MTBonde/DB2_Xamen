-- PostgreSQL DDL
-- Initial schema for the recipe and ingredient management application, placed in db/init/001_initial_schema.sql
-- Migration files should be placed in db/migrations/
-- Numbering scheme: 001, 002, ..., 010, 011, ..., 100, 101, ...for easy organization
-- next could be 002_add_users.sql


-- Enteties

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
EnergyKcalPer100 REAL CHECK (EnergyKcalPer100 >= 0),
ProteinPer100 REAL CHECK (ProteinPer100 >= 0),
CarbsPer100 REAL CHECK (CarbsPer100 >= 0),
FatPer100 REAL CHECK (FatPer100 >= 0),
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

CREATE TABLE Store (
StoreId SERIAL PRIMARY KEY,
Name VARCHAR(100) NOT NULL,
Chain VARCHAR(100),
Location TEXT
);

CREATE TABLE Barcode (
    Code VARCHAR(20) PRIMARY KEY,
    IngredientId INTEGER NOT NULL REFERENCES Ingredient(IngredientId)
);

-- relationel tables

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

CREATE TABLE StoreBarcode (
    StoreId INTEGER NOT NULL REFERENCES Store(StoreId),
    Code    VARCHAR(20) NOT NULL REFERENCES Barcode(Code),
    Brand   VARCHAR(100),
    NettoWeightGrams INTEGER CHECK (NettoWeightGrams > 0),
    Price   INTEGER CHECK (Price >= 0),
    BoughtOn DATE,
    UnitPricePerKg NUMERIC GENERATED ALWAYS AS (Price / (NettoWeightGrams / 1000.0)) STORED,
    PRIMARY KEY (StoreId, Code)
);

-- multi attribute tabel

CREATE TABLE UserPhone (
    UserId INTEGER  NOT NULL
        REFERENCES "User"(UserId)
        ON DELETE CASCADE,
    Phone  VARCHAR(20) NOT NULL,
    PRIMARY KEY (UserId, Phone)
);