

CREATE TABLE Country (
    country_id INT PRIMARY KEY,
    country_name VARCHAR(255) NOT NULL
);

CREATE TABLE City (
    city_id INT PRIMARY KEY,
    country_id INT,
    city_name VARCHAR(255) NOT NULL,
    FOREIGN KEY (country_id) REFERENCES Country(country_id)
);

CREATE TABLE Street (
    street_id INT PRIMARY KEY,
    city_id INT,
    street_name VARCHAR(255) NOT NULL,
    FOREIGN KEY (city_id) REFERENCES City(city_id)
);

CREATE TABLE Product (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(255) NOT NULL
);

CREATE TABLE Supplier_Address (
    address_id INT PRIMARY KEY,
    street_id INT,
    building VARCHAR(10),
    FOREIGN KEY (street_id) REFERENCES Street(street_id)
);

CREATE TABLE Customer_Address (
    address_id INT PRIMARY KEY,
    street_id INT,
    building VARCHAR(10),
    FOREIGN KEY (street_id) REFERENCES Street(street_id)
);

CREATE TABLE Supplier (
    supplier_id INT PRIMARY KEY,
    last_name VARCHAR(255),
    first_name VARCHAR(255),
    middle_name VARCHAR(255),
    phone VARCHAR(20),
    address_id INT,
    FOREIGN KEY (address_id) REFERENCES Supplier_Address(address_id)
);

CREATE TABLE Customer (
    customer_id INT PRIMARY KEY,
    last_name VARCHAR(255),
    first_name VARCHAR(255),
    middle_name VARCHAR(255),
    birth_date DATE,
    address_id INT,
    FOREIGN KEY (address_id) REFERENCES Customer_Address(address_id)
);

CREATE TABLE Supply (
    supply_id SERIAL PRIMARY KEY,
    supplier_id INT,
    supply_date DATE,
    product_id INT,
    quantity INT,
    FOREIGN KEY (supplier_id) REFERENCES Supplier(supplier_id),
    FOREIGN KEY (product_id) REFERENCES Product(product_id)
);

CREATE TABLE Customer_Order (
    order_id INT PRIMARY KEY,
    order_date DATE,
    customer_id INT,
    product_id INT,
    quantity INT,
    FOREIGN KEY (customer_id) REFERENCES Customer(customer_id),
    FOREIGN KEY (product_id) REFERENCES Product(product_id)
);


/* 2.Вставка данных */ 

INSERT INTO Country (country_id, country_name) VALUES
(1, 'Россия'),
(2, 'США');

INSERT INTO City (city_id, country_id, city_name) VALUES
(1, 1, 'Москва'),
(2, 2, 'Нью-Йорк');

INSERT INTO Street (street_id, city_id, street_name) VALUES
(1, 1, 'Тверская'),
(2, 2, 'Бродвей');

INSERT INTO Supplier_Address (address_id, street_id, building) VALUES
(1, 1, '10'),
(2, 2, '100');

INSERT INTO Customer_Address (address_id, street_id, building) VALUES
(1, 1, '20'),
(2, 2, '200');

INSERT INTO Supplier (supplier_id, last_name, first_name, middle_name, phone, address_id) VALUES
(1, 'Иванов', 'Иван', 'Иванович', '123456', 1),
(2, 'Джонсон', 'Майкл', 'Эдвардович', '789123', 2);

INSERT INTO Customer (customer_id, last_name, first_name, middle_name, birth_date, address_id) VALUES
(1, 'Сидоров', 'Алексей', 'Петрович', '1990-05-20', 1),
(2, 'Смит', 'Джон', 'Робертович', '1985-10-15', 2);

INSERT INTO Product (product_id, product_name) VALUES
(1, 'Ноутбук'),
(2, 'Смартфон');

/* 3.Процедура */

CREATE OR REPLACE PROCEDURE generate_supplier_orders()
LANGUAGE plpgsql
AS $$
DECLARE
    product RECORD;
    total_supplied INT;
    total_sold INT;
    current_stock INT;
    forecast INT;
