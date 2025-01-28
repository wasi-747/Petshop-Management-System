-- DROP EXISTING TABLES IF THEY EXIST
DROP TABLE IF EXISTS Sold_Pets, Sales, Payments, Addresses, Customers, Pets, Phone, Animals, Birds, Pet_Products, Sales_Details;

-- CUSTOMERS TABLE
CREATE TABLE Customers (
    cs_id INT PRIMARY KEY AUTO_INCREMENT,
    cs_fname VARCHAR(50) NOT NULL,
    cs_minit VARCHAR(5),
    cs_lname VARCHAR(50) NOT NULL
);

-- ADDRESSES TABLE (1:1 RELATION WITH CUSTOMERS)
CREATE TABLE Addresses (
    address_id INT PRIMARY KEY AUTO_INCREMENT,
    cs_id INT NOT NULL,
    cs_address VARCHAR(255) NOT NULL,
    FOREIGN KEY (cs_id) REFERENCES Customers(cs_id) ON DELETE CASCADE
);

-- PHONE TABLE (CUSTOMERS CAN HAVE MULTIPLE PHONE NUMBERS)
CREATE TABLE Phone (
    phone_id INT PRIMARY KEY AUTO_INCREMENT,
    cs_id INT NOT NULL,
    cs_phone BIGINT NOT NULL,
    FOREIGN KEY (cs_id) REFERENCES Customers(cs_id) ON DELETE CASCADE
);

-- PETS TABLE
CREATE TABLE Pets (
    pet_id INT PRIMARY KEY AUTO_INCREMENT,
    pet_category VARCHAR(50) NOT NULL,
    cost DECIMAL(10,2) NOT NULL
);

-- SALES TABLE
CREATE TABLE Sales (
    sd_id INT PRIMARY KEY AUTO_INCREMENT,
    cs_id INT NOT NULL,
    payment_id INT NOT NULL,
    date DATE NOT NULL,
    FOREIGN KEY (cs_id) REFERENCES Customers(cs_id) ON DELETE CASCADE
);

-- PAYMENTS TABLE
CREATE TABLE Payments (
    payment_id INT PRIMARY KEY AUTO_INCREMENT,
    payment_method VARCHAR(50) NOT NULL
);

-- SOLD_PETS TABLE (MANY-TO-MANY RELATIONSHIP BETWEEN SALES AND PETS)
CREATE TABLE Sold_Pets (
    sale_id INT NOT NULL,
    pet_id INT NOT NULL,
    FOREIGN KEY (sale_id) REFERENCES Sales(sd_id) ON DELETE CASCADE,
    FOREIGN KEY (pet_id) REFERENCES Pets(pet_id) ON DELETE CASCADE
);

-- PET_PRODUCTS TABLE
CREATE TABLE Pet_Products (
    pp_id INT PRIMARY KEY AUTO_INCREMENT,
    pp_name VARCHAR(50) NOT NULL,
    pp_type VARCHAR(20) NOT NULL,
    cost DECIMAL(10,2) NOT NULL,
    belongs_to VARCHAR(50)
);

-- ANIMALS TABLE
CREATE TABLE Animals (
    pet_id INT PRIMARY KEY,
    breed VARCHAR(50),
    weight FLOAT,
    height FLOAT,
    age INT,
    fur VARCHAR(30),
    FOREIGN KEY (pet_id) REFERENCES Pets(pet_id) ON DELETE CASCADE
);

-- BIRDS TABLE
CREATE TABLE Birds (
    pet_id INT PRIMARY KEY,
    type VARCHAR(50),
    noise VARCHAR(30),
    FOREIGN KEY (pet_id) REFERENCES Pets(pet_id) ON DELETE CASCADE
);

-- EXAMPLES OF COMPLEX QUERIES

-- 1. FETCH MOST EXPENSIVE PET IN EACH CATEGORY
SELECT pet_category, MAX(cost) AS max_cost
FROM Pets
GROUP BY pet_category;

-- 2. TOTAL SALES REVENUE GROUPED BY PAYMENT METHOD
SELECT p.payment_method, SUM(pt.cost) AS total_revenue
FROM Payments p
INNER JOIN Sales s ON p.payment_id = s.payment_id
INNER JOIN Sold_Pets sp ON s.sd_id = sp.sale_id
INNER JOIN Pets pt ON sp.pet_id = pt.pet_id
GROUP BY p.payment_method;

