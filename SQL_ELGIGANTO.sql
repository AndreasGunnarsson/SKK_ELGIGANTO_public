USE Student11;

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

DROP PROC ListProducts;
DROP PROC UpdatePopularity;
DROP PROC ProductDetail;
DROP PROC SearchProduct;
DROP PROC DeliverOrder;
DROP PROC StorageAdjustment;
DROP PROC NewTransaction;
DROP PROC AddToCart;
DROP PROC NewUser;
DROP PROC ListCartContent;
DROP PROC CheckoutCart;
DROP PROC CreateNewUser;
DROP PROC UpdateCostumer;

----------------------------------------------------- Tables:
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
--	Id int PRIMARY KEY IDENTITY(1,1),
	Id int NOT NULL,					-- TODO: PK?
	ProductId int NOT NULL,
	CostumerId int NOT NULL,
	Ordernumber int NOT NULL,
	Amount int NOT NULL,
	Delivered bit NOT NULL DEFAULT 0,
	ReturnAmount int NOT NULL DEFAULT 0,					-- TODO: Se över constraints.
	CONSTRAINT CHK_Order_ReturnAmount CHECK (ReturnAmount >= 0 AND ReturnAmount <= Amount)	-- Instead of using a CONSTRAINT on just one column it's used on the whole table. Needed if we want to compare values from different columns.
);
/*CREATE TABLE [Order]
(
	Id int PRIMARY KEY IDENTITY(1,1),
	OrderProductId int NOT NULL,
	CostumerId int NOT NULL,
	Ordernumber int NOT NULL,
--	Amount int NOT NULL,
	Delivered bit NOT NULL DEFAULT 0,
--	ReturnAmount int,					-- TODO: Se över constraints.
);
CREATE TABLE OrderProduct
(
	Id int NOT NULL,
	ProductId int NOT NULL,
	Amount int NOT NULL,
	ReturnAmount int
	CONSTRAINT CHK_OrderProduct_ReturnAmount CHECK (ReturnAmount > 0 AND ReturnAmount <= Amount)	-- Instead of using a CONSTRAINT on just one column it's used on the whole table. Needed if we want to compare values from different columns.
);*/
-- Använd en self join i [Order] istället?
-- Om man sätter ReturnAmount till DEFAULT 0 så löser sig allt som har med SPn "NewTransaction" att göra?
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
	[Time] datetime DEFAULT GETDATE(),
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

-- TODO: Gör SEQUENCE Id redan på Cart istället för i [Order]? Nackdel: Man går miste om en PK. Fyller den någon funktion i Cart? Fördel: Man gör inte mista om någon funktionalitet. Kanske bättre performance i slutändan?
-- TODO: Eftersom att man ha flera Orders som hör till samma så borde Order.Ordernumber inte vara RAND; kan flera rader med samma order får olika Ordernumber annars vilket inte ska inträffa.
-- TODO: Förklara "Amount int NOT NULL DEFAULT 1 CONSTRAINT CHK_Cart_Amount CHECK (Amount >= 0))" och relationen med SP:n AddToCart.
-- TODO: Ta bort [Order].Delivered? Svar: Nej, behövs för att personalen ska kunna sätta en order som levererad.
-- TODO: Döp om Popularity.Popularity till Score eller ta bort hela Popularity-tabellen.
-- TODO: Problemet med Cart och [Order] är att de endast tillåter en Product per session.
-- TODO: Borde Product ha en PopularityId istället för tvärt om? Som det är nu så måste en Product inte ha en Popularity (pga. att FK:n går andra hållet). Detta är fel.
-- TODO: Ta kanske bort Constraint på Cart då vi måste ha möjlighet att ta bort en vara i en SP ifall den når 0.
-- TODO: Använd triggers för att felchecka vad användaren matar in i en tabell. T.ex. för Costumer.Email (kolla @).
-- TODO: Rename Storage to Stock.
-- TODO: Lägg till password för Costumer.
-- TODO: Lägg till produktbeskrivning för Product.
-- TODO: Indexes.
-- TODO: Kolla över typerna och optimera dem.
-- TODO: Lägg till "user level" i Costumer och döp om den till "User". Detta för att kunna ge olika privilegier (en admin kan t.ex. lägga till produkter medan en vanlig användare endast kan beställa).
-- TODO: Gör snyggare Product.Ordernumber.

