USE [WideWorldImporters]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE OR ALTER TRIGGER [Sales].[TI_Orders]ON 
	[Sales].[Orders]AFTER INSERTAS
	BEGIN
		RAISERROR('The TI_Orders trigger was fired',1,1);
	END;
GO


/*
  Add in the Boilerplate code to verify that data
  was actually modified. If not, return and save
  the work of the Trigger.

  With this change, we won't see the message when
  no data is modified.
*/
CREATE OR ALTER TRIGGER [Sales].[TI_Orders_InsteadOf]ON 
	[Sales].[Orders]INSTEAD OF INSERTAS
	BEGIN
		RAISERROR('The TI_Orders_InsteadOf trigger was fired',1,1);
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

DROP TRIGGER Sales.TI_Orders;

/*
  With INSTEAD OF Triggers, constraints are checked only
  when the trigger performs DML on the table.

  CustomerID=0 does not exist, but no warning is issued
  because data is not actually being manipulated.
*/
INSERT INTO Sales.Orders (CustomerID, SalespersonPersonID, ContactPersonID, OrderDate, ExpectedDeliveryDate, IsUndersupplyBackordered, LastEditedBy)
	VALUES (0, 7, 1001, GETDATE(), DATEADD(DAY, 10, GETDATE()), 0, 10);
GO

/*
 ALTER the Trigger to check if the Customer is 
 currently on a Credit Freeze.

 If not, INSERT the data into the table
*/
CREATE OR ALTER TRIGGER [Sales].[TI_Orders_InsteadOf]ON 
	[Sales].[Orders]INSTEAD OF INSERTAS
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

		-- All checks passed, insert data into table
		-- Constraints will be checked with this INSERT and any 
		-- AFTER Triggers for this DML action will be executed
		INSERT INTO Sales.Orders (CustomerID, SalespersonPersonID, ContactPersonID, OrderDate, ExpectedDeliveryDate, IsUndersupplyBackordered, LastEditedBy)
			SELECT i.CustomerID, i.SalespersonPersonID, i.ContactPersonID, i.OrderDate, i.ExpectedDeliveryDate, i.IsUndersupplyBackordered, i.LastEditedBy
			 FROM INSERTED i;
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
  Set CustomerID=10 to be on credit freeze
*/
UPDATE sales.Customers SET IsOnCreditHold = 0 WHERE CustomerID=10;


/*
  Attempt the insert again
*/
INSERT INTO Sales.Orders (CustomerID, SalespersonPersonID, ContactPersonID, OrderDate, ExpectedDeliveryDate, IsUndersupplyBackordered, LastEditedBy)
	VALUES (10, 8, 1001, GETDATE(), DATEADD(DAY, 10, GETDATE()), 0, 10);
GO


/***********************
 *
 * Correcting Bad Data
 *
 **********************/

/*
  Attempt the insert again. This time with a
  provide a NULL ExpectedDeliveryDate as if coming
  fro a know, bad application or integration
*/
INSERT INTO Sales.Orders (CustomerID, SalespersonPersonID, ContactPersonID, OrderDate, ExpectedDeliveryDate, IsUndersupplyBackordered, LastEditedBy)
	VALUES (10, 8, 1001, GETDATE(), NULL, 0, 10);
GO


/*
  ALTER the Trigger to include a second check for SalesPerson.
*/
CREATE OR ALTER TRIGGER [Sales].[TI_Orders_InsteadOf]ON 
	[Sales].[Orders]INSTEAD OF INSERTAS
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

		-- System X always sends NULL for ExpectedDeliveryDate
		-- Set to OrderDate + 10 Days
		IF EXISTS ( SELECT 1 FROM INSERTED i WHERE i.ExpectedDeliveryDate is NULL )
		BEGIN
			/* 
				Create Temp Table of data for use throughout Trigger 

				This also allows us to update INSERTED data as needed for use later.
			*/	
			SELECT * INTO #tempInserted FROM INSERTED;

			UPDATE #tempInserted SET ExpectedDeliveryDate = DATEADD(day,10,OrderDate) 
				WHERE ExpectedDeliveryDate IS NULL;
		END;

		-- All checks passed, insert data into table
		INSERT INTO Sales.Orders (CustomerID, SalespersonPersonID, ContactPersonID, OrderDate, ExpectedDeliveryDate, IsUndersupplyBackordered, LastEditedBy)
			SELECT i.CustomerID, i.SalespersonPersonID, i.ContactPersonID, i.OrderDate, i.ExpectedDeliveryDate, i.IsUndersupplyBackordered, i.LastEditedBy
			 FROM #tempInserted i;

	END;
