USE Student11;

ALTER TABLE [Order] DROP CONSTRAINT FK_Order_Costumer;
ALTER TABLE [Order] DROP CONSTRAINT FK_Order_Product;
ALTER TABLE Storage DROP CONSTRAINT FK_Storage_Product;
--ALTER TABLE Storage DROP CONSTRAINT FK_Storage_Reserved;
--DROP TABLE IF EXISTS Popularity;
DROP TABLE IF EXISTS Cart;
DROP TABLE IF EXISTS StorageTransaction;
DROP TABLE IF EXISTS TransactionReason;
DROP TABLE IF EXISTS Costumer;
DROP TABLE IF EXISTS Category;
DROP TABLE IF EXISTS [Order];
DROP TABLE IF EXISTS Reserved;
DROP TABLE IF EXISTS Storage;
DROP TABLE IF EXISTS Product;

-- DROP TRIGGER IF EXISTS TR_StorageTransaction;
DROP PROC IF EXISTS ListProducts;
DROP PROC IF EXISTS UpdatePopularity;
DROP PROC IF EXISTS ProductDetail;
DROP PROC IF EXISTS SearchProduct;
DROP PROC IF EXISTS DeliverOrder;
DROP PROC IF EXISTS StorageAdjustment;
DROP PROC IF EXISTS NewTransaction;
DROP PROC IF EXISTS AddToCart;
DROP PROC IF EXISTS NewUser;
DROP PROC IF EXISTS ListCartContent;
DROP PROC IF EXISTS CheckoutCart;

CREATE TABLE Category (Id int PRIMARY KEY IDENTITY(1,1), [Name] varchar (50) NOT NULL UNIQUE);
--CREATE TABLE Popularity (Id int PRIMARY KEY IDENTITY(1,1), ProductId int NOT NULL UNIQUE, Popularity int NOT NULL DEFAULT 0);
--CREATE TABLE Popularity (Id int PRIMARY KEY IDENTITY(1,1), Popularity int NOT NULL DEFAULT 0);
--CREATE TABLE Product (Id int PRIMARY KEY IDENTITY(1,1), PopularityId int NOT NULL UNIQUE, CategoryId int NOT NULL, [Name] varchar(50) NOT NULL, Price float(53) NOT NULL CONSTRAINT CHK_Product_Price CHECK (Price > 0));
CREATE TABLE Product (Id int PRIMARY KEY IDENTITY(1,1), PopularityScore int NOT NULL DEFAULT 0, CategoryId int NOT NULL, [Name] varchar(50) NOT NULL, Price float(53) NOT NULL CONSTRAINT CHK_Product_Price CHECK (Price > 0));
CREATE TABLE Costumer (Id int PRIMARY KEY IDENTITY(1,1), [Name] varchar(50) NOT NULL, Mail varchar(50) NOT NULL UNIQUE, [Address] varchar(50) NOT NULL);
--CREATE TABLE [Order] (Id int PRIMARY KEY IDENTITY(1,1), ProductId int NOT NULL, CostumerId int NOT NULL, Ordernumber int NOT NULL DEFAULT CAST(RAND() * 100 AS int), Amount int NOT NULL, Delivered bit DEFAULT 0);
CREATE TABLE [Order] (Id int PRIMARY KEY IDENTITY(1,1), ProductId int NOT NULL, CostumerId int NOT NULL, Ordernumber int NOT NULL, Amount int NOT NULL, Delivered bit DEFAULT 0, ReturnAmount int, CONSTRAINT CHK_Order_ReturnAmount CHECK (ReturnAmount > 0 AND ReturnAmount <= Amount));		-- Instead of using a CONSTRAINT on just one column it's used on the whole table. Needed if we want to compare values from different columns
--SELECT * FROM [Order];
--UPDATE [Order] SET ReturnAmount = 4 WHERE Id = 2;
CREATE TABLE Cart (Id int PRIMARY KEY IDENTITY(1,1), CostumerId int NOT NULL, ProductId int NOT NULL, Amount int NOT NULL DEFAULT 1 CONSTRAINT CHK_Cart_Amount CHECK (Amount >= 0));
--CREATE TABLE Reserved (Id int PRIMARY KEY IDENTITY(1,1), OrderId int NOT NULL, StorageId int NOT NULL);					-- Testa utan, se förklaring nedan.
--CREATE TABLE Storage (Id int PRIMARY KEY IDENTITY(1,1), ProductId int NOT NULL, Amount int NOT NULL, ReservedId int);		-- ReservedId ska inte vara här!
CREATE TABLE Storage (Id int PRIMARY KEY IDENTITY(1,1), ProductId int NOT NULL, Amount int NOT NULL);
--CREATE TABLE Storage (Id int PRIMARY KEY IDENTITY(1,1), ProductId int NOT NULL, Amount int NOT NULL, LastTransactionReasonId int);
CREATE TABLE StorageTransaction (Id int PRIMARY KEY IDENTITY(1,1), ProductId int, [Time] datetime DEFAULT GETDATE(), Amount int NOT NULL, ReasonId int NOT NULL);
CREATE TABLE TransactionReason (Id int PRIMARY KEY IDENTITY(1,1), Reason varchar(50) NOT NULL UNIQUE);
-- DEFAULT CAST(RAND() * 100 AS int)