-- Vad fyller Reserved för funktion: Håller reda på ett värde för ett specifikt Storage.Id som är kopplat till ett Order.Id.
-- Enda syftet är att kunna koppla "Order.Amount" med ett "Storage.Amount".
-- Alternativ implementation: Ta bort Reserved-tabellen. Ha en kolumn i Order som heter StorageId.
-- Alternativ implementation2: Ta bort Reserved-tabellen. Så länge som Order.Delivered inte är true så är en vara också reserved.
-- Nackdelar med att ta bort Reserved-tabellen: Kan potentiellt vara en prestanda-förlust? Kanske går att lösa med index i rätt kolumner. Om man ska kolla saldon måste man också kolla igenom alla ordrar (levererade och icke-levererade) istället för att bara kolla reserved-tabellen. Kanske går att lösa med ett index?

----------------------------------------------------- Foreign Key constraints:
ALTER TABLE Product ADD CONSTRAINT FK_Product_Category FOREIGN KEY (CategoryId) REFERENCES Category(Id);
ALTER TABLE [Order] ADD CONSTRAINT FK_Order_Product FOREIGN KEY (ProductId) REFERENCES Product(Id);
ALTER TABLE [Order] ADD CONSTRAINT FK_Order_Costumer FOREIGN KEY (CostumerId) REFERENCES Costumer(Id);
ALTER TABLE Cart ADD CONSTRAINT FK_Cart_Costumer FOREIGN KEY (CostumerId) REFERENCES Costumer(Id);
ALTER TABLE Cart ADD CONSTRAINT FK_Cart_Product FOREIGN KEY (ProductId) REFERENCES Product(Id);
ALTER TABLE Storage ADD CONSTRAINT FK_Storage_Product FOREIGN KEY (ProductId) REFERENCES Product(Id);
ALTER TABLE StorageTransaction ADD CONSTRAINT FK_StorageTrasaction_Product FOREIGN KEY (ProductId) REFERENCES Product(Id);
ALTER TABLE StorageTransaction ADD CONSTRAINT FK_StorageTransaction_Reason FOREIGN KEY (ReasonId) REFERENCES TransactionReason(Id);

-- TODO: Lägg in dessa i tabellerna ovan istället för att använda ALTER TABLE.
-- TODO: ON DELETE CASCADE kan vara bra någonstans? Borde vara på Category ifall man nu skulle ta bort en hel kategori någon gång (men man vill inte köra DELETE utan hade varit grymmare ifall man satta NULL som Product.CategoryId).

-- Problem med FK_Storage_Reserved: Går endast att ha en Reserved per produkt. Är bättre att sköta deetta helt i "Reserved".
-- Lägg till tabell för personal?
-- Onödigt att ha "Id" och "ProductId" i Storage-tabellen? Är alltid samma sak?
-- Trigger ifall man editar Storage eller StorageTransaction som gör att man påverkar båda?
-- Trigger mellan Cart och Order?

-- Hårdkodade värden:
INSERT INTO Category ([Name]) VALUES ('GPU'), ('CPU'), ('RAM');
INSERT INTO TransactionReason (Reason) VALUES ('Delivery'), ('Return'), ('Stock adjustment');
-- Förutbestämd testdata:
INSERT INTO Product (CategoryId, PopularityScore, [Name], Price) VALUES (1, 10, 'Voodoo 2', 399.99), (1, 20, 'GeForce', 449.99), (1, 15, 'Radeon', 349.99), (1, 5, 'Bobby-graphic', 49.99), (1, 3, 'Greger graphics', 99.99);
INSERT INTO Product (CategoryId, PopularityScore, [Name], Price) VALUES (2, 35, 'Intel 300 MHz', 599.99), (2, 40, 'AMD 100 MHz', 299.99), (2, 30, 'Intel 333 MHz', 699.99), (2, 4, 'Bobby-Central possessing unit', 29.99), (2, 2, 'Greger CPU', 199.99);
INSERT INTO Product (CategoryId, PopularityScore, [Name], Price) VALUES (3, 100, 'Noname 128 MB', 49.99), (3, 200, 'Intel 512 MB', 199.99), (3, 150, 'MyMemory 1024 MB', 249.99), (3, 20, 'Boby-b-Good memory 384 MB', 249.99), (3, 10, 'Greger Memory 1024 MB', 149.99);
INSERT INTO Storage (ProductId, Amount) VALUES (1, 10), (2, 20), (3, 50), (4, 60), (5, 70), (6, 100), (7, 100), (8, 100), (9, 100), (10, 100), (11, 100), (12, 100), (13, 100), (14, 100), (15, 100);
INSERT INTO StorageTransaction (ProductId, Amount, ReasonId) VALUES (1, 10, 3), (2, 20, 3), (3, 50, 3), (4, 60, 3), (5, 70, 3), (6, 100, 3), (7, 100, 3), (8, 100, 3), (9, 100, 3), (10, 100, 3), (11, 100, 3), (12, 100, 3), (13, 100, 3), (14, 100, 3), (15, 100, 3);
INSERT INTO Costumer ([Name], Mail, [Address]) VALUES ('Boris', 'boris@mail.com', 'Borisgatan 2B');
INSERT INTO Costumer ([Name], Mail, [Address]) VALUES ('Greger', 'greger@mail.com', 'Gregervägen 3C');
INSERT INTO Costumer ([Name], Mail, [Address]) VALUES ('Klabbe', 'Klabbe@klabbmail.com', 'Bollvägen 12A');

