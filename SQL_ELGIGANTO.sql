USE Student11;

ALTER TABLE [Order] DROP CONSTRAINT FK_Order_Costumer;
ALTER TABLE [Order] DROP CONSTRAINT FK_Order_Product;
ALTER TABLE Storage DROP CONSTRAINT FK_Storage_Product;
--ALTER TABLE Storage DROP CONSTRAINT FK_Storage_Reserved;
DROP TABLE IF EXISTS Popularity;
DROP TABLE IF EXISTS Cart;
DROP TABLE IF EXISTS StorageTransaction;
DROP TABLE IF EXISTS TransactionReason;
DROP TABLE IF EXISTS Costumer;
DROP TABLE IF EXISTS Category;
DROP TABLE IF EXISTS [Order];
DROP TABLE IF EXISTS Reserved;
DROP TABLE IF EXISTS Storage;
DROP TABLE IF EXISTS Product;

DROP PROC IF EXISTS DeliverOrder;

CREATE TABLE Category (Id int PRIMARY KEY IDENTITY(1,1), [Name] varchar (50) NOT NULL UNIQUE);
CREATE TABLE Popularity (Id int PRIMARY KEY IDENTITY(1,1), ProductId int NOT NULL, Popularity int NOT NULL DEFAULT 0);
CREATE TABLE Product (Id int PRIMARY KEY IDENTITY(1,1), CategoryId int NOT NULL, [Name] varchar(50) NOT NULL, Price float(53) NOT NULL);
CREATE TABLE Costumer (Id int PRIMARY KEY IDENTITY(1,1), [Name] varchar(50) NOT NULL, Mail varchar(50) NOT NULL UNIQUE, [Address] varchar(50) NOT NULL);
CREATE TABLE [Order] (Id int PRIMARY KEY IDENTITY(1,1), ProductId int NOT NULL, CostumerId int NOT NULL, Ordernumber int NOT NULL DEFAULT CAST(RAND() * 100 AS int), Amount int NOT NULL, Delivered bit DEFAULT 0);
CREATE TABLE Cart (Id int PRIMARY KEY IDENTITY(1,1), CostumerId int NOT NULL, ProductId int NOT NULL, Amount int NOT NULL DEFAULT 1);
-- CREATE TABLE Reserved (Id int PRIMARY KEY IDENTITY(1,1), OrderId int NOT NULL, StorageId int NOT NULL);					-- Testa utan, se förklaring nedan.
--CREATE TABLE Storage (Id int PRIMARY KEY IDENTITY(1,1), ProductId int NOT NULL, Amount int NOT NULL, ReservedId int);		-- ReservedId ska inte vara här!
CREATE TABLE Storage (Id int PRIMARY KEY IDENTITY(1,1), ProductId int NOT NULL, Amount int NOT NULL);
CREATE TABLE StorageTransaction (Id int PRIMARY KEY IDENTITY(1,1), ProductId int, [Time] datetime DEFAULT GETDATE(), Amount int NOT NULL, ReasonId int NOT NULL);
CREATE TABLE TransactionReason (Id int PRIMARY KEY IDENTITY(1,1), Reason varchar(50) NOT NULL UNIQUE);

-- Vad fyller Reserved för funktion: Håller reda på ett värde för ett specifikt Storage.Id som är kopplat till ett Order.Id.
-- Enda syftet är att kunna koppla "Order.Amount" med ett "Storage.Amount".
-- Alternativ implementation: Ta bort Reserved-tabellen. Ha en kolumn i Order som heter StorageId.
-- Alternativ implementation2: Ta bort Reserved-tabellen. Så länge som Order.Delivered inte är true så är en vara också reserved.
-- Nackdelar med att ta bort Reserved-tabellen: Kan potentiellt vara en prestanda-förlust? Kanske går att lösa med index i rätt kolumner. Om man ska kolla saldon måste man också kolla igenom alla ordrar (levererade och icke-levererade) istället för att bara kolla reserved-tabellen. Kanske går att lösa med ett index?

ALTER TABLE Product ADD CONSTRAINT FK_Product_Category FOREIGN KEY (CategoryId) REFERENCES Category(Id);
ALTER TABLE Popularity ADD CONSTRAINT FK_Popularity_Product FOREIGN KEY (ProductId) REFERENCES Product(Id);
ALTER TABLE [Order] ADD CONSTRAINT FK_Order_Product FOREIGN KEY (ProductId) REFERENCES Product(Id);
ALTER TABLE [Order] ADD CONSTRAINT FK_Order_Costumer FOREIGN KEY (CostumerId) REFERENCES Costumer(Id);
ALTER TABLE Cart ADD CONSTRAINT FK_Cart_Costumer FOREIGN KEY (CostumerId) REFERENCES Costumer(Id);
ALTER TABLE Cart ADD CONSTRAINT FK_Cart_Product FOREIGN KEY (ProductId) REFERENCES Product(Id);
-- ALTER TABLE Reserved ADD CONSTRAINT FK_Reserved_Order FOREIGN KEY (OrderId) REFERENCES [Order](Id);
-- ALTER TABLE Reserved ADD CONSTRAINT FK_Reserved_Storage FOREIGN KEY (StorageId) REFERENCES Storage(Id);
ALTER TABLE Storage ADD CONSTRAINT FK_Storage_Product FOREIGN KEY (ProductId) REFERENCES Product(Id);
-- ALTER TABLE Storage ADD CONSTRAINT FK_Storage_Reserved FOREIGN KEY (ReservedId) REFERENCES Reserved(Id);
ALTER TABLE StorageTransaction ADD CONSTRAINT FK_StorageTrasaction_Product FOREIGN KEY (ProductId) REFERENCES Product(Id);
ALTER TABLE StorageTransaction ADD CONSTRAINT FK_StorageTransaction_Reason FOREIGN KEY (ReasonId) REFERENCES TransactionReason(Id);

