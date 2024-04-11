USE Bank

-- 01. Create Table Logs 

CREATE TABLE [Logs] (
	LogId INT PRIMARY KEY IDENTITY,
	AccountId INT NOT NULL,
	OldSum DECIMAL(18,2),
	NewSum DECIMAL(18,2)
	)

GO

CREATE OR ALTER TRIGGER tr_AddToLogWhenAccountBalanceChanges
ON [Accounts] FOR UPDATE
AS
	INSERT INTO [Logs] ([AccountId], [OldSum], [NewSum])
		 SELECT [i].[AccountHolderId]
				 , [d].[Balance]
				 , [i].[Balance]
		   FROM [inserted] AS [i]
           JOIN [deleted] AS [d] ON [i].[Id] = [d].[Id]
		  WHERE [i].[Balance] <> [d].[Balance]

GO


-- 02. Create Table Emails 

CREATE TABLE [NotificationEmails] 
	(
		[Id] INT PRIMARY KEY IDENTITY,
		[Recipient] INT NOT NULL,
		[Subject] NVARCHAR(200),
		[Body] NVARCHAR(MAX)
	)

GO

CREATE OR ALTER TRIGGER tr_CreateNewEmail
ON [Logs] FOR INSERT
AS
	INSERT INTO [NotificationEmails] ([Recipient], [Subject], [Body])
		 SELECT [i].[AccountId]
				, CONCAT('Balance change for account: ', [i].[AccountId])
				, CONCAT('On ', GETDATE(), ' your balance was changed from ', [i].OldSum, ' to ', [i].[NewSum], '.')
		   FROM [inserted] AS [i]

GO

-- 03. Deposit Money 

CREATE OR ALTER PROC usp_DepositMoney(@AccountId INT, @MoneyAmount MONEY)
AS
BEGIN
	IF @MoneyAmount > 0.0000
	BEGIN
		UPDATE [Accounts]
		   SET [Balance] += @MoneyAmount
		 WHERE [Id] = @AccountId
	END
END

-- 04. Withdraw Money Procedure

GO

CREATE OR ALTER PROC usp_WithdrawMoney (@AccountId INT, @MoneyAmount MONEY)
AS
BEGIN
	IF @MoneyAmount > 0.0000
	BEGIN
		UPDATE [Accounts]
		   SET [Balance] -= @MoneyAmount
		 WHERE [Id] = @AccountId
	END
END

GO

-- 05. Money Transfer

GO

 CREATE OR ALTER PROC usp_TransferMoney(@SenderId INT, @ReceiverId INT, @Amount MONEY)
 AS
 BEGIN
	IF @Amount > 0.0000
	BEGIN
		EXEC usp_WithdrawMoney @SenderId, @Amount
		EXEC usp_DepositMoney @ReceiverId, @Amount
	END
 END

GO