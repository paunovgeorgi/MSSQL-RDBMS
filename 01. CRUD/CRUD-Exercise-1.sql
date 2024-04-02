SELECT * FROM Departments

SELECT [Name] 
FROM [Departments]

SELECT FirstName, LastName, Salary
FROM Employees

SELECT FirstName, MiddleName, LastName
FROM Employees

SELECT [FirstName] + '.' + [LastName] + '@softuni.bg' AS [Full Email Address]
FROM Employees;

SELECT DISTINCT Salary
FROM Employees

SELECT * FROM Employees
Where JobTitle = 'Sales Representative';

SELECT FirstName, LastName, JobTitle
FROM Employees
Where Salary BETWEEN 20000 AND 30000

SELECT FirstName + ' ' + MiddleName + ' ' + LastName AS [Full Name]
FROM Employees
--WHERE Salary = 25000 OR Salary = 14000 OR Salary = 12500 OR Salary = 23600;
WHERE Salary IN (25000, 14000, 125000, 23600);

SELECT FirstName, LastName
FROM Employees
WHERE ManagerID IS NULL

SELECT FirstName, LastName, Salary
FROM Employees
WHERE Salary > 50000
ORDER BY Salary DESC

SELECT TOP 5 FirstName, LastName
FROM Employees
ORDER BY Salary DESC

SELECT FirstName, LastName
FROM Employees
WHERE DepartmentID != 4

SELECT * FROM Employees
ORDER BY Salary DESC, FirstName, LastName DESC, MiddleName

GO
CREATE VIEW V_EmployeesSalaries AS
	 SELECT FirstName, LastName, Salary
	   FROM Employees;
GO

CREATE VIEW V_EmployeeNameJobTitle
	     AS
	 SELECT CONCAT(FirstName, ' ', MiddleName, ' ', LastName)
	     AS [Full Name], JobTitle
	   FROM Employees; 

GO

SELECT DISTINCT JobTitle
		   FROM Employees;

SELECT TOP 10 * FROM Projects
WHERE StartDate <= GetDate()
ORDER BY StartDate, [Name]

SELECT TOP 7 FirstName, LastName, HireDate
FROM Employees
ORDER BY HireDate DESC

--UPDATE Employees
--SET Salary = Salary * 1.12
--WHERE DepartmentID IN (1, 2, 4, 11)