-- Problem med FK_Storage_Reserved: Går endast att ha en Reserved per produkt. Är bättre att sköta deetta helt i "Reserved".
-- Lägg till tabell för personal?
-- Onödigt att ha "Id" och "ProductId" i Storage-tabellen? Är alltid samma sak?
-- Trigger ifall man editar Storage eller StorageTransaction som gör att man påverkar båda?
-- Trigger mellan Cart och Order?

-- Hårdkodade värden:
INSERT INTO Category ([Name]) VALUES ('GPU'), ('CPU'), ('RAM');
INSERT INTO TransactionReason (Reason) VALUES ('Delivery'), ('Return'), ('Stock adjustment');

-- Förutbestämd testdata:
INSERT INTO Product (CategoryId, [Name], Price) VALUES (1, 'Voodoo 2', 399.99);
INSERT INTO Product (CategoryId, [Name], Price) VALUES (1, 'Radeon', 349.99);
INSERT INTO Product (CategoryId, [Name], Price) VALUES (2, 'AMD 100 MHz', 299.99);
INSERT INTO Product (CategoryId, [Name], Price) VALUES (2, 'Intel 300 MHz', 599.99);
INSERT INTO Product (CategoryId, [Name], Price) VALUES (3, 'Noname 128 MB', 49.99);
INSERT INTO Product (CategoryId, [Name], Price) VALUES (3, 'Intel 512 MB', 199.99);
INSERT INTO Costumer ([Name], Mail, [Address]) VALUES ('Boris', 'bor@mail.com', 'Hemgatan 2');
INSERT INTO Costumer ([Name], Mail, [Address]) VALUES ('Greger', 'greger@mail.com', 'Husvägen 3');
INSERT INTO Storage (ProductId, Amount) VALUES (1, 10), (2, 20), (3, 50), (4, 60), (5, 70), (6, 100);

-- Händelseförlopp:
INSERT INTO Cart (CostumerId, ProductId) VALUES (1, 2);			-- Skapa en kundvagn för en kund med en produkt (GPU - Radeon).
UPDATE Cart SET Amount = 2 WHERE Id = 1;						-- Uppdaterar hur många varor kunden har i kundvagnen.
INSERT INTO [Order] (ProductId, CostumerId, Amount)				-- Kopierar värdena från Cart till [Order]-tabellen (detta för att ge det ett ordernummer).
	SELECT CostumerId, ProductId, Amount FROM Cart
	WHERE Id = 1;
DELETE FROM Cart WHERE Id = 1;									-- Tar bort Id:t från Cart-tabellen.
-- INSERT INTO Reserved (OrderId, StorageId) VALUES (1, 2);		-- Lägger in en reservation för order 1 som är kopplat till ett Id i lagret.
--------------------------------------- Allt för att leverera order nedanför:
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
-- Problem: Kommer att uppdatera rätt Storage.ProductId men inte ifrån rätt rad i [Order]. Kommer att ta första [Order]-raden.
-- Lösning: Denna måste också välja den rad ([Order].Id) som man valt i @SelectedOrderId.
-- Lösning: Inner join efter FROM? Innan WHERE?
-- SELECT efter +=?
END
-- Ska sätta [Order].Delivered till true.
-- Måste också kolla ifall [Order].Delivered är false innan man ändrar värdet.
-- WHERE: Vilka rows som ska uppdateras.

-- Vill läsa [Order].Id någonstans..
EXEC DeliverOrder @SelectedOrderId = 3;
UPDATE [Order] SET [Order].Delivered = 0;
UPDATE [Order] SET [Order].Amount = 10 WHERE Id = 1;
SELECT * FROM [Order];
SELECT * FROM Storage;

------- Test:
SELECT * FROM Cart;
-- SELECT * FROM Reserved;
SELECT * FROM [Order];
SELECT * FROM Storage;

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

SELECT * FROM Category;
SELECT * FROM Popularity;
SELECT * FROM Product;
SELECT * FROM [Order];
SELECT * FROM Costumer;
SELECT * FROM Cart;
SELECT * FROM Reserved;
SELECT * FROM Storage;
SELECT * FROM StorageTransaction;
SELECT * FROM TransactionReason;