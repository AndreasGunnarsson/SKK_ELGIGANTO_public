
----------------------------------------------------- Drop FK:s, drop tables, sequence and all stored procedures:
ALTER TABLE [Order] DROP CONSTRAINT FK_Order_Costumer;
ALTER TABLE [Order] DROP CONSTRAINT FK_Order_Product;
ALTER TABLE Storage DROP CONSTRAINT FK_Storage_Product;
ALTER TABLE Product DROP CONSTRAINT FK_Product_Category;

DROP TABLE Cart;
DROP TABLE StorageTransaction;
DROP TABLE TransactionReason;
DROP TABLE Costumer;
DROP TABLE Category;
DROP TABLE [Order];
DROP TABLE Storage;
DROP TABLE Product;

DROP SEQUENCE OrderSequence;

DROP PROC CreateNewCostumer;
DROP PROC UpdateCostumer;
DROP PROC ListProducts;
DROP PROC SearchProduct;
DROP PROC UpdatePopularity;
DROP PROC ProductDetail;
DROP PROC AddToCart;
DROP PROC ListCartContent;
DROP PROC CheckoutCart;
DROP PROC NewTransaction;
DROP PROC DeliverOrder;
DROP PROC ViewOrder;
DROP PROC UpdateOrder;
DROP PROC StorageAdjustment;
DROP PROC PopularityReport;
DROP PROC ReturnReport;
DROP PROC CategoryReport;

----------------------------------------------------- SELECT for all tables:
SELECT * FROM Category;
SELECT * FROM Product;
SELECT * FROM Costumer;
SELECT * FROM Cart;
SELECT * FROM [Order];
SELECT * FROM Storage;
SELECT * FROM StorageTransaction;
SELECT * FROM TransactionReason;

----------------------------------------------------- EXEC for all stored procedures:
EXEC CreateNewCostumer @UserName = 'Turtle', @Email = 'turtle1@tmntmail.com', @Address = 'Kloak 4';
	-- Skapar en ny användare.
	-- Kräver att alla argument är ifyllda.
EXEC UpdateCostumer @SelectedCostumerId = 2, @UpdatedName = 'Ninja', @UpdatedEmail = 'ninjaman@mail.com', @UpdatedAddress = 'Skuggatan 33F', @DeleteAccount = 0;
	-- Uppdaterar informationen för en kund.
	-- Det enda som krävs är att @SelectedCostumerId innehåller ett Id från Costumer.Id. Rekommenderat att man fyller i minst en av Update-argumenten annars händer inget.
	-- @DeleteAccount är default 0, om det sätts till 1 tas kontot bort.
EXEC ListProducts @SelectedCategoryId = 2, @RowsToSkip = 0, @RowsAmountToReturn = 5;
	-- Listar produkter. Listan är sorterad efter produktens popularitet.
	-- @SelectedCategoryId kräver ett Product.CategoryId (mellan 1 och 3).
	-- @RowsToSkip och @RowsAmountToReturn har med pagination att göra.
EXEC SearchProduct @SearchString = 'best', @CategoryId = 2, @IsAvailable = 1, @SortColumn = 1, @SortOrder = 1, @RowsToSkip = 0, @RowsAmountToReturn = 5;
	-- Söker efter en specikfik vara.
	-- @SearchString är den textsträng man vill söka efter (söker i Product.[Name]).
	-- @CategoryId är den kategori man vill söka i (1, 2 och 3 finns). NULL = alla kategorier.
	-- @IsAvailabel tar endast med de produkter som finns i lager om den är satt till 1. 0 = tar med allt.
	-- @SortColumn 0 = Popularity, 2 = Price, 3 = Name.
	-- @SortOrder 0 = ASC, 1 = DESC.
	-- @RowsToSkip och @RowsAmountToReturn fyller samma funktion som i ListProducts-SP:n.
	-- Man behöver inte använda några argument när man kallar på SearchProduct men rekommenderat är att iaf fylla i @SearchString.
EXEC ProductDetail @SelectedProductId = 11;
	-- Visar detaljer för en specifik vara. Lägger till 1 poäng i Product.PopularityScore.
	-- Kräver att man fyller i ett Product.Id.
EXEC AddToCart @CurrentUserId = 1, @ProductId = 4, @ProductAmount = 5;
	-- Lägger till eller tar bort en vara från varukorgen. Lägger till/tar bort 5 poäng (Product.PopularityScore) per vara.
	-- Kräver att alla argument är ifyllda.
	-- @ProductAmount kan vara ett negativt värde.
	-- @ProductId kan ta olika varor för samma @CurrentUserId.