-- Test:
/* INSERT INTO Cart (CostumerId, ProductId) VALUES (1, 2);
UPDATE Cart SET Amount -= 1;
SELECT * FROM Cart;
SELECT * FROM Product
INSERT INTO Product (CategoryId, [Name], Price) VALUES (1, 'fef', 0.1)
INSERT INTO Popularity (ProductId) VALUES (12);			-- Test for constraint */

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
-- TODO: Är float bästa typen för Product.Price?
-- TODO: Indexes.
-- TODO: Kolla över typerna och optimera dem.
-- TODO: Lägg till "user level" i Costumer och döp om den till "User". Detta för att kunna ge olika privilegier (en admin kan t.ex. lägga till produkter medan en vanlig användare endast kan beställa).
-- TODO: Gör snyggare Product.Ordernumber.

-- Vad fyller Reserved för funktion: Håller reda på ett värde för ett specifikt Storage.Id som är kopplat till ett Order.Id.
-- Enda syftet är att kunna koppla "Order.Amount" med ett "Storage.Amount".
-- Alternativ implementation: Ta bort Reserved-tabellen. Ha en kolumn i Order som heter StorageId.
-- Alternativ implementation2: Ta bort Reserved-tabellen. Så länge som Order.Delivered inte är true så är en vara också reserved.
-- Nackdelar med att ta bort Reserved-tabellen: Kan potentiellt vara en prestanda-förlust? Kanske går att lösa med index i rätt kolumner. Om man ska kolla saldon måste man också kolla igenom alla ordrar (levererade och icke-levererade) istället för att bara kolla reserved-tabellen. Kanske går att lösa med ett index?

