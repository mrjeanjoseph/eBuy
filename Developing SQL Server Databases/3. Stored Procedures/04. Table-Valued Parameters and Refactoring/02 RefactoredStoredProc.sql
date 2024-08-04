USE [Contacts]
GO
IF EXISTS(SELECT 1 FROM SYS.PROCEDURES WHERE [name] = 'InsertContactNotes')
	BEGIN
		DROP PROCEDURE [Contacts].[dbo].[InsertContactNotes]
	END;
GO

CREATE OR ALTER PROCEDURE [dbo].[InsertContactNotes](
	@ContactId INT,
	@Notes VARCHAR(MAX)
) AS
BEGIN

	INSERT INTO [Contacts].[dbo].[ContactNotes](
		ContactId,
		Notes
	) 
	SELECT @ContactId, Value FROM STRING_SPLIT(@Notes, ',');


	SELECT * 
	FROM [Contacts].[dbo].ContactNotes 
	WHERE ContactId = @ContactId 
	ORDER BY NoteId DESC;
END;
GO
RETURN;

--Testing the script right quick
EXEC dbo.InsertContactNotes
	@ContactId = 39, 
	@Notes = 'You can use C# to create Windows client applications, XML Web services; distributed components; client-server applications, database applications; and much much more';
-- This SP separate the entry where there's a comma.