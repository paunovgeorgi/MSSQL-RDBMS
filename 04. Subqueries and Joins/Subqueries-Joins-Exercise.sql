USE SoftUni

-- 01. Employee Address 

SELECT TOP 5
e.EmployeeID, e.JobTitle, e.AddressID, a.AddressText
FROM
Employees AS e
JOIN Addresses AS a ON e.AddressID = a.AddressID
ORDER BY AddressID

-- 02. Addresses with Towns

SELECT TOP 50
e.FirstName, e.LastName, t.[Name] AS Town, a.AddressText
FROM
Employees AS e
JOIN Addresses AS a ON e.AddressID = a.AddressID
JOIN Towns AS t on a.TownID = t.TownID
ORDER BY e.FirstName, e.LastName

-- 03. Sales Employees

SELECT e.EmployeeID, e.FirstName, e.LastName, d.[Name] AS [DepartmentName] 
FROM Employees AS e
JOIN Departments AS d ON e.DepartmentID = d.DepartmentID AND d.[Name] = 'Sales'
ORDER BY EmployeeID

-- 04. Employee Departments 

SELECT TOP 5
e.EmployeeID, e.FirstName, e.Salary, d.[Name] AS [DepartmentName] 
FROM Employees AS e
JOIN Departments AS d ON e.DepartmentID = d.DepartmentID AND e.Salary > 15000
ORDER BY d.DepartmentID

-- 05. Employees Without Projects

SELECT TOP 3 e.EmployeeID, e.FirstName 
FROM Employees AS e
LEFT JOIN EmployeesProjects AS ep ON e.EmployeeID = ep.EmployeeID
WHERE ep.ProjectID IS NULL
ORDER BY EmployeeID

-- 06. Employees Hired After

SELECT e.FirstName, e.LastName, e.HireDate, d.[Name] AS [DeptName] 
FROM
Employees AS e
JOIN Departments AS d ON e.DepartmentID = d.DepartmentID 
WHERE e.HireDate > '01-01-1999' AND d.Name IN ('Sales', 'Finance')
ORDER BY e.HireDate

-- 07. Employees With Project

SELECT TOP 5
e.EmployeeID, e.FirstName, p.[Name] AS [ProjectName] 
FROM Employees AS e
JOIN EmployeesProjects AS ep ON e.EmployeeID = ep.EmployeeID
JOIN Projects AS p ON ep.ProjectID = p.ProjectID
WHERE p.StartDate > '08/13/2002'
ORDER BY e.EmployeeID

-- 08. Employee 24 

SELECT e.EmployeeID, e.FirstName,
  CASE
	  WHEN DATEPART(YEAR, p.StartDate) >= 2005 THEN NULL
	  ELSE p.[Name]
	  END AS [ProjectName] 
  FROM
Employees AS e
JOIN EmployeesProjects AS ep ON e.EmployeeID = ep.EmployeeID AND e.EmployeeID = 24
LEFT JOIN Projects AS p ON ep.ProjectID = p.ProjectID

-- 09. Employee Manager

SELECT e.EmployeeID, e.FirstName, m.EmployeeID, m.FirstName AS [ManagerName]
FROM 
Employees AS e
JOIN Employees AS m ON m.EmployeeID = e.ManagerID
WHERE e.ManagerID IN (3, 7)
ORDER BY e.EmployeeID

-- 10. Employees Summary

SELECT TOP 50
e.EmployeeID,
CONCAT_WS(' ', e.FirstName, e.LastName) AS [EmployeeName],
CONCAT_WS(' ', m.FirstName, m.LastName) AS [ManagerName],
d.[Name] AS [DepartmentName]
FROM Employees AS e
JOIN Employees AS m ON e.ManagerID = m.EmployeeID
JOIN Departments AS d ON e.DepartmentID = d.DepartmentID
ORDER BY e.EmployeeID

-- 11. Min Average Salary

SELECT TOP 1 AVG(e.Salary) AS AvgSalary
FROM Employees AS e
JOIN Departments AS d ON e.DepartmentID = d.DepartmentID
GROUP BY d.DepartmentID
ORDER BY AvgSalary

-- 12. Highest Peaks in Bulgaria

USE Geography

