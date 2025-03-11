-------------------------------------------------------------------------------
-- (0) ДОБАВЛЯЕМ БАЗОВЫЕ СПРАВОЧНЫЕ ДАННЫЕ (СТРАНА, ГОРОД, УЛИЦА, АДРЕС ПОСТАВЩИКА)
-------------------------------------------------------------------------------
-- 1. Добавляем страну
INSERT INTO Country (country_id, country_name) VALUES (1, 'Россия');
INSERT INTO Country (country_id, country_name) VALUES (2, 'Китай');

-- 2. Добавляем город, ссылаясь на страну
INSERT INTO City (city_id, country_id, city_name) VALUES (1, 1, 'Москва');
INSERT INTO City (city_id, country_id, city_name) VALUES (2, 2, 'Пекин');

-- 3. Добавляем улицу, ссылаясь на город
INSERT INTO Street (street_id, city_id, street_name) VALUES (1, 1, 'Ленина');
INSERT INTO Street (street_id, city_id, street_name) VALUES (2, 2, 'Мао');

-- 4. Добавляем адрес поставщика, ссылаясь на улицу
INSERT INTO Supplier_Address (address_id, street_id, building) VALUES (1, 1, '25А');
INSERT INTO Supplier_Address (address_id, street_id, building) VALUES (2, 2, '25А');


-------------------------------------------------------------------------------
-- (1) ДАЁМ ПРАВО ПОСТАВЩИКУ ПРОСМАТРИВАТЬ ИНФОРМАЦИЮ О СВОИХ ПОСТАВКАХ + АВТОРЕГИСТРАЦИЯ
-------------------------------------------------------------------------------
-- 1) Создаём роль для поставщиков
CREATE ROLE supplier_role;

-- 2) Таблица логинов поставщиков (если её ещё нет)
CREATE TABLE IF NOT EXISTS Supplier_Login (
    supplier_id INT,
    login       VARCHAR(32),
    CONSTRAINT fk_supplier_login FOREIGN KEY (supplier_id) REFERENCES Supplier(supplier_id)
);

-- 3) Процедура авторегистрации поставщика
CREATE OR REPLACE PROCEDURE register_supplier (
    new_supplier_id   INT,
    new_last_name     VARCHAR(255),
    new_first_name    VARCHAR(255),
    new_middle_name   VARCHAR(255),
    new_phone         VARCHAR(20),
    new_address_id    INT
)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO Supplier (
        supplier_id, 
        last_name, 
        first_name, 
        middle_name, 
        phone, 
        address_id
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

-- 4) Представление, фильтрующее поставки по CURRENT_USER
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

GRANT SELECT ON my_supplies_view TO supplier_role;
GRANT EXECUTE ON PROCEDURE register_supplier(INT, VARCHAR(255), VARCHAR(255), VARCHAR(255), VARCHAR(20), INT) TO supplier_role;
GRANT INSERT ON Supplier TO supplier_role;
GRANT INSERT ON Supplier_Login TO supplier_role;

-- ПРИМЕР ИСПОЛЬЗОВАНИЯ:
-- 1) Администратор создаёт пользователя поставщика
-- CREATE USER supX WITH PASSWORD 'password';
-- GRANT supplier_role TO supX;

-- 2) Подключаемся под supX и выполняем:
-- CALL register_supplier(3, 'Сидоров', 'Сидор', 'Сидорович', '+79001234567', 102);

-- 3) Теперь supX видит только свои поставки:
-- SELECT * FROM my_supplies_view;


-------------------------------------------------------------------------------
-- (2) ДАЁМ ПРАВО ПРОДАВЦУ ИЗМЕНЯТЬ СТОИМОСТЬ ТОВАРА, ЕСЛИ ТОВАРА < 10 ШТУК
-------------------------------------------------------------------------------
CREATE ROLE seller_role;

CREATE OR REPLACE FUNCTION update_price_if_stock_low(
    p_product_id INT,
    p_new_price  DECIMAL(10,2)
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
        
        RETURN 'Цена обновлена. (stock < 10).';
    ELSE
        RETURN 'Не получится обновить цену: stock >= 10.';
    END IF;
END;
$$;

GRANT EXECUTE ON FUNCTION update_price_if_stock_low(INT, DECIMAL) TO seller_role;
GRANT UPDATE (price) ON TABLE Pricing TO seller_role;


-------------------------------------------------------------------------------
-- (3) ДАЁМ ПРАВО АДМИНИСТРАТОРУ СЧИТЫВАТЬ 10% ЗАПИСЕЙ ИЗ СЕРЕДИНЫ ТАБЛИЦЫ 'ЗАКАЗЧИКИ'
-------------------------------------------------------------------------------
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


-------------------------------------------------------------------------------
-- (4) ДАЁМ ПРАВО ТОВАРОВЕДУ ВСТАВЛЯТЬ ПОСТАВКИ, ЕСЛИ ТАКОЙ НЕ БЫЛО В ЭТОТ ДЕНЬ
-------------------------------------------------------------------------------
CREATE ROLE merchandiser_role;

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
        RETURN 'Error: Supply for this supplier, product, and date already exists.';
    END IF;

    INSERT INTO Supply(supply_id, supplier_id, supply_date, product_id, quantity)
    VALUES (
        nextval('supply_seq'), 
        p_supplier_id,
        p_supply_date,
        p_product_id,
        p_quantity
    );

    RETURN 'Success: new supply inserted.';
END;
$$;

GRANT EXECUTE ON FUNCTION insert_supply_if_not_exists(INT, DATE, INT, INT) 
  TO merchandiser_role;
GRANT INSERT ON TABLE Supply TO merchandiser_role;


-------------------------------------------------------------------------------
-- (5) ДАЁМ ПРАВО АДМИНИСТРАТОРУ IT УДАЛЯТЬ ПРОЦЕДУРЫ
-------------------------------------------------------------------------------
CREATE ROLE admin_it_role;

CREATE OR REPLACE PROCEDURE test_procedure()
LANGUAGE plpgsql
AS $$
BEGIN
    RAISE NOTICE 'Чё-то там.';
END;
$$;

ALTER PROCEDURE test_procedure() OWNER TO admin_it_role;

GRANT CREATE ON SCHEMA public TO admin_it_role;

-- Под it_admin:
-- DROP PROCEDURE test_procedure();
