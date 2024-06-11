CREATE DATABASE Bitbucket

GO

USE Bitbucket

GO

-- 01. DDL

CREATE TABLE Users(
[Id] INT PRIMARY KEY IDENTITY,
[Username] VARCHAR(30) NOT NULL,
[Password] VARCHAR(30) NOT NULL,
[Email] VARCHAR(50) NOT NULL
)

CREATE TABLE Repositories(
[Id] INT PRIMARY KEY IDENTITY,
[Name] VARCHAR(50) NOT NULL
)

CREATE TABLE RepositoriesContributors(
[RepositoryId] INT FOREIGN KEY REFERENCES Repositories(Id) NOT NULL,
[ContributorId] INT FOREIGN KEY REFERENCES Users(Id) NOT NULL,
PRIMARY KEY (RepositoryId, ContributorId)
)

CREATE TABLE Issues(
[Id] INT PRIMARY KEY IDENTITY,
[Title] VARCHAR(255) NOT NULL,
[IssueStatus] VARCHAR(6) NOT NULL,
[RepositoryId] INT FOREIGN KEY REFERENCES Repositories(Id) NOT NULL,
[AssigneeId] INT FOREIGN KEY REFERENCES Users(Id) NOT NULL
)

CREATE TABLE Commits(
[Id] INT PRIMARY KEY IDENTITY,
[Message] VARCHAR(255) NOT NULL,
[IssueId] INT FOREIGN KEY REFERENCES Issues(Id),
[RepositoryId] INT FOREIGN KEY REFERENCES Repositories(Id) NOT NULL,
[ContributorId] INT FOREIGN KEY REFERENCES Users(Id) NOT NULL
)

CREATE TABLE Files(
[Id] INT PRIMARY KEY IDENTITY,
[Name] VARCHAR(100) NOT NULL,
[Size] DECIMAL(15,2) NOT NULL,
[ParentId] INT FOREIGN KEY REFERENCES Files(Id),
[CommitId] INT FOREIGN KEY REFERENCES Commits(Id)
)

-- 02. Insert 

INSERT INTO Files([Name], [Size], ParentId, CommitId)
	VALUES
('Trade.idk', 2598.0, 1, 1),
('menu.net', 9238.31, 2, 2),
('Administrate.soshy', 1246.93, 3, 3),
('Controller.php', 7353.15, 4, 4),
('Find.java', 9957.86, 5, 5),
('Controller.json', 14034.87, 3, 6),
('Operate.xix', 7662.92, 7, 7)

INSERT INTO Issues(Title, IssueStatus, RepositoryId, AssigneeId)
	VALUES
('Critical Problem with HomeController.cs file', 'open', 1, 4),
('Typo fix in Judge.html', 'open', 4, 3),
('Implement documentation for UsersService.cs', 'closed', 8, 2),
('Unreachable code in Index.cs', 'open', 9, 8)

-- 03. Update

UPDATE Issues
   SET IssueStatus = 'Closed'
 WHERE AssigneeId = 6

 -- 04. Delete 

 SELECT Id FROM Repositories
 WHERE [Name] = 'Softuni-Teamwork'

 DELETE FROM RepositoriesContributors
       WHERE RepositoryId =  (SELECT Id FROM Repositories
                              WHERE [Name] = 'Softuni-Teamwork')

DELETE FROM Issues 
      WHERE RepositoryId = (SELECT Id FROM Repositories
                              WHERE [Name] = 'Softuni-Teamwork')
	

-- 05. Commits 

  SELECT Id, [Message], RepositoryId, ContributorId 
    FROM Commits
ORDER BY Id, [Message], RepositoryId, ContributorId

-- 06. Front-end 

   SELECT Id, [Name], [Size] 
     FROM Files
    WHERE [Name] LIKE '%html%' AND Size > 1000
 ORDER BY Size DESC, Id, [Name]

 -- 07. Issue Assignment 

 SELECT * FROM Users
 SELECT * FROM Issues

  SELECT i.Id, CONCAT(Username, ' ', ':', ' ',  i.Title) AS [IssueAssignee]
    FROM Users AS u
    JOIN Issues AS i 
      ON u.Id = i.AssigneeId
ORDER BY i.Id DESC, i.AssigneeId

-- 08. Single Files 
  
    SELECT fp.Id, fp.[Name], CONCAT(fp.Size, 'KB') AS Size
      FROM Files AS fc
RIGHT JOIN Files AS Fp
        ON fc.ParentId = fp.Id
     WHERE fc.Id IS NULL
  ORDER BY fp.Id, fp.[Name], fp.Size DESC

-- 09. Commits in Repositories

SELECT TOP 5 r.Id, r.[Name], COUNT(c.Id) AS [Commits]
  FROM Commits AS c
 JOIN Repositories AS r ON c.RepositoryId = r.Id
 JOIN RepositoriesContributors AS rc ON rc.RepositoryId = r.Id
 GROUP BY r.Id, r.[Name]
 ORDER BY Count(c.Id) DESC, r.Id, r.[Name]

 -- 10. Average Size

 SELECT u.Username,
        AVG(f.Size) AS [Size]
   FROM Users AS u
   JOIN Commits AS c
     ON c.ContributorId = u.Id
   JOIN Files AS f 
     ON c.Id = f.CommitId
GROUP BY u.Username
ORDER BY [Size] DESC, u.Username 

-- 11. All User Commits

GO

CREATE FUNCTION udf_AllUserCommits(@username VARCHAR(30))
RETURNS INT
AS
BEGIN
	DECLARE @result INT
				SET @result = ( SELECT
					COUNT(c.Id)
			   FROM Users AS u
			   JOIN Commits AS c 
				 ON c.ContributorId = u.Id
				 WHERE u.Username = @username
				)
	RETURN @result
END

GO


SELECT dbo.udf_AllUserCommits('UnderSinduxrein')

-- 12. Search for Files 

GO

CREATE PROCEDURE usp_SearchForFiles(@fileExtension VARCHAR(10))
AS
BEGIN
	SELECT Id, [Name], CONCAT([Size], 'KB') AS [Size]
	  FROM Files
	 WHERE [Name] LIKE '%.' + @fileExtension
  ORDER BY [Id], [Name], [Size] DESC
END

GO

EXEC usp_SearchForFiles 'txt'










