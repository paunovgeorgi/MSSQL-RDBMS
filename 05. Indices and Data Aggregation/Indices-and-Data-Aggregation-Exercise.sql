
-- 01. Records’ Count

SELECT COUNT(*) AS [Count] FROM WizzardDeposits

-- 02. Longest Magic Wand

SELECT MAX(MagicWandSize) AS LongestMagicWand
FROM WizzardDeposits

-- 03. Longest Magic Wand per Deposit Groups

SELECT DepositGroup,
MAX(MagicWandSize) AS LongestMagicWand
FROM WizzardDeposits
GROUP BY DepositGroup

-- 4. Smallest Deposit Group Per Magic Wand Size

SELECT TOP 2 DepositGroup
FROM WizzardDeposits
GROUP BY DepositGroup
ORDER BY AVG(MagicWandSize) 

-- 5. Deposits Sum

SELECT DepositGroup,
SUM(DepositAmount) AS [TotalSum]
FROM WizzardDeposits
GROUP BY DepositGroup

-- 6. Deposits Sum for Ollivander Family

  SELECT DepositGroup,
         SUM(DepositAmount) 
	  AS [TotalSum]
    FROM WizzardDeposits
GROUP BY DepositGroup, MagicWandCreator
  HAVING MagicWandCreator = 'Ollivander family'

-- 7. Deposits Filter

  SELECT DepositGroup,
         SUM(DepositAmount) AS [TotalSum]
    FROM WizzardDeposits
GROUP BY DepositGroup, MagicWandCreator
  HAVING MagicWandCreator = 'Ollivander family' AND SUM(DepositAmount) < 150000
ORDER BY [TotalSum] DESC

-- 8. Deposit Charge

  SELECT DepositGroup, MagicWandCreator,
     MIN(DepositCharge) AS [MinDepositCharge]
    FROM WizzardDeposits
GROUP BY DepositGroup, MagicWandCreator
ORDER BY MagicWandCreator, DepositGroup

-- 9. Age Groups

SELECT AgeGroup, COUNT(Age) AS [WizardCount] FROM(
      SELECT Age,
        CASE
	          WHEN Age Between 0 AND 10 THEN '[0-10]'
		      WHEN Age Between 11 AND 20 THEN '[11-20]'
		      WHEN Age Between 21 AND 30 THEN '[21-30]'
		      WHEN Age Between 31 AND 40 THEN '[31-40]'
		      WHEN Age Between 41 AND 50 THEN '[41-50]'
		      WHEN Age Between 51 AND 60 THEN '[51-60]'
		      ELSE '[61+]'
		    END AS [AgeGroup]
       FROM WizzardDeposits) AS AgeGroupQuery
	GROUP BY AgeGroup

-- 10. First Letter

  SELECT LEFT(FirstName, 1) AS [FirstLetter]
    FROM WizzardDeposits
   WHERE DepositGroup = 'Troll Chest'
GROUP BY LEFT(FirstName, 1)

-- 11. Average Interest

  SELECT DepositGroup,
         IsDepositExpired,
         AVG(DepositInterest) AS [AverageInterest]
    FROM WizzardDeposits
   WHERE DepositStartDate > '01/01/1985'
GROUP BY DepositGroup, IsDepositExpired
ORDER BY DepositGroup DESC, IsDepositExpired ASC

-- 12. *Rich Wizard, Poor Wizard

SELECT
	SUM([Host Wizard Deposit] - [Guest Wizard Deposit])
	 AS [SumDifference]
   FROM(
		 SELECT FirstName
			 AS [Host Wizard],
				DepositAmount
			 AS [Host Wizard Deposit],
				LEAD(FirstName) OVER(ORDER BY Id)
			 AS [Guest Wizard],
				LEAD(DepositAmount) OVER(ORDER BY Id)
			 AS [Guest Wizard Deposit]
		   FROM WizzardDeposits ) AS HostGuestQuery
   WHERE [Guest Wizard] IS NOT NULL

GO

USE SoftUni

GO

-- 13. Departments Total Salaries

  SELECT DepartmentID,
	     SUM(Salary) AS [TotalSalary]
    FROM Employees
GROUP BY DepartmentID
ORDER BY DepartmentID

-- 14. Employees Minimum Salaries

  SELECT DepartmentID,
	     MIN(Salary) AS [MinimumSalary]
    FROM Employees
   WHERE DepartmentID IN (2, 5, 7) AND HireDate > '01/01/2000'
GROUP BY DepartmentID

-- 15. Employees Average Salaries

SELECT * INTO [NewTable] 
FROM Employees
WHERE Salary > 30000

DELETE FROM NewTable
WHERE ManagerID = 42

UPDATE NewTable
SET Salary += 5000
WHERE DepartmentID = 1

  SELECT DepartmentID,
         AVG(Salary) AS [AverageSalary]
    FROM NewTable
GROUP BY DepartmentID

-- 16. Employees Maximum Salaries

  SELECT DepartmentID,
		 MAX(Salary) AS [MaxSalary]
    FROM Employees
GROUP BY DepartmentID
  HAVING MAX(Salary) < 30000 OR MAX(Salary) > 70000

-- 17. Employees Count Salaries

SELECT COUNT(*) AS [Count]
  FROM Employees
 WHERE ManagerID IS NULL 


-- 18. *3rd Highest Salary

  SELECT 
DISTINCT DepartmentID, Salary 
    FROM(
		 SELECT DepartmentId, Salary,
			    DENSE_RANK() OVER(PARTITION BY DepartmentId ORDER BY Salary DESC) AS [Rank]
		   FROM Employees
		 )   AS RankedDepartmentSalary
 WHERE RankedDepartmentSalary.[Rank] = 3

-- 19. **Salary Challenge

SELECT TOP 10 FirstName, LastName, DepartmentID
  FROM Employees AS e
 WHERE e.Salary > (
		SELECT AVG(Salary) AS [AverageSalary]
		  FROM Employees AS [esub]
	     WHERE esub.DepartmentID = e.DepartmentID
      GROUP BY DepartmentID
		)
ORDER BY e.DepartmentID
