ALTER TABLE Product ADD CONSTRAINT FK_Product_Category FOREIGN KEY (CategoryId) REFERENCES Category(Id);
--ALTER TABLE Product ADD CONSTRAINT FK_Product_Popularity FOREIGN KEY (PopularityId) REFERENCES Popularity(Id);
--ALTER TABLE Popularity ADD CONSTRAINT FK_Popularity_Product FOREIGN KEY (ProductId) REFERENCES Product(Id);
ALTER TABLE [Order] ADD CONSTRAINT FK_Order_Product FOREIGN KEY (ProductId) REFERENCES Product(Id);
ALTER TABLE [Order] ADD CONSTRAINT FK_Order_Costumer FOREIGN KEY (CostumerId) REFERENCES Costumer(Id);
ALTER TABLE Cart ADD CONSTRAINT FK_Cart_Costumer FOREIGN KEY (CostumerId) REFERENCES Costumer(Id);
ALTER TABLE Cart ADD CONSTRAINT FK_Cart_Product FOREIGN KEY (ProductId) REFERENCES Product(Id);
--ALTER TABLE Reserved ADD CONSTRAINT FK_Reserved_Order FOREIGN KEY (OrderId) REFERENCES [Order](Id);
--ALTER TABLE Reserved ADD CONSTRAINT FK_Reserved_Storage FOREIGN KEY (StorageId) REFERENCES Storage(Id);
ALTER TABLE Storage ADD CONSTRAINT FK_Storage_Product FOREIGN KEY (ProductId) REFERENCES Product(Id);
--ALTER TABLE Storage ADD CONSTRAINT FK_Storage_TransactionReason FOREIGN KEY (LastTransactionReasonId) REFERENCES TransactionReason(Id);
--ALTER TABLE Storage ADD CONSTRAINT FK_Storage_Reserved FOREIGN KEY (ReservedId) REFERENCES Reserved(Id);
ALTER TABLE StorageTransaction ADD CONSTRAINT FK_StorageTrasaction_Product FOREIGN KEY (ProductId) REFERENCES Product(Id);
ALTER TABLE StorageTransaction ADD CONSTRAINT FK_StorageTransaction_Reason FOREIGN KEY (ReasonId) REFERENCES TransactionReason(Id);

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
--INSERT INTO Popularity (Popularity) VALUES (10), (15), (20), (40), (35), (30), (100), (200), (150);
INSERT INTO Product (CategoryId, PopularityScore, [Name], Price) VALUES (1, 10, 'Voodoo 2', 399.99), (1, 20, 'GeForce', 449.99), (1, 15, 'Radeon', 349.99);
INSERT INTO Product (CategoryId, PopularityScore, [Name], Price) VALUES (2, 35, 'Intel 300 MHz', 599.99), (2, 40, 'AMD 100 MHz', 299.99), (2, 30, 'Intel 333 MHz', 699.99);
INSERT INTO Product (CategoryId, PopularityScore, [Name], Price) VALUES (3, 100, 'Noname 128 MB', 49.99), (3, 200, 'Intel 512 MB', 199.99), (3, 150, 'MyMemory 1024 MB', 249.99);
--INSERT INTO Popularity (ProductId, Popularity) VALUES (1, 10), (2, 15), (3, 20), (4, 40), (5, 35), (6, 30), (7, 100), (8, 200), (9, 150);
--DELETE FROM Product;
--SELECT * FROM Popularity;
--SELECT * FROM Product;
INSERT INTO Costumer ([Name], Mail, [Address]) VALUES ('Boris', 'boris@mail.com', 'Borisgatan 2');
INSERT INTO Costumer ([Name], Mail, [Address]) VALUES ('Greger', 'greger@mail.com', 'Gregervägen 3');
INSERT INTO Storage (ProductId, Amount) VALUES (1, 10), (2, 20), (3, 50), (4, 60), (5, 70), (6, 100), (7, 100), (8, 100), (9, 100);

-- Händelseförlopp:
/*INSERT INTO Cart (CostumerId, ProductId) VALUES (1, 2);			-- Skapa en kundvagn för en kund med en produkt (GPU - Radeon).
UPDATE Cart SET Amount = 2 WHERE Id = 1;						-- Uppdaterar hur många varor kunden har i kundvagnen.
INSERT INTO [Order] (ProductId, CostumerId, Amount)				-- Kopierar värdena från Cart till [Order]-tabellen (detta för att ge det ett ordernummer).
	SELECT CostumerId, ProductId, Amount FROM Cart
	WHERE Id = 1;
DELETE FROM Cart WHERE Id = 1;									-- Tar bort Id:t från Cart-tabellen. */
-- INSERT INTO Reserved (OrderId, StorageId) VALUES (1, 2);		-- Lägger in en reservation för order 1 som är kopplat till ett Id i lagret.

----------------------------------------------------- ListProducts SP:
CREATE OR ALTER PROCEDURE ListProducts
@SelectedCategoryId int,
@RowsToSkip int = 0,
@RowsAmount int = 3
AS
BEGIN
	SELECT Product.Id, [Name], Price FROM Product
	WHERE CategoryId = @SelectedCategoryId
	ORDER BY PopularityScore DESC
	OFFSET @RowsToSkip ROWS FETCH NEXT @RowsAmount ROWS ONLY;		-- Pagination. OFFSET = The number of rows to skip. FETCH = The amount of rows after the OFFSET that's returned.
