USE [WideWorldImporters]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
 * Demo Notes:
 *
 * 1. Fresh copy of WideWorldImporters
 * 2. F5: execute selected statement
 * 3. Ctrl-R: Hide the results window that appears
 */


CREATE OR ALTER TRIGGER [Sales].[TI_Orders]ON 
	[Sales].[Orders]AFTER INSERTAS
	BEGIN
		RAISERROR('The TI_Orders trigger was fired',1,1);
	END;
GO


/*
 The Trigger will be fired REGARDLESS of actual data manipulation.
 Remember, it is the DML Action being called which causes 
 the Trigger to execute
*/
INSERT INTO Sales.Orders 
	SELECT * FROM sales.orders WHERE OrderID = 0;
GO

/*
  Add in the Boilerplate code to verify that data
  was actually modified. If not, return and save
  the work of the Trigger.

  With this change, we won't see the message when
  no data is modified.
*/
CREATE OR ALTER TRIGGER [Sales].[TI_Orders]ON 
	[Sales].[Orders]AFTER INSERTAS
	BEGIN
		-- Check count of rows modified from calling DML Action
		IF (ROWCOUNT_BIG() = 0)
			RETURN;
		-- Do not print any result details from Trigger
		SET NOCOUNT ON;
		-- In the case of a MERGE statement, the ROWCOUNT_BIG will return
		-- the rowcount of all actions (INSERT, UPDATE, and DELETE), not
		-- just the INSERT count
		IF NOT EXISTS (SELECT 1 FROM INSERTED)
			RETURN;

		RAISERROR('The TI_Orders trigger was fired',1,1);
	END;
GO

/*
 Attempt the same insert of zero rows.

 There should be no output this time.
*/
INSERT INTO Sales.Orders 
	SELECT * FROM sales.orders WHERE OrderID = 0;
GO


/*
  With AFTER Triggers, constraints are checked first.

  With a Foreign Key on "CustomerID", that constraint must
  pass first before the data can be saved and the Trigger
  is Executed.
*/
INSERT INTO Sales.Orders (CustomerID, SalespersonPersonID, ContactPersonID, OrderDate, ExpectedDeliveryDate, IsUndersupplyBackordered, LastEditedBy)
	VALUES (10, 7, 1001, GETDATE(), DATEADD(DAY, 10, GETDATE()), 0, 10);
GO

/*
  Now attempt the same INSERT with a CustomerID that
  does not exist in the Sales.Customer table
*/
INSERT INTO Sales.Orders (CustomerID, SalespersonPersonID, ContactPersonID, OrderDate, ExpectedDeliveryDate, IsUndersupplyBackordered, LastEditedBy)
	VALUES (0, 7, 1001, GETDATE(), DATEADD(DAY, 10, GETDATE()), 0, 10);
GO


/*
 ALTER the Trigger to check if the Customer is 
 currently on a Credit Freeze
*/
CREATE OR ALTER TRIGGER [Sales].[TI_Orders]ON 
	[Sales].[Orders]AFTER INSERTAS
	BEGIN
		IF (ROWCOUNT_BIG() = 0)
			RETURN;

		SET NOCOUNT ON;

		IF NOT EXISTS (SELECT 1 FROM INSERTED)
			RETURN;
		
		-- Is this customer credit on hold?
		IF EXISTS 
		(
			SELECT 1 FROM INSERTED i 
				INNER JOIN Customers c on i.CustomerID = c.CustomerID
			WHERE c.IsOnCreditHold = 1
		)
		BEGIN
			RAISERROR('Customer is currently on a credit freeze',16,1);
			ROLLBACK TRAN;
			RETURN;
		END;
	END;
GO

/*
  Set CustomerID=10 to be on credit freeze
*/
UPDATE sales.Customers SET IsOnCreditHold = 1 WHERE CustomerID=10;

/*
  Attempt the insert.
*/
INSERT INTO Sales.Orders (CustomerID, SalespersonPersonID, ContactPersonID, OrderDate, ExpectedDeliveryDate, IsUndersupplyBackordered, LastEditedBy)
	VALUES (10, 8, 1001, GETDATE(), DATEADD(DAY, 10, GETDATE()), 0, 10);
GO

/*
  ALTER the Trigger to include a second check for SalesPerson.
*/
CREATE OR ALTER TRIGGER [Sales].[TI_Orders]ON 
	[Sales].[Orders]AFTER INSERTAS
	BEGIN
		IF (ROWCOUNT_BIG() = 0)
			RETURN;

		SET NOCOUNT ON;

		IF NOT EXISTS (SELECT 1 FROM INSERTED)
			RETURN;
		
		-- Is this customer credit on hold?
		IF EXISTS 
		(
			SELECT 1 FROM INSERTED i 
				INNER JOIN Sales.Customers c on i.CustomerID = c.CustomerID
			WHERE c.IsOnCreditHold = 1
		)
		BEGIN
			RAISERROR('Customer is currently on a credit freeze',16,1);
			ROLLBACK TRAN;
			RETURN;
		END;

		-- Is this a valid Sales Person
		IF EXISTS 
		(
			SELECT 1 FROM INSERTED i 
				INNER JOIN Application.People p on i.SalespersonPersonID = p.PersonID
			WHERE p.IsSalesperson = 0
		)
		BEGIN
			RAISERROR('The supplied user is not currently a Sales Person',16,1);
			ROLLBACK TRAN;
			RETURN;
		END;

	END;
GO

/*
	Remove the Credit Freeze from CustomerID=10
*/
UPDATE sales.Customers SET IsOnCreditHold = 0 WHERE CustomerID=10;

/*
	Attempt the INSERT. The Trigger will stop the insert on an 
	invalid SalesPersonID.
*/
INSERT INTO Sales.Orders (CustomerID, SalespersonPersonID, ContactPersonID, OrderDate, ExpectedDeliveryDate, IsUndersupplyBackordered, LastEditedBy)
	VALUES (10, 9, 1001, GETDATE(), DATEADD(DAY, 10, GETDATE()), 0, 10);

/*
	When there are multiple checks, the first to raise an error is 
	what will be returned as an error.
*/
UPDATE sales.Customers SET IsOnCreditHold = 1 WHERE CustomerID=10;



/*
  Cleanup
*/

UPDATE sales.Customers SET IsOnCreditHold = 0 WHERE CustomerID=10;

DROP TRIGGER Sales.TI_Orders;