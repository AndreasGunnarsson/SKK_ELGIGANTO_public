--USE ElGiganto11;
--USE Student11;
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

----------------------------------------------------- Exec for all stored procedures:
EXEC CreateNewCostumer @UserName = 'Turtle', @Email = 'turtle1@tmntmail.com', @Address = 'Kloak 4';
EXEC UpdateCostumer @SelectedCostumerId = 2, @UpdatedName = 'Ninja', @UpdatedEmail = 'ninjaman@mail.com', @UpdatedAddress = 'Skuggatan 33F', @DeleteAccount = 0;
EXEC ListProducts @SelectedCategoryId = 2, @RowsToSkip = 0, @RowsAmountToReturn = 5;
EXEC SearchProduct @SearchString = 'best', @CategoryId = 2, @IsAvailable = 1, @SortColumn = 1, @SortOrder = 1, @RowsToSkip = 0, @RowsAmountToReturn = 5;
EXEC ProductDetail @SelectedProductId = 11;
EXEC AddToCart @CurrentUserId = 1, @ProductId = 4, @ProductAmount = 5;
EXEC ListCartContent @CurrentUserId = 1;
EXEC CheckoutCart @CurrentUserId = 1;
EXEC DeliverOrder @SelectedOrderId = 1;
EXEC ViewOrder @SelectedOrderId = 1;
EXEC UpdateOrder @SelectedOrderId = 1, @SelectedProductId = 4, @ReturnAmount = 1;
EXEC StorageAdjustment @ProductId = 2, @NewAmount = -2, @IsIncDec = 1;
EXEC PopularityReport @CategoryId = 2, @ShowTop = 5;
EXEC ReturnReport @CategoryId = 3, @OrderBy = 1, @ShowTop = 5;
EXEC CategoryReport @StartDate = '2021-01-01 12:00:00.000000', @EndDate = '2021-01-02 12:00:00.000000';

----------------------------------------------------- Create Tables:
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
	Price decimal(5,2) NOT NULL CONSTRAINT CHK_Product_Price CHECK (Price > 0)		-- Anv�nd "decimal" ist�llet f�r "float" n�r det handlar om pengar. Kan bli fula avrundningar annars.
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
	OrderId int NOT NULL,					-- TODO: PK?
	Ordernumber int NOT NULL,
	ProductId int NOT NULL,
	CostumerId int NOT NULL,
	Amount int NOT NULL,
	Delivered bit NOT NULL DEFAULT 0,
--	ReturnAmount int NOT NULL DEFAULT 0,
	-- TODO: Tas de bort efter? Ja. Man kan fortfarande g�ra en rapport utifr�n StorageTransaction.
	-- Kolumnen beh�vs inte ens?
--	CONSTRAINT CHK_Order_ReturnAmount CHECK (ReturnAmount >= 0 AND ReturnAmount <= Amount)	-- Instead of using a CONSTRAINT on just one column it's used on the whole table. Needed if we want to compare values from different columns.
);
/*CREATE TABLE [Order]
(
	Id int PRIMARY KEY IDENTITY(1,1),
--	OrderId int NOT NULL,					-- TODO: PK?
--	OrderProductIdId int NOT NULL,			-- TODO: Snyggt namn?
	Ordernumber int NOT NULL,
--	ProductId int NOT NULL,
	CostumerId int NOT NULL,
--	Amount int NOT NULL,
	Delivered bit NOT NULL DEFAULT 0,
--	ReturnAmount int NOT NULL DEFAULT 0,
--	CONSTRAINT CHK_Order_ReturnAmount CHECK (ReturnAmount >= 0 AND ReturnAmount <= Amount)	-- Instead of using a CONSTRAINT on just one column it's used on the whole table. Needed if we want to compare values from different columns.
);
CREATE TABLE OrderProduct
(
	Id int PRIMARY KEY IDENTITY(1,1),
	OrderId int NOT NULL,
	ProductId int NOT NULL,
	Amount int NOT NULL,
	ReturnAmount int NOT NULL DEFAULT 0,
	CONSTRAINT CHK_OrderProduct_ReturnAmount CHECK (ReturnAmount >= 0 AND ReturnAmount <= Amount)	-- Instead of using a CONSTRAINT on just one column it's used on the whole table. Needed if we want to compare values from different columns.
);*/
-- Anv�nd en self join i [Order] ist�llet?
-- Om man s�tter ReturnAmount till DEFAULT 0 s� l�ser sig allt som har med SPn "NewTransaction" att g�ra?
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
	[Time] datetime2 DEFAULT SYSDATETIME(),				-- TODO: TESTA IFALL DET FUNKAR!
	Amount int NOT NULL,
	ReasonId int NOT NULL
);
CREATE TABLE TransactionReason
(
	Id int PRIMARY KEY IDENTITY(1,1),
	Reason varchar(50) NOT NULL UNIQUE
);

-- Test:
/* INSERT INTO Cart (CostumerId, ProductId) VALUES (1, 2);
UPDATE Cart SET Amount -= 1;
SELECT * FROM Cart;
SELECT * FROM Product
INSERT INTO Product (CategoryId, [Name], Price) VALUES (1, 'fef', 0.1)
INSERT INTO Popularity (ProductId) VALUES (12);			-- Test for constraint */