EXEC ListCartContent @CurrentUserId = 1;
	-- Används av kund för att lista innehållet i varukorgen.
	-- Kräver att @CurrentUserId är ifyllt med ett Id från Cart.CostumerId.
EXEC CheckoutCart @CurrentUserId = 1;
	-- Används av kund för att checka ut en varukorg. Skapar ett unikt Ordernumber och OrderId i [Order]. Lägger till 10 (Product.PopularityScore) poäng per vara.
	-- Kräver att @CurrentUserId är ifyllt med ett Id från Cart.CostumerId.
EXEC DeliverOrder @SelectedOrderId = 1;
	-- Används av personal efter packad order för att uppdatera lagersaldo och ändra status till "Delivered" på en order. Skapar också en StorageTransaction.
	-- Kräver att @SelectedOrderId är ifyllt med ett OrderId från [Order].
EXEC ViewOrder @SelectedOrderId = 1;
	-- För att kund ska kunna se vad kunden beställt och ifall ordern är levererad eller ej.
	-- Kräver att @SelectedOrderId är ifyllt med ett OrderId från [Order].
EXEC UpdateOrder @SelectedOrderId = 1, @SelectedProductId = 4, @ReturnAmount = 1;
	-- Används av kund för att returnera varor. Ordern måste vara levererad ([Order].Delivered = 1). Skapar också en StorageTransaction.
	-- Kräver att alla argument är ifyllda.
EXEC StorageAdjustment @ProductId = 2, @NewAmount = -2, @IsIncDec = 1;
	-- Används av personal för att ändra lagersaldo. Skapar också en StorageTransaction.
	-- Kräver ett @ProductId och ett @NewAmount.
	-- @IsIncDec kommer att göra en increment/decrement (beroende på ifall @NewAmount är positivt eller negativt). @IsIncDec 0 gör så att värdet i @NewAmount sätts till detta värde direkt.
EXEC PopularityReport @CategoryId = 2, @ShowTop = 5;
	-- Rappport som visar de populäraste produkterna.
	-- @CategoryId kan vara NULL (default), 1, 2 eller 3. NULL tar med alla kategorier (lågt värde på @ShowTop limitera resultat i detta fall).
	-- @ShowTop tar endast med de översta # raderna.
EXEC ReturnReport @CategoryId = 3, @OrderBy = 1, @ShowTop = 5;
	-- Rapport som visar antalet returer för en viss kategori.
	-- Ifall @CategoryId är NULL så tas alla kategorier med. Kan annars vara ett värde mellan 1 och 3.
	-- @OrderBy sorterar antingen efter antalet returer (0) eller den totala kostnaden för alla returer (1).
	-- @ShowTop fyller samma funtion som i PopularityReport.
EXEC CategoryReport @StartDate = '2021-01-01 12:00:00.000000', @EndDate = '2021-01-02 12:00:00.000000';
	-- Rapport som visar försäljning och returer för alla kategorier inom ett visst datum.
	-- Notis: Den testdata som finns fungerar inte för att göra någon vettig rapport då alla transactions är skapade vid samma tidpunkt. Kräver StorageTransactions med ReasonId 1 (Delivery) och 2 (Return).
	-- @StartDate är datumet man vill börja att kolla ifrån och @EndDate slutdatumet. Default-värden är 24 timmar bakåt för @StartDate och nuvarande tid för @EndDate.

