/*
Вариант №1
Спроектируйте базу данных, которая используется для автоматизации технологического процесса
в крупной фирме, осуществляющей оптовую торговлю промышленными товарами.
*/

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

CREATE TABLE Product (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(255)
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
    FOREIGN KEY (supplier_id) REFERENCES Supplier(supplier_id),
    FOREIGN KEY (product_id) REFERENCES Product(product_id)
);

CREATE TABLE Pricing (
    pricing_id INT PRIMARY KEY,
    product_id INT,
    price DECIMAL(10, 2),
    price_date DATE,
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

INSERT INTO Country (country_id, country_name)
VALUES
  (1, 'Россия'),
  (2, 'Китай');

INSERT INTO City (city_id, country_id, city_name)
VALUES
  (1, 1, 'Москва'),
  (2, 2, 'Пекин');

INSERT INTO Street (street_id, city_id, street_name)
VALUES
  (1, 1, 'Ленина'),  
  (2, 2, 'Мао');   

INSERT INTO Supplier_Address (address_id, street_id, building)
VALUES
  (1, 1, '25А'),
  (2, 2, '25А');

INSERT INTO Customer_Address (address_id, street_id, building)
VALUES
  (1, 1, '10'),
  (2, 1, '12'),
  (3, 2, '8'),
  (4, 2, '16');

INSERT INTO Product (product_id, product_name)
VALUES
  (1, 'Молоко'),
  (2, 'Хлеб'),
  (3, 'Сахар');

INSERT INTO Customer (customer_id, last_name, first_name, middle_name, birth_date, address_id)
VALUES
  (1, 'Иванов', 'Иван', 'Иванович', '1980-01-01', 1),
  (2, 'Петров', 'Петр', 'Петрович', '1985-02-03', 1),
  (3, 'Сидоров', 'Сергей', 'Сергеевич', '1990-03-05', 2),
  (4, 'Михайлов', 'Михаил', 'Михайлович', '1992-05-22', 2),
  (5, 'Смирнов', 'Степан', 'Степанович', '1995-08-15', 3),
  (6, 'Васильев', 'Василий', 'Васильевич', '1983-11-30', 3),
  (7, 'Кузнецов', 'Константин', 'Константинович', '1979-09-10', 4),
  (8, 'Попов', 'Павел', 'Павлович', '1987-01-20', 4),
  (9, 'Григорьев', 'Григорий', 'Григорьевич', '1999-12-31', 4),
  (10,'Александров', 'Александр', 'Александрович','1989-06-06', 4);

-- Логика регистрации поставщика
CREATE ROLE supplier_role;
GRANT USAGE, CREATE ON SCHEMA public TO supplier_role;

ALTER DEFAULT PRIVILEGES IN SCHEMA public
  GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO supplier_role;

ALTER DEFAULT PRIVILEGES IN SCHEMA public
  GRANT USAGE, SELECT ON SEQUENCES TO supplier_role;

ALTER DEFAULT PRIVILEGES IN SCHEMA public
  GRANT EXECUTE ON FUNCTIONS TO supplier_role;


CREATE TABLE Supplier_Login (
    supplier_id INT,
    login VARCHAR(32),
    CONSTRAINT fk_supplier_login FOREIGN KEY (supplier_id) REFERENCES Supplier(supplier_id)
);

CREATE OR REPLACE PROCEDURE register_supplier(
    new_supplier_id INT,
    new_last_name   TEXT,
    new_first_name  TEXT,
    new_middle_name TEXT,
    new_phone       TEXT,
    new_address_id  INT
)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO Supplier (
        supplier_id, last_name, first_name, middle_name, phone, address_id
    )
    VALUES (
        new_supplier_id,
        new_last_name,
        new_first_name,
        new_middle_name,
        new_phone,
        new_address_id
    );

    INSERT INTO Supplier_Login (supplier_id, login)
    VALUES (
        new_supplier_id,
        CURRENT_USER
    );

    RAISE NOTICE 'Новый поставщик (ID=%) зарегистрирован под логином %',
                 new_supplier_id, CURRENT_USER;
END;
$$;

GRANT EXECUTE ON PROCEDURE register_supplier(int, text, text, text, text, int)
  TO supplier_role;


/*
1.Дать право поставщику просматривать свои поставки.
*/
CREATE OR REPLACE VIEW my_supplies_view AS
SELECT
    sp.supply_id,
    sp.supply_date,
    sp.product_id,
    sp.quantity,
    sp.supplier_id
FROM Supply sp
JOIN Supplier       s  ON sp.supplier_id = s.supplier_id
JOIN Supplier_Login sl ON s.supplier_id = sl.supplier_id
WHERE sl.login = CURRENT_USER;

GRANT EXECUTE ON PROCEDURE register_supplier(
    INT, TEXT, TEXT, TEXT, TEXT, INT
)
TO supplier_role;


GRANT INSERT ON Supplier       TO supplier_role;
GRANT INSERT ON Supplier_Login TO supplier_role;
GRANT SELECT ON my_supplies_view TO supplier_role;

/*
CREATE USER sup1 WITH PASSWORD '1';
GRANT supplier_role TO sup1;
CREATE USER sup2 WITH PASSWORD '1';
GRANT supplier_role TO sup2;

Подключаемся под sup1:
CALL register_supplier(
    1,                      -- supplier_id
    'Чиназес',               -- last_name
    'Йоппер',                -- first_name
    'Хойкович',             -- middle_name
    '+7912000000',            -- phone
    1                         -- address_id
);

Подключаемся под sup2:
CALL register_supplier(
    2,                      -- supplier_id
    'Ганс',               -- last_name
    'Апстер',                -- first_name
    'Хойт',             -- middle_name
    '+7912512421',            -- phone
    2                         -- address_id
);

Подключаемся под postgres и создаём две поставки для разных людей
INSERT INTO Supply (supply_id, supplier_id, supply_date, product_id, quantity)
VALUES 
    (1, 1, CURRENT_DATE, 1, 8),  
    (2, 2, CURRENT_DATE, 2, 12);

SELECT * FROM my_supplies_view;
*/

/*
2.Дать поставщику право обновить цену на товар, если количество товара составляет меньше 10.
*/
CREATE ROLE seller_role;

GRANT SELECT ON Supply TO seller_role;

CREATE OR REPLACE FUNCTION update_price_if_stock_low(
    p_product_id INT,
    p_new_price  DECIMAL(10,2)
)
RETURNS TEXT
LANGUAGE plpgsql
AS $$
DECLARE
    total_in_stock   INT;
    my_supplier_id   INT;
    cnt_in_pricing   INT;
BEGIN
    -- 1) Определяем, какой supplier_id привязан к CURRENT_USER
    SELECT s.supplier_id
      INTO my_supplier_id
      FROM Supplier s
      JOIN Supplier_Login sl ON s.supplier_id = sl.supplier_id
     WHERE sl.login = CURRENT_USER
     LIMIT 1;

    IF my_supplier_id IS NULL THEN
        RETURN 'Ошибка: вы не являетесь поставщиком (нет supplier_id для текущего пользователя).';
    END IF;

    -- 2) Проверяем, есть ли такой товар в Pricing
    SELECT COUNT(*)
      INTO cnt_in_pricing
      FROM Pricing
     WHERE product_id = p_product_id;

    IF cnt_in_pricing = 0 THEN
        RETURN 'Ошибка: нет цены для product_id=' || p_product_id;
    END IF;

    -- 3) Смотрим, сколько именно У ЭТОГО ПОСТАВЩИКА товара
    SELECT COALESCE(SUM(quantity), 0)
      INTO total_in_stock
      FROM Supply
     WHERE supplier_id = my_supplier_id
       AND product_id = p_product_id;

    IF total_in_stock < 10 THEN
        UPDATE Pricing
           SET price = p_new_price
         WHERE product_id = p_product_id
           AND price_date = (
               SELECT MAX(price_date)
               FROM Pricing
               WHERE product_id = p_product_id
           );
        RETURN 'Цена обновлена (остаток < 10 у поставщика='||my_supplier_id||').';
    ELSE
        RETURN 'Невозможно обновить цену: у вас ' || total_in_stock || ' шт. (>=10).';
    END IF;
