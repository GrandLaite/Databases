/*
Лабораторная работа №3
Вариант №1
Процедура №2
Процедура автоматического формирования заказов на основе данных о запасах товаров и прогнозах продаж.
*/


/* Создаём таблицы */
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
    supply_id INT PRIMARY KEY,
    supplier_id INT,
    supply_date DATE,
    product_id INT,
    quantity INT,
    purchase_price DECIMAL(10, 2) NOT NULL,  
    FOREIGN KEY (supplier_id) REFERENCES Supplier(supplier_id),
    FOREIGN KEY (product_id) REFERENCES Product(product_id)
);

CREATE TABLE Pricing (
    pricing_id INT PRIMARY KEY,
    product_id INT,
    base_price DECIMAL(10, 2) NOT NULL,           
    markup_percentage DECIMAL(5, 2) DEFAULT 20.0, 
    effective_date DATE,
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

CREATE TABLE Inventory (
    inventory_id SERIAL PRIMARY KEY,
    product_id INT,
    current_stock INT NOT NULL,  
    last_update DATE,
    FOREIGN KEY (product_id) REFERENCES Product(product_id)
);


CREATE TABLE Sales_Forecast (
    forecast_id SERIAL PRIMARY KEY,
    product_id INT,
    forecasted_sales INT DEFAULT 50, 
    forecast_date DATE,
    FOREIGN KEY (product_id) REFERENCES Product(product_id)
);

CREATE TABLE Supplier_Order (
    order_id SERIAL PRIMARY KEY,
    supplier_id INT,
    order_date DATE NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL,
    status VARCHAR(20) DEFAULT 'Pending',
    FOREIGN KEY (supplier_id) REFERENCES Supplier(supplier_id),
    FOREIGN KEY (product_id) REFERENCES Product(product_id)
);


/* Вносим данные */
INSERT INTO Country (country_id, country_name) VALUES
(1, 'Россия'),
(2, 'США');

INSERT INTO City (city_id, country_id, city_name) VALUES
(1, 1, 'Москва'),
(2, 1, 'Санкт-Петербург'),
(3, 1, 'Новосибирск'),
(4, 1, 'Казань'),
(5, 2, 'Нью-Йорк'),
(6, 2, 'Лос-Анджелес'),
(7, 2, 'Чикаго'),
(8, 2, 'Сан-Франциско');

INSERT INTO Street (street_id, city_id, street_name) VALUES
(1, 1, 'Тверская'),
(2, 1, 'Арбат'),
(3, 2, 'Невский проспект'),
(4, 3, 'Красный проспект'),
(5, 3, 'Ленина'),
(6, 4, 'Пушкина'),
(7, 5, 'Бродвей'),
(8, 6, 'Голливудский бульвар'),
(9, 7, 'Мичиган авеню'),
(10, 8, 'Маркет-стрит');

INSERT INTO Supplier_Address (address_id, street_id, building) VALUES
(1, 1, '10А'),
(2, 2, '5'),
(3, 7, '100'),
(4, 8, '50'),
(5, 9, '3A'),
(6, 10, '22B');

INSERT INTO Supplier (supplier_id, last_name, first_name, middle_name, phone, address_id) VALUES
(1, 'Иванов', 'Иван', 'Иванович', '123-456', 1),
(2, 'Петров', 'Петр', 'Петрович', '654-321', 2),
(3, 'Смирнов', 'Сергей', 'Сергеевич', '555-555', 3),
(4, 'Кузьмина', 'Ольга', 'Николаевна', '333-999', 4),
(5, 'Сидоров', 'Александр', 'Иванович', '444-888', 5),
(6, 'Джонсон', 'Майкл', 'Эдвардович', '555-777', 6),
(7, 'Новиков', 'Денис', 'Викторович', '123-789', 1);

INSERT INTO Product (product_id, product_name) VALUES
(1, 'Ноутбук'),
(2, 'Смартфон'),
(3, 'Планшет'),
(4, 'Телевизор'),
(5, 'Игровая консоль'),
(6, 'Наушники');

INSERT INTO Pricing (pricing_id, product_id, base_price, markup_percentage, effective_date) VALUES
(1, 1, 50000.00, 20.0, '2024-01-01'),
(2, 2, 30000.00, 15.0, '2024-01-01'),
(3, 3, 20000.00, 10.0, '2024-01-01'),
(4, 4, 45000.00, 25.0, '2024-01-01'),
(5, 5, 25000.00, 30.0, '2024-02-01'),
(6, 6, 7000.00, 20.0, '2024-03-01'),
(7, 1, 52000.00, 18.0, '2024-04-01'),
(8, 2, 28000.00, 15.0, '2024-04-15'),
(9, 3, 22000.00, 10.0, '2024-07-01'),
(10, 4, 46000.00, 25.0, '2024-08-01'),
(11, 5, 26000.00, 30.0, '2024-08-15');

INSERT INTO Customer_Address (address_id, street_id, building) VALUES
(1, 3, '20'),
(2, 5, '40'),
(3, 6, '18A'),
(4, 9, '15'),
(5, 10, '10');

INSERT INTO Customer (customer_id, last_name, first_name, middle_name, birth_date, address_id) VALUES
(1, 'Сидоров', 'Алексей', 'Алексеевич', '1980-05-20', 1),
(2, 'Кузнецов', 'Владимир', 'Владимирович', '1990-10-12', 2),
(3, 'Морозов', 'Дмитрий', 'Дмитриевич', '1975-12-30', 3),
(4, 'Павлов', 'Егор', 'Ильич', '1988-07-15', 4),
(5, 'Зайцев', 'Максим', 'Олегович', '1991-01-22', 5),
(6, 'Лебедев', 'Виктор', 'Павлович', '1965-04-12', 2),
(7, 'Вонг', 'Ли', 'Сун', '1970-11-05', 3);

INSERT INTO Customer_Order (order_id, order_date, customer_id, product_id, quantity) VALUES
(1, '2024-02-15', 1, 1, 2),
(2, '2024-03-10', 2, 2, 1),
(3, '2024-04-05', 3, 3, 5),
(4, '2024-06-12', 4, 1, 2),
(5, '2024-06-18', 5, 2, 5),
(6, '2014-06-15', 1, 1, 3),
(7, '2013-11-23', 2, 2, 2);

INSERT INTO Supply (supply_id, supplier_id, supply_date, product_id, quantity, purchase_price) VALUES
(1, 1, '2024-01-15', 1, 100, 40000.00),
(2, 2, '2024-02-20', 2, 200, 25000.00),
(3, 3, '2024-03-25', 3, 300, 15000.00),
(4, 4, '2024-04-10', 2, 500, 24000.00),
(5, 5, '2024-05-22', 3, 300, 16000.00),
(6, 6, '2024-06-15', 1, 400, 38000.00),
(7, 3, '2024-07-25', 1, 200, 39000.00),
(8, 4, '2024-08-01', 5, 120, 22000.00),
(9, 7, '2023-07-20', 1, 100, 35000.00),
(10, 7, '2024-02-15', 2, 50, 27000.00);

INSERT INTO Inventory (product_id, current_stock, last_update) VALUES
(1, 15, '2024-04-01'),
(2, 8, '2024-04-01'),
(3, 20, '2024-04-01'),
(4, 5, '2024-04-01'),
(5, 12, '2024-04-01'),
(6, 10, '2024-04-01');

INSERT INTO Sales_Forecast (product_id, forecasted_sales, forecast_date) VALUES
(1, 50, '2024-04-01'),
(2, 30, '2024-04-01'),
(3, 40, '2024-04-01'),
(4, 25, '2024-04-01'),
(5, 20, '2024-04-01'),
(6, 15, '2024-04-01');

/* Создаём процедуру */
CREATE OR REPLACE PROCEDURE generate_supplier_orders()
LANGUAGE plpgsql
AS $$
DECLARE
    product RECORD;
BEGIN
    FOR product IN
        SELECT product_id, current_stock
        FROM Inventory
        WHERE current_stock < 50
    LOOP
        INSERT INTO Supplier_Order (supplier_id, order_date, product_id, quantity, status)
        VALUES (NULL, CURRENT_DATE, product.product_id, 50, 'Pending');
        
        UPDATE Inventory
        SET current_stock = current_stock + 50
        WHERE product_id = product.product_id;

        RAISE NOTICE 'Заказ создан для товара с ID %.Заказ содержит 50 единиц товара.', product.product_id;
    END LOOP;
END;
$$;

/* Делаем два запроса на просмотр данных чтобы убедится в нехватке товара на складе и отсутствии заказов у поставщика */
SELECT * FROM Inventory;
SELECT * FROM Supplier_Order;

/* Вызываем процедуру */
CALL generate_supplier_orders();

/* Проверяем работу процедуры */
SELECT * FROM Supplier_Order;
SELECT * FROM Inventory;