----------------------------------------------------- Create tables:
CREATE TABLE Category
(
	Id int PRIMARY KEY IDENTITY(1,1),
	[Name] varchar (50) NOT NULL UNIQUE
);
CREATE TABLE Product
(
	Id int PRIMARY KEY IDENTITY(1,1),
	PopularityScore int NOT NULL DEFAULT 0,
	CategoryId int NOT NULL,
	[Name] varchar(50) NOT NULL,
	Price decimal(5,2) NOT NULL CONSTRAINT CHK_Product_Price CHECK (Price > 0)		-- Använd "decimal" istället för "float" när det handlar om pengar. Kan bli fula avrundningar annars.
);
CREATE TABLE Costumer
(
	Id int PRIMARY KEY IDENTITY(1,1),
	[Name] varchar(50) NOT NULL,
	Mail varchar(50) NOT NULL UNIQUE,
	[Address] varchar(50) NOT NULL
);
CREATE TABLE Cart
(
	Id int PRIMARY KEY IDENTITY(1,1),
	CostumerId int NOT NULL,
	ProductId int NOT NULL,
	Amount int NOT NULL DEFAULT 1 CONSTRAINT CHK_Cart_Amount CHECK (Amount >= 0)
);
CREATE TABLE [Order]
(
	Id int PRIMARY KEY IDENTITY(1,1),
	OrderId int NOT NULL,
	Ordernumber int NOT NULL,
	ProductId int NOT NULL,
	CostumerId int NOT NULL,
	Amount int NOT NULL,
	Delivered bit NOT NULL DEFAULT 0,
);
CREATE TABLE Storage
(
	Id int PRIMARY KEY IDENTITY(1,1),
	ProductId int NOT NULL UNIQUE,
	Amount int NOT NULL
);
CREATE TABLE StorageTransaction
(
	Id int PRIMARY KEY IDENTITY(1,1),
	ProductId int NOT NULL,
	[Time] datetime2 DEFAULT SYSDATETIME(),
	Amount int NOT NULL,
	ReasonId int NOT NULL
);
CREATE TABLE TransactionReason
(
	Id int PRIMARY KEY IDENTITY(1,1),
	Reason varchar(50) NOT NULL UNIQUE
);

----------------------------------------------------- Add foreign key constraints:
ALTER TABLE Product ADD CONSTRAINT FK_Product_Category FOREIGN KEY (CategoryId) REFERENCES Category(Id);
ALTER TABLE [Order] ADD CONSTRAINT FK_Order_Product FOREIGN KEY (ProductId) REFERENCES Product(Id);
ALTER TABLE [Order] ADD CONSTRAINT FK_Order_Costumer FOREIGN KEY (CostumerId) REFERENCES Costumer(Id);
ALTER TABLE Cart ADD CONSTRAINT FK_Cart_Costumer FOREIGN KEY (CostumerId) REFERENCES Costumer(Id);
ALTER TABLE Cart ADD CONSTRAINT FK_Cart_Product FOREIGN KEY (ProductId) REFERENCES Product(Id);
ALTER TABLE Storage ADD CONSTRAINT FK_Storage_Product FOREIGN KEY (ProductId) REFERENCES Product(Id);
ALTER TABLE StorageTransaction ADD CONSTRAINT FK_StorageTrasaction_Product FOREIGN KEY (ProductId) REFERENCES Product(Id);
ALTER TABLE StorageTransaction ADD CONSTRAINT FK_StorageTransaction_Reason FOREIGN KEY (ReasonId) REFERENCES TransactionReason(Id);

----------------------------------------------------- Create non clustered indexes for all FK columns:
CREATE NONCLUSTERED INDEX IX_Product_CategoryId ON Product(CategoryId);
CREATE NONCLUSTERED INDEX IX_Order_ProductId ON [Order](ProductId);
CREATE NONCLUSTERED INDEX IX_Order_CostumerId ON [Order](CostumerId);
CREATE NONCLUSTERED INDEX IX_Cart_CostumerId ON Cart(CostumerId);
CREATE NONCLUSTERED INDEX IX_Cart_ProductId ON Cart(ProductId);
CREATE NONCLUSTERED INDEX IX_Storage_ProductId ON Storage(ProductId);
CREATE NONCLUSTERED INDEX IX_StorageTransaction_ProductId ON StorageTransaction(ProductId);
CREATE NONCLUSTERED INDEX IX_StorageTransaction_ReasonId ON StorageTransaction(ReasonId);

