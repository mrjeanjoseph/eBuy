USE [Northwind]
GO
/****** Object:  UserDefinedFunction [dbo].[ProperWithCharacters]    Script Date: 6/1/2021 2:58:45 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- Function ufn_Proper
ALTER FUNCTION [dbo].[ProperWithCharacters]
	(
		@str VARCHAR(MAX)
	) 
RETURNS VARCHAR(MAX)

AS
BEGIN
	DECLARE @pos int, @startPosition INT
 
	SET @pos = 1		
	
	SET @str = TRIM('- () _ .' FROM LOWER(@str))	
	----remove all characters not alpha
	WHILE PATINDEX('%[^ A-z '''' -]%', @str) > 0
		BEGIN
			SET @pos = PATINDEX('%[^ A-z '''' -]%', @str)
			SET @str = CONCAT(SUBSTRING(@str,1, @pos - 1),
					   SUBSTRING(@str,@pos + 1, LEN(@str)))
		END
					
	/* Capitalize the first letter of the string */
	SET @str = CONCAT(SUBSTRING(UPPER(@str),1,1), SUBSTRING(LOWER(@str),2,LEN(@str)))
	
	/*
	  Capitalize the first letter after a single quote (IE:  O'Connor)
	  Capitalize the first letter after any space in a name	
	  Capitalize the first letter after any hyphen in a name
	*/			
	
	SET @startPosition = 1
	SET @pos = 0

	WHILE CHARINDEX('''', @str, @startPosition) > 0	
		OR CHARINDEX('-', @str, @startPosition) > 0	
		OR CHARINDEX(' ', @str, @startPosition) > 0
		BEGIN
			IF CHARINDEX('''', SUBSTRING(@str, @startPosition,1)) > 0
				BEGIN
					SET @pos = CHARINDEX('''', @str, @startPosition)
				END
			ELSE IF CHARINDEX('-', SUBSTRING(@str, @startPosition,1)) > 0
				BEGIN
					SET @pos = CHARINDEX('-', @str, @startPosition)
				END
			ELSE IF CHARINDEX(' ', SUBSTRING(@str, @startPosition,1)) > 0
				BEGIN
					SET @pos = CHARINDEX(' ', @str, @startPosition)
				END

			SET @str = CONCAT(SUBSTRING(@str, 1, @pos), 
				SUBSTRING(UPPER(@str),@pos + 1, 1),
				SUBSTRING(@str,@pos + 2, LEN(@str)))

			SET @startPosition = @startPosition + 1
		END

RETURN @str

END