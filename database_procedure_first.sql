/*
Лабораторная работа №3
Вариант №1
Процедура №1
Процедура автоматического обновления цен на товары в базе данных, 
основанная на данных от поставщиков(добавление наценки к базовой цене) и изменениях спроса на рынке(при низком спросе добавляем скидку).
*/

/* Создаём таблицы */
CREATE TABLE Country (
    country_id SERIAL PRIMARY KEY,
    country_name VARCHAR(255) NOT NULL
);

CREATE TABLE City (
    city_id SERIAL PRIMARY KEY,
    country_id INT,
    city_name VARCHAR(255) NOT NULL,
    FOREIGN KEY (country_id) REFERENCES Country(country_id)
);

CREATE TABLE Street (
    street_id SERIAL PRIMARY KEY,
    city_id INT,
    street_name VARCHAR(255) NOT NULL,
    FOREIGN KEY (city_id) REFERENCES City(city_id)
);

CREATE TABLE Product (
    product_id SERIAL PRIMARY KEY,
    product_name VARCHAR(255) NOT NULL
);

CREATE TABLE Supplier_Address (
    address_id SERIAL PRIMARY KEY,
    street_id INT,
    building VARCHAR(10),
    FOREIGN KEY (street_id) REFERENCES Street(street_id)
);

CREATE TABLE Customer_Address (
    address_id SERIAL PRIMARY KEY,
    street_id INT,
    building VARCHAR(10),
    FOREIGN KEY (street_id) REFERENCES Street(street_id)
);

CREATE TABLE Supplier (
    supplier_id SERIAL PRIMARY KEY,
    last_name VARCHAR(255),
    first_name VARCHAR(255),
    middle_name VARCHAR(255),
    phone VARCHAR(20),
    address_id INT,
    FOREIGN KEY (address_id) REFERENCES Supplier_Address(address_id)
);

CREATE TABLE Customer (
    customer_id SERIAL PRIMARY KEY,
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
    purchase_price DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (supplier_id) REFERENCES Supplier(supplier_id),
    FOREIGN KEY (product_id) REFERENCES Product(product_id)
);

CREATE TABLE Pricing (
    pricing_id SERIAL PRIMARY KEY,
    product_id INT,
    base_price DECIMAL(10, 2),
    final_price DECIMAL(10, 2),
    markup_percentage DECIMAL(5, 2) DEFAULT 25.0,
    last_discount_date DATE,
    effective_date DATE,
    FOREIGN KEY (product_id) REFERENCES Product(product_id)
);

CREATE TABLE Customer_Order (
    order_id SERIAL PRIMARY KEY,
    order_date DATE,
    customer_id INT,
    product_id INT,
    quantity INT,
    FOREIGN KEY (customer_id) REFERENCES Customer(customer_id),
    FOREIGN KEY (product_id) REFERENCES Product(product_id)
);

/* Вносим данные */
INSERT INTO Country (country_name) VALUES
('Россия'),
('США'),
('Германия'),
('Франция'),
('Китай');

INSERT INTO City (country_id, city_name) VALUES
(1, 'Москва'),
(1, 'Санкт-Петербург'),
(2, 'Нью-Йорк'),
(3, 'Берлин'),
(4, 'Париж');

INSERT INTO Street (city_id, street_name) VALUES
(1, 'Тверская'),
(1, 'Арбат'),
(2, 'Бродвей'),
(3, 'Александерплац'),
(4, 'Елисейские поля');

INSERT INTO Product (product_name) VALUES
('Ноутбук'),
('Смартфон'),
('Планшет'),
('Монитор'),
('Принтер');

INSERT INTO Supplier_Address (street_id, building) VALUES
(1, '10А'),
(2, '20Б'),
(3, '15C'),
(4, '5D'),
(5, '3E');

INSERT INTO Supplier (last_name, first_name, middle_name, phone, address_id) VALUES
('Иванов', 'Иван', 'Иванович', '123-456', 1),
('Петров', 'Петр', 'Петрович', '654-321', 2),
('Сидоров', 'Алексей', 'Алексеевич', '789-123', 3),
('Смирнов', 'Дмитрий', 'Сергеевич', '456-789', 4),
('Кузнецов', 'Владимир', 'Владимирович', '321-654', 5);

