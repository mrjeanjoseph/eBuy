USE RHJsShoes;
GO

SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;

BEGIN TRAN;

    SELECT * FROM Orders.Orders;

    SELECT * FROM Orders.Orders;

COMMIT;
