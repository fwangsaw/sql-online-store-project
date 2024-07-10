/* Personal Project - Online Retail Store Database */
/* By Fabian W */
/* GitHub: https://github.com/fwangsaw */

-- ===== Database & Table creation ===== --
CREATE DATABASE OnlineRetailStore;
USE OnlineRetailStore;

CREATE TABLE Customers(
	customer_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    email VARCHAR(100)
);

CREATE TABLE Products(
	product_id INT AUTO_INCREMENT PRIMARY KEY,
    product_name VARCHAR(199) UNIQUE,
    category VARCHAR(50),
    price DECIMAL(10, 2),
    stock_quantity INT DEFAULT 0
) AUTO_INCREMENT = 1000;

create table Orders(
	order_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT,
    product_id INT,
    quantity_ordered INT,
    order_date DATETIME,
    payment_type VARCHAR(20),
    FOREIGN KEY(customer_id) REFERENCES Customers(customer_id),
    FOREIGN KEY(product_id) REFERENCES Products(product_id)
);


-- ===== Data Insertion ===== --
-- Insert 10 product names
INSERT INTO products VALUES            
					(1001, 'Pokemon Red, Green, Blue (Gen 1)', 'Game', 30, 1000),
					(1002, 'Pokemon Gold and Silver (Gen 2)', 'Game', 40, 1000),
					(1003, 'Pokemon Ruby and Sapphire (Gen 3)', 'Game', 40, 1000),
					(1004, 'Pokemon Diamond and Pearl (Gen 4)', 'Game', 40, 1000),
					(1005, 'Pokemon Black and White (Gen 5)', 'Game', 40, 1000),
					(1006, 'Pokemon X and Y (Gen 6)', 'Game', 50, 1000),
					(1007, 'Pokemon Sun and Moon (Gen 7)', 'Game', 50, 1000),
					(1008, 'Pokemon Sword and Shield (Gen 8)', 'Game', 60, 1000),
					(1009, 'Nintendo Switch Carrying Case', 'Accessories', 100, 100),
					(1010, 'Nintendo DS Touch Pen', 'Accessories', 30, 100);
-- Insert 50 random customers
call InsertRandomCustomers(50);
select * from Customers;
-- Insert 1000 orders with unique order_id values
call generate_random_orders(1000);
select * from Orders;


-- ===== Queries/Business Analyst Questions ===== --
-- Find customers' order details including product name and quantities ordered
SELECT 
	a.customer_id,
    a.first_name,
    a.last_name,
    b.product_name,
    c.quantity_ordered 
FROM Customers AS a
INNER JOIN
	Orders AS c ON a.customer_id = c.customer_id
INNER JOIN
	Products AS b ON c.product_id = b.product_id
ORDER BY customer_id LIMIT 100;

-- Find customers who have placed more than 5 orders
SELECT
	first_name,
    last_name,
    (SELECT SUM(quantity_ordered) FROM Orders AS b WHERE b.customer_id = a.customer_id) AS "Total Quantity Ordered"
FROM Customers AS a
WHERE customer_id IN (SELECT DISTINCT customer_id FROM Orders WHERE quantity_ordered >= 5);
-- OR, we can order by highest order quantities --
SELECT
	a.first_name,
    a.last_name,
    SUM(quantity_ordered) AS total_qty_order
FROM
	Customers AS a
INNER JOIN (SELECT customer_id, SUM(quantity_ordered) AS quantity_ordered FROM Orders GROUP BY customer_id) AS b ON a.customer_id = b.customer_id
WHERE b.quantity_ordered >= 5
GROUP BY a.customer_id, a.first_name, a.last_name
ORDER BY total_qty_order DESC;

-- Find top 5 best selling products
SELECT
	a.product_id,
    a.product_name,
    SUM(b.quantity_ordered) as total_qty_order
FROM
	Products AS a
INNER JOIN Orders AS b ON a.product_id = b.product_id
GROUP BY product_id, a.product_name
ORDER BY total_qty_order DESC
LIMIT 5;

-- Calculate the total revenue generated from each product, for the yearly sales
SELECT
	a.product_id,
    a.product_name,
    a.price,
    SUM(b.quantity_ordered) AS total_quantity_ordered,
    SUM(a.price * b.quantity_ordered) AS total_sales
FROM Products AS a
INNER JOIN
	Orders AS b ON a.product_id = b.product_id
WHERE b.order_date BETWEEN '2023-01-01' AND '2023-12-31'
GROUP BY product_id, product_name
ORDER BY total_sales DESC;

-- Finding sales report data that includes total sales for each category and a grand total
SELECT
	a.category,
    SUM(a.price * b.quantity_ordered) AS total_sales
FROM
	Products AS a
INNER JOIN Orders AS b ON a.product_id = b.product_id
GROUP BY a.category WITH ROLLUP
ORDER BY total_sales DESC;

-- Finding best month sales of year 2023
SELECT
	MONTH(a.order_date) AS month_date,
    SUM(a.quantity_ordered * b.price) AS monthly_sales
FROM
	Orders AS a
INNER JOIN Products AS b ON a.product_id = b.product_id
WHERE YEAR(order_date) = 2023 GROUP BY month_date ORDER BY monthly_sales DESC;

-- Count of payment via Cash vs Credit Card
SELECT
	payment_type,
    COUNT(payment_type) AS Total_Usage
FROM Orders
GROUP BY payment_type ORDER BY Total_Usage DESC;

-- Best selling product where type of payment is Cash
SELECT
	b.product_name,
    a.payment_type,
    SUM(a.quantity_ordered) AS total_ordered
FROM Orders AS a
INNER JOIN Products AS b ON a.product_id = b.product_id
WHERE a.payment_type = "Cash"
GROUP BY b.product_name
ORDER BY total_ordered DESC;


-- ===== Triggers & Modifications ===== --
-- Creating a trigger that automatically update stock_quantity in the Products table when an Order is inserted.
CREATE TRIGGER stock_update_after_order_received
AFTER INSERT ON Orders
FOR EACH ROW UPDATE Products SET stock_quantity = stock_quantity - NEW.quantity_ordered
WHERE product_id = NEW.product_id;

-- Adding some constraints on tables because sometimes we couldn't think of it ahead of time
ALTER TABLE Customers MODIFY email VARCHAR(50) DEFAULT NULL;
ALTER TABLE Orders MODIFY quantity_ordered INT NOT NULL DEFAULT 1;
ALTER TABLE Orders MODIFY order_date DATETIME DEFAULT NOW();
ALTER TABLE Orders MODIFY payment_type VARCHAR(20) DEFAULT "Cash";
ALTER TABLE Products MODIFY category VARCHAR(50) DEFAULT "Miscellaneous";
ALTER TABLE Products MODIFY price DECIMAL(10, 2) NOT NULL;

-- END OF PROJECT --




