CREATE DATABASE Zoo

USE Zoo

-- 01. DDL 

CREATE TABLE Owners(
Id INT PRIMARY KEY IDENTITY,
[Name] VARCHAR(50) NOT NULL, 
PhoneNumber VARCHAR(15) NOT NULL,
Address VARCHAR(50)
)

CREATE TABLE AnimalTypes(
Id INT PRIMARY KEY IDENTITY,
AnimalType VARCHAR(30) NOT NULL
)

CREATE TABLE Cages(
Id INT PRIMARY KEY IDENTITY,
AnimalTypeId INT FOREIGN KEY REFERENCES AnimalTypes(Id) NOT NULL
)

CREATE TABLE Animals(
Id INT PRIMARY KEY IDENTITY,
[Name] VARCHAR(30) NOT NULL, 
BirthDate DATE NOT NULL,
OwnerId INT FOREIGN KEY REFERENCES Owners(Id),
AnimalTypeId INT FOREIGN KEY REFERENCES AnimalTypes(Id) NOT NULL
)

CREATE TABLE AnimalsCages(
CageId INT FOREIGN KEY REFERENCES Cages(Id) NOT NULL,
AnimalId INT FOREIGN KEY REFERENCES Animals(Id) NOT NULL,
PRIMARY KEY (CageId, AnimalId)
)

CREATE TABLE VolunteersDepartments(
Id INT PRIMARY KEY IDENTITY,
DepartmentName VARCHAR(30) NOT NULL
)

CREATE TABLE Volunteers(
Id INT PRIMARY KEY IDENTITY,
[Name] VARCHAR(50) NOT NULL, 
PhoneNumber VARCHAR(15) NOT NULL,
Address VARCHAR(50),
AnimalId INT FOREIGN KEY REFERENCES Animals(Id),
DepartmentId INT FOREIGN KEY REFERENCES VolunteersDepartments(Id) NOT NULL
)

-- 02. Insert 

INSERT INTO Volunteers([Name], PhoneNumber, Address, AnimalId, DepartmentId)
	VALUES
('Anita Kostova', '0896365412', 'Sofia, 5 Rosa str.', 15, 1),
('Dimitur Stoev', '0877564223',NULL, 42, 4),
('Kalina Evtimova', '0896321112', 'Silistra, 21 Breza str.', 9, 7),
('Stoyan Tomov', '0898564100', 'Montana, 1 Bor str.', 18, 8),
('Boryana Mileva', '0888112233', NULL, 31, 5)

INSERT INTO Animals([Name], BirthDate, OwnerId, AnimalTypeId)
	VALUES
('Giraffe', '2018-09-21', 21, 1),
('Harpy Eagle', '2015-04-17', 15, 3),
('Hamadryas Baboon', '2017-11-02', NULL, 1),
('Tuatara', '2021-06-30', 2, 4)

SELECT Id 
  FROM Owners
 WHERE [Name] = 'Kaloqn Stoqnov'

 UPDATE Animals
 SET OwnerId = (SELECT Id 
				  FROM Owners
				 WHERE [Name] = 'Kaloqn Stoqnov'
				)
WHERE OwnerId IS NULL

-- 04. Delete 

DELETE FROM Volunteers
WHERE DepartmentId = (SELECT Id 
						FROM VolunteersDepartments
					   WHERE DepartmentName = 'Education program assistant'
					   )

DELETE FROM VolunteersDepartments
WHERE Id = (SELECT Id 
			  FROM VolunteersDepartments
		     WHERE DepartmentName = 'Education program assistant'
		    )

-- 05. Volunteers

  SELECT [Name], PhoneNumber, [Address], AnimalId, DepartmentId   
    FROM Volunteers 
ORDER BY [Name], AnimalId, DepartmentId

-- 06. Animals data

  SELECT a.[Name], at.AnimalType, FORMAT (a.BirthDate,'dd.MM.yyyy') AS [Birthdate]
    FROM Animals AS a
    LEFT JOIN AnimalTypes AS [at]
      ON a.AnimalTypeId = at.Id
ORDER BY a.[Name]

-- 07. Owners and Their Animals

  SELECT TOP 5 o.[Name] AS [Owner], COUNT(a.Id) AS [CountOfAnimals]
    FROM Owners AS o
    JOIN Animals AS a
      ON a.OwnerId = o.Id
GROUP BY o.[Name]
ORDER BY [CountOfAnimals] DESC

-- 08. Owners, Animals and Cages

SELECT CONCAT(o.[Name], '-', a.[Name]) AS OwnersAnimals,
       o.PhoneNumber,
	   ac.CageId
  FROM Animals AS a
  JOIN AnimalsCages AS ac
    ON a.Id = ac.AnimalId
  JOIN Owners AS o
    ON a.OwnerId = o.Id
 WHERE a.AnimalTypeId = 1
ORDER BY o.[Name], a.[Name] DESC

-- 09. Volunteers in Sofia

  SELECT v.[Name], v.PhoneNumber, REPLACE(REPLACE(v.[Address], 'Sofia,', ''), ' Sofia ,', '') AS [Address]
    FROM Volunteers AS v
    JOIN VolunteersDepartments AS vp
      ON v.DepartmentId = vp.Id
   WHERE vp.DepartmentName = 'Education program assistant' AND v.Address LIKE '%Sofia%'
ORDER BY v.[Name]
SELECT * FROM VolunteersDepartments

-- 10. Animals for Adoption

   SELECT a.[Name], DATEPART (YEAR, a.BirthDate) AS [BirthYear], [at].AnimalType 
     FROM Animals AS a
     JOIN AnimalTypes AS [at]
       ON a.AnimalTypeId = [at].Id
    WHERE OwnerId IS NULL 
	  AND DATEDIFF(YEAR, a.BirthDate, '01/01/2022') < 5 
	  AND a.AnimalTypeId <> 3
 ORDER BY a.[Name]

-- 11. All Volunteers in a Department












