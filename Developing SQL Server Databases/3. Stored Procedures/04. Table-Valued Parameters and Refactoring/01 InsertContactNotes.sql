USE [Contacts]
GO
/****** Object:  StoredProcedure [dbo].[InsertContactNotes]    Script Date: 1/23/2024 7:19:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


ALTER PROCEDURE [dbo].[InsertContactNotes](
	@ContactId INT,
	@Notes VARCHAR(MAX)
) AS
BEGIN
	DECLARE @NoteTable TABLE (Note VARCHAR(MAX));
	DECLARE @NoteValue VARCHAR(MAX);

	INSERT INTO @NoteTable(Note)
	SELECT Value FROM STRING_SPLIT(@Notes, ',');

	DECLARE NoteCursor CURSOR FOR
		SELECT Note FROM @NoteTable;

	OPEN NoteCursor
	FETCH NEXT FROM NoteCursor INTO @NoteValue;

	WHILE @@FETCH_STATUS = 0
		BEGIN
			INSERT INTO dbo.ContactNotes (ContactId, Notes)
				VALUES (@ContactId, @NoteValue)

			FETCH NEXT FROM NoteCursor INTO @NoteValue;

		END;

	CLOSE NoteCursor;
	DEALLOCATE NoteCursor;

	SELECT * 
	FROM [Contacts].[dbo].ContactNotes 
	WHERE ContactId = @ContactId 
	ORDER BY NoteId DESC;
END;