----------------------------------------------------- CreateNewUser SP:
CREATE OR ALTER PROCEDURE CreateNewUser
@UserName varchar(50),
@Email varchar(50),
@Address varchar(50)
AS
BEGIN
	INSERT INTO Costumer ([Name], Mail, [Address]) VALUES (@UserName, @Email, @Address);
END

-- Tets:
EXEC CreateNewUser @UserName = 'Turtle', @Email = 'turtle1@tmntmail.com', @Address = 'Kloak 4';
--EXEC CreateNewUser @UserName = 'Greger', @Email = 'greger@mail.com', @Address = 'Gregervägen 3C';
--EXEC CreateNewUser @UserName = 'Klabbe', @Email = 'Klabbe@klabbmail.com', @Address = 'Bollvägen 12A';
SELECT * FROM Costumer;

-- TODO: Returnera det senaste skapta Id:t, kan vara sjysst ifall man ska logga in direkt efter?
-- TODO: Mail confirmed.
-- Om man ska ha flera "nivår" borde kanske dessa vara separerade. Känns inte helt smart att blanda kunder med användare som har högre privelegier?

----------------------------------------------------- UpdateCostumer SP:
CREATE OR ALTER PROCEDURE UpdateCostumer
@SelectedCostumerId int,
@UpdatedName varchar(50) = NULL,
@UpdatedEmail varchar(50) = NULL,
@UpdatedAddress varchar(50) = NULL,
@DeleteAccount bit = 0
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
	ELSE IF @DeleteAccount = 1
		DELETE FROM Costumer WHERE Costumer.Id = @SelectedCostumerId
END

-- TODO: ISNULL är fullösning? Problemet är att man gör en update även fast man bara kopierar samma värde som var innan.
-- https://stackoverflow.com/questions/6677517/update-if-different-changed
-- TODO: Borde man ta bort alla Orders som har med ett account att göra ifall man tar bort kontot?
SELECT * FROM Costumer;
EXEC UpdateCostumer @SelectedCostumerId = 2, @DeleteAccount = 1;
EXEC UpdateCostumer @SelectedCostumerId = 2, @UpdatedName = 'Seeeeeger', @UpdatedEmail = 'segermail@mail.com', @UpdatedAddress = 'Nyavägen 666F';

----------------------------------------------------- ListProducts SP:
CREATE OR ALTER PROCEDURE ListProducts
@SelectedCategoryId int,
@RowsToSkip int = 0,
@RowsAmountToReturn int = 3
AS
BEGIN
	SELECT Product.Id, [Name], Price FROM Product
	WHERE CategoryId = @SelectedCategoryId
	ORDER BY PopularityScore DESC
	OFFSET @RowsToSkip ROWS FETCH NEXT @RowsAmountToReturn ROWS ONLY;		-- Pagination. OFFSET = The number of rows to skip. FETCH = The amount of rows after the OFFSET that's returned.
END

-- Test:
EXEC ListProducts @SelectedCategoryId = 1, @RowsToSkip = 0, @RowsAmountToReturn = 5;

-- TODO: Hantera exeptions: @RowsToSkip < 0, @RowsAmount <= 0?
-- SELECT * FROM Product;
-- SELECT * FROM 