----------------------------------------------------- Insert Test data:
INSERT INTO Category ([Name]) VALUES ('GPU'), ('CPU'), ('RAM');
INSERT INTO TransactionReason (Reason) VALUES ('Delivery'), ('Return'), ('Stock adjustment');
INSERT INTO Product (CategoryId, PopularityScore, [Name], Price) VALUES (1, 10, 'Voodoo 2', 399.99), (1, 20, 'GeForce', 449.99), (1, 15, 'Radeon', 349.99), (1, 5, 'Bobby-graphic', 49.99), (1, 3, 'Greger graphics', 99.99), (1, 1000, 'Best grapics card - AWESOME edition', 999.99), (1, 3, 'Probably best grapics - probable edition', 599.99);
INSERT INTO Product (CategoryId, PopularityScore, [Name], Price) VALUES (2, 35, 'Intel 300 MHz', 599.99), (2, 40, 'AMD 100 MHz', 299.99), (2, 30, 'Intel 333 MHz', 699.99), (2, 4, 'Bobby-Central possessing unit', 29.99), (2, 2, 'Greger CPU', 199.99), (2, 900, 'Best CPU - BEAST EDITION', 999.99), (2, 20, 'Probably best CPU - medium rare edition', 699.99);
INSERT INTO Product (CategoryId, PopularityScore, [Name], Price) VALUES (3, 100, 'Noname 128 MB', 49.99), (3, 200, 'Intel 512 MB', 199.99), (3, 150, 'MyMemory 1024 MB', 249.99), (3, 20, 'Bobby-b-Good memory 384 MB', 249.99), (3, 10, 'Greger Memory 1024 MB', 149.99), (3, 899, 'Best memory - UNLIMITED MB EDITION', 599.99), (3, 12, 'Probably best memeory - saurkraut edition', 299.99);
INSERT INTO StorageTransaction (ProductId, Amount, ReasonId) VALUES
	(1, 10, 3), (2, 20, 3), (3, 50, 3), (4, 60, 3), (5, 70, 3), (6, 100, 3), (7, 110, 3), (8, 120, 3), (9, 100, 3), (10, 50, 3), (11, 100, 3), (12, 30, 3), (13, 210, 3), (14, 90, 3), (15, 80, 3), (16, 50, 3), (17, 40, 3), (18, 30, 3), (19, 20, 3), (20, 60, 3), (21, 70, 3),	-- Stock adjustment.
	(1, -2, 1), (1, -1, 1), (2, -3, 1), (3, -1, 1), (2, -1, 1), (4, -10, 1), (5, -10, 1), (6, -90, 1), (8, -2, 1), (9, -3, 1), (10, -2, 1), (11, -100, 1), (12, -12, 1), (13, -200, 1), (15, -2, 1), (16, -3, 1), (17, -1, 1), (18, -15, 1), (19, -4, 1), (20, -59, 1),		-- Delivery.
	(4, 6, 2), (4, 2, 2), (4, 2, 2), (5, 5, 2), (11, 68, 2), (11, 16, 2), (11, 16, 2), (12, 6, 2), (18, 8, 2), (18, 5, 2), (18, 2, 2), (19, 2, 2);		-- Return.
INSERT INTO Storage (ProductId, Amount) VALUES
	(1, 7), (2, 16), (3, 49), (4, 50), (5, 65), (6, 10), (7, 110),				-- GPU.
	(8, 118), (9, 97), (10, 48), (11, 0), (12, 24), (13, 10), (14, 90),			-- CPU.
	(15, 78), (16, 47), (17, 39), (18, 15), (19, 18), (20, 1), (21, 70);		-- RAM.
INSERT INTO Costumer ([Name], Mail, [Address]) VALUES ('Boris', 'boris@mail.com', 'Borisgatan 2B');
INSERT INTO Costumer ([Name], Mail, [Address]) VALUES ('Greger', 'greger@mail.com', 'Gregervägen 3C');
INSERT INTO Costumer ([Name], Mail, [Address]) VALUES ('Klabbe', 'klabbe@klabbmail.com', 'Bollvägen 12A');
GO

----------------------------------------------------- CreateNewCostumer SP:
CREATE OR ALTER PROCEDURE CreateNewCostumer
@UserName varchar(50),
@Email varchar(50),
@Address varchar(50)
AS
BEGIN
	INSERT INTO Costumer ([Name], Mail, [Address])
	VALUES (@UserName, @Email, @Address);
END
GO

----------------------------------------------------- UpdateCostumer SP:
CREATE OR ALTER PROCEDURE UpdateCostumer
@SelectedCostumerId int,
@UpdatedName varchar(50) = NULL,
@UpdatedEmail varchar(50) = NULL,
@UpdatedAddress varchar(50) = NULL,
@DeleteAccount bit = 0					-- 0 = UPDATE the costumer data. 1 = deletes the costumer.
AS
BEGIN
	IF @DeleteAccount = 0
	BEGIN
		UPDATE Costumer SET
			Costumer.[Name] = ISNULL(@UpdatedName, (SELECT [Name] FROM Costumer WHERE Costumer.Id = @SelectedCostumerId)),
			Costumer.Mail = ISNULL(@UpdatedEmail, (SELECT Mail FROM Costumer WHERE Costumer.Id = @SelectedCostumerId)),
			Costumer.[Address] = ISNULL(@UpdatedAddress, (SELECT [Address] FROM Costumer WHERE Costumer.Id = @SelectedCostumerId))
		WHERE Costumer.Id = @SelectedCostumerId
	END
	ELSE IF @DeleteAccount = 1 AND @SelectedCostumerId IS NOT NULL
		DELETE FROM Costumer WHERE Costumer.Id = @SelectedCostumerId