-- TODO: Rename StorageTransaction.Amount to AdjustedAmount.
-- TODO: G�r SEQUENCE Id redan p� Cart ist�llet f�r i [Order]? Nackdel: Man g�r miste om en PK. Fyller den n�gon funktion i Cart? F�rdel: Man g�r inte mista om n�gon funktionalitet. Kanske b�ttre performance i slut�ndan?
-- TODO: Eftersom att man ha flera Orders som h�r till samma s� borde Order.Ordernumber inte vara RAND; kan flera rader med samma order f�r olika Ordernumber annars vilket inte ska intr�ffa.
-- TODO: F�rklara "Amount int NOT NULL DEFAULT 1 CONSTRAINT CHK_Cart_Amount CHECK (Amount >= 0))" och relationen med SP:n AddToCart.
-- TODO: Ta bort [Order].Delivered? Svar: Nej, beh�vs f�r att personalen ska kunna s�tta en order som levererad.
-- TODO: D�p om Popularity.Popularity till Score eller ta bort hela Popularity-tabellen.
-- TODO: Problemet med Cart och [Order] �r att de endast till�ter en Product per session.
-- TODO: Borde Product ha en PopularityId ist�llet f�r tv�rt om? Som det �r nu s� m�ste en Product inte ha en Popularity (pga. att FK:n g�r andra h�llet). Detta �r fel.
-- TODO: Ta kanske bort Constraint p� Cart d� vi m�ste ha m�jlighet att ta bort en vara i en SP ifall den n�r 0.
-- TODO: Anv�nd triggers f�r att felchecka vad anv�ndaren matar in i en tabell. T.ex. f�r Costumer.Email (kolla @).
-- TODO: Rename Storage to Stock.
-- TODO: L�gg till password f�r Costumer.
-- TODO: L�gg till produktbeskrivning f�r Product.
-- TODO: Indexes.
-- TODO: Kolla �ver typerna och optimera dem.
-- TODO: L�gg till "user level" i Costumer och d�p om den till "User". Detta f�r att kunna ge olika privilegier (en admin kan t.ex. l�gga till produkter medan en vanlig anv�ndare endast kan best�lla).
-- TODO: G�r snyggare Product.Ordernumber.

-- Vad fyller Reserved f�r funktion: H�ller reda p� ett v�rde f�r ett specifikt Storage.Id som �r kopplat till ett Order.Id.
-- Enda syftet �r att kunna koppla "Order.Amount" med ett "Storage.Amount".
-- Alternativ implementation: Ta bort Reserved-tabellen. Ha en kolumn i Order som heter StorageId.
-- Alternativ implementation2: Ta bort Reserved-tabellen. S� l�nge som Order.Delivered inte �r true s� �r en vara ocks� reserved.
-- Nackdelar med att ta bort Reserved-tabellen: Kan potentiellt vara en prestanda-f�rlust? Kanske g�r att l�sa med index i r�tt kolumner. Om man ska kolla saldon m�ste man ocks� kolla igenom alla ordrar (levererade och icke-levererade) ist�llet f�r att bara kolla reserved-tabellen. Kanske g�r att l�sa med ett index?

----------------------------------------------------- Add foreign key constraints:
ALTER TABLE Product ADD CONSTRAINT FK_Product_Category FOREIGN KEY (CategoryId) REFERENCES Category(Id);
ALTER TABLE [Order] ADD CONSTRAINT FK_Order_Product FOREIGN KEY (ProductId) REFERENCES Product(Id);
ALTER TABLE [Order] ADD CONSTRAINT FK_Order_Costumer FOREIGN KEY (CostumerId) REFERENCES Costumer(Id);
--ALTER TABLE OrderProduct ADD CONSTRAINT FK_OrderProduct_Order FOREIGN KEY (OrderId) REFERENCES [Order](Id);
--ALTER TABLE OrderProduct ADD CONSTRAINT FK_OrderProduct_Product FOREIGN KEY (ProductId) REFERENCES Product(Id);
ALTER TABLE Cart ADD CONSTRAINT FK_Cart_Costumer FOREIGN KEY (CostumerId) REFERENCES Costumer(Id);
ALTER TABLE Cart ADD CONSTRAINT FK_Cart_Product FOREIGN KEY (ProductId) REFERENCES Product(Id);
ALTER TABLE Storage ADD CONSTRAINT FK_Storage_Product FOREIGN KEY (ProductId) REFERENCES Product(Id);
ALTER TABLE StorageTransaction ADD CONSTRAINT FK_StorageTrasaction_Product FOREIGN KEY (ProductId) REFERENCES Product(Id);
ALTER TABLE StorageTransaction ADD CONSTRAINT FK_StorageTransaction_Reason FOREIGN KEY (ReasonId) REFERENCES TransactionReason(Id);
--CREATE NONCLUSTERED INDEX IX_Product_Name ON Product([Name]);
--DROP INDEX IX_Product_Name ON Product;

