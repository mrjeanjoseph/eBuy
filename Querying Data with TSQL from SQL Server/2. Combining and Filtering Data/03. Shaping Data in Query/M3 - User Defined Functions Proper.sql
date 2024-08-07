USE [Northwind]
GO
/****** Object:  UserDefinedFunction [dbo].[Proper]    Script Date: 6/1/2021 2:58:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER FUNCTION [dbo].[Proper] (@value AS VARCHAR(MAX))
RETURNS VARCHAR(MAX)
WITH EXECUTE AS CALLER
AS
BEGIN
    DECLARE @formattedValue AS  VARCHAR(MAX)
	DECLARE @firstCharacter AS  VARCHAR(1)

			
	--set all of the to lower case
	SET @value = LOWER(TRIM(@value))

	SET @firstCharacter =  		
		SUBSTRING(UPPER(@value), 1,1) --result is first letter
		

	SET @formattedValue = 
		CONCAT(@firstCharacter,SUBSTRING(@value,2,LEN(@value))) 
    RETURN @formattedValue 
END;
