CREATE DATABASE NationalTouristSitesOfBulgaria

USE NationalTouristSitesOfBulgaria

-- 01. DDL 

CREATE TABLE Categories(
Id INT PRIMARY KEY IDENTITY,
[Name] VARCHAR(50) NOT NULL
)

CREATE TABLE Locations(
Id INT PRIMARY KEY IDENTITY,
[Name] VARCHAR(50) NOT NULL,
Municipality VARCHAR(50),
Province VARCHAR(50)
)

CREATE TABLE Sites(
Id INT PRIMARY KEY IDENTITY,
[Name] VARCHAR(100) NOT NULL,
LocationId INT FOREIGN KEY REFERENCES Locations(Id) NOT NULL,
CategoryId INT FOREIGN KEY REFERENCES Categories(Id) NOT NULL,
Establishment VARCHAR(15)
)

CREATE TABLE Tourists(
Id INT PRIMARY KEY IDENTITY,
[Name] VARCHAR(50) NOT NULL,
Age INT NOT NULL CHECK(Age BETWEEN 0 AND 120),
PhoneNumber VARCHAR(20) NOT NULL,
Nationality VARCHAR(30) NOT NULL,
Reward VARCHAR(20) 
)

CREATE TABLE SitesTourists(
TouristId INT FOREIGN KEY REFERENCES Tourists(Id) NOT NULL,
SiteId INT FOREIGN KEY REFERENCES Sites(Id) NOT NULL,
PRIMARY KEY (TouristId, SiteId)
)

CREATE TABLE BonusPrizes(
Id INT PRIMARY KEY IDENTITY,
[Name] VARCHAR(50) NOT NULL
)

CREATE TABLE TouristsBonusPrizes(
TouristId INT FOREIGN KEY REFERENCES Tourists(Id) NOT NULL,
BonusPrizeId INT FOREIGN KEY REFERENCES BonusPrizes(Id) NOT NULL,
PRIMARY KEY (TouristId, BonusPrizeId)
)

-- 02. Insert 

INSERT INTO Tourists([Name], Age, PhoneNumber, Nationality, Reward)
	VALUES
('Borislava Kazakova', 52, '+359896354244', 'Bulgaria', NULL),
('Peter Bosh', 48, '+447911844141', 'UK', NULL),
('Martin Smith', 29, '+353863818592', 'Ireland', 'Bronze badge'),
('Svilen Dobrev', 49, '+359986584786', 'Bulgaria', 'Silver badge'),
('Kremena Popova', 38, '+359893298604', 'Bulgaria', NULL)

INSERT INTO Sites([Name], LocationId, CategoryId, Establishment)
	VALUES
('Ustra fortress', 90, 7, 'X'),
('Karlanovo Pyramids', 65, 7, NULL),
('The Tomb of Tsar Sevt', 63, 8, 'V BC'),
('Sinite Kamani Natural Park', 17, 1, NULL),
('St. Petka of Bulgaria – Rupite', 92, 6, '1994')

-- 03. Update 

UPDATE Sites
SET Establishment = '(not defined)'
WHERE Establishment IS NULL


-- 04. Delete 

SELECT Id 
  FROM BonusPrizes
 WHERE [Name] = 'Sleeping bag' 

DELETE FROM TouristsBonusPrizes
WHERE BonusPrizeId = 5

DELETE FROM BonusPrizes
WHERE Id = 5

--  05. Tourists 

  SELECT [Name], Age, PhoneNumber, Nationality 
    FROM Tourists
ORDER BY Nationality, Age DESC, [Name]

-- 06. Sites with Their Location and Category

  SELECT s.[Name] AS [Site],
		 l.[Name] AS [Location],
		 s.Establishment,
		 c.[Name] AS [Category]
    FROM Sites AS s
	JOIN Locations AS l ON s.LocationId = l.Id
	JOIN Categories AS c ON s.CategoryId = c.Id
ORDER BY [Category] DESC, [Location], [Site] 