-- INDEX: Storage.ProductId (s�kning och ProductDetail, StorageAdjustment). Finns redan ett icke-klustrat index d� den �r UNIQUE.
-- TODO: L�gg in dessa i tabellerna ovan ist�llet f�r att anv�nda ALTER TABLE.
-- TODO: ON DELETE CASCADE kan vara bra n�gonstans? Borde vara p� Category ifall man nu skulle ta bort en hel kategori n�gon g�ng (men man vill inte k�ra DELETE utan hade varit grymmare ifall man satta NULL som Product.CategoryId).

-- Problem med FK_Storage_Reserved: G�r endast att ha en Reserved per produkt. �r b�ttre att sk�ta deetta helt i "Reserved".
-- L�gg till tabell f�r personal?
-- On�digt att ha "Id" och "ProductId" i Storage-tabellen? �r alltid samma sak?
-- Trigger ifall man editar Storage eller StorageTransaction som g�r att man p�verkar b�da?
-- Trigger mellan Cart och Order?

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
INSERT INTO Costumer ([Name], Mail, [Address]) VALUES ('Greger', 'greger@mail.com', 'Gregerv�gen 3C');
INSERT INTO Costumer ([Name], Mail, [Address]) VALUES ('Klabbe', 'klabbe@klabbmail.com', 'Bollv�gen 12A');

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

-- Tets:
--EXEC CreateNewCostumer @UserName = 'Turtle', @Email = 'turtle1@tmntmail.com', @Address = 'Kloak 4';
--EXEC CreateNewCostumer @UserName = 'Greger', @Email = 'greger@mail.com', @Address = 'Gregerv�gen 3C';
--EXEC CreateNewCostumer @UserName = 'Klabbe', @Email = 'Klabbe@klabbmail.com', @Address = 'Bollv�gen 12A';
--SELECT * FROM Costumer;

-- TODO: Returnera det senaste skapta Id:t, kan vara sjysst ifall man ska logga in direkt efter?
-- TODO: Mail confirmed.
-- Om man ska ha flera "niv�r" borde kanske dessa vara separerade. K�nns inte helt smart att blanda kunder med anv�ndare som har h�gre privelegier?

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

-- Test:
--EXEC UpdateCostumer @SelectedCostumerId = 2, @DeleteAccount = 1;
--EXEC UpdateCostumer @SelectedCostumerId = 2, @UpdatedName = 'Ninja', @UpdatedEmail = 'ninjaman@mail.com', @UpdatedAddress = 'Skuggatan 33F', @DeleteAccount = 0;
--EXEC UpdateCostumer @SelectedCostumerId = 2, @UpdatedName = 'Ninja', @UpdatedEmail = 'ninjaman@mail.com', @UpdatedAddress = 'Skuggatan 33F', @DeleteAccount = 1;
--SELECT * FROM Costumer;

-- TODO: ISNULL �r full�sning? Problemet �r att man g�r en update �ven fast man bara kopierar samma v�rde som var innan.
-- https://stackoverflow.com/questions/6677517/update-if-different-changed
-- TODO: Borde man ta bort alla Orders som har med ett account att g�ra ifall man tar bort kontot?



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

-- Test:
--EXEC ListProducts @SelectedCategoryId = 2, @RowsToSkip = 0, @RowsAmountToReturn = 5;

-- TODO: Hantera exeptions: @RowsToSkip < 0, @RowsAmount <= 0?
-- SELECT * FROM Product;
-- SELECT * FROM 

-- TODO: Kan man p� n�got s�tt f�r reda p� max-v�rdet av rows (n�r man anv�nder OFFSET) s� att anv�ndarens klient vet n�r det r�cker?
-- TODO: Hur hanterar man att ingen @SelectedCategoryId v�ljs? Ska SP:n returnera en felkod?
-- Visa produkter baserat p� vald Category (sorterad efter Popularity).
	-- Bonus: Option f�r att sortera efter andra saker en popularity.
	-- Bonus: M�jlighet att v�lja flera kategorier. Anv�nd den d� ist�llet en SELECT p� den; sortera i klienten.

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
		AND (@IsAvailable = 0 OR (@IsAvailable = 1 AND Storage.Amount > 0))		-- Antingen m�ste @IsAvailable vara 0 OR s� m�ste @IsAvailable vara 1 AND Storage.Amount > 0.
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

-- Test:
--EXEC SearchProduct @RowsToSkip = 0, @RowsAmountToReturn = 5;
--EXEC SearchProduct @CategoryId = 3;
--EXEC SearchProduct @SearchString = '', @CategoryId = 1;
--EXEC SearchProduct @SearchString = '', @IsAvailable = 1, @SortColumn = 2, @SortOrder = 3;
--EXEC SearchProduct @SearchString = 'best', @CategoryId = 2, @IsAvailable = 1, @SortColumn = 1, @SortOrder = 1, @RowsToSkip = 0, @RowsAmountToReturn = 5;
--EXEC SearchProduct @SearchString = '', @IsAvailable = 1, @SortColumn = 0, @SortOrder = 1;
--SELECT * FROM Product;