END
GO

----------------------------------------------------- ListProducts SP:
CREATE OR ALTER PROCEDURE ListProducts
@SelectedCategoryId int,
@RowsToSkip int = 0,						-- Pagination. Will skip the first # rows. Default 0.
@RowsAmountToReturn int = 5					-- Pagination. Will return the # of rows. Default 5.
AS
BEGIN
	SELECT Product.Id AS ProductId, [Name] AS ProductName, Price
	FROM Product
	WHERE CategoryId = @SelectedCategoryId
	ORDER BY PopularityScore DESC
	OFFSET @RowsToSkip ROWS FETCH NEXT @RowsAmountToReturn ROWS ONLY;		-- Pagination. OFFSET = The number of rows to skip. FETCH = The amount of rows after the OFFSET that's returned.
END
GO

----------------------------------------------------- SearchProduct SP:
CREATE OR ALTER PROCEDURE SearchProduct
@SearchString varchar(50) = '',		-- Empty string = all Products.
@CategoryId int = NULL,				-- NULL = All categories.
@IsAvailable bit = 0,				-- 0 = Shows Product even if there are none in Stock. 1 = The Product need to be at Stock.Amount > 0.
@SortColumn int = 0,				-- 0 = Popularity, 2 = Price, 3 = Name.
@SortOrder bit = 0,					-- 0 = ASC, 1 = DESC.
@RowsToSkip int = 0,				-- Pagination. Will skip the first # rows. Default 0.
@RowsAmountToReturn int = 5					-- Pagination. Will return the # of rows. Default 5.
AS
BEGIN
	SELECT Product.Id AS ProductId, Product.[Name] AS ProductName, Product.Price
	FROM Product
	INNER JOIN Storage ON Storage.ProductId = Product.Id
	WHERE
		[Name] LIKE '%' + @SearchString + '%'
		AND (@IsAvailable = 0 OR (@IsAvailable = 1 AND Storage.Amount > 0))		-- Antingen måste @IsAvailable vara 0 OR så måste @IsAvailable vara 1 AND Storage.Amount > 0.
		AND (@CategoryId IS NULL OR (@CategoryId = Product.CategoryId))
	ORDER BY
		CASE WHEN @SortOrder = 1 AND @SortColumn = 0 THEN Product.PopularityScore END DESC,
		CASE WHEN @SortOrder = 1 AND @SortColumn = 1 THEN Product.Price END DESC,
		CASE WHEN @SortOrder = 1 AND @SortColumn = 2 THEN Product.[Name] END DESC,
		CASE WHEN @SortOrder = 0 AND @SortColumn = 0 THEN Product.PopularityScore END, 
		CASE WHEN @SortOrder = 0 AND @SortColumn = 1 THEN Product.Price END,
		CASE WHEN @SortOrder = 0 AND @SortColumn = 2 THEN Product.[Name] END
	OFFSET @RowsToSkip ROWS FETCH NEXT @RowsAmountToReturn ROWS ONLY;
END
GO

----------------------------------------------------- UpdatePopularity SP:
CREATE OR ALTER PROCEDURE UpdatePopularity
@ProductId int,
@AddedScore int,							-- The score can be different dependant on where it's added. Must be a positive number.
@ProductAmountMultiplier int = 1			-- The amount of products affected. Can be a negative number.
AS
BEGIN
	IF @AddedScore IS NOT NULL AND @AddedScore >= 0 AND @ProductId IS NOT NULL
		UPDATE Product
		SET Product.PopularityScore += (@AddedScore * @ProductAmountMultiplier)
		WHERE Product.Id = @ProductId;
END
GO

----------------------------------------------------- ProductDetail SP:
CREATE OR ALTER PROCEDURE ProductDetail
@SelectedProductId int
AS
BEGIN
	SELECT Product.Id, Category.[Name] AS Category, Product.[Name] AS ProductName, Product.Price, Storage.Amount AS StockAmount FROM Product
	INNER JOIN Storage ON Storage.ProductId = Product.Id
	INNER JOIN Category ON Category.Id = Product.CategoryId
	WHERE Product.Id = @SelectedProductId;
	EXEC UpdatePopularity @ProductId = @SelectedProductId, @AddedScore = 1;
END
GO

