/* CREATE TABLE STATEMENT
Set the first value of CustomerID  = 100, increment by 5
Use FOREIGN KEY constraints to create appropriate referential integrity constraints
Set UPDATE and DELETE behavior in accordance with your referential integrity action design
Set default value of Quantity to 1
Write a constraint that SERVICE.UnitPrice be between 1.50 and 10.00
*/
CREATE TABLE CUSTOMER (
	CustomerID		Int			NOT NULL		IDENTITY (100,5),
	FirstName		Char(25)	NOT NULL,
	LastName		Char(30)	NOT NULL,
	Phone			Char(12)	NOT NULL,
	Email			Char(30)	NULL,
	CONSTRAINT	CustomerPK		PRIMARY KEY(CustomerID),
	CONSTRAINT	CustomerAK1		UNIQUE(LastName,FirstName),
	CONSTRAINT	CustomerAK2		UNIQUE(Phone),
	CONSTRAINT	CustomerAK3		UNIQUE(Email),
	CONSTRAINT	EmailCheck		CHECK( '@' IN (Email))
);
/***** Create table INVOICE *******/
CREATE TABLE INVOICE(
	InvoiceNumber		Int			NOT NULL		IDENTITY(1,1),
	DateIn				DATETIME	NOT NULL,
	DateOut				DATETIME	NOT NULL,
	Subtotal			DECIMAL(8,2),
	Tax					DECIMAL(8,2),
	TotalAmount			DECIMAL(8,2),
	CustomerID			Int		NOT NULL,
	CONSTRAINT			InvoicePK	PRIMARY KEY(InvoiceNumber),
	CONSTRAINT			InvoiceAK	UNIQUE(CustomerID,DateIn,DateOut),
	CONSTRAINT			CustomerFK	FOREIGN KEY(CustomerID)
		REFERENCES		CUSTOMER(CustomerID)
			ON UPDATE	NO	ACTION
			ON DELETE	NO	ACTION,	
	CONSTRAINT			DateOutCheck	CHECK(DateOut > DateIn),
);

/***** TABLE SERVICE *****/
CREATE TABLE [SERVICE](
	ServiceID			INT				NOT NULL	IDENTITY(1,1),
	ServiceDescription	Char(255)		NOT NULL,
	UnitPrice			Decimal(4,2)	NOT NULL,
	CONSTRAINT			ServicePK		PRIMARY KEY(ServiceID),
	CONSTRAINT			UnitPriceCheck	Check ( UnitPrice BETWEEN 1.5 AND 10.00)
);

/**** TABLE INVOICE_ITEM ****/
CREATE TABLE INVOICE_ITEM(
	ItemNumber		INT				NOT NULL	IDENTITY(1,1),
	Quantity		INT				NOT NULL	DEFAULT	1,
	UnitPrice		DECIMAL(4,2)	NOT NULL	,
	ExtendedPrice	DECIMAL(4,2)	NULL,
	InvoiceNumber	INT				NOT NULL,
	ServiceID		INT				NOT NULL,
	CONSTRAINT		INVOICE_ITEMPK	PRIMARY KEY(ItemNumber,InvoiceNumber),
	CONSTRAINT		ServiceFK	FOREIGN KEY(ServiceID)
		REFERENCES	[SERVICE](ServiceID)
			ON UPDATE	NO	ACTION
			ON DELETE	CASCADE,
	CONSTRAINT		InvoiceFK	FOREIGN KEY(InvoiceNumber)
		REFERENCES	INVOICE(InvoiceNumber)
			ON UPDATE	NO ACTION
			ON DELETE	NO ACTION,
);

/*
Write INSERT statements to insert at least three rows into each table. Use the data
shown in Figures 2-33, 2-34, and 2-35 as a starting point, and create any other data
needed for the revised set of tables used here.
*/
/***** CUSTOMER ************/ 
INSERT INTO CUSTOMER
(CustomerID,FirstName,LastName,Phone,Email)
VALUES(120,'George','Miller',723-654-4322,'George.Miller@somewhere.com')

INSERT INTO CUSTOMER
(CustomerID,FirstName,LastName,Phone,Email)
VALUES(125,'Kathy','Miller',723-514-9877,'Kathy.Miller@somewhere.com')

INSERT INTO CUSTOMER
(CustomerID,FirstName,LastName,Phone,Email)
VALUES(130,'Betsy','Miller',723-514-8766,'Betsy.Miller@somewhere.com')

/****** SERVICE ***********/
INSERT INTO [SERVICE]
(ServiceID,ServiceDescription,UnitPrice)
VALUES(45,'Suit-Women''s',8.50)

INSERT INTO [SERVICE]
(ServiceID,ServiceDescription,UnitPrice)
VALUES(50,'Tuxedo',10.00)

INSERT INTO [SERVICE]
(ServiceID,ServiceDescription,UnitPrice)
VALUES(60,'Formal Gown',10.00)

INSERT INTO [SERVICE]
(ServiceID,ServiceDescription,UnitPrice)
VALUES(10,'Men''s Shirt',1.50)