-- S�kfunktion: S�k p� n�got och f� tillbaka de Products som matchar.
	-- Bonus: L�gg till popularitet till n�got ifall man s�ker p� det. Beh�ver g�ra en UPDATE p� alla Product som matchar s�kningen.
	-- Bonus: M�jlighet att s�ka p� flera kategorier (@CategoryId) �n en.

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

-- Test:
--EXEC UpdatePopularity @ProductId = 7, @AddedScore = 1, @ProductAmountMultiplier = 1;
--SELECT * FROM Product;

-- TODO: S�tt in f�rdefinerade v�rden f�r AddedScore (1, 5, 10).
-- TODO: Det hela �r r�tt s� flawed. Man kan bara spamma vissa saker (som SP:n ProductDetail) f�r att scoren ska �ka. Borde vara n�gon cooldown.
-- Bonus: Uppdatera score beroende p� senaste datumet som Scoren uppdaterades p�? Verkligare scenario �r att detta kanske k�rs en g�ng om dagen (nattid) f�r att uppdatera alla produkters score.
	-- Anv�nd en egen tabell f�r "globala variabler". Kan t.ex. spara LastPopularityUpdate och LastProductIdUpdated (f�r att anv�ndas i en StorageTransaction-trigger).
	-- Detta borde g�ras i backend-klienten.
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

-- TODO: Hur hanterar man "Reserved" (m�ste kolla [Order].ReturnAmount)?

-- Test:
--EXEC ProductDetail @SelectedProductId = 11;
--SELECT * FROM Product;
-- Produktdetaljer. Skriv in ett Product.Id.
	-- Ska visa Name, Category, Price och lagerstatus.

----------------------------------------------------- AddToCart SP:
CREATE OR ALTER PROCEDURE AddToCart
@CurrentUserId int,
@ProductId int,
@ProductAmount int
AS
BEGIN
	IF @CurrentUserId IS NOT NULL AND @ProductId IS NOT NULL AND @ProductAmount IS NOT NULL
	BEGIN
	-- M�ste kolla:
		-- G�r insert ifall anv�ndaren ELLER produkten inte existerar i Cart-tabellen.
		IF @ProductId NOT IN (SELECT ProductId FROM Cart WHERE Cart.CostumerId = @CurrentUserId) OR @CurrentUserId NOT IN (SELECT CostumerId FROM Cart WHERE Cart.CostumerId = @CurrentUserId)		-- We have to use IN instead of = because when = is used the subquery (SELECT) is expected to return only one row.
		BEGIN
--			PRINT 'INSERT!';
			INSERT INTO Cart (CostumerId, ProductId, Amount) VALUES (@CurrentUserId, @ProductId, @ProductAmount);
			EXEC UpdatePopularity @ProductId = @ProductId, @AddedScore = 5, @ProductAmountMultiplier = @ProductAmount;
		END
		ELSE IF (SELECT Amount + @ProductAmount FROM Cart WHERE Cart.ProductId = @ProductId AND Cart.CostumerId = @CurrentUserId) = 0
		BEGIN
--			PRINT 'DELETE!';
			DELETE FROM Cart WHERE Cart.ProductId = @ProductId AND Cart.CostumerId = @CurrentUserId;
			EXEC UpdatePopularity @ProductId = @ProductId, @AddedScore = 5, @ProductAmountMultiplier = @ProductAmount;
		END
		ELSE IF @ProductId IN (SELECT ProductId FROM Cart WHERE Cart.CostumerId = @CurrentUserId) AND (SELECT Amount + @ProductAmount FROM Cart WHERE Cart.ProductId = @ProductId AND Cart.CostumerId = @CurrentUserId) > 0
		BEGIN
--			PRINT 'UPDATE!';
			UPDATE Cart SET Cart.Amount += @ProductAmount WHERE Cart.ProductId = @ProductId AND Cart.CostumerId = @CurrentUserId;
			EXEC UpdatePopularity @ProductId = @ProductId, @AddedScore = 5, @ProductAmountMultiplier = @ProductAmount;
		END
	END
--	ELSE
--		PRINT 'Error: One or more arguments is NULL.';
END
GO

-- Test:
EXEC AddToCart @CurrentUserId = 1, @ProductId = 4, @ProductAmount = 5;
--SELECT * FROM Cart;
--SELECT * FROM Product;
-- TODO: Rename CurrentUserId to CurrentCostumerId.
-- TODO: Add a feature to remove the card instantly (withouh having to reach 0).
-- TODO: Borde kolla ifall Storage.Amount > 0.

-- @CurrentUserId �r �nnu en sak man skulle vilja hantera som en "global variabel". �r d�rmed b�ttre att hantera i backend-klienten.

