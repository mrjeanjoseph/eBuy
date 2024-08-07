USE [WideWorldImporters]
GO

/****** Object:  StoredProcedure [dbo].[SBActivated_IntermediateMessageQueue]    Script Date: 11/7/2018 2:10:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/* 
 * PROCEDURE: dbo.SBActivated_IntermediateMessageQueue 
 */



/* 
   This is the SPROC that will take a message off of the intermediate queue, where
   groups of bill messages have been placed by a batch trigger action, and then separate
   them into individual messages for another queue.  The XML message contains all
   of the necessary information, including what service, contract and message type
   for the provided messages.
*/
CREATE OR ALTER PROCEDURE [Application].[SBActivated_IntermediateMessageQueue]
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @conversation_handle UNIQUEIDENTIFIER;
	DECLARE @message_body XML;
	DECLARE @message_type_name sysname;

	BEGIN TRY

		-- Put this in a transaction. If something fails it can be returned to the queue.
		BEGIN TRANSACTION;

			WAITFOR (                
				RECEIVE TOP(1) 
					@conversation_handle = conversation_handle,
					@message_body = message_body,
					@message_type_name = message_type_name
					FROM IntermediateMessageQueue
			), TIMEOUT 5000;

			-- exit when waiting has been timed out
			IF (@conversation_handle IS NOT NULL)
			BEGIN
                
				/* If the message we got is for the purposes of putting it on a queue elsewhere, parse it out. */
                /* If it is not of this type, then in all likelyhood it is an error message or end of conversation */
				IF (@message_type_name = N'IntermediateMessage')
				BEGIN
                 
					DECLARE 
						@ServiceName sysname,
						@ContractName sysname,
						@MessageType	sysname,
						@TriggerXML		XML = NULL;

					SELECT
						@ServiceName = x.value('(/Request/ServiceName)[1]','sysname'),
						@ContractName = x.value('(/Request/ContractName)[1]','sysname'),
						@MessageType = x.value('(/Request/MessageType)[1]','sysname'),
						@TriggerXML = x.query('/Request/TriggerXML/data')
					FROM @message_body.nodes('/Request') AS T(x);


					BEGIN
						
						/* 
							This Cursor is now going to take the "DATA" node of the XML document that was passed in
							and send each row as a new message to the Queue.  All messages will use the same conversation
							handle to limit the amount of contention on the Service Broker backing tables.
						*/
						IF EXISTS (SELECT NULL FROM @TriggerXML.nodes('data/row') AS T(X))
						BEGIN
							DECLARE @InitDlgHandle UNIQUEIDENTIFIER
							DECLARE @parsedXML XML = NULL

							/*
								Inserting parsed xml into temp table with SELECT...INTO before using it because it is much slower to iterate over without doing this or when using INSERT INTO;
								kept cursor because the other option (querying each record by id) is slower than iterating over the cursor
							*/
							SELECT IDENTITY(INT, 1, 1) id, T.x.query('.') parsedXML INTO #TriggerParsed FROM @TriggerXML.nodes('data/row') AS T(x);

							IF (@@ROWCOUNT > 1)
								CREATE UNIQUE CLUSTERED INDEX [CX_#TriggerParsed] ON #TriggerParsed(id ASC);

							DECLARE SBMessagesCur CURSOR FOR
								SELECT parsedXML FROM #TriggerParsed

							OPEN SBMessagesCur 
							FETCH NEXT FROM SBMessagesCur INTO @parsedXML

							While @@Fetch_Status = 0 
							BEGIN
								/* push message onto processing queue */
                                                            
								BEGIN DIALOG @InitDlgHandle
									FROM SERVICE [MonologueSenderService]
									TO SERVICE @ServiceName, 'CURRENT DATABASE'
									ON CONTRACT @ContractName
									WITH ENCRYPTION = OFF;

								SEND ON CONVERSATION @InitDlgHandle
									MESSAGE TYPE @MessageType
									(@parsedXML)

								FETCH NEXT FROM SBMessagesCur INTO @parsedXML
							END -- End of Fetch

							CLOSE SBMessagesCur
							DEALLOCATE SBMessagesCur
						
						END

					END
					
					END CONVERSATION @conversation_handle;

				END
			END

		COMMIT;

	END TRY
	BEGIN CATCH

		CLOSE SBMessagesCur
		DEALLOCATE SBMessagesCur

		--Test whether the transaction is uncommittable.
		IF (XACT_STATE()) = -1
		BEGIN
			ROLLBACK TRANSACTION;
		END;
 
		-- Test wether the transaction is active and valid.
		IF (XACT_STATE()) = 1
		BEGIN
			DECLARE @error INT, @message NVARCHAR(3000);
			SELECT @error = ERROR_NUMBER(), @message = ERROR_MESSAGE();
			END CONVERSATION @conversation_handle WITH error = @error DESCRIPTION = @message;
			COMMIT;
		END
			
	END CATCH;
END



