USE [master]
GO
/****** Object:  Database [RHJsShoes]    Script Date: 2019-08-05 4:28:06 PM ******/
CREATE DATABASE [RHJsShoes]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'RHJsShoes', FILENAME = N'C:\devtrunk\sql-files\RHJsShoes\RHJsShoes.mdf' , SIZE = 73728KB , MAXSIZE = UNLIMITED, FILEGROWTH = 65536KB ), 
 FILEGROUP [BobsData] 
( NAME = N'RHJsData', FILENAME = N'C:\devtrunk\sql-files\RHJsShoes\RHJsData.mdf' , SIZE = 8192KB , MAXSIZE = UNLIMITED, FILEGROWTH = 65536KB )
 LOG ON 
( NAME = N'RHJsLogs', FILENAME = N'C:\devtrunk\sql-files\RHJsShoes\RHJsLog.ldf' , SIZE = 204800KB , MAXSIZE = 2048GB , FILEGROWTH = 65536KB ), 
( NAME = N'RHJsShoes_log', FILENAME = N'C:\devtrunk\sql-files\RHJsShoes\RHJsShoes_log.ldf' , SIZE = 204800KB , MAXSIZE = 2048GB , FILEGROWTH = 65536KB )
GO
ALTER DATABASE [RHJsShoes] SET COMPATIBILITY_LEVEL = 130
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [RHJsShoes].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [RHJsShoes] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [RHJsShoes] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [RHJsShoes] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [RHJsShoes] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [RHJsShoes] SET ARITHABORT OFF 
GO
ALTER DATABASE [RHJsShoes] SET AUTO_CLOSE ON 
GO
ALTER DATABASE [RHJsShoes] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [RHJsShoes] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [RHJsShoes] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [RHJsShoes] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [RHJsShoes] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [RHJsShoes] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [RHJsShoes] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [RHJsShoes] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [RHJsShoes] SET  ENABLE_BROKER 
GO
ALTER DATABASE [RHJsShoes] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [RHJsShoes] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [RHJsShoes] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [RHJsShoes] SET ALLOW_SNAPSHOT_ISOLATION ON 
GO
ALTER DATABASE [RHJsShoes] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [RHJsShoes] SET READ_COMMITTED_SNAPSHOT ON 
GO
ALTER DATABASE [RHJsShoes] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [RHJsShoes] SET RECOVERY SIMPLE 
GO
ALTER DATABASE [RHJsShoes] SET  MULTI_USER 
GO
ALTER DATABASE [RHJsShoes] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [RHJsShoes] SET DB_CHAINING OFF 
GO
ALTER DATABASE [RHJsShoes] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO
ALTER DATABASE [RHJsShoes] SET TARGET_RECOVERY_TIME = 60 SECONDS 
GO
ALTER DATABASE [RHJsShoes] SET DELAYED_DURABILITY = DISABLED 
GO
ALTER DATABASE [RHJsShoes] SET QUERY_STORE = OFF
GO
USE [RHJsShoes]
GO
ALTER DATABASE SCOPED CONFIGURATION SET LEGACY_CARDINALITY_ESTIMATION = OFF;
GO
ALTER DATABASE SCOPED CONFIGURATION SET MAXDOP = 0;
GO
ALTER DATABASE SCOPED CONFIGURATION SET PARAMETER_SNIFFING = ON;
GO
ALTER DATABASE SCOPED CONFIGURATION SET QUERY_OPTIMIZER_HOTFIXES = OFF;
GO
USE [RHJsShoes]
GO
/****** Object:  Schema [Orders]    Script Date: 2019-08-05 4:28:07 PM ******/
CREATE SCHEMA [Orders]
GO
/****** Object:  UserDefinedFunction [Orders].[CheckDates]    Script Date: 2019-08-05 4:28:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   FUNCTION [Orders].[CheckDates] 
    (@OrderDate date, @RequestedDate date)
    RETURNS BIT
    AS BEGIN
        RETURN (IIF(@RequestedDate > @OrderDate, 1, 0))
    END
GO
/****** Object:  Table [Orders].[Salutations]    Script Date: 2019-08-05 4:28:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Orders].[Salutations](
	[SalutationID] [int] IDENTITY(1,1) NOT NULL,
	[Salutation] [varchar](5) NOT NULL,
 CONSTRAINT [PK_Salutations_SalutationID] PRIMARY KEY CLUSTERED 
(
	[SalutationID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [Orders].[CityState]    Script Date: 2019-08-05 4:28:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Orders].[CityState](
	[CityStateID] [int] IDENTITY(1,1) NOT NULL,
	[CityStateCity] [nvarchar](100) NOT NULL,
	[CityStateProv] [nvarchar](100) NOT NULL,
	[CityStateCountry] [nvarchar](100) NOT NULL,
	[CityStatePostalCode] [nvarchar](20) NOT NULL,
 CONSTRAINT [PK_CityState_CityStateID] PRIMARY KEY CLUSTERED 
(
	[CityStateID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [Orders].[Customers]    Script Date: 2019-08-05 4:28:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Orders].[Customers](
	[CustID] [int] IDENTITY(1,1) NOT NULL,
	[CustName] [nvarchar](200) NOT NULL,
	[CustStreet] [nvarchar](200) NULL,
	[CityStateID] [int] NOT NULL,
	[SalutationID] [int] NOT NULL,
 CONSTRAINT [PK_Customers_CustID] PRIMARY KEY CLUSTERED 
(
	[CustID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [Orders].[CustomerList]    Script Date: 2019-08-05 4:28:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   VIEW [Orders].[CustomerList]
WITH SCHEMABINDING 
AS
  SELECT 
    cust.CustName             AS Name, 
    sal.Salutation            AS Salutation,
    cust.CustStreet           AS Street, 
    city.CityStateCity        AS City, 
    city.CityStateProv        AS StateProv,
    city.CityStatePostalCode  AS PostalCode,
    city.CityStateCountry     AS Country
  FROM orders.Customers cust
    INNER JOIN Orders.CityState city
      ON cust.CityStateID = city.CityStateID
    INNER JOIN Orders.Salutations sal
      ON cust.SalutationID = sal.SalutationID;
GO
/****** Object:  View [Orders].[OnlyTheAs]    Script Date: 2019-08-05 4:28:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- View WITH CHECK OPTION
CREATE   VIEW [Orders].[OnlyTheAs]
WITH SCHEMABINDING
AS
  SELECT c.CustName
  FROM Orders.Customers c
  WHERE c.CustName LIKE 'A%'
WITH CHECK OPTION  
GO
/****** Object:  Table [Orders].[Orders]    Script Date: 2019-08-05 4:28:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Orders].[Orders](
	[OrderID] [int] IDENTITY(1,1) NOT NULL,
	[OrderYear] [smallint] NOT NULL,
	[OrderDate] [date] NOT NULL,
	[OrderRequestedDate] [date] NOT NULL,
	[OrderDeliveryDate] [datetime2](0) NULL,
	[CustID] [int] NOT NULL,
	[OrderIsExpedited] [bit] NOT NULL,
 CONSTRAINT [PK_Orders_OrderYear_OrderID] PRIMARY KEY CLUSTERED 
(
	[OrderYear] ASC,
	[OrderID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [Orders].[Orders2018]    Script Date: 2019-08-05 4:28:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Orders].[Orders2018](
	[OrderID] [int] IDENTITY(1,1) NOT NULL,
	[OrderYear] [smallint] NOT NULL,
	[OrderDate] [date] NOT NULL,
	[OrderRequestedDate] [date] NOT NULL,
	[OrderDeliveryDate] [datetime2](0) NULL,
	[CustID] [int] NOT NULL,
	[OrderIsExpedited] [bit] NOT NULL,
 CONSTRAINT [PK_Orders2018_OrderYear_OrderID] PRIMARY KEY CLUSTERED 
(
	[OrderYear] ASC,
	[OrderID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [Orders].[PartitionedOrders]    Script Date: 2019-08-05 4:28:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- Create partitioned view
CREATE VIEW [Orders].[PartitionedOrders]
WITH SCHEMABINDING
AS
    SELECT OrderID, OrderYear, OrderDate, OrderRequestedDate, OrderDeliveryDate, CustID, OrderIsExpedited
    FROM Orders.Orders
    UNION ALL
    SELECT OrderID, OrderYear, OrderDate, OrderRequestedDate, OrderDeliveryDate, CustID, OrderIsExpedited
    FROM Orders.Orders2018
GO
/****** Object:  Table [Orders].[OrderItems]    Script Date: 2019-08-05 4:28:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Orders].[OrderItems](
	[OrderItemID] [int] IDENTITY(1,1) NOT NULL,
	[OrderID] [int] NOT NULL,
	[OrderYear] [smallint] NOT NULL,
	[StockID] [int] NOT NULL,
	[Quantity] [smallint] NOT NULL,
	[Discount] [numeric](4, 2) NOT NULL,
 CONSTRAINT [PK_OrderItems_OrderItemID] PRIMARY KEY CLUSTERED 
(
	[OrderItemID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [Orders].[OrderTracking]    Script Date: 2019-08-05 4:28:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Orders].[OrderTracking](
	[OrderId] [int] IDENTITY(1,1) NOT NULL,
	[OrderDate] [datetime2](0) NOT NULL,
	[RequestedDate] [datetime2](0) NOT NULL,
	[DeliveryDate] [datetime2](0) NULL,
	[CustName] [nvarchar](200) NOT NULL,
	[CustAddress] [nvarchar](200) NOT NULL,
	[ShoeStyle] [varchar](200) NOT NULL,
	[ShoeSize] [varchar](10) NOT NULL,
	[SKU] [char](8) NOT NULL,
	[UnitPrice] [numeric](7, 2) NOT NULL,
	[Quantity] [smallint] NOT NULL,
	[Discount] [numeric](4, 2) NOT NULL,
	[IsExpedited] [bit] NOT NULL,
	[TotalPrice]  AS (([Quantity]*[UnitPrice])*((1.0)-[Discount])),
 CONSTRAINT [PK_OrderTracking_OrderId] PRIMARY KEY CLUSTERED 
(
	[OrderId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [BobsData]
) ON [BobsData]
GO
/****** Object:  Table [Orders].[Stock]    Script Date: 2019-08-05 4:28:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Orders].[Stock](
	[StockID] [int] IDENTITY(1,1) NOT NULL,
	[StockSKU] [char](8) NOT NULL,
	[StockSize] [varchar](10) NOT NULL,
	[StockName] [varchar](100) NOT NULL,
	[StockPrice] [numeric](7, 2) NOT NULL,
 CONSTRAINT [PK_Stock_StockID] PRIMARY KEY CLUSTERED 
(
	[StockID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET IDENTITY_INSERT [Orders].[CityState] ON 

INSERT [Orders].[CityState] ([CityStateID], [CityStateCity], [CityStateProv], [CityStateCountry], [CityStatePostalCode]) VALUES (1, N'Golgafrincham', N'GuideShire', N'UK', N'1MSGGS')
INSERT [Orders].[CityState] ([CityStateID], [CityStateCity], [CityStateProv], [CityStateCountry], [CityStatePostalCode]) VALUES (2, N'Islington', N'Greater London', N'UK', N'42CSIGL')
SET IDENTITY_INSERT [Orders].[CityState] OFF
SET IDENTITY_INSERT [Orders].[Customers] ON 

INSERT [Orders].[Customers] ([CustID], [CustName], [CustStreet], [CityStateID], [SalutationID]) VALUES (1, N'Arthur Dent', N'1 Main St', 1, 1)
INSERT [Orders].[Customers] ([CustID], [CustName], [CustStreet], [CityStateID], [SalutationID]) VALUES (2, N'Trillian Astra', N'42 Cricket St.', 2, 2)
SET IDENTITY_INSERT [Orders].[Customers] OFF
SET IDENTITY_INSERT [Orders].[OrderItems] ON 

INSERT [Orders].[OrderItems] ([OrderItemID], [OrderID], [OrderYear], [StockID], [Quantity], [Discount]) VALUES (1, 1, 2019, 1, 26, CAST(20.00 AS Numeric(4, 2)))
INSERT [Orders].[OrderItems] ([OrderItemID], [OrderID], [OrderYear], [StockID], [Quantity], [Discount]) VALUES (2, 2, 2019, 3, 1, CAST(20.00 AS Numeric(4, 2)))
SET IDENTITY_INSERT [Orders].[OrderItems] OFF
SET IDENTITY_INSERT [Orders].[Orders] ON 

INSERT [Orders].[Orders] ([OrderID], [OrderYear], [OrderDate], [OrderRequestedDate], [OrderDeliveryDate], [CustID], [OrderIsExpedited]) VALUES (1, 2019, CAST(N'2019-03-01' AS Date), CAST(N'3000-01-01' AS Date), NULL, 1, 1)
INSERT [Orders].[Orders] ([OrderID], [OrderYear], [OrderDate], [OrderRequestedDate], [OrderDeliveryDate], [CustID], [OrderIsExpedited]) VALUES (2, 2019, CAST(N'2019-03-01' AS Date), CAST(N'2019-06-01' AS Date), NULL, 2, 0)
SET IDENTITY_INSERT [Orders].[Orders] OFF
SET IDENTITY_INSERT [Orders].[Orders2018] ON 

INSERT [Orders].[Orders2018] ([OrderID], [OrderYear], [OrderDate], [OrderRequestedDate], [OrderDeliveryDate], [CustID], [OrderIsExpedited]) VALUES (1, 2018, CAST(N'2018-03-01' AS Date), CAST(N'2018-04-01' AS Date), NULL, 1, 0)
INSERT [Orders].[Orders2018] ([OrderID], [OrderYear], [OrderDate], [OrderRequestedDate], [OrderDeliveryDate], [CustID], [OrderIsExpedited]) VALUES (2, 2018, CAST(N'2018-03-01' AS Date), CAST(N'2018-04-01' AS Date), NULL, 2, 0)
SET IDENTITY_INSERT [Orders].[Orders2018] OFF
SET IDENTITY_INSERT [Orders].[OrderTracking] ON 

INSERT [Orders].[OrderTracking] ([OrderId], [OrderDate], [RequestedDate], [DeliveryDate], [CustName], [CustAddress], [ShoeStyle], [ShoeSize], [SKU], [UnitPrice], [Quantity], [Discount], [IsExpedited]) VALUES (2, CAST(N'2019-03-01T00:00:00.0000000' AS DateTime2), CAST(N'2019-04-01T00:00:00.0000000' AS DateTime2), NULL, N'Arthur Dent', N'Magarathea', N'BabySneakers', N'3', N'BABYSHO1', CAST(20.00 AS Numeric(7, 2)), 1, CAST(0.00 AS Numeric(4, 2)), 0)
INSERT [Orders].[OrderTracking] ([OrderId], [OrderDate], [RequestedDate], [DeliveryDate], [CustName], [CustAddress], [ShoeStyle], [ShoeSize], [SKU], [UnitPrice], [Quantity], [Discount], [IsExpedited]) VALUES (3, CAST(N'2019-03-01T00:00:00.0000000' AS DateTime2), CAST(N'2019-04-01T00:00:00.0000000' AS DateTime2), NULL, N'Arthur Dent', N'Magarathea', N'Killer Heels', N'7', N'HEELS001', CAST(75.00 AS Numeric(7, 2)), 1, CAST(0.00 AS Numeric(4, 2)), 0)
INSERT [Orders].[OrderTracking] ([OrderId], [OrderDate], [RequestedDate], [DeliveryDate], [CustName], [CustAddress], [ShoeStyle], [ShoeSize], [SKU], [UnitPrice], [Quantity], [Discount], [IsExpedited]) VALUES (9, CAST(N'2019-03-15T00:00:00.0000000' AS DateTime2), CAST(N'2019-05-01T00:00:00.0000000' AS DateTime2), NULL, N'Arthur Dent', N'Golgafrincham', N'Slippers', N'3', N'SLIPPERS', CAST(20.00 AS Numeric(7, 2)), 1, CAST(0.00 AS Numeric(4, 2)), 0)
SET IDENTITY_INSERT [Orders].[OrderTracking] OFF
SET IDENTITY_INSERT [Orders].[Salutations] ON 

INSERT [Orders].[Salutations] ([SalutationID], [Salutation]) VALUES (2, N'Miss')
INSERT [Orders].[Salutations] ([SalutationID], [Salutation]) VALUES (1, N'Mr.')
INSERT [Orders].[Salutations] ([SalutationID], [Salutation]) VALUES (3, N'Mrs.')
SET IDENTITY_INSERT [Orders].[Salutations] OFF
SET IDENTITY_INSERT [Orders].[Stock] ON 

INSERT [Orders].[Stock] ([StockID], [StockSKU], [StockSize], [StockName], [StockPrice]) VALUES (1, N'OXFORD01', N'10_D', N'Oxford', CAST(50.00 AS Numeric(7, 2)))
INSERT [Orders].[Stock] ([StockID], [StockSKU], [StockSize], [StockName], [StockPrice]) VALUES (2, N'BABYSHO1', N'3', N'BabySneakers', CAST(20.00 AS Numeric(7, 2)))
INSERT [Orders].[Stock] ([StockID], [StockSKU], [StockSize], [StockName], [StockPrice]) VALUES (3, N'HEELS001', N'7', N'Killer Heels', CAST(75.00 AS Numeric(7, 2)))
SET IDENTITY_INSERT [Orders].[Stock] OFF
SET ANSI_PADDING ON
GO
/****** Object:  Index [UQ_CityState_Street_City_Country_PostalCode]    Script Date: 2019-08-05 4:28:07 PM ******/
ALTER TABLE [Orders].[CityState] ADD  CONSTRAINT [UQ_CityState_Street_City_Country_PostalCode] UNIQUE NONCLUSTERED 
(
	[CityStateCity] ASC,
	[CityStateProv] ASC,
	[CityStateCountry] ASC,
	[CityStatePostalCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [UQ_Salutations_Salutation]    Script Date: 2019-08-05 4:28:07 PM ******/
ALTER TABLE [Orders].[Salutations] ADD  CONSTRAINT [UQ_Salutations_Salutation] UNIQUE NONCLUSTERED 
(
	[Salutation] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [UQ_Stock_StockSKU_StockSize]    Script Date: 2019-08-05 4:28:07 PM ******/
ALTER TABLE [Orders].[Stock] ADD  CONSTRAINT [UQ_Stock_StockSKU_StockSize] UNIQUE NONCLUSTERED 
(
	[StockSKU] ASC,
	[StockSize] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
ALTER TABLE [Orders].[OrderItems] ADD  CONSTRAINT [DF_OrderItems_Quantity_1]  DEFAULT ((1)) FOR [Quantity]
GO
ALTER TABLE [Orders].[Orders] ADD  CONSTRAINT [DF_Orders_OrderIsExpedited_False]  DEFAULT ((0)) FOR [OrderIsExpedited]
GO
ALTER TABLE [Orders].[Orders2018] ADD  CONSTRAINT [DF_Orders2018_OrderIsExpedited_False]  DEFAULT ((0)) FOR [OrderIsExpedited]
GO
ALTER TABLE [Orders].[Customers]  WITH CHECK ADD  CONSTRAINT [FK_Customers_CityStateID_CityState_CityStateID] FOREIGN KEY([CityStateID])
REFERENCES [Orders].[CityState] ([CityStateID])
GO
ALTER TABLE [Orders].[Customers] CHECK CONSTRAINT [FK_Customers_CityStateID_CityState_CityStateID]
GO
ALTER TABLE [Orders].[Customers]  WITH CHECK ADD  CONSTRAINT [FK_Customers_SaluationID_Salutations_SalutationID] FOREIGN KEY([SalutationID])
REFERENCES [Orders].[Salutations] ([SalutationID])
GO
ALTER TABLE [Orders].[Customers] CHECK CONSTRAINT [FK_Customers_SaluationID_Salutations_SalutationID]
GO
ALTER TABLE [Orders].[OrderItems]  WITH CHECK ADD  CONSTRAINT [FK_OrderItems_OrderYear_OrderId_Orders] FOREIGN KEY([OrderYear], [OrderID])
REFERENCES [Orders].[Orders] ([OrderYear], [OrderID])
GO
ALTER TABLE [Orders].[OrderItems] CHECK CONSTRAINT [FK_OrderItems_OrderYear_OrderId_Orders]
GO
ALTER TABLE [Orders].[OrderItems]  WITH CHECK ADD  CONSTRAINT [FK_OrderItems_StockID_Stock_StockID] FOREIGN KEY([StockID])
REFERENCES [Orders].[Stock] ([StockID])
GO
ALTER TABLE [Orders].[OrderItems] CHECK CONSTRAINT [FK_OrderItems_StockID_Stock_StockID]
GO
ALTER TABLE [Orders].[Orders]  WITH CHECK ADD  CONSTRAINT [FK_Orders_CustID_Customers_CustID] FOREIGN KEY([CustID])
REFERENCES [Orders].[Customers] ([CustID])
GO
ALTER TABLE [Orders].[Orders] CHECK CONSTRAINT [FK_Orders_CustID_Customers_CustID]
GO
ALTER TABLE [Orders].[Orders2018]  WITH CHECK ADD  CONSTRAINT [FK_Orders2018_CustID_Customers_CustID] FOREIGN KEY([CustID])
REFERENCES [Orders].[Customers] ([CustID])
GO
ALTER TABLE [Orders].[Orders2018] CHECK CONSTRAINT [FK_Orders2018_CustID_Customers_CustID]
GO
ALTER TABLE [Orders].[CityState]  WITH CHECK ADD  CONSTRAINT [CK_CityState_Address_cannot_be_blank] CHECK  ((concat([CityStateCity],[CityStateProv],[CityStateCountry],[CityStatePostalCode])<>''))
GO
ALTER TABLE [Orders].[CityState] CHECK CONSTRAINT [CK_CityState_Address_cannot_be_blank]
GO
ALTER TABLE [Orders].[Customers]  WITH CHECK ADD  CONSTRAINT [CK_Customers_CustomerName_cannot_be_blank] CHECK  (([CustName]<>''))
GO
ALTER TABLE [Orders].[Customers] CHECK CONSTRAINT [CK_Customers_CustomerName_cannot_be_blank]
GO
ALTER TABLE [Orders].[OrderItems]  WITH CHECK ADD  CONSTRAINT [CK_OrderItems_Discount_GE_zero] CHECK  (([Discount]>=(0.0)))
GO
ALTER TABLE [Orders].[OrderItems] CHECK CONSTRAINT [CK_OrderItems_Discount_GE_zero]
GO
ALTER TABLE [Orders].[OrderItems]  WITH CHECK ADD  CONSTRAINT [CK_OrderItems_Quantity_GT_zero] CHECK  (([Quantity]>(0)))
GO
ALTER TABLE [Orders].[OrderItems] CHECK CONSTRAINT [CK_OrderItems_Quantity_GT_zero]
GO
ALTER TABLE [Orders].[Orders]  WITH CHECK ADD  CONSTRAINT [CK_Orders_Current] CHECK  (([OrderYear]>=(2019) AND [OrderYear]<(2020)))
GO
ALTER TABLE [Orders].[Orders] CHECK CONSTRAINT [CK_Orders_Current]
GO
ALTER TABLE [Orders].[Orders]  WITH CHECK ADD  CONSTRAINT [CK_Orders_DeliveryDate_GE_OrderDate] CHECK  (([OrderDeliveryDate]>=[OrderDate]))
GO
ALTER TABLE [Orders].[Orders] CHECK CONSTRAINT [CK_Orders_DeliveryDate_GE_OrderDate]
GO
ALTER TABLE [Orders].[Orders]  WITH CHECK ADD  CONSTRAINT [CK_Orders_RequestedDate_GE_OrderDate] CHECK  (([OrderRequestedDate]>=[OrderDate]))
GO
ALTER TABLE [Orders].[Orders] CHECK CONSTRAINT [CK_Orders_RequestedDate_GE_OrderDate]
GO
ALTER TABLE [Orders].[Orders2018]  WITH CHECK ADD  CONSTRAINT [CK_Orders2018_Current] CHECK  (([OrderYear]>=(2018) AND [OrderYear]<(2019)))
GO
ALTER TABLE [Orders].[Orders2018] CHECK CONSTRAINT [CK_Orders2018_Current]
GO
ALTER TABLE [Orders].[Orders2018]  WITH CHECK ADD  CONSTRAINT [CK_Orders2018_DeliveryDate_GE_OrderDate] CHECK  (([OrderDeliveryDate]>=[OrderDate]))
GO
ALTER TABLE [Orders].[Orders2018] CHECK CONSTRAINT [CK_Orders2018_DeliveryDate_GE_OrderDate]
GO
ALTER TABLE [Orders].[Orders2018]  WITH CHECK ADD  CONSTRAINT [CK_Orders2018_RequestedDate_GE_OrderDate] CHECK  (([OrderRequestedDate]>=[OrderDate]))
GO
ALTER TABLE [Orders].[Orders2018] CHECK CONSTRAINT [CK_Orders2018_RequestedDate_GE_OrderDate]
GO
ALTER TABLE [Orders].[Salutations]  WITH CHECK ADD  CONSTRAINT [CK_Salutations_Salutation_cannot_be_blank] CHECK  (([Salutation]<>''))
GO
ALTER TABLE [Orders].[Salutations] CHECK CONSTRAINT [CK_Salutations_Salutation_cannot_be_blank]
GO
ALTER TABLE [Orders].[Stock]  WITH CHECK ADD  CONSTRAINT [CK_Stock_item_cannot_be_blank] CHECK  ((concat([StockSKU],[StockSize],[StockName])<>''))
GO
ALTER TABLE [Orders].[Stock] CHECK CONSTRAINT [CK_Stock_item_cannot_be_blank]
GO
ALTER TABLE [Orders].[Stock]  WITH CHECK ADD  CONSTRAINT [CK_Stock_Price_GT_zero] CHECK  (([StockPrice]>(0)))
GO
ALTER TABLE [Orders].[Stock] CHECK CONSTRAINT [CK_Stock_Price_GT_zero]
GO
USE [master]
GO
ALTER DATABASE [RHJsShoes] SET  READ_WRITE 
GO
