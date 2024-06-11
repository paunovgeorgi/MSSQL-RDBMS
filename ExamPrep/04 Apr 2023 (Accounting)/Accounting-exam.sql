CREATE DATABASE Accounting

USE Accounting

-- 01. DDL

CREATE TABLE Countries(
Id INT PRIMARY KEY IDENTITY,
[Name] VARCHAR(30) NOT NULL
)

CREATE TABLE Addresses(
Id INT PRIMARY KEY IDENTITY,
StreetName NVARCHAR(20) NOT NULL,
StreetNumber INT, 
PostCode INT NOT NULL,
City VARCHAR(25) NOT NULL,
CountryId INT FOREIGN KEY REFERENCES Countries(Id) NOT NULL
)

CREATE TABLE Vendors(
Id INT PRIMARY KEY IDENTITY,
[Name] NVARCHAR(25) NOT NULL,
NumberVAT NVARCHAR(15) NOT NULL,
AddressId INT FOREIGN KEY REFERENCES Addresses(Id) NOT NULL
)

CREATE TABLE Clients(
Id INT PRIMARY KEY IDENTITY,
[Name] NVARCHAR(25) NOT NULL,
NumberVAT NVARCHAR(15) NOT NULL,
AddressId INT FOREIGN KEY REFERENCES Addresses(Id) NOT NULL
)

CREATE TABLE Categories(
Id INT PRIMARY KEY IDENTITY,
[Name] VARCHAR(10) NOT NULL
)

CREATE TABLE Products(
Id INT PRIMARY KEY IDENTITY,
[Name] NVARCHAR(35) NOT NULL,
PRICE DECIMAL(18,2) NOT NULL,
CategoryId INT FOREIGN KEY REFERENCES Categories(Id) NOT NULL,
VendorId INT FOREIGN KEY REFERENCES Vendors(Id) NOT NULL
)

CREATE TABLE Invoices(
Id INT PRIMARY KEY IDENTITY,
Number INT UNIQUE NOT NULL,
IssueDate DATETIME2 NOT NULL,
DueDate DATETIME2 NOT NULL,
Amount DECIMAL(18,2) NOT NULL,
Currency VARCHAR(5) NOT NULL,
ClientId INT FOREIGN KEY REFERENCES Clients(Id) NOT NULL
)

CREATE TABLE ProductsClients(
ProductId INT FOREIGN KEY REFERENCES Products(Id),
ClientId INT FOREIGN KEY REFERENCES Clients(Id),
PRIMARY KEY (ProductId, ClientId)
)

-- 02. Insert

INSERT INTO Products([Name], Price, CategoryId, VendorId)
	 VALUES
('SCANIA Oil Filter XD01', 78.69, 1, 1),
('MAN Air Filter XD01', 97.38, 1, 5),
('DAF Light Bulb 05FG87', 55.00, 2, 13),
('ADR Shoes 47-47.5', 49.85, 3, 5),
('Anti-slip pads S', 5.87, 5, 7)

INSERT INTO Invoices(Number, IssueDate, DueDate, Amount, Currency, ClientId)
	 VALUES
(1219992181, '2023-03-01', '2023-04-30', 180.96, 'BGN', 3),
(1729252340, '2022-11-06', '2023-01-04', 158.18, 'EUR', 13),
(1950101013, '2023-02-17', '2023-04-18', 615.15, 'USD', 19)

-- 03. Update

UPDATE Invoices
   SET DueDate = '2023-04-01'
WHERE DATEPART(YEAR, IssueDate) = 2022 AND DATEPART(MONTH, IssueDate) = 11

UPDATE Clients
   SET AddressId = 3
 WHERE [Name] LIKE '%CO%'

 -- 04. Delete

DELETE FROM Invoices
WHERE ClientId IN (SELECT Id FROM Clients WHERE LEFT(NumberVAT, 2) = 'IT')

