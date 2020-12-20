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
DROP PROC IF EXISTS ProductDetail;
DROP PROC IF EXISTS DeliverOrder;
DROP PROC IF EXISTS StorageAdjustment;
DROP PROC IF EXISTS NewTransaction;

CREATE TABLE Category (Id int PRIMARY KEY IDENTITY(1,1), [Name] varchar (50) NOT NULL UNIQUE);
--CREATE TABLE Popularity (Id int PRIMARY KEY IDENTITY(1,1), ProductId int NOT NULL UNIQUE, Popularity int NOT NULL DEFAULT 0);
--CREATE TABLE Popularity (Id int PRIMARY KEY IDENTITY(1,1), Popularity int NOT NULL DEFAULT 0);
--CREATE TABLE Product (Id int PRIMARY KEY IDENTITY(1,1), PopularityId int NOT NULL UNIQUE, CategoryId int NOT NULL, [Name] varchar(50) NOT NULL, Price float(53) NOT NULL CONSTRAINT CHK_Product_Price CHECK (Price > 0));
CREATE TABLE Product (Id int PRIMARY KEY IDENTITY(1,1), PopularityScore int NOT NULL DEFAULT 0, CategoryId int NOT NULL, [Name] varchar(50) NOT NULL, Price float(53) NOT NULL CONSTRAINT CHK_Product_Price CHECK (Price > 0));
CREATE TABLE Costumer (Id int PRIMARY KEY IDENTITY(1,1), [Name] varchar(50) NOT NULL, Mail varchar(50) NOT NULL UNIQUE, [Address] varchar(50) NOT NULL);
--CREATE TABLE [Order] (Id int PRIMARY KEY IDENTITY(1,1), ProductId int NOT NULL, CostumerId int NOT NULL, Ordernumber int NOT NULL DEFAULT CAST(RAND() * 100 AS int), Amount int NOT NULL, Delivered bit DEFAULT 0);
CREATE TABLE [Order] (Id int PRIMARY KEY IDENTITY(1,1), ProductId int NOT NULL, CostumerId int NOT NULL, Ordernumber int NOT NULL DEFAULT CAST(RAND() * 100 AS int), Amount int NOT NULL, Delivered bit DEFAULT 0, ReturnAmount int, CONSTRAINT CHK_Order_ReturnAmount CHECK (ReturnAmount > 0 AND ReturnAmount <= Amount));		-- Instead of using a CONSTRAINT on just one column it's used on the whole table. Needed if we want to compare values from different columns
--SELECT * FROM [Order];
--UPDATE [Order] SET ReturnAmount = 4 WHERE Id = 2;
CREATE TABLE Cart (Id int PRIMARY KEY IDENTITY(1,1), CostumerId int NOT NULL, ProductId int NOT NULL, Amount int NOT NULL DEFAULT 1 CONSTRAINT CHK_Cart_Amount CHECK (Amount > 0));
--CREATE TABLE Reserved (Id int PRIMARY KEY IDENTITY(1,1), OrderId int NOT NULL, StorageId int NOT NULL);					-- Testa utan, se förklaring nedan.
--CREATE TABLE Storage (Id int PRIMARY KEY IDENTITY(1,1), ProductId int NOT NULL, Amount int NOT NULL, ReservedId int);		-- ReservedId ska inte vara här!
CREATE TABLE Storage (Id int PRIMARY KEY IDENTITY(1,1), ProductId int NOT NULL, Amount int NOT NULL);
--CREATE TABLE Storage (Id int PRIMARY KEY IDENTITY(1,1), ProductId int NOT NULL, Amount int NOT NULL, LastTransactionReasonId int);
CREATE TABLE StorageTransaction (Id int PRIMARY KEY IDENTITY(1,1), ProductId int, [Time] datetime DEFAULT GETDATE(), Amount int NOT NULL, ReasonId int NOT NULL);
CREATE TABLE TransactionReason (Id int PRIMARY KEY IDENTITY(1,1), Reason varchar(50) NOT NULL UNIQUE);

-- Test:
/* INSERT INTO Cart (CostumerId, ProductId) VALUES (1, 2);
UPDATE Cart SET Amount -= 1;
SELECT * FROM Cart;
SELECT * FROM Product
INSERT INTO Product (CategoryId, [Name], Price) VALUES (1, 'fef', 0.1)
INSERT INTO Popularity (ProductId) VALUES (12);			-- Test for constraint */

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
INSERT INTO Product (CategoryId, PopularityScore, [Name], Price) VALUES (1, 10, 'Voodoo 2', 399.99), (1, 15, 'Radeon', 349.99), (1, 20, 'GeForce', 449.99);
INSERT INTO Product (CategoryId, PopularityScore, [Name], Price) VALUES (2, 40, 'AMD 100 MHz', 299.99), (2, 35, 'Intel 300 MHz', 599.99), (2, 30, 'Intel 333 MHz', 699.99);
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
@SelectedCategoryId int = NULL
AS
BEGIN
	SELECT Product.Id, [Name], Price, PopularityScore FROM Product			-- TODO: Ta bort Popularity.Popularity, endast för debug.
	WHERE CategoryId = @SelectedCategoryId
	ORDER BY PopularityScore DESC;
