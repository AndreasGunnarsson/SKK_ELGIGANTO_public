USE Student11;

ALTER TABLE [Order] DROP CONSTRAINT FK_Order_Costumer;
ALTER TABLE [Order] DROP CONSTRAINT FK_Order_Product;
ALTER TABLE Storage DROP CONSTRAINT FK_Storage_Product;
ALTER TABLE Storage DROP CONSTRAINT FK_Storage_Reserved;
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

CREATE TABLE Category (Id int PRIMARY KEY IDENTITY(1,1), [Name] varchar (50) NOT NULL UNIQUE);
CREATE TABLE Popularity (Id int PRIMARY KEY IDENTITY(1,1), ProductId int NOT NULL, Popularity int NOT NULL DEFAULT 0);
CREATE TABLE Product (Id int PRIMARY KEY IDENTITY(1,1), CategoryId int NOT NULL, [Name] varchar(50) NOT NULL, Price float(53) NOT NULL);
CREATE TABLE Costumer (Id int PRIMARY KEY IDENTITY(1,1), [Name] varchar(50) NOT NULL, Mail varchar(50) NOT NULL UNIQUE, [Address] varchar(50) NOT NULL);
CREATE TABLE [Order] (Id int PRIMARY KEY IDENTITY(1,1), ProductId int NOT NULL, CostumerId int NOT NULL, Ordernumber int NOT NULL DEFAULT CAST(RAND() * 100 AS int), Amount int NOT NULL);
CREATE TABLE Cart (Id int PRIMARY KEY IDENTITY(1,1), CostumerId int NOT NULL, ProductId int NOT NULL, Amount int NOT NULL DEFAULT 1);
CREATE TABLE Reserved (Id int PRIMARY KEY IDENTITY(1,1), OrderId int NOT NULL, StorageId int NOT NULL);
CREATE TABLE Storage (Id int PRIMARY KEY IDENTITY(1,1), ProductId int NOT NULL, Amount int NOT NULL, ReservedId int);
CREATE TABLE StorageTransaction (Id int PRIMARY KEY IDENTITY(1,1), ProductId int, [Time] datetime DEFAULT GETDATE(), Amount int NOT NULL, ReasonId int NOT NULL);
CREATE TABLE TransactionReason (Id int PRIMARY KEY IDENTITY(1,1), Reason varchar(50) NOT NULL UNIQUE);

ALTER TABLE Product ADD CONSTRAINT FK_Product_Category FOREIGN KEY (CategoryId) REFERENCES Category(Id);
ALTER TABLE Popularity ADD CONSTRAINT FK_Popularity_Product FOREIGN KEY (ProductId) REFERENCES Product(Id);
ALTER TABLE [Order] ADD CONSTRAINT FK_Order_Product FOREIGN KEY (ProductId) REFERENCES Product(Id);
ALTER TABLE [Order] ADD CONSTRAINT FK_Order_Costumer FOREIGN KEY (CostumerId) REFERENCES Costumer(Id);
ALTER TABLE Cart ADD CONSTRAINT FK_Cart_Costumer FOREIGN KEY (CostumerId) REFERENCES Costumer(Id);
ALTER TABLE Cart ADD CONSTRAINT FK_Cart_Product FOREIGN KEY (ProductId) REFERENCES Product(Id);
ALTER TABLE Reserved ADD CONSTRAINT FK_Reserved_Order FOREIGN KEY (OrderId) REFERENCES [Order](Id);
ALTER TABLE Reserved ADD CONSTRAINT FK_Reserved_Storage FOREIGN KEY (StorageId) REFERENCES Storage(Id);
ALTER TABLE Storage ADD CONSTRAINT FK_Storage_Product FOREIGN KEY (ProductId) REFERENCES Product(Id);
ALTER TABLE Storage ADD CONSTRAINT FK_Storage_Reserved FOREIGN KEY (ReservedId) REFERENCES Reserved(Id);
ALTER TABLE StorageTransaction ADD CONSTRAINT FK_StorageTrasaction_Product FOREIGN KEY (ProductId) REFERENCES Product(Id);
ALTER TABLE StorageTransaction ADD CONSTRAINT FK_StorageTransaction_Reason FOREIGN KEY (ReasonId) REFERENCES TransactionReason(Id);

-- L�gg till tabell f�r personal?
-- On�digt att ha "Id" och "ProductId" i Storage-tabellen? �r alltid samma sak?
-- Trigger ifall man editar Storage eller StorageTransaction som g�r att man p�verkar b�da?
-- Trigger mellan Cart och Order?

-- H�rdkodade v�rden:
INSERT INTO Category ([Name]) VALUES ('GPU'), ('CPU'), ('RAM');
INSERT INTO TransactionReason (Reason) VALUES ('Delivery'), ('Return'), ('Stock adjustment');

-- F�rutbest�md testdata:
INSERT INTO Product (CategoryId, [Name], Price) VALUES (1, 'Voodoo 2', 399.99);
INSERT INTO Product (CategoryId, [Name], Price) VALUES (1, 'Radeon', 349.99);
INSERT INTO Product (CategoryId, [Name], Price) VALUES (2, 'AMD 100 MHz', 299.99);
INSERT INTO Product (CategoryId, [Name], Price) VALUES (2, 'Intel 300 MHz', 599.99);
INSERT INTO Product (CategoryId, [Name], Price) VALUES (3, 'Noname 128 MB', 49.99);
INSERT INTO Product (CategoryId, [Name], Price) VALUES (3, 'Intel 512 MB', 199.99);
INSERT INTO Costumer ([Name], Mail, [Address]) VALUES ('Boris', 'bor@mail.com', 'Hemgatan 2');
INSERT INTO Costumer ([Name], Mail, [Address]) VALUES ('Greger', 'greger@mail.com', 'Husv�gen 3');
INSERT INTO Storage (ProductId, Amount) VALUES (1, 10), (2, 5), (3, 50), (4, 55), (5, 70), (6, 105);


INSERT INTO Cart (CostumerId, ProductId) VALUES (1, 2);			-- Skapa en kundvagn f�r en kund med en produkt (grafikkort - Radeon).
UPDATE Cart SET Amount = 2 WHERE Id = 1;						-- Uppdaterar hur m�nga varor kunden har i kundvagnen.
INSERT INTO [Order] (ProductId, CostumerId, Amount)				-- Kopierar v�rdena fr�n Cart till [Order]-tabellen (detta f�r att ge det ett ordernummer).
SELECT CostumerId, ProductId, Amount FROM Cart
WHERE Id = 3;
DELETE FROM Cart WHERE Id = 2;									-- Tar bort Id:t fr�n Cart-tabellen.
INSERT INTO Reserved (OrderId, StorageId) VALUES ()
SELECT * FROM Reserved;
SELECT * FROM [Order];
SELECT * FROM Storage;
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