----------------------------------------------------- AddToCart SP:
CREATE OR ALTER PROCEDURE AddToCart
@CurrentUserId int,
@ProductId int,
@ProductAmount int
AS
BEGIN
	IF @CurrentUserId IS NOT NULL AND @ProductId IS NOT NULL AND @ProductAmount IS NOT NULL
	BEGIN
		IF @ProductId NOT IN (SELECT ProductId FROM Cart WHERE Cart.CostumerId = @CurrentUserId) OR @CurrentUserId NOT IN (SELECT CostumerId FROM Cart WHERE Cart.CostumerId = @CurrentUserId)		-- We have to use IN instead of = because when = is used the subquery (SELECT) is expected to return only one row.
		BEGIN
			INSERT INTO Cart (CostumerId, ProductId, Amount) VALUES (@CurrentUserId, @ProductId, @ProductAmount);
			EXEC UpdatePopularity @ProductId = @ProductId, @AddedScore = 5, @ProductAmountMultiplier = @ProductAmount;
		END
		ELSE IF (SELECT Amount + @ProductAmount FROM Cart WHERE Cart.ProductId = @ProductId AND Cart.CostumerId = @CurrentUserId) = 0
		BEGIN
			DELETE FROM Cart WHERE Cart.ProductId = @ProductId AND Cart.CostumerId = @CurrentUserId;
			EXEC UpdatePopularity @ProductId = @ProductId, @AddedScore = 5, @ProductAmountMultiplier = @ProductAmount;
		END
		ELSE IF @ProductId IN (SELECT ProductId FROM Cart WHERE Cart.CostumerId = @CurrentUserId) AND (SELECT Amount + @ProductAmount FROM Cart WHERE Cart.ProductId = @ProductId AND Cart.CostumerId = @CurrentUserId) > 0
		BEGIN
			UPDATE Cart SET Cart.Amount += @ProductAmount WHERE Cart.ProductId = @ProductId AND Cart.CostumerId = @CurrentUserId;
			EXEC UpdatePopularity @ProductId = @ProductId, @AddedScore = 5, @ProductAmountMultiplier = @ProductAmount;
		END
	END
END
GO

----------------------------------------------------- ListCartContent SP:
CREATE OR ALTER PROCEDURE ListCartContent
@CurrentUserId int
AS
BEGIN
	SELECT Product.Id, Product.[Name], Product.Price AS PrinceSingleUnit, Cart.Amount, Product.Price * Cart.Amount AS TotalPriceRow, SUM(Product.Price * Cart.Amount) OVER() AS TotalPrice
		FROM Cart
		INNER JOIN Product ON Product.Id = Cart.ProductId
		WHERE Cart.CostumerId = @CurrentUserId;
END
GO

----------------------------------------------------- CheckoutCart SP:
CREATE SEQUENCE OrderSequence
	START WITH 1
	INCREMENT BY 1;
GO

