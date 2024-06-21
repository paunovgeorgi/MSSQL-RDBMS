CREATE DATABASE RailwaysDb 

USE RailwaysDb

-- 01. DDL 

CREATE TABLE Passengers(
Id INT PRIMARY KEY IDENTITY,
[Name] NVARCHAR(80) NOT NULL
)

CREATE TABLE Towns(
Id INT PRIMARY KEY IDENTITY,
[Name] VARCHAR(30) NOT NULL
)

CREATE TABLE RailwayStations(
Id INT PRIMARY KEY IDENTITY,
[Name] VARCHAR(50) NOT NULL,
TownId INT FOREIGN KEY REFERENCES Towns(id) NOT NULL
)

CREATE TABLE Trains(
Id INT PRIMARY KEY IDENTITY,
HourOfDeparture VARCHAR(5) NOT NULL,
HourOfArrival VARCHAR(5) NOT NULL,
DepartureTownId INT FOREIGN KEY REFERENCES Towns(Id) NOT NULL,
ArrivalTownId INT FOREIGN KEY REFERENCES Towns(Id) NOT NULL
)


CREATE TABLE TrainsRailwayStations(
TrainId INT FOREIGN KEY REFERENCES Trains(id) NOT NULL,
RailwayStationId INT FOREIGN KEY REFERENCES RailwayStations(id) NOT NULL,
PRIMARY KEY (TrainId, RailwayStationId)
)

CREATE TABLE MaintenanceRecords(
Id INT PRIMARY KEY IDENTITY,
DateOfMaintenance DATE NOT NULL,
Details VARCHAR(2000) NOT NULL,
TrainId INT FOREIGN KEY REFERENCES Trains(id) NOT NULL
)

CREATE TABLE Tickets(
Id INT PRIMARY KEY IDENTITY,
Price DECIMAL(18,2) NOT NULL,
DateOfDeparture DATE NOT NULL,
DateOfArrival DATE NOT NULL,
TrainId INT FOREIGN KEY REFERENCES Trains(id) NOT NULL,
PassengerId INT FOREIGN KEY REFERENCES Passengers(Id)
)

-- 02. Insert

INSERT INTO Trains(HourOfDeparture, HourOfArrival, DepartureTownId, ArrivalTownId)
	VALUES
('07:00', '19:00', 1, 3),
('08:30', '20:30', 5, 6),
('09:00', '21:00', 4, 8),
('06:45', '03:55', 27, 7),
('10:15', '12:15', 15, 5)

INSERT INTO TrainsRailwayStations(TrainId, RailwayStationId)
	VALUES
(36, 1), 
(36, 4),
(36, 31),
(36, 57),
(36, 7),
(37, 13),
(37, 54),
(37, 60),
(37, 16),
(38, 10),
(38, 50),
(38, 52),
(38, 22),
(39, 68),
(39, 3),
(39, 31),
(39, 19),
(40, 41),
(40, 7),
(40, 52),
(40, 13)

INSERT INTO Tickets(Price, DateOfDeparture, DateOfArrival, TrainId, PassengerId)
	VALUES
(90.00,	'2023-12-01', '2023-12-01',	36,	1),
(115.00, '2023-08-02', '2023-08-02', 37, 2),
(160.00, '2023-08-03', '2023-08-03', 38, 3),
(255.00, '2023-09-01', '2023-09-02', 39, 21),
(95.00,	'2023-09-02', '2023-09-03',	40,	22)

--  03. Update 

UPDATE Tickets
SET DateOfDeparture = DATEADD(DAY, 7, DateOfDeparture),
    DateOfArrival = DATEADD(DAY, 7, DateOfArrival)
WHERE DATEPART(MONTH, DateOfDeparture) > 10

-- 04. Delete 

DELETE FROM TrainsRailwayStations
WHERE TrainId = 7

DELETE FROM Tickets
WHERE TrainId = 7

DELETE FROM MaintenanceRecords
WHERE TrainId = 7

DELETE FROM Trains
WHERE Id = 7

-- 05. Tickets by Price and Date Departure 

  SELECT DateOfDeparture,
	     Price
    FROM Tickets
ORDER BY Price, DateOfDeparture DESC

-- 06. Passengers with their Tickets

  SELECT p.[Name] AS PassengerName,
		 t.Price AS TicketPrice,
		 t.DateOfDeparture,
		 t.TrainId
    FROM Passengers AS p
	JOIN Tickets AS t ON p.Id = t.PassengerId
ORDER BY t.Price DESC, p.[Name]

-- 07. Railway Stations without Passing Trains

  SELECT tw.[Name] AS [Town],
		 rs.[Name] AS [RailwayStation]	
    FROM RailwayStations AS rs
	JOIN Towns AS tw ON rs.TownId = tw.Id
   WHERE rs.Id NOT IN (SELECT RailwayStationId FROM TrainsRailwayStations)
ORDER BY [Town], [RailwayStation]

-- 08. First 3 Trains Between 08:00 and 08:59 


  SELECT TOP 3
		 t.Id,
	     t.HourOfDeparture,
		 tc.Price AS TicketPrice,
		 tw.[Name] AS Destination
    FROM Trains AS t
	JOIN Tickets AS tc ON t.Id = tc.TrainId
	JOIN Towns AS tw ON t.ArrivalTownId = tw.Id
   WHERE (t.HourOfDeparture BETWEEN '08:00' AND '08:59') AND tc.Price > 50.00
ORDER BY TicketPrice

-- 09. Count of Passengers Paid More Than Average

  SELECT t.[Name] AS TownName,
		 COUNT(*) AS PassengersCount
    FROM Tickets AS ti 
	JOIN Trains AS tr ON ti.TrainId = tr.Id
	JOIN Towns AS t ON tr.ArrivalTownId = t.Id
    WHERE ti.Price > 76.99
GROUP BY t.[Name]
ORDER BY TownName


-- 10. Maintenance Inspection with Town and Station

  SELECT t.Id AS TrainId,
		 tw.[Name] AS DepartureTown,
		 mr.Details
    FROM MaintenanceRecords AS mr
	JOIN Trains AS t ON mr.TrainId = t.Id
	JOIN Towns AS tw ON t.DepartureTownId = tw.Id
   WHERE mr.Details LIKE '%inspection%'
ORDER BY t.Id

-- 11. Towns with Trains

GO

CREATE FUNCTION udf_TownsWithTrains(@name VARCHAR(30))
RETURNS INT
AS
BEGIN
	RETURN (SELECT COUNT(*)
  FROM Towns AS tw
  JOIN Trains AS tr ON tr.ArrivalTownId = tw.Id OR tr.DepartureTownId = tw.Id
 WHERE tw.[Name] = @name)
END

GO

-- 12. Search Passengers travelling to Specific Town

GO

CREATE PROCEDURE usp_SearchByTown(@townName VARCHAR(30))
AS
BEGIN

	SELECT p.[Name] AS PassengerName,
		   t.DateOfDeparture,
		   tr.HourOfDeparture
	  FROM Passengers AS p
	  JOIN Tickets AS t ON p.Id = t.PassengerId
	  JOIN Trains AS tr ON tr.Id = t.TrainId
	  JOIN Towns AS tw ON tr.ArrivalTownId = tw.Id
	 WHERE tw.Name = @townName
  ORDER BY t.DateOfDeparture DESC, p.[Name]

END

GO