-- TODO: Kan man på något sätt får reda på max-värdet av rows (när man använder OFFSET) så att användarens klient vet när det räcker?
-- TODO: Hur hanterar man att ingen @SelectedCategoryId väljs? Ska SP:n returnera en felkod?
-- Visa produkter baserat på vald Category (sorterad efter Popularity).
	-- Bonus: Option för att sortera efter andra saker en popularity.
	-- Bonus: Möjlighet att välja flera kategorier. Använd den då istället en SELECT på den; sortera i klienten.

----------------------------------------------------- SearchProduct SP:
CREATE OR ALTER PROCEDURE SearchProduct
@SearchString varchar(50) = '',		-- Empty string = all Products.
@CategoryId int = NULL,				-- NULL = All categories.
@IsAvailable bit = 0,				-- 0 = Shows Product even if there are none in Stock. 1 = The Product need to be at Stock.Amount > 0.
@SortColumn int = 0,				-- 0 = Popularity, 2 = Price, 3 = Name.
@SortOrder bit = 0,					-- 0 = ASC, 1 = DESC.
@RowsToSkip int = 0,				-- The number of rows (from the top of the serch result) to exclude.
@RowsAmountToReturn int = 3					-- Number of rows after @RowsToSkip to include.
AS
BEGIN
	SELECT Product.Id, Product.[Name], Product.Price
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

-- Test:
EXEC SearchProduct @RowsToSkip = 0, @RowsAmountToReturn = 5;
EXEC SearchProduct @CategoryId = 1;
EXEC SearchProduct @SearchString = '', @CategoryId = 1;
EXEC SearchProduct @SearchString = '', @IsAvailable = 1, @SortColumn = 2, @SortOrder = 3;
EXEC SearchProduct @SearchString = '', @CategoryId = 2, @IsAvailable = 12, @SortColumn = 2, @SortOrder = 1, @RowsToSkip = 0, @RowsAmountToReturn = 3;
EXEC SearchProduct @SearchString = '', @IsAvailable = 1, @SortColumn = 0, @SortOrder = 1;
SELECT * FROM Product;

-- Sökfunktion: Sök på något och få tillbaka de Products som matchar.
	-- Bonus: Lägg till popularitet till något ifall man söker på det. Behöver göra en UPDATE på alla Product som matchar sökningen.
	-- Bonus: Möjlighet att söka på flera kategorier (@CategoryId) än en.

----------------------------------------------------- UpdatePopularity SP:
CREATE OR ALTER PROCEDURE UpdatePopularity
@ProductId int,
@AddedScore int,							-- The score can be different dependant on where it's added. Must be a positive number.
@ProductAmountMultiplier int = 1			-- The amount of products affected. Can be a negative number.
AS
BEGIN
	IF @AddedScore IS NOT NULL AND @AddedScore >= 0 AND @ProductId IS NOT NULL
		UPDATE Product SET Product.PopularityScore += (@AddedScore * @ProductAmountMultiplier) WHERE Product.Id = @ProductId;
END

-- Test:
EXEC UpdatePopularity @ProductId = 7, @AddedScore = 1, @ProductAmountMultiplier = 1;
SELECT * FROM Product;

-- TODO: Sätt in fördefinerade värden för AddedScore (1, 5, 10).
-- TODO: Det hela är rätt så flawed. Man kan bara spamma vissa saker (som SP:n ProductDetail) för att scoren ska öka. Borde vara någon cooldown.
-- Bonus: Uppdatera score beroende på senaste datumet som Scoren uppdaterades på? Verkligare scenario är att detta kanske körs en gång om dagen (nattid) för att uppdatera alla produkters score.
	-- Använd en egen tabell för "globala variabler". Kan t.ex. spara LastPopularityUpdate och LastProductIdUpdated (för att användas i en StorageTransaction-trigger).
	-- Detta borde göras i backend-klienten.
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

-- TODO: Hur hanterar man "Reserved" (måste kolla [Order].ReturnAmount)?

EXEC ProductDetail @SelectedProductId = 5;
SELECT * FROM Product;
-- Produktdetaljer. Skriv in ett Product.Id.
	-- Ska visa Name, Category, Price och lagerstatus.
----------------------------------------------------- AddToCart SP:
CREATE OR ALTER PROCEDURE AddToCart
@CurrentUserId int,					-- When no "=" is used an argument with a value is required (the argument can still be set to NULL whel calling the SP).
@ProductId int,
@ProductAmount int
AS
BEGIN
	IF @CurrentUserId IS NOT NULL AND @ProductId IS NOT NULL AND @ProductAmount IS NOT NULL
	BEGIN
	-- Måste kolla:
		-- Gör insert ifall användaren ELLER produkten inte existerar i Cart-tabellen.
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