GO


/*
  Attempt the insert again. This time with a
  provide a NULL ExpectedDeliveryDate as if coming
  fro a know, bad application or integration
*/
INSERT INTO Sales.Orders (CustomerID, SalespersonPersonID, ContactPersonID, OrderDate, ExpectedDeliveryDate, IsUndersupplyBackordered, LastEditedBy)
	VALUES (10, 8, 1001, GETDATE(), NULL, 0, 10);
GO


/*******************************
 *
 * UPDATING data using a VIEW
 *
 ******************************/

/*
  Create a view that only shows the Delivery Address for customers by CustomerID
*/
CREATE OR ALTER VIEW Sales.CustomerAddressDeliveryView AS
	SELECT CustomerID, DeliveryAddressLine1 AS AddressLine1, DeliveryAddressLine2 AS AddressLine2, 
		DeliveryPostalCode AS PostalCode, CityName AS City, StateProvinceCode AS State
	FROM Sales.Customers CU
		INNER JOIN Application.Cities C on CU.DeliveryCityID = C.CityID
		INNER JOIN Application.StateProvinces SP on C.StateProvinceID = SP.StateProvinceID;
GO

/*
  Verify that the view is working.
*/
SELECT * FROM Sales.CustomerAddressDeliveryView;
GO


CREATE OR ALTER TRIGGER [Sales].[TI_CustomerAddressDeliveryView]
ON Sales.CustomerAddressDeliveryView INSTEAD OF UPDATE
AS
BEGIN
	IF (ROWCOUNT_BIG() = 0)
	RETURN;

	SET NOCOUNT ON;

	IF NOT EXISTS (SELECT 1 FROM INSERTED)
		RETURN;

	-- Create Temp Table for incoming data
	CREATE TABLE #tempAddress (
		CustomerID int,
		AddressLine1 nvarchar(60) COLLATE database_default,
		AddressLine2 nvarchar(60) COLLATE database_default,
		PostalCode nvarchar(10) COLLATE database_default,
		City nvarchar(50) COLLATE database_default,
		State nvarchar(50) COLLATE database_default,
		DeliveryCityID int null,
	);

	-- Select all data into new Temp Table
	INSERT INTO #tempAddress
		SELECT CustomerID, AddressLine1, AddressLine2, PostalCode, City, State, null from INSERTED;

	-- Update the Temp Table with the DeliveryCityID 
	-- based on City name and State
	-- NOTE: SIGNIFICANTLY MORE ERROR CHECKING WOULD HAVE TO BE DONE IN PRODUCTION!!
	UPDATE #tempAddress SET DeliveryCityID = C.CityID FROM #tempAddress 
		INNER JOIN Application.Cities C	ON #tempAddress.City = C.CityName
		INNER JOIN Application.StateProvinces SP on C.StateProvinceID = SP.StateProvinceID
			WHERE SP.StateProvinceCode = #tempAddress.State

	-- Finally Update the Customer table with the
	-- correct Address Lines, Postal Code, and DeliveryCityID
	-- that was looked up from the Cities table
	UPDATE Sales.Customers SET 
		DeliveryAddressLine1 = i.AddressLine1,
		DeliveryAddressLine2 = i.AddressLine2,
		DeliveryPostalCode = i.PostalCode,
		DeliveryCityID = i.DeliveryCityID
	FROM #tempAddress i INNER JOIN Sales.Customers 
		ON i.CustomerID = Sales.Customers.CustomerID
	WHERE i.DeliveryCityID IS NOT NULL;

END;


/*
  Examine the current customer address first
*/
select CustomerID, DeliveryAddressLine1, DeliveryAddressLine2, DeliveryPostalCode, DeliveryCityID
	from Sales.Customers WHERE CustomerID=10;

/*
  Update the values USING the view!
*/
UPDATE Sales.CustomerAddressDeliveryView SET
	AddressLine1 = '100 Jones Road',
	AddressLine2 = 'Suite 200',
	PostalCode = '90210',
	City = 'Bell',
	[State] = 'CA'
WHERE CustomerId = 10;


/*
  Verify the updated customer address
*/
select CustomerID, DeliveryAddressLine1, DeliveryAddressLine2, DeliveryPostalCode, DeliveryCityID
	from Sales.Customers WHERE CustomerID=10;