-- 07. Count of Sites in Sofia Province


  SELECT l.Province,
		 l.Municipality,
		 l.[Name] AS [Location],
		 COUNT(*) AS CountOfSites 
    FROM Locations AS l
	JOIN Sites AS s ON s.LocationId = l.Id
   WHERE Province = 'Sofia'
GROUP BY l.[Name], l.Province, l.Municipality
ORDER BY CountOfSites DESC, l.[Name]

-- 08. Tourist Sites established BC

  SELECT s.[Name] AS [Site],
	     l.[Name] AS [Location],
		 l.Municipality,
		 l.Province,
		 s.Establishment
    FROM Locations AS l
	JOIN Sites AS s ON s.LocationId = l.Id
   WHERE LEFT(l.[Name], 1) NOT IN ('B', 'M', 'D')
     AND RIGHT(s.Establishment, 2) = 'BC'
ORDER BY [Site]

-- 09. Tourists with their Bonus Prizes 

   SELECT t.[Name],
 	      t.Age,
 		  t.PhoneNumber,
 		  t.Nationality,
		  CASE
			  WHEN tb.TouristId IS NULL THEN '(no bonus prize)'
			  ELSE b.[Name]
 		  END AS [Reward]
     FROM Tourists AS t
LEFT JOIN TouristsBonusPrizes AS tb ON tb.TouristId = t.Id
LEFT JOIN BonusPrizes AS b ON tb.BonusPrizeId = b.Id
 ORDER BY t.[Name]

-- 10. Tourists visiting History & Archaeology sites

  SELECT SUBSTRING(t.[Name], CHARINDEX(' ', t.[Name]) + 1, LEN(t.[Name]) - CHARINDEX(' ', t.[Name])) AS LastName,
		 t.Nationality,
		 t.Age,
		 t.PhoneNumber
    FROM Tourists AS t
	JOIN SitesTourists AS st ON st.TouristId = t.Id
	JOIN Sites AS s ON st.SiteId = s.Id
	JOIN Categories AS c ON s.CategoryId = c.Id
   WHERE c.[Name] = 'History and archaeology'
GROUP BY t.[Name], t.Nationality, t.Age, t.PhoneNumber
ORDER BY [LastName]	  


-- 11. Tourists Count on a Tourist Site

GO

CREATE FUNCTION udf_GetTouristsCountOnATouristSite (@Site VARCHAR(100))
RETURNS INT
AS
BEGIN

RETURN (  SELECT COUNT(*)
    FROM Tourists AS t
	JOIN SitesTourists AS st ON t.Id = st.TouristId
	JOIN Sites AS s ON s.Id = st.SiteId
   WHERE s.[Name] = @Site)

END

GO

-- 12. Annual Reward Lottery

GO

CREATE PROCEDURE usp_AnnualRewardLottery(@TouristName VARCHAR(50))
AS
BEGIN

	SELECT [Name],
		   CASE
       WHEN (SELECT 
         COUNT(*) 
    FROM Tourists AS t
	JOIN SitesTourists AS st ON t.Id = st.TouristId
	JOIN Sites AS s ON s.Id = st.SiteId
	WHERE t.[Name] = @TouristName) >= 100 THEN 'Gold badge'
      
	   WHEN (SELECT 
         COUNT(*) 
    FROM Tourists AS t
	JOIN SitesTourists AS st ON t.Id = st.TouristId
	JOIN Sites AS s ON s.Id = st.SiteId
	WHERE t.[Name] = @TouristName) >= 50 THEN 'Silver badge'

	   WHEN (SELECT 
         COUNT(*) 
    FROM Tourists AS t
	JOIN SitesTourists AS st ON t.Id = st.TouristId
	JOIN Sites AS s ON s.Id = st.SiteId
	WHERE t.[Name] = @TouristName) >= 20 THEN 'Bronze badge'
END AS [Reward]
	  FROM Tourists
	  WHERE [Name] = @TouristName

END

GO