END

EXEC ListProducts @SelectedCategoryId = 3;

-- TODO: Felhantering, vad händer ifall man skriver in en kategori som inte existerar?

-- SELECT * FROM Product;
-- SELECT * FROM 

-- Visa produkter baserat på vald Category (sorterad efter Popularity).
	-- Bonus: Option för att sortera efter andra saker en popularity.
----------------------------------------------------- UpdatePopularity SP:
-- Ska köras då användaren använder ProductDetail, lägger till i ChangeCart eller kör CheckoutCart.
-- Tar ett värde som en artikel ska uppdateras med.
----------------------------------------------------- SearchProduct SP:
-- Sökfunktion: Sök på något och få tillbaka de Products som matchar.
	-- Sök-toggle: Visa endast de som finns tillgängliga i lager.
	-- Sortering: popularitet, pris och namn.
	-- Bonus: Lägg till popularitet till något ifall man söker på det.
----------------------------------------------------- ProductDetail SP:
CREATE OR ALTER PROCEDURE ProductDetail
@SelectedProductId int = NULL
AS
BEGIN
	-- TODO: Kör SP för att uppdatera Popularity för vald Product.
	SELECT Product.Id, Category.[Name], Product.[Name], Product.Price, Storage.Amount FROM Product
	INNER JOIN Storage ON Storage.ProductId = Product.Id
	INNER JOIN Category ON Category.Id = Product.CategoryId
	WHERE Product.Id = @SelectedProductId;
END

-- TODO: Hur hanterar man "Reserved" (måste kolla [Order].ReturnAmount)?

EXEC ProductDetail @SelectedProductId = 5;
-- Produktdetaljer. Skriv in ett Product.Id.
	-- Ska visa Name, Category, Price och lagerstatus.
----------------------------------------------------- ListCartContent SP:
-- List the content in a cart with a specific Id.
----------------------------------------------------- ChangeCart SP:
-- If the ProductId already is in the cart the amount will increment with 1.
-- If we decrement the Amount and it reaches 0 the Cart is removed.
-- Add a feature to remove the card instantly (withouh having to reach 0).
----------------------------------------------------- CheckoutCart SP:
-- Copis the values from Cart to [Order].
-- Remove the Cart.
----------------------------------------------------- UpdateOrder SP:
-- Används ifall en kund vill returnera en vara.
-- Går att uppdatera [Order].ReturnAmount med denna.
----------------------------------------------------- AddRemoveProduct SP:
-- Lägger till/tar bort en Product. Måste också ta bort dess Popularity i samma veva.
-- Kan behöva en ON DELETE CASCADE på FK:n i tabeller här..
----------------------------------------------------- UpdateProduct SP:
-- Updaterar pris och description på en Product.
----------------------------------------------------- NewCostumer SP:
-- Lägger till ny användare.
----------------------------------------------------- UpdateCostumer SP:
-- Uppdaterar info för en användare.


----------------------------------------------------- Deliver order SP:
-- Används av personalen.
-- [Order].Delivered = 1
-- Calls the "NewTransaction" SP.
-- UPDATE Storage.Amount

-- DELETE FROM Reserved WHERE Id = 1;								-- Ta bort reservation.
INSERT INTO [Order] (ProductId, CostumerId, Amount) VALUES (1, 1, 1);			-- Testdata för att leverera order.
-- INSERT INTO Reserved (OrderId, StorageId) VALUES (2, 1);		-- 
INSERT INTO [Order] (ProductId, CostumerId, Amount) VALUES (2, 1, 3);			-- Testdata för att leverera order.
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
@SelectedOrderId int = NULL
AS
BEGIN
UPDATE [Order] SET [Order].Delivered = 1
WHERE [Order].Id = @SelectedOrderId;

UPDATE Storage SET Storage.Amount -=
(
	SELECT [Order].Amount
	FROM [Order]
	WHERE [Order].Id = @SelectedOrderId
)
FROM [Order]
WHERE Storage.ProductId =
(
	SELECT [Order].ProductId FROM [Order]
	WHERE [Order].Id = @SelectedOrderId
)
-- Använd SP som skapar StorageTransaction här! Ska ta en in-parameter (transactionReason)
--INSERT INTO StorageTransaction (ProductId, Amount, ReasonId)
--SELECT ProductID, Amount, LastTransactionReasonId FROM [Order];
END
-- Ska sätta [Order].Delivered till true.
-- Måste också kolla ifall [Order].Delivered är false innan man ändrar värdet. Om det inte är sant skicka tillbaka ett felmeddelande (se vecka 11? OUTPUT?).

-- Vill läsa [Order].Id någonstans..
EXEC DeliverOrder @SelectedOrderId = 2;
-- Test:
UPDATE [Order] SET [Order].Delivered = 0;
UPDATE [Order] SET [Order].Amount = 10 WHERE Id = 1;
SELECT * FROM [Order];
SELECT * FROM Storage;

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