-- Test:
EXEC AddToCart @CurrentUserId = 1, @ProductId = 6, @ProductAmount = 2;
SELECT * FROM Cart;
SELECT * FROM Product;
-- TODO: Add a feature to remove the card instantly (withouh having to reach 0).
-- TODO: Borde kolla ifall Storage.Amount > 0.

-- @CurrentUserId är ännu en sak man skulle vilja hantera som en "global variabel". Är därmed bättre att hantera i backend-klienten.

-- Kolla dessa:
-- https://docs.microsoft.com/en-us/sql/t-sql/statements/create-procedure-transact-sql?view=sql-server-ver15
-- https://docs.microsoft.com/en-us/sql/relational-databases/in-memory-oltp/a-guide-to-query-processing-for-memory-optimized-tables?view=sql-server-ver15
-- https://docs.microsoft.com/en-us/sql/relational-databases/in-memory-oltp/creating-natively-compiled-stored-procedures?view=sql-server-ver15
-- Bättre prestanda och man kan sätta en parameter som "NOT NULL".
----------------------------------------------------- ListCartContent SP:
CREATE OR ALTER PROCEDURE ListCartContent
@CurrentUserId int
AS
BEGIN
	SELECT Product.Id, Product.[Name], Product.Price AS PrinceSingleUnit, Cart.Amount, SUM(Product.Price * Cart.Amount) AS TotalPriceRow, SUM(Product.Price * Cart.Amount) OVER() AS TotalPrice
		FROM Cart
		INNER JOIN Product ON Product.Id = Cart.ProductId
		WHERE Cart.CostumerId = @CurrentUserId
		GROUP BY Product.Id, Product.[Name], Product.Price, Cart.Amount;
END

-- Test:
EXEC ListCartContent @CurrentUserId = 2;
EXEC AddToCart @CurrentUserId = 1, @ProductId = 1, @ProductAmount = 2;
EXEC AddToCart @CurrentUserId = 2, @ProductId = 3, @ProductAmount = 2;
EXEC AddToCart @CurrentUserId = 1, @ProductId = 2, @ProductAmount = 2;
EXEC AddToCart @CurrentUserId = 2, @ProductId = 4, @ProductAmount = 2;
SELECT * FROM Cart;
SELECT * FROM Product;
-- List the content in a cart with a specific Id.
-- TODO: Skriv ut totala summan!
----------------------------------------------------- CheckoutCart SP:
CREATE SEQUENCE OrderSequence
	START WITH 1
	INCREMENT BY 1;

CREATE OR ALTER PROCEDURE CheckoutCart
@CurrentUserId int
AS
BEGIN
	IF @CurrentUserId IN (SELECT CostumerId FROM Cart WHERE CostumerId = @CurrentUserId)
	BEGIN
		DECLARE @OrderIdSequence int = NEXT VALUE FOR OrderSequence;
		DECLARE @RandomOrdernumber int = CAST(RAND() * 100000000 + @CurrentUserId AS int);
	--	SET @RandomOrdernumber = ;
		PRINT @OrderIdSequence;			-- DEBUG
		PRINT @RandomOrdernumber;		-- DEBUG

		INSERT INTO [Order] (Id, CostumerId, ProductId, Ordernumber, Amount)
			SELECT @OrderIdSequence, CostumerId, ProductId, @RandomOrdernumber, Amount
			FROM Cart
			WHERE Cart.CostumerId = @CurrentUserId;
	/*	INSERT INTO [Order] (CostumerId, ProductId, Ordernumber, Amount)
			SELECT CostumerId, ProductId, @RandomOrdernumber, Amount
			FROM Cart
			WHERE Cart.CostumerId = @CurrentUserId;*/
		DELETE FROM Cart
			WHERE Cart.CostumerId = @CurrentUserId;
--		EXEC UpdatePopularity @ProductId = 7, @AddedScore = 1, @ProductAmountMultiplier = 1;
	END
END
-- Test:
EXEC CheckoutCart @CurrentUserId = 1;

SELECT * FROM Cart;
SELECT * FROM [Order];
SELECT * FROM sys.sequences WHERE [name] = 'OrderSequence';
SELECT current_value FROM sys.sequences WHERE [name] = 'OrderSequence';
SELECT NEXT VALUE FOR OrderSequence;