END

-- Test:
EXEC ListProducts @SelectedCategoryId = 1, @RowsToSkip = 1, @RowsAmount = 2;


-- SELECT * FROM Product;
-- SELECT * FROM 

-- TODO: Kan man på något sätt får reda på max-värdet av rows (när man använder OFFSET) så att användarens klient vet när det räcker?
-- TODO: Testa pagnation med mer testdata. Detta är mer intressant att använda i klienten.
-- TODO: Hur hanterar man att ingen @SelectedCategoryId väljs? Ska SP:n returnera en felkod?
-- Visa produkter baserat på vald Category (sorterad efter Popularity).
	-- Bonus: Option för att sortera efter andra saker en popularity.
	-- Bonus: Möjlighet att välja flera kategorier. Använd den då istället en SELECT på den; sortera i klienten.
	----------------------------------------------------- SearchProduct SP:
CREATE OR ALTER PROCEDURE SearchProduct
@SearchString varchar(50) = NULL,	-- NULL = Empty string/all Products.
@CategoryId int = NULL,		-- NULL = All categories.
@IsAvailable bit = 0,		-- 0 = Shows Product even if there are none in Stock. 1 = The Product need to be at Stock.Amount > 0.
@SortColumn int = 0,		-- 0 = Popularity, 2 = Price, 3 = Name.
@SortOrder bit = 0,			-- 0 = ASC, 1 = DESC.
@RowsToSkip int = 0,		-- The number of rows (from the top of the serch result) to exclude.
@RowsAmount int = 3			-- Number of rows after @RowsToSkip to include.
AS
BEGIN
--	PRINT 'SearchString: ' + @SearchString + ' CategoryId: ' + CAST (@CategoryId AS varchar(50)) + ' IsAvailable: ' + CAST(@IsAvailable AS varchar(50)) + ' SortColumn: ' + CAST(@SortColumn AS varchar(50)) + ' SortOrder: ' + CAST(@SortOrder AS varchar(50));

	SELECT Product.Id, Product.[Name], Product.Price
	FROM Product
	INNER JOIN Storage ON Storage.ProductId = Product.Id
	WHERE
		[Name] LIKE '%' + @SearchString + '%'
		AND (@IsAvailable = 0 OR(@IsAvailable = 1 AND Storage.Amount > 0))		-- Antingen måste @IsAvailable vara 0 OR så måste @IsAvailable vara 1 AND Storage.Amount > 0.
		AND (@CategoryId IS NULL OR(@CategoryId = Product.CategoryId))
	ORDER BY
		CASE WHEN @SortOrder = 1 AND @SortColumn = 0 THEN Product.PopularityScore END DESC,
		CASE WHEN @SortOrder = 1 AND @SortColumn = 1 THEN Product.Price END DESC,
		CASE WHEN @SortOrder = 1 AND @SortColumn = 2 THEN Product.[Name] END DESC,
		CASE WHEN @SortOrder = 0 AND @SortColumn = 0 THEN Product.PopularityScore END, 
		CASE WHEN @SortOrder = 0 AND @SortColumn = 1 THEN Product.Price END,
		CASE WHEN @SortOrder = 0 AND @SortColumn = 2 THEN Product.[Name] END
	OFFSET @RowsToSkip ROWS FETCH NEXT @RowsAmount ROWS ONLY;
END


-- Test:
-- 0 = Popularity, 2 = Price, 3 = Name.
EXEC SearchProduct @SearchString = '', @CategoryId = 1;
EXEC SearchProduct @SearchString = '', @IsAvailable = 1, @SortColumn = 2, @SortOrder = 3;
EXEC SearchProduct @SearchString = '', @CategoryId = 2, @IsAvailable = 12, @SortColumn = 2, @SortOrder = 1, @RowsToSkip = 0, @RowsAmount = 3;
EXEC SearchProduct @SearchString = '', @IsAvailable = 1, @SortColumn = 0, @SortOrder = 1;
SELECT * FROM Product;
-- Sökfunktion: Sök på något och få tillbaka de Products som matchar.
	-- Bonus: Lägg till popularitet till något ifall man söker på det. Behöver göra en UPDATE på alla Product som matchar sökningen.
	-- Bonus: Man kan skriva in * och det översätts till %!
	-- Bonus: Möjlighet att söka på flera kategorier (@CategoryId) än en.
