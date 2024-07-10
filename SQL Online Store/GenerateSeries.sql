/* Create stored procedure generate_series() since mySQL doesn't have this */
DELIMITER //
CREATE PROCEDURE generate_random_orders(in num_orders int)
BEGIN
	DECLARE i INT DEFAULT 0;
    DECLARE customer_count INT;
    DECLARE product_count INT;
	-- Get counts of Customers and Products
    SELECT COUNT(*) INTO customer_count FROM Customers;
    SELECT COUNT(*) INTO product_count FROM Products;
    
    WHILE i < num_orders DO
        INSERT INTO Orders (customer_id, product_id, quantity_ordered, order_date, payment_type)
        VALUES (
			FLOOR(RAND() * customer_count) + 1,        -- Random customer_id starting from 1
            FLOOR(RAND() * product_count) + 1001,      -- Random product_id starting from 1001
            FLOOR(RAND() * 5) + 1,                       -- Random quantity_ordered (1 to 5 items)
            TIMESTAMPADD(SECOND, FLOOR(RAND() * TIMESTAMPDIFF(SECOND, '2023-01-01', '2023-12-31')), '2023-01-01'), -- Random order_date between '2023-01-01' and '2023-12-31'
            CASE FLOOR(RAND() * 2) WHEN 0 THEN 'Credit' ELSE 'Cash' END);
		set i = i + 1;
	END WHILE;
END //
DELIMITER ;