-- TODO: UpdatePopularity  -  Behövs antagligen en IF om man ska köra UpdatePopularity också. Behöver man använda temporära tabeller och WHILE igen?
-- TODO: Borde kolla ifall Storage.Amount > 0. Kan hämta att värdet ändrats under tiden som man gör saker. Kanske går att lägga en order men man borde iaf få en varning?
-- TODO: Random-algoritmen är rätt dålig. Borde baseras på datum eller något för att minimera risken att duplicates uppstår. Datum, CostumerId + Random (4 siffror).
-- TODO: borde returnera ordernummer eller Id?
----------------------------------------------------- Undandled orders SP:
-- Används av personalen för att hantera Ordrar som lagts.

----------------------------------------------------- NewTransaction SP:
CREATE OR ALTER PROCEDURE NewTransaction
--@TransactionReason int = NULL,
@SelectedOrdernumber int = NULL,
@ProductId int = NULL,
@Amount int = NULL
AS
BEGIN
--	PRINT @SelectedOrdernumber;
	IF @SelectedOrdernumber IS NOT NULL
	BEGIN
		PRINT 'OrderId is NOT NULL';
		IF IS NOT NULL (SELECT TOP 1 [Order].ReturnAmount FROM [Order] WHERE [Order].Ordernumber = @SelectedOrdernumber)	-- TODO! Använder inte längre NULL utan är 0 by default.
		-- Lösning: IS NOT NULL i WHERE?
		BEGIN
			PRINT 'Delivery (not a Return)';
			INSERT INTO StorageTransaction (ProductId, Amount, ReasonId)
			SELECT ProductId, (Amount * -1), 1 FROM [Order] WHERE [Order].Ordernumber = @SelectedOrdernumber;
		END
		ELSE IF NULL IN (SELECT [Order].ReturnAmount FROM [Order] WHERE [Order].Ordernumber = @SelectedOrdernumber)
		BEGIN
			PRINT 'Return';
			INSERT INTO StorageTransaction (ProductId, Amount, ReasonId)
			SELECT ProductId, ReturnAmount, 2 FROM [Order] WHERE [Order].Ordernumber = @SelectedOrdernumber;
		END
	END
	ELSE IF @ProductId IS NOT NULL AND @Amount IS NOT NULL
	BEGIN
		PRINT 'Stock adjustment';
		INSERT INTO StorageTransaction (ProductId, Amount, ReasonId)
		VALUES (@ProductId, @Amount, 3);
	END
	ELSE
	BEGIN
		PRINT 'Not a valid option';
	END
END

-- TODO: Se över if-satser och NULL-värden i parametrarna.

-- Test:
EXEC NewTransaction @SelectedOrdernumber = 16654526;
EXEC NewTransaction @ProductId = 2, @Amount = 10;
UPDATE [Order] SET [Order].ReturnAmount = 2 WHERE Id = 2;
SELECT * FROM [Order];
SELECT * FROM StorageTransaction;
SELECT * FROM TransactionReason;
-- Måste köras innan själva förändringen i lagersaldo skett.
-- Kollar ifall [Order].Delivered är true så handlar det om StorageTransaction med Reason "Delivery". Använder Product och Amount ifrån [Order].
-- Ifall [Order].Delivered är false så handlar det om en "Return". Använd Product och Amount från [Order].
-- Ifall @OrderId = NULL men @ProductId och @Amount har ett värde så är det en lager-justering.

-- Om det skett en förändring mellan [Order].Amount 

-- Kan man lägga TransactionReason-saldo-uppdatering i en trigger (kommer att vara det enda som inte kollas i denna SP). Känns konstigt att dela upp det på det viset.

-- Måste på något sätt ta reda på den senaste förändringen som skett.
	-- Om man först jämför skillnaden på den Order man valt (betyder att vi behöver två stycken parametrar) med Storage och sparar detta i en variabel.
	-- Ifall det inte är ifrån en order (Det är null) så vet man att det är en lokal lager-förändring.
		-- Hur vet man då vad man ska ändra?
	-- Ifall Order.Delivered är 0 så är det en retur.
	-- Om Storage.Amount == 
--END

