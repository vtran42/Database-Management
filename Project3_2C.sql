/* 2C */
/* Create the new table - CUST_INVOICE*/
CREATE TABLE CUST_INVOICE(
	InvoiceNumber		Int			NOT NULL,
	DateIn				DATETIME	NOT NULL,
	DateOut				DATETIME	NOT NULL,
	Subtotal			DECIMAL(8,2),
	Tax					DECIMAL(8,2),
	TotalAmount			DECIMAL(8,2),
	CustomerID			Int		NOT NULL,
	CONSTRAINT			CustInvoicePK	PRIMARY KEY(InvoiceNumber),
	CONSTRAINT			CustInvoiceAK	UNIQUE(CustomerID,DateIn,DateOut),
	CONSTRAINT			CustInvoiceFK	FOREIGN KEY(CustomerID)
		REFERENCES		CUSTOMER(CustomerID)
			ON UPDATE	NO	ACTION
			ON DELETE	NO	ACTION,	
	CONSTRAINT			DateOutCheck	CHECK(DateOut > DateIn),
);
/* Copy the data from INVOICE to CUST_INVOICE */
INSERT INTO CUST_INVOICE
( InvoiceNumber, DateIn, DateOut, Subtotal, Tax, TotalAmount, CustomerID)
SELECT InvoiceNumber, DateIn, DateOut, Subtotal, Tax, TotalAmount, CustomerID
FROM INVOICE;
/* Run to verify that all changes have been made correctly */
ALTER TABLE INVOICE_ITEM
DROP CONSTRAINT InvoiceFK;
/* Drop old table INVOICE */
DROP TABLE INVOICE;


/* 2E */
CREATE TABLE CUSTOMER_INVOICE_INT (
	CustomerID  INT NOT NULL,
	InvoiceNumber INT NOT NULL,
	
	CONSTRAINT CustomerInvoice_PK PRIMARY KEY (CustomerID, InvoiceNumber),
	CONSTRAINT CustomerInvoice_Int_FK 
		FOREIGN KEY (InvoiceNumber) REFERENCES CUST_INVOICE(InvoiceNumber),
	CONSTRAINT CustomerInvoice_FK 
		FOREIGN KEY (CustomerID) REFERENCES CUSTOMER(CustomerID)
);

INSERT INTO CUSTOMER_INVOICE_INT(CustomerID, InvoiceNumber)
	SELECT CustomerID, InvoiceNumber
	FROM CUST_INVOICE
	WHERE CustomerID IS NOT NULL;

/*2F */
SELECT LastName, FirstName, CustomerID
FROM CUSTOMER
ORDER BY LastName, FirstName;

/*2H */
/* Drop the Constraints in Customer Table */
ALTER TABLE CUSTOMER
	DROP CONSTRAINT CustomerPK;
/* Add and Drop the Constraints in Customer Table */
ALTER TABLE CUSTOMER
	ADD CONSTRAINT CustomerPK PRIMARY KEY (LastName, FirstName);
/* Add two columns LastName and FirstName into the INVOICE table */
ALTER TABLE CUST_INVOICE
	ADD LastName Char30 NOT NULL;
ALTER TABLE CUST_INVOICE
	ADD FirstName Char25 NOT NULL;
/* Drop and add Constraint in CUST_INVOICE */
ALTER TABLE CUST_INVOICE
	DROP CONSTRAINT InvoiceFK;
ALTER TABLE CUST_INVOICE
	ADD CONSTRAINT InvoiceFK FOREIGN KEY (LastName, FirstName) REFERENCES CUSTOMER;


/* CREATE VIEW */
CREATE VIEW DeleteInvoiceView As
	SELECT *
	FROM CUST_INVOICE;

CREATE VIEW DeleteInvoiceItemView As
	SELECT *
	FROM INVOICE_ITEM;
/*TRIGGER Code to Delete All Invoice but last child*/
CREATE TRIGGER INVOICEITEM_DeleteCheck
	INSTEAD OF DELETE ON DeleteInvoiceItemView;
DECLARE 
	rowcount int;
BEGIN
	/* First determine if this is the last invoice in the InvoiceItem */
	SELECT Count(*) into rowcount
	FROM INVOICE_ITEM
	WHERE INVOICE_ITEM.InvoiceNumber = old:InvoiceNumber;

	IF (rowcount > 1)
	THEN
		/*Not last Invoice, allow deletetion */
		DELETE INVOICE_ITEM
		WHERE INVOICE_ITEM.InvoiceNumber = old:InvoiceNumber;
	ELSE
		/* Send a message to user saying that the last invoice in the invoice */
		/* in a INVOICE cannot be deleted*/
	END IF;
END;

/* Trigger Code to DELETE Last Child and Parent When necessary */
CREATE TRIGGER INVOICE_ITEM_DeleteCheck 
	INSTEAD OF DELETE ON DeleteInvoiceITem2View
DECLARE 
	rowcount int;
BEGIN
	/* First determine if this is the last Invoice in the InvoiceItem */
	SELECT Count(*) into rowcount
	FROM CUST_INVOICE
	WHERE CUST_INVOICE.InvoiceNumber = old:InvoiceNumber;
	/* Delete Employee row regardless of whether InvoiceItem is deleted */
	DELETE CUST_INVOICE
	WHERE CUST_INVOICE.InvoiceNumber = old:InvoiceNumber;

	IF(rowcount = 1)
	THEN
	/* Last Customer Invoice in InvoiceItem, delete InvoiceNumber*/
	DELETE INVOICE_ITEM
	WHERE INVOICE_ITEM.ItemNumber = old:ItemNumber;
	
	END IF;
END;