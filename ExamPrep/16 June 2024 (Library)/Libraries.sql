CREATE DATABASE LibraryDb 
USE master
USE LibraryDb

-- 01. DDL

CREATE TABLE Genres(
Id INT PRIMARY KEY IDENTITY,
[Name] NVARCHAR(30) NOT NULL
)

CREATE TABLE Contacts(
Id INT PRIMARY KEY IDENTITY,
Email NVARCHAR(100),
PhoneNumber NVARCHAR(20),
PostAddress NVARCHAR(200),
Website NVARCHAR(50)
)

CREATE TABLE Authors(
Id INT PRIMARY KEY IDENTITY,
[Name] NVARCHAR(100) NOT NULL,
ContactId INT FOREIGN KEY REFERENCES Contacts(Id) NOT NULL
)

CREATE TABLE Libraries(
Id INT PRIMARY KEY IDENTITY,
[Name] NVARCHAR(50) NOT NULL,
ContactId INT FOREIGN KEY REFERENCES Contacts(Id) NOT NULL
)

CREATE TABLE Books(
Id INT PRIMARY KEY IDENTITY,
Title NVARCHAR(100) NOT NULL,
YearPublished INT NOT NULL,
ISBN NVARCHAR(13) UNIQUE NOT NULL,
AuthorId INT FOREIGN KEY REFERENCES Authors(Id) NOT NULL,
GenreId INT FOREIGN KEY REFERENCES Genres(Id) NOT NULL
)

CREATE TABLE LibrariesBooks(
LibraryId INT FOREIGN KEY REFERENCES Libraries(Id) NOT NULL,
BookId INT FOREIGN KEY REFERENCES Books(Id) NOT NULL,
PRIMARY KEY(LibraryId, BookId)
)

-- 02. Insert

INSERT INTO Contacts(Email, PhoneNumber, PostAddress, Website)
	VALUES
(NULL,	NULL, NULL,	NULL),
(NULL,	NULL, NULL,	NULL),
('stephen.king@example.com', '+4445556666',	'15 Fiction Ave, Bangor, ME', 'www.stephenking.com'),
('suzanne.collins@example.com',	'+7778889999', '10 Mockingbird Ln, NY, NY', 'www.suzannecollins.com')

INSERT INTO Authors([Name], ContactId)
	VALUES
('George Orwell', 21),
('Aldous Huxley', 22),
('Stephen King', 23),
('Suzanne Collins',	24)

INSERT INTO Books(Title, YearPublished, ISBN, AuthorId, GenreId)
	VALUES
('1984', 1949, '9780451524935',	16,	2),
('Animal Farm',	1945, '9780451526342', 16, 2),
('Brave New World',	1932, '9780060850524', 17, 2),
('The Doors of Perception',	1954, '9780060850531', 17, 2),
('The Shining',	1977, '9780307743657', 18, 9),
('It',	1986, '9781501142970', 18,	9),
('The Hunger Games', 2008, '9780439023481', 19, 7),
('Catching Fire', 2009,	'9780439023498', 19, 7),
('Mockingjay', 2010, '9780439023511', 19, 7)

INSERT INTO LibrariesBooks(LibraryId, BookId)
	VALUES
(1,	36),
(1,	37),
(2,	38),
(2,	39),
(3,	40),
(3,	41),
(4,	42),
(4,	43),
(5,	44)

-- 03. Update 

SELECT * FROM Authors

SELECT * FROM Contacts

SELECT c.Id 
  FROM Authors AS a
  JOIN Contacts AS c ON a.ContactId = c.Id
 WHERE c.Website IS NULL

 UPDATE Contacts
 SET Website = 'www,'
 WHERE Id IN (SELECT c.Id 
  FROM Authors AS a
  JOIN Contacts AS c ON a.ContactId = c.Id
 WHERE c.Website IS NULL)


UPDATE Contacts
   SET Website = 'www.' + LOWER(REPLACE([a].[Name], ' ', '')) + '.com'
  FROM Contacts AS c
  JOIN Authors AS a ON c.Id = a.ContactId
 WHERE c.Website IS NULL

-- 04. Delete 