END;
$$;



GRANT SELECT ON Supply TO seller_role;
GRANT SELECT, UPDATE ON Pricing TO seller_role;
GRANT EXECUTE ON FUNCTION update_price_if_stock_low(INT, DECIMAL) TO seller_role;

GRANT EXECUTE ON PROCEDURE register_supplier(
    INT, TEXT, TEXT, TEXT, TEXT, INT
)
TO seller_role;

GRANT INSERT ON Supplier       TO seller_role;
GRANT INSERT ON Supplier_Login TO seller_role;
GRANT INSERT ON Supply TO seller_role;

/*
INSERT INTO Supply (supply_id, supplier_id, supply_date, product_id, quantity)
VALUES 
    (1, 1, CURRENT_DATE, 1, 8),   
    (2, 1, CURRENT_DATE, 2, 15);
*/


/*
CREATE USER sel1 WITH PASSWORD '1';
GRANT seller_role TO sel1;

INSERT INTO Pricing (pricing_id, product_id, price, price_date)
VALUES
  (1, 1, 120.00, CURRENT_DATE),
  (2, 2,  50.00, CURRENT_DATE),
  (3, 3,  75.00, CURRENT_DATE);

Под sel1:
SELECT update_price_if_stock_low(1, 99.99);
*/

/*
3.Дать право администратору считывать 10% из середины таблицы Customer.
*/
CREATE ROLE admin_role;

