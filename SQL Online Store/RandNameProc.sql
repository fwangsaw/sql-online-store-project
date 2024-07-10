/* Create random list of names and stored procedure for it */
CREATE TEMPORARY TABLE RandomFirstNames (
    first_name VARCHAR(50)
);

CREATE TEMPORARY TABLE RandomLastNames (
    last_name VARCHAR(50)
);

INSERT INTO RandomFirstNames (first_name) VALUES 
('John'), ('Jane'), ('Duke'), ('Sayaka'), ('Ken'), 
('Stephen'), ('Quincy'), ('Kira'), ('Gwen'), ('Laura'),
('Ashley'), ('Elizabeth'), ('George'), ('Santiago'), ('Tanaka');

INSERT INTO RandomLastNames (last_name) VALUES 
('Smith'), ('Junior'), ('Matsumoto'), ('Ortega'), ('Brecken'), 
('Holmes'), ('Yamamoto'), ('McGuire'), ('Cruz'), ('Martinez'),
('Zhang'), ('Chang'), ('Blackwell'), ('Inoue'), ('Nguyen');

-- Stored procedure
DELIMITER //

CREATE PROCEDURE InsertRandomCustomers(IN num_customers INT)
BEGIN
    DECLARE i INT DEFAULT 0;
    DECLARE fname VARCHAR(50);
    DECLARE lname VARCHAR(50);
    DECLARE email_val VARCHAR(100);

    WHILE i < num_customers DO
        -- Select random first and last names
        SELECT first_name INTO fname 
        FROM RandomFirstNames 
        ORDER BY RAND() LIMIT 1;

        SELECT last_name INTO lname 
        FROM RandomLastNames 
        ORDER BY RAND() LIMIT 1;
        
        -- Generate email
        SET email_val = CONCAT(lower(fname), '.', lower(lname), '@gmail.com');
        
        -- Insert into Customers table
        INSERT INTO Customers (first_name, last_name, email) 
        VALUES (fname, lname, email_val);
        
        SET i = i + 1;
    END WHILE;
END //

DELIMITER ;