BEGIN
    FOR product IN
        SELECT product_id
        FROM Product
    LOOP
        SELECT COALESCE(SUM(quantity), 0) INTO total_supplied
        FROM Supply
        WHERE product_id = product.product_id;

        SELECT COALESCE(SUM(quantity), 0) INTO total_sold
        FROM Customer_Order
        WHERE product_id = product.product_id;

        current_stock := total_supplied - total_sold;

        SELECT CEIL(COALESCE(AVG(quantity), 0)) INTO forecast
        FROM Customer_Order
        WHERE product_id = product.product_id
          AND order_date >= CURRENT_DATE - INTERVAL '3 months';

        IF current_stock < forecast THEN
            INSERT INTO Supply (supplier_id, supply_date, product_id, quantity)
            VALUES (
                1,               
                CURRENT_DATE,    
                product.product_id,
                forecast     
            );

            RAISE NOTICE 'ID товара: %, Поставлено: %, Продано: %, Текущий остаток: %, Прогноз: %',
                product.product_id, total_supplied, total_sold, current_stock, forecast;
        END IF;
    END LOOP;
END;
$$;

/* 4.Вставка данных для тестирования */
INSERT INTO Supply (supplier_id, supply_date, product_id, quantity)
VALUES
    (1, CURRENT_DATE - INTERVAL '4 months', 1, 300), 
    (1, CURRENT_DATE - INTERVAL '2 months', 1, 150);


INSERT INTO Customer_Order (order_id, order_date, customer_id, product_id, quantity)
VALUES
    (1, CURRENT_DATE - INTERVAL '3 months', 1, 1, 120),
    (2, CURRENT_DATE - INTERVAL '2 months', 2, 1, 120), 
    (3, CURRENT_DATE - INTERVAL '1 month', 1, 1, 120);   



/* 5.Проверяем, что всё корректно посчиталось */
WITH SupplyData AS (
    SELECT 
        product_id,
        SUM(quantity) AS total_supplied
    FROM Supply
    GROUP BY product_id
),
SalesData AS (
    SELECT 
        product_id,
        SUM(quantity) AS total_sold,
        CEIL(COALESCE(AVG(
            CASE 
                WHEN order_date >= CURRENT_DATE - INTERVAL '3 months' THEN quantity
                ELSE NULL
            END
        ), 0)) AS forecast
    FROM Customer_Order
    GROUP BY product_id
)
SELECT 
    p.product_id,
    COALESCE(supply.total_supplied, 0) AS total_supplied,
    COALESCE(sales.total_sold, 0) AS total_sold,
    COALESCE(supply.total_supplied, 0) - COALESCE(sales.total_sold, 0) AS current_stock,
    COALESCE(sales.forecast, 0) AS forecast
FROM Product p
LEFT JOIN SupplyData supply ON p.product_id = supply.product_id
LEFT JOIN SalesData sales ON p.product_id = sales.product_id
WHERE COALESCE(supply.total_supplied, 0) > 0
   OR COALESCE(sales.total_sold, 0) > 0
   OR COALESCE(supply.total_supplied, 0) - COALESCE(sales.total_sold, 0) > 0
   OR COALESCE(sales.forecast, 0) > 0;


/* 6. Вызываем процедуру */
CALL generate_supplier_orders();

/* 7.Проверяем, что всё верно добавилось */
WITH SupplyData AS (
    SELECT 
        product_id,
        SUM(quantity) AS total_supplied
    FROM Supply
    GROUP BY product_id
),
SalesData AS (
    SELECT 
        product_id,
        SUM(quantity) AS total_sold,
        CEIL(COALESCE(AVG(
            CASE 
                WHEN order_date >= CURRENT_DATE - INTERVAL '3 months' THEN quantity
                ELSE NULL
            END
        ), 0)) AS forecast
    FROM Customer_Order
    GROUP BY product_id
)
SELECT 
    p.product_id,
    COALESCE(supply.total_supplied, 0) AS total_supplied,
    COALESCE(sales.total_sold, 0) AS total_sold,
    COALESCE(supply.total_supplied, 0) - COALESCE(sales.total_sold, 0) AS current_stock,
    COALESCE(sales.forecast, 0) AS forecast
FROM Product p
LEFT JOIN SupplyData supply ON p.product_id = supply.product_id
LEFT JOIN SalesData sales ON p.product_id = sales.product_id
WHERE COALESCE(supply.total_supplied, 0) > 0
   OR COALESCE(sales.total_sold, 0) > 0
   OR COALESCE(supply.total_supplied, 0) - COALESCE(sales.total_sold, 0) > 0

   OR COALESCE(sales.forecast, 0) > 0;