DELETE FROM ProductsClients
WHERE ClientId IN (SELECT Id FROM Clients WHERE LEFT(NumberVAT, 2) = 'IT')

DELETE 
  FROM Clients
 WHERE LEFT(NumberVAT, 2) = 'IT'
 
 -- 05. Invoices by Amount and Date

  SELECT Number, Currency
    FROM Invoices
ORDER BY Amount DESC, DueDate

-- 06. Products by Category

  SELECT p.Id, p.[Name], p.Price, c.[Name] 
    FROM Products AS p
	JOIN Categories AS c
	  ON p.CategoryId = c.Id
   WHERE CategoryId IN (3, 5)
ORDER BY PRICE DESC

-- 07. Clients without Products

   SELECT c.Id, c.[Name],
          CONCAT(a.StreetName, ' ', a.StreetNumber, ', ', a.City, ', ', a.PostCode, ', ', ct.[Name]) AS [Address]
     FROM Clients AS c
LEFT JOIN ProductsClients AS pc
       ON pc.ClientId = c.Id
	 JOIN Addresses AS a
	   ON c.AddressId = a.Id
	 JOIN Countries AS ct
	   ON a.CountryId = ct.Id
    WHERE pc.ProductId IS NULL
 ORDER BY c.[Name]

 -- 08. First 7 Invoices

SELECT TOP 7
           i.Number, i.Amount, c.[Name] AS Client 
      FROM Invoices AS i
      JOIN Clients AS c
        ON i.ClientId = c.Id
     WHERE i.IssueDate < '2023-01-01 ' AND i.Currency = 'EUR' OR i.Amount > 500.00 AND LEFT(c.NumberVAT, 2) = 'DE'
  ORDER BY i.Number, i.Amount DESC
   
-- 09. Clients with VAT

   SELECT c.[Name] AS [Client],
	      MAX(p.Price) AS [Price],
	  	  c.NumberVAT AS [VAT Number]
     FROM Clients AS c
     JOIN ProductsClients AS pc
       ON pc.ClientId = c.Id
     JOIN Products AS p
       ON pc.ProductId = p.Id
    WHERE RIGHT(c.[Name], 2) <> 'KG'
 GROUP BY c.[Name], c.NumberVAT
 ORDER BY [Price] DESC

 -- 10. Clients by Price

 SELECT c.[Name] AS [Client], 
        FLOOR(AVG(p.Price)) AS [Average Price]
   FROM Clients AS c
   JOIN ProductsClients AS pc
     ON pc.ClientId = c.Id
   JOIN Products AS p
     ON pc.ProductId = p.Id
   JOIN Vendors AS v
     ON p.VendorId = v.Id
  WHERE v.NumberVAT LIKE '%FR%'
  GROUP BY c.[Name]
  ORDER BY [Average Price], c.[Name] DESC

  -- 11. Product with Clients

GO

CREATE FUNCTION udf_ProductWithClients(@name NVARCHAR(35))
RETURNS INT
AS
BEGIN

RETURN (SELECT COUNT(*)
          FROM Clients AS c
          JOIN ProductsClients AS pc
            ON pc.ClientId = c.Id
          JOIN Products AS p
            ON pc.ProductId = p.Id
         WHERE p.[Name] = @name)

END

GO

-- 12. Search for Vendors from a Specific Country

GO

CREATE PROCEDURE usp_SearchByCountry @country VARCHAR(10) 
AS
BEGIN

  SELECT v.[Name] AS [Vendor],
         v.[NumberVAT] AS [VAT],
   	     CONCAT(a.StreetName, ' ', a.StreetNumber) AS [Street Info],
   	     CONCAT(a.City, ' ', a.PostCode) AS [City Info]
    FROM Countries AS c
    JOIN Addresses AS a
      ON a.CountryId = c.Id
    JOIN Vendors AS v
      ON v.AddressId = a.Id
   WHERE c.[Name] = @country
ORDER BY [Vendor], a.City

END

GO