----------------------------------------------------- Deliver order SP:
CREATE OR ALTER PROCEDURE DeliverOrder
@SelectedOrdernumber int
AS
BEGIN
--	SELECT * FROM [Order];
	IF 0 IN (SELECT [Order].Delivered FROM [Order] WHERE [Order].Ordernumber = @SelectedOrdernumber)
	BEGIN
		PRINT 'HERE';
		UPDATE [Order] SET [Order].Delivered = 1
			WHERE [Order].Ordernumber = @SelectedOrdernumber;

		DECLARE @LoopCounter int = 1;
		PRINT @LoopCounter;					-- DEBUG.

		CREATE TABLE #temptable
			(Id int PRIMARY KEY IDENTITY(1,1), ProductId int NOT NULL, Amount int NOT NULL);

		INSERT INTO #temptable (ProductId, Amount)
			SELECT [Order].ProductId, [Order].Amount
			FROM [Order]
			WHERE [Order].Ordernumber = @SelectedOrdernumber;

		SELECT * FROM #temptable;			-- DEBUG.

		WHILE @LoopCounter <= (SELECT COUNT(Id) FROM [Order] WHERE [Order].Ordernumber = @SelectedOrdernumber)
		BEGIN
			UPDATE Storage SET Storage.Amount -=
			(
				SELECT #temptable.Amount
				FROM #temptable
				WHERE #temptable.Id = @LoopCounter
			)
			WHERE Storage.ProductId =
			(
				SELECT #temptable.ProductId
				FROM #temptable
				WHERE #temptable.Id = @LoopCounter
			)
			SET @LoopCounter += 1;
			PRINT @LoopCounter;			--DEBUG
		END
	END
END

-- Test:
EXEC DeliverOrder @SelectedOrdernumber = 45410858;
SELECT * FROM Cart;
SELECT * FROM [Order];
SELECT * FROM Storage;
SELECT * FROM StorageTransaction;
SELECT * FROM TransactionReason;
UPDATE [Order] SET [Order].Delivered = 0;
DELETE FROM [Order] WHERE Id = 3;
UPDATE [Order] SET [Order].Amount = 10 WHERE Id = 1;

-- TODO: Testa vad som är effektivast i IF-satsen, IN, TOP 1 och =?
-- TODO: Måste lägga till "NewTransaction" någonstans.

----------------------------------------------------- ViewOrder SP:
-- Visar för användaren statusen på ordern (delivered eller ej).
-- Används också fö att skriva ut saker som är relevanta för UpdateOrder.
----------------------------------------------------- UpdateOrder SP:
CREATE OR ALTER PROCEDURE UpdateOrder
--@CurrentUserId int,
@ProductId int,
@OrderNumber int,
@ReturnAmount int
AS
BEGIN
	IF (SELECT Delivered FROM [Order] WHERE [Order].CostumerId = @OrderNumber AND [Order].ProductId = @ProductId) = 1
		PRINT 'HERE';
	ELSE
		PRINT 'Error: The order has to be delivered before it can be returned.';
END

EXEC UpdateOrder @ProductId = 1, @OrderNumber = 38, @ReturnAmount = 1;

SELECT * FROM [Order];

-- Man borde också kunna använda Ordernumber?
-- Används ifall en kund vill returnera en vara.
-- Går att uppdatera [Order].ReturnAmount med denna.
----------------------------------------------------- Bonus: AddRemoveProduct SP:
-- Måste också hantera produkter som t.ex. ligger i Cart.
-- Lägger till/tar bort en Product. Måste också ta bort dess Popularity i samma veva.
-- Kan behöva en ON DELETE CASCADE på FK:n i tabeller här..
----------------------------------------------------- Bonus: UpdateProduct SP:
-- Updaterar pris och description på en Product.
-- Kan också lägga till en ny? Byt namn.

----------------------------------------------------- Storage adjustment SP:
CREATE OR ALTER PROCEDURE StorageAdjustment
@SelectedProductId int = NULL,
@NewAmount int = NULL,
@IsIncDec bit = 1
AS
BEGIN
IF @SelectedProductId IS NOT NULL AND @NewAmount IS NOT NULL AND @IsIncDec = 1
BEGIN
	PRINT 'Valid';
	EXEC NewTransaction @ProductId = @SelectedProductId, @Amount = @NewAmount;
	-- Problem: Since we write a direct value to SET the Newtransaction.Amount is wrong; this should show the difference.
	-- NewTransaction hanterar endast diff-värden. Om man vill ha något annat än en diff måste man skriva detta i denna SP (StorageAdjustment).
	-- Problem: We need error checking. We cant set a stock Amount that's below 0.
	UPDATE Storage SET Storage.Amount += @NewAmount WHERE Storage.ProductId = @SelectedProductId;
