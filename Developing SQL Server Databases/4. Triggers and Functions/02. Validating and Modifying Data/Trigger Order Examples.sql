USE [WideWorldImporters]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

DROP TRIGGER IF EXISTS Sales.TU_Orders_AFTER;
GO

/*
  Create a trigger AFTER UPDATE, no order specified
*/
CREATE OR ALTER TRIGGER [Sales].[TU_Orders_CreatedFirst]ON 
	[Sales].[Orders]AFTER UPDATEAS
	BEGIN
		IF (ROWCOUNT_BIG() = 0)
			RETURN;

		SET NOCOUNT ON;

		IF NOT EXISTS (SELECT 1 FROM DELETED)
			RETURN;

		RAISERROR('The [TU_Orders_CreatedFirst] trigger was fired',1,1);
	END;
GO

/*
  Create a second AFTER UPDATE
*/
CREATE OR ALTER TRIGGER [Sales].[TU_Orders_CreatedSecond]ON 
	[Sales].[Orders]AFTER UPDATEAS
	BEGIN
		IF (ROWCOUNT_BIG() = 0)
			RETURN;

		SET NOCOUNT ON;

		IF NOT EXISTS (SELECT 1 FROM DELETED)
			RETURN;

		RAISERROR('The [TU_Orders_CreatedSecond] trigger was fired',1,1);
	END;
GO


/*
  Cause a trigger to execute by simply attempting to update a value in the
  Sales.Orders table to itself.
*/
UPDATE Sales.Orders SET SalespersonPersonID=SalespersonPersonID WHERE OrderID = 20;
GO

/*
  Now drop the first trigger and recreate it
*/
DROP TRIGGER Sales.TU_Orders_CreatedFirst;
GO


CREATE OR ALTER TRIGGER [Sales].[TU_Orders_CreatedFirst]ON 
	[Sales].[Orders]AFTER UPDATEAS
	BEGIN
		IF (ROWCOUNT_BIG() = 0)
			RETURN;

		SET NOCOUNT ON;

		IF NOT EXISTS (SELECT 1 FROM DELETED)
			RETURN;

		RAISERROR('The [TU_Orders_CreatedFirst] trigger was fired',1,1);
	END;
GO

/*
  Run the same update. Notice that the order switched.
*/
UPDATE Sales.Orders SET SalespersonPersonID=SalespersonPersonID WHERE OrderID = 20;
GO

/*
  Now 
*/
sp_settriggerorder @triggername = 'Sales.TU_Orders_CreatedFirst', @order = 'first', @stmttype = 'UPDATE';
GO

sp_settriggerorder @triggername = 'Sales.TU_Orders_CreatedSecond', @order = 'last', @stmttype = 'UPDATE';
GO

UPDATE Sales.Orders SET SalespersonPersonID=SalespersonPersonID WHERE OrderID = 20;
GO

DROP TRIGGER IF EXISTS Sales.TU_Orders_CreatedFirst;
DROP TRIGGER IF EXISTS Sales.TU_Orders_CreatedSecond;
DROP TRIGGER IF EXISTS [Sales].[TU_Orders_Logging];
GO

/***********************************************
 *
 * When reassigning orders to a new sales person, 
 * log how many orders they had assigned to them.
 *
 ***********************************************/

SELECT * FROM Application.People WHERE IsSalesperson=1;
GO

CREATE OR ALTER TRIGGER [Application].[TU_People_ChangeSalesPerson]ON 
	[Application].[People]AFTER UPDATEAS
	BEGIN
		IF (ROWCOUNT_BIG() = 0)
			RETURN;

		SET NOCOUNT ON;

		IF NOT EXISTS (SELECT 1 FROM DELETED)
			RETURN;

		SELECT * INTO #ModifiedData FROM (			
			SELECT PersonID, IsSalesperson FROM DELETED WHERE IsSalesperson=1
			EXCEPT
			SELECT PersonID, IsSalesperson FROM INSERTED WHERE IsSalesperson=0
		) ModifiedData;

		/*
		  If a person is no longer a sales person, update all orders belonging
		  to them and reassign them to PersonID=20.
		*/
		IF EXISTS (SELECT 1 FROM #ModifiedData)
		BEGIN
			UPDATE Sales.Orders SET SalespersonPersonID = 20
				FROM Sales.Orders O INNER JOIN #ModifiedData MD ON O.SalespersonPersonID=MD.PersonID;
		END;
		
	END;
GO

/*
  At some point later, a second Trigger is created to log how many orders a
  sales person had before they are reassigned. If this was a true business
  requirement, it should be refactored into a single trigger.

  Just keep rolling with the example for now.
*/
CREATE OR ALTER TRIGGER [Application].[TU_People_LogSalesChange]ON 
	[Application].[People]AFTER UPDATEAS
	BEGIN
		IF (ROWCOUNT_BIG() = 0)
			RETURN;

		SET NOCOUNT ON;

		IF NOT EXISTS (SELECT 1 FROM DELETED)
			RETURN;
		
		/*
		  Custom Operation
		*/
		DECLARE @operationType nvarchar(16) = 'UPDATE SP_ID';

		/*
		  This is the same query as the other trigger, because we are
		  looking for the same thing.
		*/
		SELECT * INTO #ModifiedData FROM (			
				SELECT PersonID, IsSalesperson FROM DELETED WHERE IsSalesperson=1
				EXCEPT
				SELECT PersonID, IsSalesperson FROM INSERTED WHERE IsSalesperson=0
		) ModifiedData;

		/*
		  For each row of the modified data, select a JSON document of the previous data to include
		  in the audit log table.
		*/
		INSERT INTO Application.AuditLog ([ModifiedTime], [ModifiedBy], [Operation], [SchemaName], [TableName], [TableID], [LogData])
			SELECT GETDATE(), SYSTEM_USER, @operationType, 'Application','Person', M1.PersonId, M2.LogData
				FROM #ModifiedData M1
				CROSS APPLY (
					SELECT LogData=(select M1.PersonID as SalesPersionId, COUNT(*) AS OrdersBeforeReassign from Sales.Orders O WHERE O.SalespersonPersonID = M1.PersonID FOR JSON PATH)
				) AS M2
	END;
GO


/*
  Look to see what is currently in the log table
*/ 
TRUNCATE TABLE Application.AuditLog;
SELECT * FROM Application.AuditLog;

/*
  Update a person and remove their 'IsSalesperson' status
*/
SELECT * FROM Application.People WHERE PersonID = 3;
UPDATE Application.People SET IsSalesperson=0 WHERE PersonID=3;
GO

/*
  The update was logged... but there's no record of their orders
*/ 
SELECT * FROM Application.AuditLog;
GO

/*
  Let's force the order so that we get our logging accomplished first
*/
sp_settriggerorder @triggername = '[Application].[TU_People_LogSalesChange]', @order = 'first', @stmttype = 'UPDATE';
GO

/*
  Then reassign the orders to another person
*/
sp_settriggerorder @triggername = '[Application].[TU_People_ChangeSalesPerson]', @order = 'last', @stmttype = 'UPDATE';
GO

/*
  Try again!
*/
UPDATE Application.People SET IsSalesperson=0 WHERE PersonID=6;
GO

/*
  With the proper order we can now get our count and then reassign.
*/ 
SELECT * FROM Application.AuditLog;

