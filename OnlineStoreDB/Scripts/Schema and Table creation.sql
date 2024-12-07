--------------------------------------------------------
-- Creates an OnlineStore database
--------------------------------------------------------
IF NOT EXISTS(SELECT * FROM sys.databases WHERE name = 'OnlineStore')
	BEGIN
		CREATE DATABASE OnlineStore;
	END

USE OnlineStoreDB;



--------------------------------------------------------
-- Creates schemas for the tables
--------------------------------------------------------
CREATE SCHEMA person;

CREATE SCHEMA sales;

CREATE SCHEMA production;


--------------------------------------------------------
-- Creates tables
--------------------------------------------------------
CREATE TABLE person.customer(
	customer_id		INT				NOT NULL IDENTITY (1, 1),
	name			VARCHAR (100)	NOT NULL,
	address			VARCHAR (255)	NOT NULL,
	city			VARCHAR (50)	NOT NULL,
	state			VARCHAR (2)		NOT NULL,
	zip_code		VARCHAR (5)		NOT NULL,
	phone			VARCHAR (25)	NULL,
	email			VARCHAR (100)	NOT NULL,
	wishlist		VARCHAR (255)	NULL,
	credit_card_id	VARCHAR (30)	NOT NULL,
	expiration_date	VARCHAR (5)		NOT NULL,
	holder_name		VARCHAR (50)	NOT NULL,
	[description]	VARCHAR (2000)	NULL,
	CONSTRAINT pk_customer PRIMARY KEY (customer_id)
);

CREATE TABLE production.product_category(
	product_category_id	INT				NOT NULL IDENTITY (1, 1),
	name				VARCHAR (50)	NOT NULL,
	parent_category_id	INT				NULL,
	CONSTRAINT pk_product_category PRIMARY KEY (product_category_id),
	CONSTRAINT fk_product_category_self 
		FOREIGN KEY (parent_category_id) 
		REFERENCES production.product_category(product_category_id)
);

------------------------------------------------------------------------------------------
CREATE TABLE production.product(
	product_id			INT				NOT NULL IDENTITY (1, 1),
	product_number		VARCHAR (7)		NOT NULL,
	name				VARCHAR (255)	NOT NULL,
	vendor_name			VARCHAR (255)	NOT NULL,
	compatible_os		VARCHAR (50)	NULL,
	required_disk_space	FLOAT			NULL,
	required_ram		FLOAT			NULL,
	weight				FLOAT			NULL,
	height				FLOAT			NULL,
	width				FLOAT			NULL,
	length				FLOAT			NULL,
	product_category_id	INT				NOT NULL,
	list_price			DECIMAL (10, 2) NOT NULL,
	CONSTRAINT pk_product PRIMARY KEY (product_id),
	CONSTRAINT fk_product_product_category FOREIGN KEY (product_category_id) 
		REFERENCES production.product_category (product_category_id) 
		ON DELETE CASCADE 
		ON UPDATE NO ACTION
);

-------------------------------------------------------------------------------------
CREATE TABLE sales.[order](
	order_id			INT				NOT NULL IDENTITY (1, 1),
	customer_id			INT				NOT NULL,
	status				VARCHAR (50)	NOT NULL,
	order_date			DATETIME		NOT NULL,
	CONSTRAINT pk_order PRIMARY KEY (order_id),
	CONSTRAINT fk_order_customer FOREIGN KEY(customer_id) 
		REFERENCES person.customer (customer_id) 
		ON DELETE CASCADE 
		ON UPDATE NO ACTION
);
--------------------------------------------------------------------------------------
CREATE TABLE sales.order_item(
	order_id		INT NOT NULL,
	item_id			INT NOT NULL,
	product_id		INT NOT NULL,
	quantity		INT NOT NULL,
	CONSTRAINT pk_order_item PRIMARY KEY (order_id, item_id),
	CONSTRAINT fk_order_item_order FOREIGN KEY (order_id)
		REFERENCES sales.[order] (order_id) 
		ON DELETE CASCADE 
		ON UPDATE NO ACTION,
	CONSTRAINT fk_order_item_product FOREIGN KEY (product_id) 
		REFERENCES production.product (product_id) 
		ON DELETE NO ACTION 
		ON UPDATE NO ACTION
);

----------------------------------------------------------------------------------------
CREATE TABLE sales.order_shipment(
	order_shipment_id	INT				NOT NULL IDENTITY (1, 1),
	order_id			INT				NOT NULL,
	created_at			DATETIME		NOT NULL,
	price				DECIMAL (10, 2) NOT NULL,
	CONSTRAINT pk_order_shipment PRIMARY KEY (order_shipment_id),
	CONSTRAINT fk_order_shipment_order FOREIGN KEY(order_id)
		REFERENCES sales.[order] (order_id) 
		ON DELETE CASCADE 
		ON UPDATE NO ACTION
);
----------------------------------------------------------------------------------------
CREATE TABLE production.review(
	product_id		INT				NOT NULL,
	author_id		INT				NOT NULL,
	content			VARCHAR (4000)	NOT NULL,
	rating			INT				NOT NULL,
	review_date		DATETIME		NOT NULL,
	CONSTRAINT pk_review PRIMARY KEY (product_id, author_id),
	CONSTRAINT fk_review_product FOREIGN KEY (product_id) 
		REFERENCES production.product (product_id) 
		ON DELETE CASCADE 
		ON UPDATE NO ACTION,
	CONSTRAINT fk_review_customer FOREIGN KEY (author_id) 
		REFERENCES person.customer (customer_id) 
		ON DELETE CASCADE 
		ON UPDATE NO ACTION,
	CONSTRAINT chk_review_raiting_range CHECK(rating >= 0 and rating <= 5)
);

CREATE TABLE production.review_image(
	review_image_id		INT				NOT NULL IDENTITY (1, 1),
	product_id			INT				NOT NULL,
	author_id			INT				NOT NULL,
	image_url			VARCHAR(500)	NOT NULL,
	CONSTRAINT pk_review_image PRIMARY KEY (product_id, author_id, review_image_id),
	CONSTRAINT fk_review_image_product FOREIGN KEY (product_id) 
		REFERENCES production.product (product_id) 
		ON DELETE CASCADE 
		ON UPDATE NO ACTION,
	CONSTRAINT fk_review_image_customer FOREIGN KEY (author_id) 
		REFERENCES person.customer (customer_id) 
		ON DELETE CASCADE 
		ON UPDATE NO ACTION,
);
--------------------------------------------------------------------------------------
CREATE TABLE dbo.migration_history(
	migration_history_id	INT				NOT NULL,
	description				VARCHAR(500)	NOT NULL,
	CONSTRAINT pk_migration_history PRIMARY KEY (migration_history_id)
);
-----------------------------------------------------------------------------------