SELECT c.CountryCode, m.MountainRange, p.PeakName, p.Elevation 
FROM Countries AS c
JOIN MountainsCountries AS mc ON c.CountryCode = mc.CountryCode AND c.CountryCode = 'BG'
JOIN Mountains AS m ON mc.MountainId = m.Id
JOIN Peaks AS p ON m.id = p.MountainId AND p.Elevation > 2835
ORDER BY p.Elevation DESC

-- 13. Count Mountain Ranges

--SELECT CountryCode FROM Countries WHERE CountryCode = 'BG'

SELECT c.CountryCode,
COUNT(m.MountainRange) AS [MountainRanges]
FROM Countries AS c
JOIN MountainsCountries AS mc ON c.CountryCode = mc.CountryCode AND c.CountryCode IN ('US', 'BG', 'RU')
JOIN Mountains AS m ON mc.MountainId = m.Id
GROUP BY c.CountryCode

-- 14. Countries With or Without Rivers

SELECT TOP 5 c.CountryName, r.RiverName FROM
Countries AS c
LEFT JOIN CountriesRivers AS cr ON c.CountryCode = cr.CountryCode
LEFT JOIN RIVERS AS r ON cr.RiverId = r.Id 
WHERE c.ContinentCode = 'AF'
ORDER BY c.CountryName

-- 15. Continents and Currencies

SELECT ContinentCode, CurrencyCode, CurrencyUsage
FROM (
    SELECT *,
    DENSE_RANK() OVER(PARTITION BY [ContinentCode] ORDER BY CurrencyUsage DESC) AS CurrencyRank
    FROM(
        SELECT con.ContinentCode, c.CurrencyCode,
        COUNT(c.CurrencyCode) AS [CurrencyUsage]
        FROM
        Continents AS con
        LEFT JOIN Countries AS c ON con.ContinentCode = c.ContinentCode
        GROUP BY con.ContinentCode, c.CurrencyCode
        ) AS dt
    WHERE dt.CurrencyUsage > 1 
	) AS dt2
WHERE CurrencyRank = 1
ORDER BY ContinentCode

-- 16. Countries Without any Mountains

SELECT COUNT(c.CountryName) AS [Count]
FROM Countries AS c
LEFT JOIN MountainsCountries AS cm ON c.CountryCode = cm.CountryCode
WHERE MountainId IS NULL

-- 17. Highest Peak and Longest River by Country

SELECT TOP 5
c.CountryName,
MAX(p.Elevation) AS [HighestPeakElevation],
MAX(r.Length) AS [LongestRiverLength]
FROM Countries AS c
LEFT JOIN MountainsCountries AS cm ON c.CountryCode = cm.CountryCode
LEFT JOIN Mountains AS m ON cm.MountainId = m.Id
LEFT JOIN Peaks AS p On m.Id = p.MountainId
LEFT JOIN CountriesRivers AS cr ON c.CountryCode = cr.CountryCode
LEFT JOIN Rivers AS r ON cr.RiverId = r.Id
GROUP BY c.CountryName
ORDER BY HighestPeakElevation DESC, LongestRiverLength DESC, c.CountryName

-- 18. Highest Peak Name and Elevation by Country

SELECT TOP 5 Country,
      CASE	
	      WHEN PeakName IS NULL THEN '(no highest peak)'
	      ELSE PeakName
	END AS [Highest Peak Name],
      CASE	
	      WHEN Elevation IS NULL THEN 0
	      ELSE Elevation
	      END AS [Highest Peak Elevation],
      CASE	
	      WHEN MountainRange IS NULL THEN '(no mountain)'
	      ELSE MountainRange
	      END AS [Mountain]
  FROM(
SELECT
      c.CountryName AS [Country],
      m.MountainRange,
      p.PeakName,
      p.Elevation,
      DENSE_RANK() OVER(PARTITION BY c.CountryName ORDER BY p.Elevation) AS [PeakRank]
 FROM Countries AS c
     LEFT JOIN MountainsCountries AS cm ON c.CountryCode = cm.CountryCode
     LEFT JOIN Mountains AS m ON cm.MountainId = m.Id
     LEFT JOIN Peaks AS p On m.Id = p.MountainId
) AS [PeakRankingQuery]
WHERE PeakRank = 1
ORDER BY Country, [Highest Peak Name]

















