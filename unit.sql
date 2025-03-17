-- =========================
-- (0) СОЗДАНИЕ ТАБЛИЦ ПО СХЕМЕ
-- =========================

/*
Вариант №1
Спроектируйте базу данных, которая используется для автоматизации технологического процесса
в крупной фирме, осуществляющей оптовую торговлю промышленными товарами.
*/

-- 1) Страны
CREATE TABLE Country (
    country_id INT PRIMARY KEY,
    country_name VARCHAR(255) NOT NULL
);

-- 2) Города
CREATE TABLE City (
    city_id INT PRIMARY KEY,
    country_id INT,
    city_name VARCHAR(255) NOT NULL,
    FOREIGN KEY (country_id) REFERENCES Country(country_id)
);

-- 3) Улицы
CREATE TABLE Street (
    street_id INT PRIMARY KEY,
    city_id INT,
    street_name VARCHAR(255) NOT NULL,
    FOREIGN KEY (city_id) REFERENCES City(city_id)
);

-- 4) Адреса поставщиков
CREATE TABLE Supplier_Address (
    address_id INT PRIMARY KEY,
    street_id INT,
    building VARCHAR(10),
    FOREIGN KEY (street_id) REFERENCES Street(street_id)
);

-- 5) Адреса клиентов
CREATE TABLE Customer_Address (
    address_id INT PRIMARY KEY,
    street_id INT,
    building VARCHAR(10),
    FOREIGN KEY (street_id) REFERENCES Street(street_id)
);

-- 6) Таблица поставщиков
CREATE TABLE Supplier (
    supplier_id INT PRIMARY KEY,
    last_name VARCHAR(255),
    first_name VARCHAR(255),
    middle_name VARCHAR(255),
    phone VARCHAR(20),
    address_id INT,
    FOREIGN KEY (address_id) REFERENCES Supplier_Address(address_id)
);

-- 7) Таблица продуктов
CREATE TABLE Product (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(255)
);

-- 8) Таблица клиентов
CREATE TABLE Customer (
    customer_id INT PRIMARY KEY,
    last_name VARCHAR(255),
    first_name VARCHAR(255),
    middle_name VARCHAR(255),
    birth_date DATE,
    address_id INT,
    FOREIGN KEY (address_id) REFERENCES Customer_Address(address_id)
);

-- 9) Таблица поставок
CREATE TABLE Supply (
    supply_id INT PRIMARY KEY,
    supplier_id INT,
    supply_date DATE,
    product_id INT,
    quantity INT,
    FOREIGN KEY (supplier_id) REFERENCES Supplier(supplier_id),
    FOREIGN KEY (product_id) REFERENCES Product(product_id)
);

-- 10) Таблица цен
CREATE TABLE Pricing (
    pricing_id INT PRIMARY KEY,
    product_id INT,
    price DECIMAL(10, 2),
    price_date DATE,
    FOREIGN KEY (product_id) REFERENCES Product(product_id)
);

-- 11) Заказы клиентов
CREATE TABLE Customer_Order (
    order_id INT PRIMARY KEY,
    order_date DATE,
    customer_id INT,
    product_id INT,
    quantity INT,
    FOREIGN KEY (customer_id) REFERENCES Customer(customer_id),
    FOREIGN KEY (product_id) REFERENCES Product(product_id)
);


--------------------------------------------------------------------------
-- (1) ЗАПОЛНЯЕМ ОСНОВНЫЕ СПРАВОЧНЫЕ ДАННЫЕ
--------------------------------------------------------------------------
-- Шаг 1. Добавляем Страны (Россия, Китай)
INSERT INTO Country (country_id, country_name)
VALUES
  (1, 'Россия'),
  (2, 'Китай');

-- Шаг 2. Добавляем Города
INSERT INTO City (city_id, country_id, city_name)
VALUES
  (1, 1, 'Москва'),
  (2, 2, 'Пекин');

-- Шаг 3. Добавляем Улицы
INSERT INTO Street (street_id, city_id, street_name)
VALUES
  (1, 1, 'Ленина'),  -- Москва
  (2, 2, 'Мао');     -- Пекин

-- Шаг 4. Адреса поставщиков
INSERT INTO Supplier_Address (address_id, street_id, building)
VALUES
  (1, 1, '25А'),
  (2, 2, '25А');

-- Шаг 5. Адреса клиентов
INSERT INTO Customer_Address (address_id, street_id, building)
VALUES
  (1, 1, '10'),
  (2, 1, '12'),
  (3, 2, '8'),
  (4, 2, '16');