----------------------------------------------------- UpdatePopularity SP:
CREATE OR ALTER PROCEDURE UpdatePopularity
@AddedScore int,
@ProductId int,
@ProductAmount int = 1
AS
BEGIN
	IF @AddedScore IS NOT NULL AND @ProductId IS NOT NULL
		UPDATE Product SET Product.PopularityScore += (@AddedScore * @ProductAmount) WHERE Product.Id = @ProductId;
END

-- Test:
EXEC UpdatePopularity @AddedScore = 1, @ProductId = 8;
SELECT * FROM Product;

-- TODO: Måste kunna ta amount också, detta för att man ska kunna multiplicera med antalet produkter som lagts till. Detta är ett designval. Vet inte om det är bästa popularitets-algoritmen.

-- Ska köras då användaren använder ProductDetail, lägger till i AddToCart eller kör CheckoutCart.
-- Problem: Det hela är rätt så flawed. Man kan bara spamma vissa saker (som SP:n ProductDetail) för att scoren ska öka. Borde vara någon cooldown.
-- Bonus: Uppdatera score beroende på senaste datumet som Scoren uppdaterades på? Verkligare scenario är att detta kanske körs en gång om dagen (nattid) för att uppdatera alla produkters score.
	-- Använd en egen tabell för "globala variabler". Kan t.ex. spara LastPopularityUpdate och LastProductIdUpdated (för att användas i en StorageTransaction-trigger).
	-- Detta borde göras i backend-klienten.
----------------------------------------------------- ProductDetail SP:
CREATE OR ALTER PROCEDURE ProductDetail
@SelectedProductId int = NULL
AS
BEGIN
	SELECT Product.Id, Category.[Name], Product.[Name], Product.Price, Storage.Amount FROM Product
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
@CurrentUserId int,					-- When no "=" is used an argument with a value is required (the argument can still use NULL as a value).
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
			EXEC UpdatePopularity @ProductId = @ProductId, @AddedScore = 5, @ProductAmount = @ProductAmount;
		END
		ELSE IF (SELECT Amount + @ProductAmount FROM Cart WHERE Cart.ProductId = @ProductId AND Cart.CostumerId = @CurrentUserId) = 0
		BEGIN
--			PRINT 'DELETE!';
			DELETE FROM Cart WHERE Cart.ProductId = @ProductId AND Cart.CostumerId = @CurrentUserId;
			EXEC UpdatePopularity @ProductId = @ProductId, @AddedScore = 5, @ProductAmount = @ProductAmount;
			--UpdatePopularity
		END
		ELSE IF @ProductId IN (SELECT ProductId FROM Cart WHERE Cart.CostumerId = @CurrentUserId)
		BEGIN
--			PRINT 'UPDATE!';
			UPDATE Cart SET Cart.Amount += @ProductAmount WHERE Cart.ProductId = @ProductId AND Cart.CostumerId = @CurrentUserId;
			EXEC UpdatePopularity @ProductId = @ProductId, @AddedScore = 5, @ProductAmount = @ProductAmount;
			--UpdatePopularity
		END
	END
	ELSE
		PRINT 'Error: One or more arguments is NULL.';
END
-- TODO: Använd en trigger på Cart som tar bort raden ifall Cart.Amount <= 0?
-- TODO: Måste buggtesta. Är möjligt att få negativ PopularityScore även fast ingen vara läggs till eller tas bort från Cart. T.ex. då man kör en AddToCart när Cart är tom från början.

-- Test:
-- Testa MINUS!
EXEC AddToCart @CurrentUserId = 2, @ProductId = 3, @ProductAmount = -10;
SELECT * FROM Cart;
SELECT * FROM Product;

