USE [Northwind]
GO
/****** Object:  UserDefinedFunction [dbo].[OrderAmountPurchased]    Script Date: 6/1/2021 2:57:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER FUNCTION [dbo].[OrderAmountPurchased] 
(
	@orderId int
)
RETURNS Decimal(20,2)
AS
BEGIN

DECLARE @unitPrice AS DECIMAL(10,2)
DECLARE @qty AS INT
DECLARE @discount AS DECIMAL(20,2)
DECLARE @value AS DECIMAL(20,2)

SELECT 
	@orderId = OrderId,
	@unitPrice = UnitPrice,
	@discount = Discount
FROM [Order Details]
WHERE OrderId = @orderId

IF @qty = 0	
	SET @value = 0.0
ELSE
	BEGIN
		SELECT  
			@value = 
			CASE WHEN @orderId IS NULL THEN
				0.0
			ELSE
				SUM((unitprice * Quantity) - (unitprice * Quantity * Discount))
			END
		FROM [Order Details] WHERE OrderID = @orderId
	END
RETURN @value
END