-- Kolla dessa:
-- https://docs.microsoft.com/en-us/sql/t-sql/statements/create-procedure-transact-sql?view=sql-server-ver15
-- https://docs.microsoft.com/en-us/sql/relational-databases/in-memory-oltp/a-guide-to-query-processing-for-memory-optimized-tables?view=sql-server-ver15
-- https://docs.microsoft.com/en-us/sql/relational-databases/in-memory-oltp/creating-natively-compiled-stored-procedures?view=sql-server-ver15
-- B�ttre prestanda och man kan s�tta en parameter som "NOT NULL".
----------------------------------------------------- ListCartContent SP:
CREATE OR ALTER PROCEDURE ListCartContent
@CurrentUserId int
AS
BEGIN
	SELECT Product.Id, Product.[Name], Product.Price AS PrinceSingleUnit, Cart.Amount, Product.Price * Cart.Amount AS TotalPriceRow, SUM(Product.Price * Cart.Amount) OVER() AS TotalPrice
		FROM Cart
		INNER JOIN Product ON Product.Id = Cart.ProductId
		WHERE Cart.CostumerId = @CurrentUserId
--		GROUP BY Product.Id, Product.[Name], Product.Price, Cart.Amount;
END
GO

-- Test:
EXEC ListCartContent @CurrentUserId = 1;
EXEC AddToCart @CurrentUserId = 1, @ProductId = 1, @ProductAmount = 2;
EXEC AddToCart @CurrentUserId = 2, @ProductId = 3, @ProductAmount = 3;
EXEC AddToCart @CurrentUserId = 1, @ProductId = 2, @ProductAmount = 4;
EXEC AddToCart @CurrentUserId = 2, @ProductId = 4, @ProductAmount = 5;
SELECT * FROM Cart;
SELECT * FROM Product;
-- List the content in a cart with a specific Id.
-- TODO: Skriv ut totala summan!
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
--		PRINT @OrderIdSequence;			-- DEBUG
--		PRINT @RandomOrdernumber;		-- DEBUG

		INSERT INTO [Order] (OrderId, CostumerId, ProductId, Ordernumber, Amount)
			SELECT @OrderIdSequence, CostumerId, ProductId, @RandomOrdernumber, Amount
			FROM Cart
			WHERE Cart.CostumerId = @CurrentUserId;

		DELETE FROM Cart
			WHERE Cart.CostumerId = @CurrentUserId;

		DECLARE @LoopCounter int = 1;
--		PRINT @LoopCounter;					-- DEBUG.

		CREATE TABLE #temptable
			(Id int PRIMARY KEY IDENTITY(1,1), ProductId int NOT NULL, Amount int NOT NULL);

		INSERT INTO #temptable (ProductId, Amount)
			SELECT [Order].ProductId, [Order].Amount
			FROM [Order]
			WHERE [Order].OrderId = @OrderIdSequence;