SELECT * FROM Costumer;
EXEC AddToCart @CurrentUserId = 1, @ProductId = NULL, @ProductAmount = 2;

INSERT INTO Cart (CostumerId, ProductId, Amount) VALUES (3, 5, 1);
DELETE FROM Cart;
INSERT INTO Cart (CostumerId, ProductId, Amount) VALUES (1, 3, 3);
-- TODO: Ska ta bort Cart ifall Amount <= 0.
-- @CurrentUserId är ännu en sak man skulle vilja hantera som en "global variabel". Är därmed bättre att hantera i backend-klienten.
-- If the ProductId already is in the cart the amount will increment with 1.
-- If we decrement the Amount and it reaches 0 the Cart is removed.
-- Add a feature to remove the card instantly (withouh having to reach 0).

-- Kolla dessa:
-- https://docs.microsoft.com/en-us/sql/t-sql/statements/create-procedure-transact-sql?view=sql-server-ver15
-- https://docs.microsoft.com/en-us/sql/relational-databases/in-memory-oltp/a-guide-to-query-processing-for-memory-optimized-tables?view=sql-server-ver15
-- https://docs.microsoft.com/en-us/sql/relational-databases/in-memory-oltp/creating-natively-compiled-stored-procedures?view=sql-server-ver15
-- Bättre prestanda och man kan sätta en parameter som "NOT NULL".
----------------------------------------------------- ListCartContent SP:
CREATE OR ALTER PROCEDURE ListCartContent
@CurrentUser int
AS
BEGIN
	SELECT Product.Id, Product.[Name], Product.Price, Cart.Amount FROM Cart
	INNER JOIN Product ON Product.Id = Cart.ProductId
	WHERE Cart.CostumerId = @CurrentUser;
END

-- TODO: Borde JOINa tabeller för att skriva ut namn på åt minsone produkten.
-- Test:
EXEC ListCartContent @CurrentUser = 2;
EXEC AddToCart @CurrentUserId = 1, @ProductId = 1, @ProductAmount = 2;
EXEC AddToCart @CurrentUserId = 2, @ProductId = 3, @ProductAmount = 2;
EXEC AddToCart @CurrentUserId = 1, @ProductId = 2, @ProductAmount = 2;
EXEC AddToCart @CurrentUserId = 2, @ProductId = 4, @ProductAmount = 2;
SELECT * FROM Cart;
-- List the content in a cart with a specific Id.
----------------------------------------------------- CheckoutCart SP:
CREATE OR ALTER PROCEDURE CheckoutCart
@CurrentUserId int
AS
BEGIN
	DECLARE @RandomOrdernumber int;
	SET @RandomOrdernumber = CAST(RAND() * 100000000 + @CurrentUserId AS int);
--	PRINT @RandomOrdernumber;
	INSERT INTO [Order] (CostumerId, ProductId, Ordernumber, Amount)
		SELECT CostumerId, ProductId, @RandomOrdernumber, Amount
		FROM Cart
		WHERE Cart.CostumerId = @CurrentUserId;

	DELETE FROM Cart
		WHERE Cart.CostumerId = @CurrentUserId;
END

-- Test:
EXEC CheckoutCart @CurrentUserId = 1;

SELECT * FROM Cart;
SELECT * FROM [Order];

-- TODO: Random-algoritmen är rätt dålig. Borde baseras på datum eller något för att minimera risken att duplicates uppstår.
-- TODO: Borde sätta en Order.Ordernumber här!
-- Copies the values from Cart to [Order].
-- Remove the Cart.
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
----------------------------------------------------- NewUser SP:
--CREATE OR ALTER PROCEDURE NewUser
--@UserName
-- TODO: Fortsätt här!
--SELECT * FROM Costumer
-- Lägger till ny användare.
-- Om man ska ha flera "nivår" borde kanske dessa vara separerade. Känns inte helt smart att blanda kunder med användare som har högre privelegier?
----------------------------------------------------- UpdateCostumer SP:
-- Uppdaterar info för en användare.
----------------------------------------------------- Deliver order SP:
-- Används av personalen.
-- [Order].Delivered = 1
-- Calls the "NewTransaction" SP.
-- UPDATE Storage.Amount