INSERT INTO Customer_Address (street_id, building) VALUES
(1, '1A'),
(2, '2B'),
(3, '3C'),
(4, '4D'),
(5, '5E');

INSERT INTO Customer (last_name, first_name, middle_name, birth_date, address_id) VALUES
('Сидоров', 'Алексей', 'Алексеевич', '1980-05-20', 1),
('Кузнецов', 'Дмитрий', 'Сергеевич', '1990-10-12', 2),
('Иванова', 'Мария', 'Александровна', '1985-07-15', 3),
('Петрова', 'Анна', 'Сергеевна', '1995-01-30', 4),
('Смирнова', 'Ольга', 'Дмитриевна', '2000-11-05', 5);

INSERT INTO Supply (supplier_id, supply_date, product_id, quantity, purchase_price) VALUES
(1, '2023-06-01', 1, 100, 40000.00),
(2, '2023-01-01', 2, 200, 30000.00),
(3, '2023-05-01', 3, 150, 20000.00),
(4, '2023-07-01', 4, 80, 15000.00),
(5, CURRENT_DATE, 5, 120, 10000.00);

INSERT INTO Pricing (product_id, base_price, effective_date) VALUES
(1, 40000.00, '2023-01-01'),
(2, 30000.00, '2023-03-01'),
(3, 20000.00, '2023-05-01'),
(4, 15000.00, '2023-07-01'),
(5, 10000.00, CURRENT_DATE);

INSERT INTO Customer_Order (order_date, customer_id, product_id, quantity) VALUES
('2023-01-10', 1, 1, 50),
('2023-03-15', 2, 2, 100),
('2023-05-20', 3, 3, 30),
('2023-07-25', 4, 4, 40),
(CURRENT_DATE - INTERVAL '1 month', 5, 5, 60);

/* Создаём процедуру */

CREATE OR REPLACE PROCEDURE update_pricing_and_apply_discount()
LANGUAGE plpgsql
AS $$
DECLARE
    supply_record RECORD;
    sold_quantity INT;
    new_final_price DECIMAL(10, 2);
BEGIN
    FOR supply_record IN 
        SELECT s.supply_id, s.product_id, s.quantity, s.supply_date, s.purchase_price
        FROM Supply s
    LOOP
        UPDATE Pricing
        SET final_price = supply_record.purchase_price * 1.25
        WHERE product_id = supply_record.product_id;

        SELECT COALESCE(SUM(co.quantity), 0) INTO sold_quantity
        FROM Customer_Order co
        WHERE co.product_id = supply_record.product_id
          AND co.order_date BETWEEN supply_record.supply_date AND supply_record.supply_date + INTERVAL '3 months';

        IF sold_quantity < supply_record.quantity * 0.3 THEN
            new_final_price := supply_record.purchase_price * 1.25 * 0.9;

            UPDATE Pricing
            SET final_price = new_final_price,
                last_discount_date = CURRENT_DATE
            WHERE product_id = supply_record.product_id;
        END IF;
    END LOOP;
END;
$$;

/* Добавляем два заказа */
INSERT INTO Supply (supplier_id, supply_date, product_id, quantity, purchase_price)
VALUES 
(1, '2023-06-01', 1, 100, 40000.00),
(2, '2023-01-01', 2, 200, 30000.00);

/* В первом заказе продаём больше 30% и цена получает только наценку в 25% без скидки */
/* Во втором заказе продаём меньше 30% и цена получает наценку в 25%, а затем скидку в 10% */
INSERT INTO Customer_Order (order_date, customer_id, product_id, quantity)
VALUES 
('2023-07-01', 1, 1, 50),
('2023-02-01', 2, 2, 40);

SELECT product_id, base_price, final_price, last_discount_date FROM Pricing;

CALL update_pricing_and_apply_discount();

SELECT product_id, base_price, final_price, last_discount_date FROM Pricing;