CREATE OR ALTER PROCEDURE CheckoutCart
@CurrentUserId int
AS
BEGIN
	IF @CurrentUserId IN (SELECT CostumerId FROM Cart WHERE CostumerId = @CurrentUserId)
	BEGIN
		DECLARE @OrderIdSequence int = NEXT VALUE FOR OrderSequence;
		DECLARE @RandomOrdernumber int = CAST(RAND() * 100000000 + @CurrentUserId AS int);

		INSERT INTO [Order] (OrderId, CostumerId, ProductId, Ordernumber, Amount)
			SELECT @OrderIdSequence, CostumerId, ProductId, @RandomOrdernumber, Amount
			FROM Cart
			WHERE Cart.CostumerId = @CurrentUserId;

		DELETE FROM Cart
			WHERE Cart.CostumerId = @CurrentUserId;

		DECLARE @LoopCounter int = 1;

		CREATE TABLE #temptable
			(Id int PRIMARY KEY IDENTITY(1,1), ProductId int NOT NULL, Amount int NOT NULL);

		INSERT INTO #temptable (ProductId, Amount)
			SELECT [Order].ProductId, [Order].Amount
			FROM [Order]
			WHERE [Order].OrderId = @OrderIdSequence;

		WHILE @LoopCounter <= (SELECT COUNT(Id) FROM #temptable)
		BEGIN
			DECLARE @Product int = (SELECT ProductId FROM #temptable WHERE Id = @LoopCounter);
			DECLARE @Amount int = (SELECT Amount FROM #temptable WHERE Id = @LoopCounter);
			EXEC UpdatePopularity @ProductId = @Product, @AddedScore = 10, @ProductAmountMultiplier = @Amount;
			SET @LoopCounter += 1;
		END
	END
END
GO

----------------------------------------------------- NewTransaction SP:
CREATE OR ALTER PROCEDURE NewTransaction
@TransactionReason int,				-- 1 = Delivery, 2 = Return, 3 = Stock adjustment
@SelectedOrderId int = NULL,
@ProductId int = NULL,
@Amount int = NULL
AS
BEGIN
	IF @TransactionReason = 1 AND @SelectedOrderId IS NOT NULL
	BEGIN
		INSERT INTO StorageTransaction (ProductId, Amount, ReasonId)
			SELECT ProductId, (Amount * -1), 1
			FROM [Order]
			WHERE [Order].OrderId = @SelectedOrderId;
	END
	ELSE IF @TransactionReason = 2 AND @SelectedOrderId IS NOT NULL AND @ProductId IS NOT NULL AND @Amount > 0 
	BEGIN
		INSERT INTO StorageTransaction (ProductId, Amount, ReasonId)
			SELECT ProductId, @Amount, 2
			FROM [Order]
			WHERE [Order].OrderId = @SelectedOrderId AND [Order].ProductId = @ProductId;
	END
	ELSE IF @TransactionReason = 3 AND @ProductId IS NOT NULL AND @Amount IS NOT NULL
	BEGIN
		INSERT INTO StorageTransaction (ProductId, Amount, ReasonId)
		VALUES (@ProductId, @Amount, 3);
	END
END
GO

----------------------------------------------------- DeliverOrder SP:
CREATE OR ALTER PROCEDURE DeliverOrder
@SelectedOrderId int
AS
BEGIN
	IF 0 IN (SELECT [Order].Delivered FROM [Order] WHERE [Order].OrderId = @SelectedOrderId)
	BEGIN
		UPDATE [Order] SET [Order].Delivered = 1
			WHERE [Order].OrderId = @SelectedOrderId;

		EXEC NewTransaction @TransactionReason = 1, @SelectedOrderId = @SelectedOrderId;

		DECLARE @LoopCounter int = 1;
		
		CREATE TABLE #temptable2
			(Id int PRIMARY KEY IDENTITY(1,1), ProductId int NOT NULL, Amount int NOT NULL);

		INSERT INTO #temptable2 (ProductId, Amount)
			SELECT [Order].ProductId, [Order].Amount
			FROM [Order]
			WHERE [Order].OrderId = @SelectedOrderId;

		WHILE @LoopCounter <= (SELECT COUNT(Id) FROM #temptable2)
		BEGIN
			UPDATE Storage SET Storage.Amount -=
			(
				SELECT #temptable2.Amount
					FROM #temptable2
					WHERE #temptable2.Id = @LoopCounter
			)
			WHERE Storage.ProductId =
			(
				SELECT #temptable2.ProductId
					FROM #temptable2
					WHERE #temptable2.Id = @LoopCounter
			)
			SET @LoopCounter += 1;
		END
	END
END
GO

----------------------------------------------------- ViewOrder SP:
CREATE OR ALTER PROCEDURE ViewOrder
@SelectedOrderId int
AS
BEGIN
	SELECT
		Ordernumber,
		ProductId,
		Product.[Name] AS ProductName,
		Amount AS AmountOrdered,
		DeliveryStatus =
		CASE Delivered
			WHEN 0 THEN 'Not delivered'
			WHEN 1 THEN 'Delivered'
		END
	FROM [Order]
	INNER JOIN Product ON [Order].ProductId = Product.Id
	WHERE OrderId = @SelectedOrderId;
END
GO

----------------------------------------------------- UpdateOrder SP:
CREATE OR ALTER PROCEDURE UpdateOrder
@SelectedOrderId int,
@SelectedProductId int,
@ReturnAmount int
AS
BEGIN
	IF (SELECT Delivered FROM [Order] WHERE [Order].OrderId = @SelectedOrderId AND [Order].ProductId = @SelectedProductId) = 1 AND @ReturnAmount <= (SELECT Amount FROM [Order] WHERE [Order].OrderId = @SelectedOrderId AND [Order].ProductId = @SelectedProductId) AND @ReturnAmount > 0
	BEGIN
		UPDATE [Order]
			SET Amount -= @ReturnAmount
			WHERE [Order].OrderId = @SelectedOrderId AND [Order].ProductId = @SelectedProductId;
		UPDATE Storage
			SET Amount += @ReturnAmount
			WHERE Storage.ProductId = @SelectedProductId;

		EXEC NewTransaction @TransactionReason = 2, @SelectedOrderId = @SelectedOrderId, @ProductId = @SelectedProductId, @Amount = @ReturnAmount;
	END
END
GO

----------------------------------------------------- Storage adjustment SP:
CREATE OR ALTER PROCEDURE StorageAdjustment
@ProductId int,
@NewAmount int,
@IsIncDec bit = 1		-- 1 = Increment/decrement amount. 0 = set a value directly.
AS
BEGIN
	IF @IsIncDec = 1 AND (SELECT Amount + @NewAmount FROM Storage WHERE Storage.ProductId = @ProductId) >= 0
	BEGIN
		UPDATE Storage
			SET Storage.Amount += @NewAmount
			WHERE Storage.ProductId = @ProductId;
		EXEC NewTransaction @TransactionReason = 3, @ProductId = @ProductId, @Amount = @NewAmount;
	END
	ELSE IF @IsIncDec = 0 AND @NewAmount >= 0
	BEGIN
		DECLARE @Diff int = (SELECT @NewAmount - Amount FROM Storage WHERE ProductId = @ProductId)
		PRINT @Diff;
		UPDATE Storage
			SET Storage.Amount = @NewAmount
			WHERE Storage.ProductId = @ProductId;
		EXEC NewTransaction @TransactionReason = 3, @ProductId = @ProductId, @Amount = @Diff;
	END
END
GO

----------------------------------------------------- PopularityReport SP:
CREATE OR ALTER PROCEDURE PopularityReport
@CategoryId int = NULL,			-- NULL = includes all categories. The result may be cropped by @ShowTop depending on how many products there are.
@ShowTop int = 5
AS
BEGIN
	SELECT
		TOP (@ShowTop)
		DENSE_RANK() OVER(PARTITION BY Product.CategoryId ORDER BY Product.PopularityScore DESC) AS [Rank],
		Category.[Name] AS Category,
		Product.[Name] AS ProductName,
		Product.PopularityScore AS Score
	FROM Product
	INNER JOIN Category ON Category.Id = Product.CategoryId
	WHERE (@CategoryId IS NULL OR (@CategoryId = CategoryId));
END
GO

----------------------------------------------------- ReturnReport SP:
CREATE OR ALTER PROCEDURE ReturnReport
@CategoryId int = NULL,			-- NULL = All categories.
@OrderBy bit = 0,				-- 0 = Order by amount of returns. 1 = Order by the total cost of returns.
@ShowTop int = 5
AS
BEGIN
	SELECT
		TOP (@ShowTop)
		Product.Id,
		Product.[Name],
		SUM(StorageTransaction.Amount) AS AmountOfReturns,
		SUM(StorageTransaction.Amount * Product.Price) AS TotalCost
		FROM StorageTransaction
		INNER JOIN Product ON Product.Id = StorageTransaction.ProductId
		WHERE (@CategoryId IS NULL AND StorageTransaction.ReasonId = 2 OR (@CategoryId = Product.CategoryId AND StorageTransaction.ReasonId = 2))
		GROUP BY Product.Id, Product.[Name]
		ORDER BY
			CASE WHEN @OrderBy = 0 THEN SUM(StorageTransaction.Amount) END DESC,
			CASE WHEN @OrderBy = 1 THEN SUM(StorageTransaction.Amount * Product.Price) END DESC;
END
GO

----------------------------------------------------- CategoryReport SP:
CREATE OR ALTER PROCEDURE CategoryReport
@StartDate datetime2 = NULL,		-- YYYY-MM-DD hh:mm:ss[.nnnnnnn]. If NULL it's set to -24h.
@EndDate datetime2 = NULL			-- YYYY-MM-DD hh:mm:ss[.nnnnnnn]. If NULL it sets current datetime2.
AS
BEGIN
	IF @StartDate IS NULL
		SET @StartDate = DATEADD(dd, -1, SYSDATETIME());
	IF @EndDate IS NULL
		SET @EndDate = SYSDATETIME();

	IF DATEDIFF(second, @StartDate, @EndDate) !< 0
	BEGIN
		SELECT
			C.[Name] AS CategoryName,
			SUM(CASE WHEN S.ReasonId = 1 THEN S.Amount * -1 END) AS SoldAmount,
			SUM(CASE WHEN S.ReasonId = 2 THEN S.Amount END) AS ReturnedAmount
			FROM StorageTransaction S
			INNER JOIN Product P ON S.ProductId = P.Id
			INNER JOIN Category C ON P.CategoryId = C.Id
			WHERE S.[Time] BETWEEN @StartDate AND @EndDate
			GROUP BY C.[Name];
	END
END
GO