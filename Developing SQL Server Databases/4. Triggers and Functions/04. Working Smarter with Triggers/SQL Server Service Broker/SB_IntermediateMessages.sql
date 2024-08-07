USE [WideWorldImporters]
GO


/****** Object:  StoredProcedure [dbo].[SB_SendIntermediateMessages]    Script Date: 11/7/2018 1:57:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/* 
 * PROCEDURE: dbo.SB_SendIntermediateMessages 
 */

-- This procedure sends items to the queue for asynchronous triggers
CREATE OR ALTER PROCEDURE [Application].[SB_SendIntermediateMessages]
    @ServiceName VARCHAR(250),
    @ContractName VARCHAR(250),
	@MessageType	VARCHAR(250),
	@TriggerXML		XML = NULL

AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @msg XML
	
	-- build the XML message
	SET @msg = (SELECT
                    ServiceName = @ServiceName,
                    ContractName = @ContractName,
                    MessageType	= @MessageType,
					TriggerXML		= @TriggerXML
				FOR XML PATH('Request'))
	
	DECLARE @DlgId UNIQUEIDENTIFIER
	
	BEGIN DIALOG @DlgId
		FROM SERVICE [MonologueSenderService]
		TO SERVICE 'IntermediateMessageService', 'CURRENT DATABASE'
		ON CONTRACT [IntermediateMessageContract]
	WITH ENCRYPTION = OFF;
	
	-- send the message
	SEND ON CONVERSATION @DlgId
	MESSAGE TYPE [IntermediateMessage] (@msg);

END