-- Шаг 6. Добавляем Продукты
INSERT INTO Product (product_id, product_name)
VALUES
  (1, 'Молоко'),
  (2, 'Хлеб'),
  (3, 'Сахар');

-- Шаг 7. Тестовые Клиенты (для проверки)
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


--------------------------------------------------------------------------
-- (2) ДАЁМ ПРАВО ПОСТАВЩИКУ ПРОСМАТРИВАТЬ СВОИ ПОСТАВКИ + АВТОРЕГИСТРАЦИЯ
--------------------------------------------------------------------------
-- 1) Создаём роль \"supplier_role\"
CREATE ROLE supplier_role;
GRANT USAGE ON SCHEMA public TO supplier_role;
GRANT CREATE ON SCHEMA public TO supplier_role;
-- Сначала даём право supplier_role работать со схемой:
GRANT USAGE, CREATE ON SCHEMA public TO supplier_role;

-- Теперь разрешаем по умолчанию все необходимые права на новые объекты в схеме:
ALTER DEFAULT PRIVILEGES IN SCHEMA public
  GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO supplier_role;

ALTER DEFAULT PRIVILEGES IN SCHEMA public
  GRANT USAGE, SELECT ON SEQUENCES TO supplier_role;

ALTER DEFAULT PRIVILEGES IN SCHEMA public
  GRANT EXECUTE ON FUNCTIONS TO supplier_role;


-- 2) Таблица Supplier_Login (привязка supplier_id -> CURRENT_USER)
CREATE TABLE Supplier_Login (
    supplier_id INT,
    login VARCHAR(32),
    CONSTRAINT fk_supplier_login FOREIGN KEY (supplier_id) REFERENCES Supplier(supplier_id)
);

-- 3) Процедура \"register_supplier\" (авторегистрация)
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

-- ДАЁМ ПРАВА supplier_role вызывать процедуру
GRANT EXECUTE ON PROCEDURE register_supplier(int, text, text, text, text, int)
  TO supplier_role;
-- 4) Представление \"my_supplies_view\" (только свои поставки)
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

-- 5) Права
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

(ii) Подключаемся под sup1:
CALL register_supplier(
    1,                      -- supplier_id
    'Чиназес',               -- last_name
    'Йоппер',                -- first_name
    'Хойкович',             -- middle_name
    '+7912000000',            -- phone
    1                         -- address_id
);

CALL register_supplier(
    2,                      -- supplier_id
    'Ганс',               -- last_name
    'Апстер',                -- first_name
    'Хойт',             -- middle_name
    '+7912512421',            -- phone
    2                         -- address_id
);

-- Подключаемся под зарегистрированного поставщика (например, `sup1`) и добавляем поставки
INSERT INTO Supply (supply_id, supplier_id, supply_date, product_id, quantity)
VALUES 
    (1, 1, CURRENT_DATE, 1, 8),  
    (2, 2, CURRENT_DATE, 2, 12);
*/

SELECT * FROM my_supplies_view;

-----------------------------------------------------------------------
-- (3) ДАЁМ ПРАВО ПРОДАВЦУ ИЗМЕНЯТЬ СТОИМОСТЬ ТОВАРА, ЕСЛИ < 10 ШТ. В НАЛИЧИИ
--------------------------------------------------------------------------
-- 1) Роль продавца
CREATE ROLE seller_role;

-- 2) Функция update_price_if_stock_low
CREATE OR REPLACE FUNCTION update_price_if_stock_low(
    p_product_id INT,
    p_new_price DECIMAL(10,2)
)
RETURNS TEXT
LANGUAGE plpgsql
AS $$
DECLARE
    total_in_stock INT;
BEGIN
    SELECT COALESCE(SUM(quantity), 0)
      INTO total_in_stock
      FROM Supply
     WHERE product_id = p_product_id;

    IF total_in_stock < 10 THEN
        UPDATE Pricing
           SET price = p_new_price
         WHERE product_id = p_product_id
           AND price_date = (
               SELECT MAX(price_date)
               FROM Pricing
               WHERE product_id = p_product_id
           );
        RETURN 'Цена обновлена (stock < 10).';
    ELSE
        RETURN 'Невозможно обновить цену: stock >= 10.';
    END IF;
END;
$$;

GRANT EXECUTE ON FUNCTION update_price_if_stock_low(INT, DECIMAL)
  TO seller_role;

-- Продавцу нужно право менять \"price\" в таблице Pricing
GRANT UPDATE (price) ON Pricing TO seller_role;