/****** INVOICE **************/
INSERT INTO INVOICE
(InvoiceNumber,CustomerID,DateIn,DateOut,Subtotal,Tax,TotalAmount)
VALUES(2011005,125,'07-Oct-11','11-Oct-11',12.00,0.95,12.95)

INSERT INTO INVOICE
(InvoiceNumber,CustomerID,DateIn,DateOut,Subtotal,Tax,TotalAmount)
VALUES(2011008,130,'12-Oct-11','14-Oct-11',140.50,11.10,151.60)

INSERT INTO INVOICE
(InvoiceNumber,CustomerID,DateIn,DateOut,Subtotal,Tax,TotalAmount)
VALUES(2011009,120,'12-Oct-11','14-Oct-11',27.00,2.13,29.13)

/***** INVOICE_ITEM ************/
INSERT INTO INVOICE_ITEM
(InvoiceNumber,ItemNumber,ServiceID,Quantity,UnitPrice,ExtendedPrice)
VALUES(2011005,1,16,2,3.50,7.00)

INSERT INTO INVOICE_ITEM
(InvoiceNumber,ItemNumber,ServiceID,Quantity,UnitPrice,ExtendedPrice)
VALUES(2011008,4,25,10,6.00,60.00)

INSERT INTO INVOICE_ITEM
(InvoiceNumber,ItemNumber,ServiceID,Quantity,UnitPrice,ExtendedPrice)
VALUES(2011009,1,40,3,9.00,27.00)

/*Write an UPDATE statement to change values of SERVICE.Description from Mens
Shirt to Mens’ Shirts */
UPDATE		[SERVICE]
	SET		ServiceDescription = 'Mens'' Shirt'
	WHERE [SERVICE].ServiceID = 10;

/*Write a DELETE statement(s) to delete an INVOICE and all of the items on that
INVOICE */
DELETE	FROM INVOICE
WHERE	CustomerID = 120;

/*Create a view called OrderSummaryView that contains
INVOICE.InvoiceNumber,INVOICE.DateIn, INVOICE.DateOut,
INVOICE_ITEM.ItemNumber, INVOICE_ITEM. Service,and
INVOICE_ITEM.ExtendedPrice */
CREATE VIEW OrderSummaryView AS
	SELECT INVOICE.InvoiceNumber, INVOICE.DateIn,INVOICE.DateOut,
			INVOICE_ITEM.ItemNumber, INVOICE_ITEM.ServiceID, INVOICE_ITEM.ExtendedPrice
	FROM INVOICE, INVOICE_ITEM;
/**** SQL VIEW */
SELECT *
FROM OrderSummaryView
ORDER BY InvoiceNumber

/*Create a view called CustomerOrderSummaryView that contains
INVOICE.InvoiceNumber,CUSTOMER.FirstName, CUSTOMER.LastName,
CUSTOMER.Phone, INVOICE.DateIn,INVOICE.DateOut, INVOICE.SubTotal,
INVOICE_ITEM.ItemNumber, INVOICE_ITEM.Service,and
INVOICE_ITEM.ExtendedPrice
*/
CREATE VIEW CustomerOrderSummaryView AS
	SELECT INVOICE.InvoiceNumber, CUSTOMER.FirstName, CUSTOMER.LastName,CUSTOMER.Phone,
			INVOICE.DateIn, INVOICE.DateOut,INVOICE.Subtotal,
			INVOICE_ITEM.ItemNumber, INVOICE_ITEM.ServiceID, INVOICE_ITEM.ExtendedPrice
	FROM CUSTOMER, INVOICE,INVOICE_ITEM
SELECT *
FROM CustomerOrderSummaryView
ORDER BY LastName;

/*Create a view called CustomerOrderHistoryView that 
(1) includes all columns ofCustomer-OrderSummaryView except INVOICE_ITEM.ItemNumber and
INVOICE_ITEM.Service, 
(2) groups orders by CUSTOMER.LastName,CUSTOMER.FirstName andINVOICE.InvoiceNumber in that order, and 
(3) sums and averages INVOICE_ITEM.ExtendedPricefor each order for each customer */
CREATE VIEW CustomerOrderHistoryView AS
	SELECT	InvoiceNumber, FirstName,LastName,Phone,DateIn, 
			DateOut,Subtotal,
			SUM(ExtendedPrice),AVG(ExtendedPrice) 
	FROM CustomerOrderSummaryView
	GROUP BY LastName, FirstName, InvoiceNumber
	ORDER BY LastName, FirstName, InvoiceNumber

SELECT *
FROM CustomerOrderHistoryView

/*Create a view called CustomerOrderCheckView that uses CustomerOrderHistoryView
and that shows that any customers for whom the sum of
INVOICE_ITEM.ExtendedPrice is not equal to INVOICE.Subtotal */
CREATE VIEW CustomerOrderCheckView AS
	SELECT *
	FROM CustomerOrderHistoryView,INVOICE,INVOICE_ITEM
	WHERE sum(INVOICE_ITEM.ExtendedPrice) != INVOICE.Subtotal

SELECT *
FROM CustomerOrderCheckView;