-- DELETE FROM Reserved WHERE Id = 1;								-- Ta bort reservation.
--INSERT INTO [Order] (ProductId, CostumerId, Amount) VALUES (1, 1, 1);			-- Testdata för att leverera order.
-- INSERT INTO Reserved (OrderId, StorageId) VALUES (2, 1);		-- 
--INSERT INTO [Order] (ProductId, CostumerId, Amount) VALUES (2, 1, 3);			-- Testdata för att leverera order.
-- INSERT INTO Reserved (OrderId, StorageId) VALUES (3, 2);		-- 
-- Vi behöver tabellerna Storage, Order och Reserved.
-- [Order] för att läsa Amount och ProductId.
-- Reserved behövs för att kunna välja en specifik [Order] (Id) att läsa [Amount] ifrån. Detta då vi kan ha flera rader i [Order] men vi vill endast använda Amount från en specifik av dem.
-- Storage för att vi där ska ändra Amount för ett specfikt ProductId.
-- Kommer att ligga i en SP (namn: DeliverOrder) som tar ett Id (på en [Order]. Alternativt att man kan skriva in ett specifikt "Ordernumber") som argument.
	-- Ska uppdatera Storage så att det Amount man har i [Order] dras av i Storage.
	-- Ska sätta [Order].Delivered till true.
	-- Ta bort den Reserved som tillhör den specifika ordern (Sätta [Order].Delivered manuellt (steget ovan) kanske inte behövs ifall man använder en trigger på Reserved (då den ändras)?

-- WHERE Reserved.OrderId = @USERINPUT

-- Denna UPDATE ska ta Id:t på en [Order] och 
/* UPDATE Storage SET Storage.Amount -= O.Amount
FROM [Order] AS O
WHERE O.ProductId = Storage.ProductId;

SELECT Storage SET Storage.Amount -= O.Amount
FROM [Order] AS O
INNER JOIN Reserved ON [Order].Id = Reserved.OrderId
WHERE O.Id = Reserved.OrderId; */

/* CREATE OR ALTER PROCEDURE UpdateStorage
@SelectedOrderId int = NULL
AS
UPDATE Storage SET Storage.Amount -= O.Amount
FROM [Order] AS O, Reserved AS R
WHERE Storage.ProductId = (
SELECT [Order].ProductId FROM Reserved
INNER JOIN [Order] ON [Order].Id = Reserved.OrderId
INNER JOIN Storage ON Storage.Id = Reserved.StorageId
WHERE [Order].Id = @SelectedOrderId
) 
GO;

-- WHERE: Vilka rows som ska uppdateras.

-- Vill läsa [Order].Id någonstans..
EXEC UpdateStorage @SelectedOrderId = 2; */

CREATE OR ALTER PROCEDURE DeliverOrder
@SelectedOrdernumber int
AS
BEGIN
	UPDATE [Order] SET [Order].Delivered = 1
	WHERE [Order].Ordernumber = @SelectedOrdernumber;

	-- TODO: Vi måste även kolla vilken produkt ifall det är så att flera produkter påverkas. En while-loop?
	-- Använd SUM istället?
	DECLARE @LoopCounter int = 1;
	PRINT @LoopCounter;		-- DEBUG.

	CREATE TABLE #temptable
		(Id int PRIMARY KEY IDENTITY(1,1), ProductId int NOT NULL, Amount int NOT NULL);

	INSERT INTO #temptable (ProductId, Amount)
		SELECT [Order].ProductId, [Order].Amount
		FROM [Order]
		WHERE [Order].Ordernumber = @SelectedOrdernumber;

		SELECT * FROM #temptable;			-- DEBUG.

	WHILE @LoopCounter <= (SELECT COUNT(Id) FROM [Order] WHERE [Order].Ordernumber = @SelectedOrdernumber)
	BEGIN
--	SELECT * FROM [Order];
--		SELECT * INTO #temptable FROM [Order] WHERE [Order].Ordernumber = @SelectedOrdernumber;
--		SELECT * FROM #Temptable;
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
--			SELECT [Order].ProductId FROM [Order]
--			WHERE [Order].Ordernumber = @SelectedOrdernumber
		)

		SET @LoopCounter += 1;
