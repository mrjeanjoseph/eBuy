USE [Contacts]
GO
--Creating Custom data type

DROP TYPE IF EXISTS [dbo].DriverLicense
CREATE TYPE [dbo].DriverLicense FROM CHAR(32) NOT NULL;
GO
RETURN;


--Testing the data type
DECLARE @DV dbo.DriverLicense = 'FD3KJKF3LJFKLJFD3L0';
SELECT @DV;
GO
RETURN;

--Creating Custom data type for the Contact Note
DROP TYPE IF EXISTS dbo.ContactNote;
GO
CREATE TYPE dbo.ContactNote AS TABLE (Note VARCHAR(MAX) NOT NULL);
GO
RETURN;



--Now Altering the storedProc
USE [Contacts]
GO
IF EXISTS(SELECT 1 FROM SYS.PROCEDURES WHERE [name] = 'InsertContactNotes')
	BEGIN
		DROP PROCEDURE [dbo].[InsertContactNotes]
	END;
GO

CREATE OR ALTER PROCEDURE [dbo].[InsertContactNotes](
	@ContactId INT,
	@Notes dbo.ContactNote READONLY
) AS
BEGIN

	INSERT INTO [Contacts].[dbo].[ContactNotes](
		ContactId,
		Notes
	) 
	SELECT @ContactId, Note FROM @Notes;

	SELECT * 
	FROM [Contacts].[dbo].ContactNotes 
	WHERE ContactId = @ContactId 
	ORDER BY NoteId DESC;
END;
GO
RETURN;