-- Пример использования:
--   (i)  Админ: CREATE USER sel1 WITH PASSWORD '1'; GRANT seller_role TO sel1;
--   (ii) sel1: SELECT update_price_if_stock_low(1, 99.99);
--        Если запас (Supply.quantity) для product_id=1 < 10, цена обновится.


--------------------------------------------------------------------------
-- (4) ДАЁМ ПРАВО АДМИНИСТРАТОРУ СЧИТЫВАТЬ \"10%\" ИЗ СЕРЕДИНЫ ТАБЛИЦЫ CUSTOMER
--------------------------------------------------------------------------
-- 1) Роль администратора
CREATE ROLE admin_role;

-- 2) Представление middle_10_percent_customers
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

-- Пример:
--   (i)  Админ: CREATE USER admin1 WITH PASSWORD '1'; GRANT admin_role TO admin1;
--   (ii) admin1: SELECT * FROM middle_10_percent_customers;
--        Получим \"около 10%\" строк, расположенных в середине.


--------------------------------------------------------------------------
-- (5) ТОВАРОВЕДУ / ПРОДАВЦУ: ВСТАВКА ПОСТАВКИ, ЕСЛИ ЕЩЁ НЕ СУЩЕСТВУЕТ
--------------------------------------------------------------------------
CREATE ROLE merchandiser_role;

-- Функция insert_supply_if_not_exists
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

-- Пример:
--   (i)  CREATE USER merch1 WITH PASSWORD '1';
--        GRANT merchandiser_role TO merch1;
--   (ii) Под merch1:
--        SELECT insert_supply_if_not_exists(100, CURRENT_DATE, 1, 10);
--        Если нет такой записи, вставит; если уже существует, вернёт ошибку.


--------------------------------------------------------------------------
-- (6) ДАЁМ ПРАВО АДМИНИСТРАТОРУ IT УДАЛЯТЬ ПРОЦЕДУРЫ
--------------------------------------------------------------------------
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

-- Пример:
--   (i)  CREATE USER it_admin WITH PASSWORD '1';
--        GRANT admin_it_role TO it_admin;
--   (ii) Под it_admin:
--        DROP PROCEDURE test_procedure();
--        Если другой пользователь попробует, получит \"permission denied\".


--------------------------------------------------------------------------
-- (7) ДОПОЛНИТЕЛЬНЫЕ ТЕСТОВЫЕ ДАННЫЕ ДЛЯ ПРОВЕРКИ
--------------------------------------------------------------------------
-- Пример поставщиков / поставок, чтобы всё работало из коробки.
-- (Можно расширять и изменять при необходимости)

-- 1) Добавим одного поставщика вручную (ID=1)
INSERT INTO Supplier (supplier_id, last_name, first_name, middle_name, phone, address_id)
VALUES (1, 'Иванов', 'Иван', 'Иванович', '+79000000001', 1);

-- 2) Примеры поставок от поставщика 1
INSERT INTO Supply (supply_id, supplier_id, supply_date, product_id, quantity)
VALUES
  (1, 1, CURRENT_DATE, 1, 50),
  (2, 1, CURRENT_DATE, 2,  5),
  (3, 1, CURRENT_DATE, 3,  2);

-- 3) Цены
INSERT INTO Pricing (pricing_id, product_id, price, price_date)
VALUES
  (1, 1, 120.00, CURRENT_DATE),
  (2, 2,  50.00, CURRENT_DATE),
  (3, 3,  75.00, CURRENT_DATE);

-- 4) Проверка продавца:
--    CREATE USER sel1 WITH PASSWORD '1'; GRANT seller_role TO sel1;
--    Под sel1:
--       SELECT update_price_if_stock_low(2, 45.00);
--    Если суммарно товара 2 < 10 штук, цена сменится на 45.00.

-- 5) Проверка товароведа:
--    CREATE USER merch1 WITH PASSWORD '1'; GRANT merchandiser_role TO merch1;
--    Под merch1:
--       SELECT insert_supply_if_not_exists(1, CURRENT_DATE, 2, 10);
--    Добавит новую поставку, если такой ещё нет (supplier_id=1, product_id=2, date=сегодня).

-- 6) Проверка авторегистрации поставщика:
--    CREATE USER supA WITH PASSWORD '1'; GRANT supplier_role TO supA;
--    Под supA:
--       CALL register_supplier(200, 'Лебедев', 'Лев', 'Львович', '+79009990000', 2);
--    Теперь в Supplier появится (ID=200), в Supplier_Login привязка (200, 'supA').
--    Любые поставки, где supplier_id=200, будут видны только supA через my_supplies_view.

-- На этом все пять пунктов задания закрыты.