--		PRINT @LoopCounter;			--DEBUG
	END
-- Använd SP som skapar StorageTransaction här! Ska ta en in-parameter (transactionReason)
--INSERT INTO StorageTransaction (ProductId, Amount, ReasonId)
--SELECT ProductID, Amount, LastTransactionReasonId FROM [Order];
END
-- Ska sätta [Order].Delivered till true.
-- Måste också kolla ifall [Order].Delivered är false innan man ändrar värdet. Om det inte är sant skicka tillbaka ett felmeddelande (se vecka 11? OUTPUT?).

-- Vill läsa [Order].Id någonstans..
EXEC DeliverOrder @SelectedOrdernumber = 63249852;
-- Test:
SELECT * FROM [Order];
SELECT * FROM Storage;
DELETE FROM [Order] WHERE Id = 3;
UPDATE [Order] SET [Order].Delivered = 0;
UPDATE [Order] SET [Order].Amount = 10 WHERE Id = 1;

-- TODO: Måste lägga till "NewTransaction" någonstans.
------- Test:
SELECT * FROM Cart;
-- SELECT * FROM Reserved;
SELECT * FROM [Order];
SELECT * FROM Storage;


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
	-- NewTransaction hantterar endast diff-värden. Om man vill ha något annat än en diff måste man skriva detta i denna SP (StorageAdjustment).
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
----------------------------------------------------- Transaction SP:
CREATE OR ALTER PROCEDURE NewTransaction
--@TransactionReason int = NULL,
@OrderId int = NULL,
@ProductId int = NULL,
@Amount int = NULL
AS
BEGIN
	PRINT @OrderId;
	IF @OrderId IS NOT NULL
	BEGIN
		PRINT 'OrderId is NOT NULL';
		IF (SELECT [Order].ReturnAmount FROM [Order] WHERE [Order].Id = @OrderId) IS NULL
		BEGIN
			PRINT 'Delivery (not a Return)';
			INSERT INTO StorageTransaction (ProductId, Amount, ReasonId)
			SELECT ProductID, (Amount * -1), 1 FROM [Order] WHERE [Order].Id = @OrderId;
		END
		ELSE IF (SELECT [Order].ReturnAmount FROM [Order] WHERE [Order].Id = @OrderId) IS NOT NULL
		BEGIN
			PRINT 'Return';
			INSERT INTO StorageTransaction (ProductId, Amount, ReasonId)
			SELECT ProductID, ReturnAmount, 2 FROM [Order] WHERE [Order].Id = @OrderId;
		END
	END
	ELSE IF @ProductId IS NOT NULL AND @Amount IS NOT NULL
	BEGIN
		PRINT 'Product';
		INSERT INTO StorageTransaction (ProductId, Amount, ReasonId)
		VALUES (@ProductId, @Amount, 3);
		-- Problem: Måste på något sätt veta ifall det är ett negativt eller positivt värde som skrvits in; StorageTransaction ska hålla en differens!
		-- Lösningen just nu: Denna SP tar ett +/--värde som läggs till i StorageTransaction. Det är SP:n som kallar på NewTransaction som får lösa eventuella omvandlingar.
	END
	ELSE
	BEGIN
		PRINT 'Not a valid option';
	END
END

-- TODO: Se över if-satser och NULL-värden i parametrarna.

EXEC NewTransaction @OrderId = 2;
EXEC NewTransaction @ProductId = 2, @Amount = 10;

-- Test:
UPDATE [Order] SET [Order].ReturnAmount = 2 WHERE Id = 2;
SELECT * FROM [Order];
SELECT * FROM StorageTransaction;
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
--SELECT * FROM Popularity;
SELECT * FROM Product;
SELECT * FROM [Order];
SELECT * FROM Costumer;
SELECT * FROM Cart;
--SELECT * FROM Reserved;
SELECT * FROM Storage;
SELECT * FROM StorageTransaction;
SELECT * FROM TransactionReason;