END
ELSE IF @SelectedProductId IS NOT NULL AND @NewAmount IS NOT NULL AND @IsIncDec = 0
BEGIN
	PRINT 'Valid2'
	-- TODO: Will use a "full" value that's not just an increment/decrement.
	-- We must first get the diff from the current Storage.Amount because that's what will be sent to the NewTransaction SP.
	-- Behöver en Variabel som sparar värdet och en if-sats beroende på ifall värdet är positivt eller negativt.
END
ELSE
	PRINT 'Not valid';
END


EXEC StorageAdjustment @SelectedProductId = 2, @NewAmount = 2, @IsIncDec = 1;
SELECT * FROM StorageTransaction;
SELECT * FROM Storage;

-- TODO: Borde skriva vilken användare som gjorde förändringen.

----------------------------------------------------- PopularityReport SP
CREATE OR ALTER PROCEDURE PopularityReport
@CategoryId int = NULL
AS
BEGIN
	SELECT
		DENSE_RANK() OVER(PARTITION BY Product.CategoryId ORDER BY Product.PopularityScore DESC) AS [Rank],
		Category.[Name] AS Category,
		Product.[Name],
		Product.PopularityScore AS Score
	FROM Product
	INNER JOIN Category ON Category.Id = Product.CategoryId;
	-- TOP 5 med högst Popularity.PopularityScore.
	-- Kan börja med TOP 3!
	-- SELECT * FROM Product
END
UPDATE Product SET PopularityScore = 10 WHERE Id = 4;
SELECT * FROM Product;
----------------------------------------------------- ReturnReport
-- TOP 5 mest returnerade för vald kategori.
-- Använd "window functions (ascoolt!, men utanför kursen), table functions, loopa i en SP och fylla på en tabellvariabel m.m." för att visa TOP 5 i för varje kategori i 
----------------------------------------------------- CategoryReport

----------------------------------------------------- Trigger för Transaction.

/* CREATE OR ALTER TRIGGER TR_StorageTransaction ON Storage
FOR UPDATE
AS
BEGIN
--	DECLARE @insertReason INT = 1;
	INSERT INTO StorageTransaction (ProductId, Amount, ReasonId) SELECT ProductID, Amount, LastTransactionReasonId FROM inserted;

	-- Problem: Vi måste ge olika reasons beroende på hur UPDATE:n skett:
		-- Delivery, Return eller Stock Adjustment.
	-- Lösning: Skulle kunna spara värdet på sista TransactionReason någonstans? Går t.ex. att lägga till en kolumn i "Storage".
--	SELECT * FROM inserted;
--	SELECT * FROM deleted;
--	SELECT * FROM TransactionReason;
END
-- Använd OUTPUT?

-- CREATE TABLE StorageTransaction (Id int PRIMARY KEY IDENTITY(1,1), ProductId int, [Time] datetime DEFAULT GETDATE(), Amount int NOT NULL, ReasonId int NOT NULL);
UPDATE Storage SET Amount = 67 WHERE Id = 5;
SELECT * FROM Storage;
SELECT * FROM StorageTransaction;
SELECT * FROM TransactionReason; */

----------------------------- Saker som ska implementeras nedan:
-- Reservera artikel i lagret.
-- Leverera order:
	-- Ta bort reservation-
	-- Sänk lagersaldo (med "Amount" från [Order]).
	-- Skapa lagertransaktion (med "TransactionReason" : "Delivery").
-- Justera lager:
	-- Ändra lagersaldo
	-- Skapa en lagertransaktion (med "TransactionReason" : "Stock adjustment").
-- Returnera:
	-- ???

-- Andra frågor
---------------
-- Hur hanterar man flera varor?
	-- Antingen har man flera rader i tabellerna Cart och [Order] som man sedan sätter ihop.
	-- Alternativ: Man har en till tabell med varorna man valt.
	-- Fulhack: Förutsätt att man endast hanterar en vara. Detta verkar vara det vi ska göra enligt texten?
-- Vi måste göra en UPDATE Cart på det sista Id:t som lades till.
-- Trigger då man drar ner (UPDATE) Cart till 0 varor för att ta bort varan.

------------------------- SELECT:s for all tables:
SELECT * FROM Category;
SELECT * FROM Product;
SELECT * FROM [Order];
SELECT * FROM Costumer;
SELECT * FROM Cart;
SELECT * FROM Storage;
SELECT * FROM StorageTransaction;
SELECT * FROM TransactionReason;