SELECT 
* FROM Authors AS a
  JOIN Books AS b ON b.AuthorId = a.Id
 WHERE [Name] = 'Alex Michaelides'

 DELETE FROM LibrariesBooks
 WHERE BookId = 1

 DELETE FROM Books
 WHERE Id = 1

 DELETE FROM Authors
 WHERE Id = 1

-- 05. Chronological Order

  SELECT Title AS [Book Title],
	     ISBN,
		 YearPublished AS [YearReleased]
    FROM Books
ORDER BY YearPublished DESC, Title

-- 06. Books by Genre 

  SELECT b.Id,
	     b.Title,
		 b.ISBN,
		 g.[Name] AS [Genre]
    FROM Books AS b
	JOIN Genres AS g ON b.GenreId = g.Id
   WHERE g.[Name] IN ('Biography', 'Historical Fiction')
ORDER BY g.[Name], b.Title

-- 07. Missing Genre 

  SELECT l.[Name] AS [Library],
         c.Email
    FROM Libraries AS l
    JOIN Contacts AS c ON l.ContactId = c.Id
   WHERE l.Id NOT IN (
        SELECT DISTINCT lb.LibraryId
          FROM LibrariesBooks AS lb
          JOIN Books b ON lb.BookId = b.Id
          JOIN Genres g ON b.GenreId = g.Id
         WHERE g.[Name] = 'Mystery')
ORDER BY l.[Name]

-- 08. First 3 Books

  SELECT TOP 3
         b.Title,
	     b.YearPublished AS [Year],
		 g.[Name] AS [Genre]
    FROM Books AS b
	JOIN Genres AS g ON b.GenreId = g.Id
   WHERE (b.YearPublished > 2000 AND b.Title LIKE '%a%') OR (b.YearPublished < 1950 AND g.[Name] LIKE '%Fantasy%')
ORDER BY b.Title, b.YearPublished DESC

-- 09. Authors from UK 

  SELECT a.[Name] AS [Author],
         c.Email,
		 c.PostAddress AS [Address]
    FROM Authors AS a
	JOIN Contacts AS c ON a.ContactId = c.Id
   WHERE RIGHT(c.PostAddress, 2) = 'UK'
ORDER BY a.[Name]

-- 10. Fictions in Denver

SELECT * FROM Libraries
SELECT * FROM Contacts
WHERE PostAddress LIKE '%Denver%'

-- library id = 4

   SELECT a.[Name] As [Author],
          b.Title AS [Title],
		  l.[Name] AS [Library],
		  c.PostAddress AS [Library Address]
     FROM Books AS b
	 JOIN Authors AS a ON b.AuthorId = a.Id
	 JOIN LibrariesBooks AS lb ON b.Id = lb.BookId
	 JOIN Libraries AS l ON lb.LibraryId = l.Id
	 JOIN Contacts AS c On l.ContactId = c.Id
	 WHERE lb.LibraryId IN (  SELECT l.Id
    FROM Contacts AS c
	JOIN Libraries AS l ON l.ContactId = c.Id
   WHERE PostAddress LIKE '%Denver%') AND b.Id IN (SELECT b.Id
				 FROM Books AS b
				 JOIN Genres AS g ON b.GenreId = g.Id
				 WHERE g.[Name] = 'Fiction')
 ORDER BY b.Title ASC

  -- 11. Authors with Books

  GO

  CREATE FUNCTION udf_AuthorsWithBooks(@name NVARCHAR(100))
  RETURNS INT
  AS
  BEGIN
		RETURN (  SELECT COUNT(a.Id)
					FROM Authors AS a
					JOIN Books AS b ON b.AuthorId = a.Id
				   WHERE a.[Name] = @name
				GROUP BY a.Id)
  END

  GO

-- 12. Search by Genre 

GO

CREATE PROCEDURE usp_SearchByGenre(@genreName NVARCHAR(30))
AS
BEGIN
       SELECT b.Title,
              b.YearPublished AS [Year],
     		 b.ISBN,
     		 a.[Name] AS [Author],
     		 g.[Name] AS [Genre]
         FROM Books AS b
     	JOIN Genres As g ON b.GenreId = g.Id
     	JOIN Authors AS a ON b.AuthorId = a.Id
        WHERE g.[Name] = @genreName
     ORDER BY b.[Title]
		

END

GO