--		SELECT * FROM #temptable;			-- DEBUG.

		WHILE @LoopCounter <= (SELECT COUNT(Id) FROM #temptable)
		BEGIN
			DECLARE @Product int = (SELECT ProductId FROM #temptable WHERE Id = @LoopCounter);
--			PRINT @Product;
			DECLARE @Amount int = (SELECT Amount FROM #temptable WHERE Id = @LoopCounter);
--			PRINT @Amount;
			EXEC UpdatePopularity @ProductId = @Product, @AddedScore = 10, @ProductAmountMultiplier = @Amount;
			SET @LoopCounter += 1;
--			PRINT @LoopCounter;			--DEBUG
		END
	END
END
GO

-- Test:
--EXEC CheckoutCart @CurrentUserId = 1;

--SELECT * FROM Cart;
--SELECT * FROM [Order];
--SELECT * FROM Product;
--SELECT * FROM sys.sequences WHERE [name] = 'OrderSequence';
--SELECT current_value FROM sys.sequences WHERE [name] = 'OrderSequence';
--SELECT NEXT VALUE FOR OrderSequence;
--EXEC AddToCart @CurrentUserId = 1, @ProductId = 1, @ProductAmount = 2;
--EXEC AddToCart @CurrentUserId = 2, @ProductId = 3, @ProductAmount = 2;
--EXEC AddToCart @CurrentUserId = 1, @ProductId = 2, @ProductAmount = 2;
--EXEC AddToCart @CurrentUserId = 2, @ProductId = 4, @ProductAmount = 2;
--EXEC AddToCart @CurrentUserId = 3, @ProductId = 4, @ProductAmount = 5;

-- TODO: Borde kolla ifall Storage.Amount > 0. Kan h�mta att v�rdet �ndrats under tiden som man g�r saker. Kanske g�r att l�gga en order men man borde iaf f� en varning?
-- TODO: Random-algoritmen �r r�tt d�lig. Borde baseras p� datum eller n�got f�r att minimera risken att duplicates uppst�r. Datum, CostumerId + Random (4 siffror).
-- TODO: borde returnera ordernummer eller Id?
----------------------------------------------------- Bonus: Undandled orders SP:
-- Anv�nds av personalen f�r att hantera Ordrar som lagts.
----------------------------------------------------- NewTransaction SP:
CREATE OR ALTER PROCEDURE NewTransaction
@TransactionReason int,				-- 1 = Delivery, 2 = Return, 3 = Stock adjustment
-- TODO: Anv�nd ocks� [Order].OrderId!
--@SelectedOrdernumber int = NULL,		-- TODO: Bonus.
@SelectedOrderId int = NULL,
--@ReturnAmount int = NULL,
@ProductId int = NULL,
@Amount int = NULL
AS
BEGIN
	IF @TransactionReason = 1 AND @SelectedOrderId IS NOT NULL
	BEGIN
--		PRINT 'Delivery';				-- DEBUG.
		INSERT INTO StorageTransaction (ProductId, Amount, ReasonId)
			SELECT ProductId, (Amount * -1), 1
			FROM [Order]
			WHERE [Order].OrderId = @SelectedOrderId;
	END
	ELSE IF @TransactionReason = 2 AND @SelectedOrderId IS NOT NULL AND @ProductId IS NOT NULL AND @Amount > 0 
	BEGIN
--		PRINT 'Return';					-- DEBUG.
		INSERT INTO StorageTransaction (ProductId, Amount, ReasonId)
			SELECT ProductId, @Amount, 2
			FROM [Order]
			WHERE [Order].OrderId = @SelectedOrderId AND [Order].ProductId = @ProductId;
	END
--	PRINT @SelectedOrdernumber;
/*	IF @SelectedOrdernumber IS NOT NULL
	BEGIN
		PRINT 'OrderId is NOT NULL';
		IF (SELECT TOP 1 [Order].ReturnAmount FROM [Order] WHERE [Order].Ordernumber = @SelectedOrdernumber) = 0
		-- L�sning: IS NOT NULL i WHERE?
		BEGIN
			PRINT 'Delivery (not a Return)';
			INSERT INTO StorageTransaction (ProductId, Amount, ReasonId)
			SELECT ProductId, (Amount * -1), 1 FROM [Order] WHERE [Order].Ordernumber = @SelectedOrdernumber;
		END
		ELSE IF (SELECT [Order].ReturnAmount FROM [Order] WHERE [Order].Ordernumber = @SelectedOrdernumber) > 0
		BEGIN
			PRINT 'Return';
			INSERT INTO StorageTransaction (ProductId, Amount, ReasonId)
			SELECT ProductId, ReturnAmount, 2 FROM [Order] WHERE [Order].Ordernumber = @SelectedOrdernumber;
		END
	END */
	ELSE IF @TransactionReason = 3 AND @ProductId IS NOT NULL AND @Amount IS NOT NULL
	BEGIN
--		PRINT 'Stock adjustment';		-- DEBUG.
		INSERT INTO StorageTransaction (ProductId, Amount, ReasonId)
		VALUES (@ProductId, @Amount, 3);
	END
--	ELSE								-- DEBUG.
--	BEGIN
--		PRINT 'Not a valid option';
--	END
END
GO

-- TODO: Se �ver if-satser och NULL-v�rden i parametrarna.

-- Test:
--EXEC NewTransaction @SelectedOrdernumber = 16654526;
--EXEC NewTransaction @TransactionReason = 1, @ProductId = 2, @Amount = 10;
--UPDATE [Order] SET [Order].ReturnAmount = 2 WHERE Id = 2;
--SELECT * FROM [Order];
--SELECT * FROM StorageTransaction;
--SELECT * FROM TransactionReason;
-- M�ste k�ras innan sj�lva f�r�ndringen i lagersaldo skett.
-- Kollar ifall [Order].Delivered �r true s� handlar det om StorageTransaction med Reason "Delivery". Anv�nder Product och Amount ifr�n [Order].
-- Ifall [Order].Delivered �r false s� handlar det om en "Return". Anv�nd Product och Amount fr�n [Order].
-- Ifall @OrderId = NULL men @ProductId och @Amount har ett v�rde s� �r det en lager-justering.

-- Om det skett en f�r�ndring mellan [Order].Amount 

-- Kan man l�gga TransactionReason-saldo-uppdatering i en trigger (kommer att vara det enda som inte kollas i denna SP). K�nns konstigt att dela upp det p� det viset.

-- M�ste p� n�got s�tt ta reda p� den senaste f�r�ndringen som skett.
	-- Om man f�rst j�mf�r skillnaden p� den Order man valt (betyder att vi beh�ver tv� stycken parametrar) med Storage och sparar detta i en variabel.
	-- Ifall det inte �r ifr�n en order (Det �r null) s� vet man att det �r en lokal lager-f�r�ndring.
		-- Hur vet man d� vad man ska �ndra?
	-- Ifall Order.Delivered �r 0 s� �r det en retur.
	-- Om Storage.Amount == 
--END

----------------------------------------------------- DeliverOrder SP:
CREATE OR ALTER PROCEDURE DeliverOrder
--@SelectedOrdernumber int,		-- TODO: Bonus.
@SelectedOrderId int
AS
BEGIN
--	SELECT * FROM [Order];
	IF 0 IN (SELECT [Order].Delivered FROM [Order] WHERE [Order].OrderId = @SelectedOrderId)
	BEGIN
--		PRINT 'Delivered is 0';			-- DEBUG.
		UPDATE [Order] SET [Order].Delivered = 1
			WHERE [Order].OrderId = @SelectedOrderId;

		EXEC NewTransaction @TransactionReason = 1, @SelectedOrderId = @SelectedOrderId;

		DECLARE @LoopCounter int = 1;
--		PRINT CONCAT ('LoopCounter: ', @LoopCounter);					-- DEBUG.
		
		CREATE TABLE #temptable2
			(Id int PRIMARY KEY IDENTITY(1,1), ProductId int NOT NULL, Amount int NOT NULL);

		INSERT INTO #temptable2 (ProductId, Amount)
			SELECT [Order].ProductId, [Order].Amount
			FROM [Order]
			WHERE [Order].OrderId = @SelectedOrderId;

--		SELECT * FROM #temptable2;			-- DEBUG.

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
--			PRINT CONCAT('LoopCounter (inside): ', @LoopCounter);					-- DEBUG.
		END
	END
END
GO

-- Test:
--EXEC DeliverOrder @SelectedOrderId = 1;
--EXEC DeliverOrder @SelectedOrdernumber = 45410858;
--SELECT * FROM [Order];
--SELECT * FROM Storage;
--SELECT * FROM StorageTransaction;

--SELECT * FROM Cart;
--SELECT * FROM TransactionReason;
--UPDATE [Order] SET [Order].Delivered = 0;
--DELETE FROM [Order] WHERE Id = 3;
--UPDATE [Order] SET [Order].Amount = 10 WHERE Id = 1;

-- TODO: Testa vad som �r effektivast i IF-satsen, IN, TOP 1 och =?
-- TODO: M�ste l�gga till "NewTransaction" n�gonstans.

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

--EXEC ViewOrder @SelectedOrderId = 1;
--SELECT * FROM [Order];
-- Bonus: Ordernumber
-- Visar f�r anv�ndaren statusen p� ordern (delivered eller ej).
-- Anv�nds ocks� f� att skriva ut saker som �r relevanta f�r UpdateOrder.
----------------------------------------------------- UpdateOrder SP:
CREATE OR ALTER PROCEDURE UpdateOrder
--@CurrentUserId int,
@SelectedOrderId int,
@SelectedProductId int,
--@OrderNumber int,
@ReturnAmount int
AS
BEGIN
	IF (SELECT Delivered FROM [Order] WHERE [Order].OrderId = @SelectedOrderId AND [Order].ProductId = @SelectedProductId) = 1 AND @ReturnAmount <= (SELECT Amount FROM [Order] WHERE [Order].OrderId = @SelectedOrderId AND [Order].ProductId = @SelectedProductId) AND @ReturnAmount > 0
	BEGIN
--		PRINT 'You are here';		-- DEBUG.
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

-- Test:
--EXEC UpdateOrder @SelectedOrderId = 1, @SelectedProductId = 4, @ReturnAmount = 1;
--EXEC ViewOrder @SelectedOrderId = 1;

--SELECT * FROM [Order];
--SELECT * FROM Storage;
--SELECT * FROM StorageTransaction;

-- Borde g�ra n�got mer s� att de som arbeter har koll p� vad som h�nt?
-- Man borde ocks� kunna anv�nda Ordernumber?
-- Anv�nds ifall en kund vill returnera en vara.
-- G�r att uppdatera [Order].ReturnAmount med denna.
----------------------------------------------------- Bonus: AddRemoveProduct SP:
-- M�ste ocks� hantera produkter som t.ex. ligger i Cart.
-- L�gger till/tar bort en Product. M�ste ocks� ta bort dess Popularity i samma veva.
-- Kan beh�va en ON DELETE CASCADE p� FK:n i tabeller h�r..
----------------------------------------------------- Bonus: UpdateProduct SP:
-- Updaterar pris och description p� en Product.
-- Kan ocks� l�gga till en ny? Byt namn.

----------------------------------------------------- Storage adjustment SP:
CREATE OR ALTER PROCEDURE StorageAdjustment
@ProductId int,
@NewAmount int,
@IsIncDec bit = 1		-- 1 = Increment/decrement amount. 0 = set a value directly.
-- TODO: StorageTransaction bryr sig endast om med hur mycket n�got �ndras.
AS
BEGIN
--	SELECT Amount + @NewAmount FROM Storage WHERE Storage.ProductId = @ProductId;
	IF @IsIncDec = 1 AND (SELECT Amount + @NewAmount FROM Storage WHERE Storage.ProductId = @ProductId) >= 0
	BEGIN
--		PRINT 'Here';			-- DEBUG.
		UPDATE Storage
			SET Storage.Amount += @NewAmount
			WHERE Storage.ProductId = @ProductId;
		EXEC NewTransaction @TransactionReason = 3, @ProductId = @ProductId, @Amount = @NewAmount;
	END
	ELSE IF @IsIncDec = 0 AND @NewAmount >= 0
	BEGIN
--		PRINT 'IsIncDec 0';		-- DEBUG.
		DECLARE @Diff int = (SELECT @NewAmount - Amount FROM Storage WHERE ProductId = @ProductId)
		PRINT @Diff;
		UPDATE Storage
			SET Storage.Amount = @NewAmount
			WHERE Storage.ProductId = @ProductId;
		EXEC NewTransaction @TransactionReason = 3, @ProductId = @ProductId, @Amount = @Diff;
	END
END
GO

-- Test:
--EXEC StorageAdjustment @ProductId = 2, @NewAmount = -2, @IsIncDec = 1;
--SELECT * FROM Storage;
--SELECT * FROM StorageTransaction;

-- TODO: Borde skriva vilken anv�ndare som gjorde f�r�ndringen.

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

--EXEC PopularityReport @CategoryId = 2, @ShowTop = 5;
--SELECT * FROM Product;

-- TODO: Fungerar men DENSE_RANK()

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
--	ELSE
	--CASE WHEN @SortOrder = 1 AND @SortColumn = 0 THEN Product.PopularityScore END DESC,
END
GO

-- Test:
--EXEC ReturnReport @CategoryId = 3, @OrderBy = 1, @ShowTop = 5;
--SELECT * FROM Product;
--SELECT * FROM StorageTransaction;

--SELECT *
--	FROM StorageTransaction
--	INNER JOIN Product ON Product.Id = StorageTransaction.ProductId
--	WHERE Product.CategoryId = 1 AND StorageTransaction.ReasonId = 2
	--GROUP BY Product.Id, Product.[Name], StorageTransaction.Amount
-- TODO: TotalCost �r en r�tt s� ful kolumn.
-- TODO: TOP 5 mest returnerade f�r vald kategori.
-- Anv�nd "window functions (ascoolt!, men utanf�r kursen), table functions, loopa i en SP och fylla p� en tabellvariabel m.m." f�r att visa TOP 5 i f�r varje kategori i 
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
--	PRINT @StartDate;			-- DEBUG.
--	PRINT @EndDate;				-- DEBUG.

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

-- Test:
--EXEC CategoryReport @StartDate = '2021-01-01 12:00:00.000000', @EndDate = '2021-01-02 12:00:00.000000';

--INSERT INTO StorageTransaction (ProductId, Amount, ReasonId) VALUES (3, -4, 1);
--INSERT INTO StorageTransaction (ProductId, Amount, ReasonId) VALUES (2, -3, 1);
--INSERT INTO StorageTransaction (ProductId, Amount, ReasonId) VALUES (5, -2, 1);
--INSERT INTO StorageTransaction (ProductId, Amount, ReasonId) VALUES (6, -1, 1);
--INSERT INTO StorageTransaction (ProductId, Amount, ReasonId) VALUES (7, 4, 2);
--INSERT INTO StorageTransaction (ProductId, Amount, ReasonId) VALUES (8, 3, 2);
--INSERT INTO StorageTransaction (ProductId, Amount, ReasonId) VALUES (9, 2, 2);
--INSERT INTO StorageTransaction (ProductId, Amount, ReasonId) VALUES (10, 1, 2);
--SELECT * FROM StorageTransaction;

-- TODO: DATEDIFF(second) �r antagligen f�r finlirigt om man vill j�mf�ra datum m�nader eller kanske �r ifr�n varandra.
----------------------------------------------------- Trigger f�r Transaction.

/* CREATE OR ALTER TRIGGER TR_StorageTransaction ON Storage
FOR UPDATE
AS
BEGIN
--	DECLARE @insertReason INT = 1;
	INSERT INTO StorageTransaction (ProductId, Amount, ReasonId) SELECT ProductID, Amount, LastTransactionReasonId FROM inserted;

	-- Problem: Vi m�ste ge olika reasons beroende p� hur UPDATE:n skett:
		-- Delivery, Return eller Stock Adjustment.
	-- L�sning: Skulle kunna spara v�rdet p� sista TransactionReason n�gonstans? G�r t.ex. att l�gga till en kolumn i "Storage".
--	SELECT * FROM inserted;
--	SELECT * FROM deleted;
--	SELECT * FROM TransactionReason;
END
-- Anv�nd OUTPUT?

-- CREATE TABLE StorageTransaction (Id int PRIMARY KEY IDENTITY(1,1), ProductId int, [Time] datetime DEFAULT GETDATE(), Amount int NOT NULL, ReasonId int NOT NULL);
UPDATE Storage SET Amount = 67 WHERE Id = 5;
SELECT * FROM Storage;
SELECT * FROM StorageTransaction;
SELECT * FROM TransactionReason; */

----------------------------- Saker som ska implementeras nedan:
-- Reservera artikel i lagret.
-- Leverera order:
	-- Ta bort reservation-
	-- S�nk lagersaldo (med "Amount" fr�n [Order]).
	-- Skapa lagertransaktion (med "TransactionReason" : "Delivery").
-- Justera lager:
	-- �ndra lagersaldo
	-- Skapa en lagertransaktion (med "TransactionReason" : "Stock adjustment").
-- Returnera:
	-- ???

-- Andra fr�gor
---------------
-- Hur hanterar man flera varor?
	-- Antingen har man flera rader i tabellerna Cart och [Order] som man sedan s�tter ihop.
	-- Alternativ: Man har en till tabell med varorna man valt.
	-- Fulhack: F�ruts�tt att man endast hanterar en vara. Detta verkar vara det vi ska g�ra enligt texten?
-- Vi m�ste g�ra en UPDATE Cart p� det sista Id:t som lades till.
-- Trigger d� man drar ner (UPDATE) Cart till 0 varor f�r att ta bort varan.