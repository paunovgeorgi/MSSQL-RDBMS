USE SoftUni

-- 01. Employees with Salary Above 35000

GO

CREATE PROC usp_GetEmployeesSalaryAbove35000
AS
BEGIN
	SELECT FirstName, LastName 
	  FROM Employees
	 WHERE Salary > 35000
END

GO

EXEC dbo.usp_GetEmployeesSalaryAbove35000

-- 02. Employees with Salary Above Number

GO

CREATE OR ALTER PROC usp_GetEmployeesSalaryAboveNumber @limit DECIMAL(18,4)
AS
BEGIN
	SELECT FirstName, LastName 
	FROM Employees
	WHERE Salary >= @Limit
END

GO

EXEC dbo.usp_GetEmployeesSalaryAboveNumber 40000

-- 03. Town Names Starting With

GO 

CREATE OR ALTER PROC usp_GetTownsStartingWith @firstLetter NVARCHAR(10)
AS
BEGIN
	SELECT [Name] 
	  FROM Towns
	 WHERE LEFT([Name], LEN(@firstLetter)) = @firstLetter
END

GO

EXEC usp_GetTownsStartingWith 'san'

-- 04. Employees from Town

GO

CREATE PROCEDURE usp_GetEmployeesFromTown @townName NVARCHAR(50)
AS
BEGIN

	SELECT e.FirstName, e.LastName 
	  FROM Employees AS e
	  JOIN Addresses AS a ON e.AddressID = a.AddressID
	  JOIN Towns AS t ON a.TownID = t.TownID
	  WHERE t.Name = @townName
END

GO

EXEC usp_GetEmployeesFromTown 'Sofia'

-- 05. Salary Level Function

GO

CREATE FUNCTION ufn_GetSalaryLevel(@salary DECIMAL(18,4))
RETURNS VARCHAR(8)
AS
BEGIN
	DECLARE @salaryLevel VARCHAR(8)
		 IF @salary < 30000 
		SET @salaryLevel = 'Low' 
    ELSE IF @salary <= 50000
	    SET @salaryLevel = 'Average'
    ELSE IF @salary > 50000
	    SET @salaryLevel = 'High'
	   RETURN @salaryLevel
END

GO

SELECT Salary,
	   dbo.ufn_GetSalaryLevel(Salary) AS [Salary Level]
  FROM Employees

-- 06. Employees by Salary Level

GO

CREATE PROC usp_EmployeesBySalaryLevel @salaryLevel VARCHAR(8)
AS
BEGIN
	SELECT FirstName, LastName
	  FROM Employees
	 WHERE dbo.ufn_GetSalaryLevel(Salary) = @salaryLevel
END

GO

EXEC usp_EmployeesBySalaryLevel 'High'

-- 07. Define Function

GO

CREATE OR ALTER FUNCTION ufn_IsWordComprised(@setOfLetters VARCHAR(MAX), @word VARCHAR(MAX))
RETURNS BIT
AS
BEGIN
	DECLARE @i INT = 1
	DECLARE @char VARCHAR(1)
	SET @i = 1
	WHILE (@i <= LEN(@word))
		BEGIN
			    SET @char = SUBSTRING(@word, @i, 1)
			     IF (CHARINDEX(@char, @setOfLetters) > 0)
			    SET @i = @i + 1
		       ELSE
			 RETURN 0
		 END	
	RETURN 1
END

Go

-- 08. *Delete Employees and Departments

GO

CREATE PROCEDURE usp_DeleteEmployeesFromDepartment (@departmentId INT)
AS
BEGIN
	 DELETE FROM EmployeesProjects
		   WHERE EmployeeID IN (SELECT EmployeeID
								  FROM Employees
							     WHERE DepartmentID = @departmentId
								)
	 UPDATE Employees
	 SET ManagerID = NULL
	 WHERE ManagerID IN (SELECT EmployeeID
						   FROM Employees
	                      WHERE DepartmentID = @departmentId
						)
	  ALTER TABLE Departments
	 ALTER COLUMN ManagerID INT

	 UPDATE Departments
	    SET ManagerID = NULL
	  WHERE ManagerID IN (SELECT EmployeeID
						    FROM Employees
						   WHERE DepartmentID = @departmentId
						  )
	 DELETE FROM Employees
	       WHERE DepartmentID = @departmentId

	 DELETE FROM Departments
	       WHERE DepartmentID = @departmentId

	 SELECT COUNT(EmployeeID) 
	   FROM Employees
      WHERE DepartmentID = @departmentId   
END

GO

EXEC dbo.usp_DeleteEmployeesFromDepartment 2

-- 09. Find Full Name

USE Bank

SELECT * FROM AccountHolders

GO

CREATE PROCEDURE usp_GetHoldersFullName 
AS
BEGIN
	SELECT FirstName + ' ' + LastName AS [Full Name] 
	  FROM AccountHolders
END

GO

-- 10. People with Balance Higher Than

GO

CREATE PROCEDURE usp_GetHoldersWithBalanceHigherThan @totalBalance DECIMAL(10,2)
AS
BEGIN

  SELECT FirstName, LastName
    FROM(
	  SELECT ah.FirstName, ah.LastName,
		     SUM(a.Balance) AS [TotalBalance]
	    FROM AccountHolders AS ah
	    JOIN Accounts AS a ON ah.Id = a.AccountHolderId
	GROUP BY ah.FirstName, LastName
		) AS TotalBalanceQuery
   WHERE TotalBalance > @totalBalance
ORDER BY FirstName, LastName

END

GO

-- 11. Future Value Function

GO

CREATE FUNCTION ufn_CalculateFutureValue(@sum DECIMAL(16,4), @yearlyInterest FLOAT, @numOfYears INT)
RETURNS DECIMAL(16,4)
BEGIN
	 RETURN @sum * (POWER((1 + @yearlyInterest), @numOfYears))	 
END

GO

SELECT dbo.ufn_CalculateFutureValue(1000, 0.10, 5)

-- 12. Calculating Interest

GO

CREATE PROCEDURE usp_CalculateFutureValueForAccount @id INT, @interestRate FLOAT
AS
BEGIN
      SELECT 
		    a.Id AS [Account Id],
		    ah.FirstName AS [First Name],
		    ah.LastName AS [LastName],
		    a.Balance AS [Current Balance],
		dbo.ufn_CalculateFutureValue(a.Balance, @interestRate, 5) AS [Balance in 5 years]
       FROM AccountHolders AS ah
       JOIN Accounts AS a ON ah.Id = a.AccountHolderId
      WHERE a.Id = @id
END

GO

USE Diablo

-- 13. *Cash in User Games Odd Rows 

GO

CREATE OR ALTER FUNCTION [ufn_CashInUsersGames](@gameName NVARCHAR(50))
RETURNS TABLE
AS RETURN (
			SELECT SUM([Cash]) AS [SumCash]
			FROM (
					SELECT Cash,
	  					   ROW_NUMBER() OVER (ORDER BY [Cash] DESC) AS [RowNumber]
					  FROM UsersGames 
						AS ug
					  JOIN Games
						AS g 
						ON ug.GameId = g.Id
					 WHERE g.Name = @gameName
				) 
			   AS CashSumQuery
			WHERE CashSumQuery.RowNumber % 2 <> 0
	      )	
 GO