-- 3. FETCH CUSTOMER SALES WITH TOTAL PURCHASE AMOUNT
SELECT c.cs_id, CONCAT(c.cs_fname, ' ', c.cs_lname) AS customer_name, 
       SUM(pt.cost) AS total_spent
FROM Customers c
INNER JOIN Sales s ON c.cs_id = s.cs_id
INNER JOIN Sold_Pets sp ON s.sd_id = sp.sale_id
INNER JOIN Pets pt ON sp.pet_id = pt.pet_id
GROUP BY c.cs_id;

-- 4. FILTER CUSTOMERS WHO SPENT MORE THAN AVERAGE SALES REVENUE
SELECT c.cs_id, CONCAT(c.cs_fname, ' ', c.cs_lname) AS customer_name, 
       SUM(pt.cost) AS total_spent
FROM Customers c
INNER JOIN Sales s ON c.cs_id = s.cs_id
INNER JOIN Sold_Pets sp ON s.sd_id = sp.sale_id
INNER JOIN Pets pt ON sp.pet_id = pt.pet_id
GROUP BY c.cs_id
HAVING total_spent > (SELECT AVG(pt.cost) FROM Pets pt);

-- 5. JOIN: SALES DETAILS INCLUDING CUSTOMER, PAYMENT METHOD, AND PETS
SELECT s.sd_id, CONCAT(c.cs_fname, ' ', c.cs_lname) AS customer_name,
       p.payment_method, s.date, GROUP_CONCAT(pt.pet_category) AS pets_purchased,
       SUM(pt.cost) AS total_cost
FROM Sales s
INNER JOIN Customers c ON s.cs_id = c.cs_id
INNER JOIN Payments p ON s.payment_id = p.payment_id
INNER JOIN Sold_Pets sp ON s.sd_id = sp.sale_id
INNER JOIN Pets pt ON sp.pet_id = pt.pet_id
GROUP BY s.sd_id;

-- 6. SUBQUERY: FILTER PETS SOLD IN MULTIPLE SALES
SELECT pt.pet_id, pt.pet_category, COUNT(sp.sale_id) AS times_sold
FROM Pets pt
INNER JOIN Sold_Pets sp ON pt.pet_id = sp.pet_id
GROUP BY pt.pet_id
HAVING times_sold > 1;

-- 7. TRIGGER: PREVENT UPDATING PETS THAT HAVE BEEN SOLD
DELIMITER $$
CREATE TRIGGER prevent_sold_pet_update
BEFORE UPDATE ON Pets
FOR EACH ROW
BEGIN
    IF (SELECT COUNT(*) FROM Sold_Pets WHERE pet_id = OLD.pet_id) > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Cannot update sold pet details';
    END IF;
END$$
DELIMITER ;

-- 8. VIEW: CUSTOMER SPENDING SUMMARY
CREATE VIEW Customer_Spending AS
SELECT c.cs_id, CONCAT(c.cs_fname, ' ', c.cs_lname) AS customer_name,
       SUM(pt.cost) AS total_spent
FROM Customers c
INNER JOIN Sales s ON c.cs_id = s.cs_id
INNER JOIN Sold_Pets sp ON s.sd_id = sp.sale_id
INNER JOIN Pets pt ON sp.pet_id = pt.pet_id
GROUP BY c.cs_id;

-- 9. FETCH PRODUCTS USED FOR SPECIFIC PET TYPES (e.g., Dogs)
SELECT pp.pp_name, pp.pp_type, pp.cost
FROM Pet_Products pp
WHERE pp.belongs_to = 'dog';

-- 10. CALCULATE TOTAL SALES PER CUSTOMER PER MONTH
SELECT c.cs_id, CONCAT(c.cs_fname, ' ', c.cs_lname) AS customer_name, 
       DATE_FORMAT(s.date, '%Y-%m') AS sales_month, 
       SUM(pt.cost) AS monthly_spent
FROM Customers c
INNER JOIN Sales s ON c.cs_id = s.cs_id
INNER JOIN Sold_Pets sp ON s.sd_id = sp.sale_id
INNER JOIN Pets pt ON sp.pet_id = pt.pet_id
GROUP BY c.cs_id, sales_month;