CREATE OR REPLACE VIEW middle_10_percent_customers AS
WITH cte AS (
    SELECT
        c.*,
        ROW_NUMBER() OVER (ORDER BY customer_id) AS rn,
        COUNT(*) OVER () AS total_count
    FROM Customer c
)
SELECT *
FROM cte
WHERE rn >= 0.45 * total_count
  AND rn <= 0.55 * total_count;

GRANT SELECT ON middle_10_percent_customers TO admin_role;
/*
CREATE USER admin1 WITH PASSWORD '1'; 
GRANT admin_role TO admin1;
Под admin1: SELECT * FROM middle_10_percent_customers;
*/

/*
4.Дать право товароведу вставлять информацию о поставке, если в этот день такой же поставки ещё не было.
*/
CREATE ROLE merchandiser_role;

CREATE SEQUENCE IF NOT EXISTS supply_seq START 1000;

CREATE OR REPLACE FUNCTION insert_supply_if_not_exists(
    p_supplier_id INT,
    p_supply_date DATE,
    p_product_id INT,
    p_quantity INT
)
RETURNS TEXT
LANGUAGE plpgsql
AS $$
DECLARE
    existing_count INT;
BEGIN
    SELECT COUNT(*)
      INTO existing_count
      FROM Supply
     WHERE supplier_id = p_supplier_id
       AND product_id  = p_product_id
       AND supply_date = p_supply_date;

    IF existing_count > 0 THEN
        RETURN 'Error: такая поставка (supplier+product+date) уже есть.';
    END IF;

    INSERT INTO Supply(supply_id, supplier_id, supply_date, product_id, quantity)
    VALUES (
        nextval('supply_seq'),
        p_supplier_id,
        p_supply_date,
        p_product_id,
        p_quantity
    );

    RETURN 'Success: новая поставка добавлена.';
END;
$$;

GRANT EXECUTE ON FUNCTION insert_supply_if_not_exists(INT, DATE, INT, INT)
  TO merchandiser_role;

GRANT INSERT ON Supply TO merchandiser_role;
GRANT SELECT, INSERT ON Supply TO merchandiser_role;
GRANT USAGE, SELECT ON SEQUENCE supply_seq TO merchandiser_role;


/*
CREATE USER merch1 WITH PASSWORD '1';
GRANT merchandiser_role TO merch1;
Под merch1:
(supplier_id,supply_date,product_id,quantity)
SELECT insert_supply_if_not_exists(100, CURRENT_DATE, 1, 10);
*/

/*
5.Дать право администратору IT удалять процедуры.
*/
CREATE ROLE admin_it_role;

CREATE OR REPLACE PROCEDURE test_procedure()
LANGUAGE plpgsql
AS $$
BEGIN
    RAISE NOTICE 'Тестовая процедура, всё ок.';
END;
$$;

ALTER PROCEDURE test_procedure() OWNER TO admin_it_role;

GRANT CREATE ON SCHEMA public TO admin_it_role;

/*
CREATE USER it_admin WITH PASSWORD '1';
GRANT admin_it_role TO it_admin;
Под it_admin:
DROP PROCEDURE test_procedure();
*/
