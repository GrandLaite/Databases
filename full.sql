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
-- (1) ДАЁМ ПРАВО ПОСТАВЩИКУ ПРОСМАТРИВАТЬ ИНФОРМАЦИЮ О СВОИХ ПОСТАВКАХ
-------------------------------------------------------------------------------
-- 1) Создаём роль для поставщиков
CREATE ROLE supplier_role;

-- Создаём двух пользователей-поставщиков
CREATE USER sup1 WITH PASSWORD '1';
CREATE USER sup2 WITH PASSWORD '1';

-- Назначаем роль поставщика
GRANT supplier_role TO sup1;
GRANT supplier_role TO sup2;

-- 2) Таблица логинов поставщиков (если её ещё нет)
CREATE TABLE IF NOT EXISTS Supplier_Login (
    supplier_id INT,
    login       VARCHAR(32),
    CONSTRAINT fk_supplier_login FOREIGN KEY (supplier_id) REFERENCES Supplier(supplier_id)
);

-- 3) Представление, фильтрующее поставки по CURRENT_USER
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

-- ==== Вставка ТЕСТОВЫХ данных ====
-- Добавляем поставщиков в таблицу Supplier:
INSERT INTO Supplier (supplier_id, last_name, first_name, middle_name, phone, address_id)
VALUES
 (1, 'Иванов', 'Иван', 'Иванович', '+79421512561', 100),
 (2, 'Петров', 'Пётр', 'Петрович', '+79875125321', 101);

-- Привязываем их логины (sup1 → supplier_id=1, sup2 → supplier_id=2)
INSERT INTO Supplier_Login (supplier_id, login)
VALUES
 (1, 'sup1'),
 (2, 'sup2');

-- Предположим, есть товары:
INSERT INTO Product (product_id, product_name)
VALUES
 (1, 'Молоко'),
 (2, 'Хлеб');

-- Добавим поставки: две для supplier_id=1 и одну для supplier_id=2
INSERT INTO Supply (supply_id, supplier_id, supply_date, product_id, quantity)
VALUES
 (10, 1, CURRENT_DATE, 1, 50), -- от поставщика 1 (user sup1)
 (11, 1, CURRENT_DATE, 2, 10), 
 (12, 2, CURRENT_DATE, 2, 20); -- от поставщика 2 (user sup2)

-- Пример проверки:
--   Подключаемся под sup1:
--       SELECT * FROM my_supplies_view;
--   Ожидаем увидеть supply_id = 10, 11
--
--   Подключаемся под sup2:
--       SELECT * FROM my_supplies_view;
--   Ожидаем увидеть supply_id = 12
--
-- Если sup2 (или кто-либо не владелец) сделает:
--       SELECT * FROM Supply;
-- при отсутствии прямого GRANT SELECT будет:
--       "ERROR: permission denied for table Supply"


-------------------------------------------------------------------------------
-- (2) ДАЁМ ПРАВО ПРОДАВЦУ ИЗМЕНЯТЬ СТОИМОСТЬ ТОВАРА, ЕСЛИ ТОВАРА < 10 ШТУК
-------------------------------------------------------------------------------
-- 1) Роль продавца
CREATE ROLE seller_role;

CREATE USER sel WITH PASSWORD '1';
GRANT seller_role TO sel;

-- 2) Функция для изменения цены, если остаток < 10
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

-- Для демонстрации добавим записи в Pricing
INSERT INTO Pricing (pricing_id, product_id, price, price_date)
VALUES
 (1, 1, 120.00, CURRENT_DATE),
 (2, 2,  50.00, CURRENT_DATE);

-- Пример проверки:
--   Подключаемся под sel:
--       SELECT update_price_if_stock_low(1, 99.99);
-- Если в Supply для product_id=1 < 10, цена обновится, иначе вернётся сообщение.


-------------------------------------------------------------------------------
-- (3) ДАЁМ ПРАВО АДМИНИСТРАТОРУ СЧИТЫВАТЬ 10% ЗАПИСЕЙ ИЗ СЕРЕДИНЫ ТАБЛИЦЫ 'ЗАКАЗЧИКИ'
-------------------------------------------------------------------------------
-- 1) Роль администратора
CREATE ROLE admin_role;

CREATE USER admin WITH PASSWORD '1';
GRANT admin_role TO admin;

-- 2) Представление "10% с середины"
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

-- Тестовые клиенты
INSERT INTO Customer (customer_id, last_name, first_name, middle_name, birth_date, address_id)
VALUES
 (1,'Иванов','Иван','Иванович','1980-01-01',101),
 (2,'Петров','Пётр','Петрович','1985-02-03',102),
 (3,'Сидоров','Сергей','Сергеевич','1990-03-05',103),
 (4,'Михайлов','Михаил','Михайлович','1992-05-22',104),
 (5,'Смирнов','Степан','Степанович','1995-08-15',105),
 (6,'Васильев','Василий','Васильевич','1983-11-30',106),
 (7,'Кузнецов','Константин','Константинович','1979-09-10',107),
 (8,'Попов','Павел','Павлович','1987-01-20',108),
 (9,'Григорьев','Григорий','Григорьевич','1999-12-31',109),
 (10,'Александров','Александр','Александрович','1989-06-06',110);

-- Проверка:
--   Подключаемся под admin:
--       SELECT * FROM middle_10_percent_customers;
-- Увидим ~10% записей (1 строку) вокруг середины (5-6-я строка).


-------------------------------------------------------------------------------
-- (4) ДАЁМ ПРАВО ТОВАРОВЕДУ ИЛИ ПРОДАВЦУ ВСТАВЛЯТЬ ИНФОРМАЦИЮ О ПОСТАВКЕ
--     (ЕСЛИ В ЭТОТ ДЕНЬ ТАКАЯ ЖЕ ПОСТАВКА ОТ ЭТОГО ПОСТАВЩИКА ЕЩЁ НЕ ЗАПИСАНА)
-------------------------------------------------------------------------------
-- 1) Роль товароведа
CREATE ROLE merchandiser_role;

CREATE USER merch WITH PASSWORD '1';
GRANT merchandiser_role TO merch;

-- 2) Функция вставки, если не существует дубль (supplier+product+date)
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

    -- Для supply_id используем некую последовательность (supply_seq)
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

-- 3) Выдаём права только товароведу
GRANT EXECUTE ON FUNCTION insert_supply_if_not_exists(INT, DATE, INT, INT) 
  TO merchandiser_role;

GRANT INSERT ON TABLE Supply TO merchandiser_role;

-- 4) Тест:
-- Подключаемся под merch:
--   SELECT insert_supply_if_not_exists(1, CURRENT_DATE, 1001, 100);
-- должно вернуться 'Success: new supply inserted.'
-- Повторный вызов с теми же параметрами вернёт 'Error: ...'
--
-- Если другой пользователь (например, sel) попробует:
--   SELECT insert_supply_if_not_exists(2, CURRENT_DATE, 1002, 50);
-- => "ERROR: permission denied for function insert_supply_if_not_exists"


-------------------------------------------------------------------------------
-- (5) ДАЁМ ПРАВО АДМИНИСТРАТОРУ IT УДАЛЯТЬ ПРОЦЕДУРЫ
-------------------------------------------------------------------------------
CREATE ROLE admin_it_role;

CREATE USER it_admin WITH PASSWORD '1';
GRANT admin_it_role TO it_admin;

CREATE OR REPLACE PROCEDURE test_procedure()
LANGUAGE plpgsql
AS $$
BEGIN
    RAISE NOTICE 'Чё-то там.';
END;
$$;

ALTER PROCEDURE test_procedure() OWNER TO admin_it_role;

GRANT CREATE ON SCHEMA public TO admin_it_role;

-- Проверка:
--   Подключаемся под it_admin:
--       DROP PROCEDURE test_procedure();
-- Если другой пользователь (например, merch) попробует:
--       DROP PROCEDURE test_procedure();
-- то будет:
--   "ERROR: must be owner of procedure test_procedure"


-------------------------------------------------------------------------------
-- (ДОПОЛНИТЕЛЬНЫЕ ДАННЫЕ ПОСЛЕ ВСЕХ ПУНКТОВ ЛАБОРАТОРНОЙ)
-------------------------------------------------------------------------------
-- 1) Создадим последовательность supply_seq (если её нет),
--    чтобы insert_supply_if_not_exists() могла генерировать supply_id
CREATE SEQUENCE IF NOT EXISTS supply_seq START 1000;

-- 2) Добавим недостающие адреса для Customer_Address,
--    чтобы не было ошибок по address_id=101..110 (ссылаются на таблицу Street).
--    Разобьём для примера: часть в город 1 (Москва), часть в город 2 (Пекин).
INSERT INTO Customer_Address (address_id, street_id, building)
VALUES
 (101, 1, '10'),
 (102, 1, '12'),
 (103, 1, '14'),
 (104, 1, '16'),
 (105, 1, '18'),
 (106, 2, '20'),
 (107, 2, '22'),
 (108, 2, '24'),
 (109, 2, '26'),
 (110, 2, '28');

-- (Примечание: если уже были вставлены такие адреса
--  в пункте (3) выше, можно пропустить.)

-- 3) Добавим ещё один товар и цену
INSERT INTO Product (product_id, product_name)
VALUES (3, 'Сыр');

INSERT INTO Pricing (pricing_id, product_id, price, price_date)
VALUES (3, 3, 200.00, CURRENT_DATE);

-- 4) Создадим тестовую поставку с маленьким количеством,
--    чтобы функция update_price_if_stock_low "сработала".
INSERT INTO Supply (supply_id, supplier_id, supply_date, product_id, quantity)
VALUES (13, 1, CURRENT_DATE, 3, 5); -- поставщик 1, товар 'Сыр', quantity=5 (<10)

-- Пример проверки под sel (роль seller_role):
--    SELECT update_price_if_stock_low(3, 150.00);
-- Ожидаем результат: 'Цена обновлена. (stock < 10).' 
-- и в таблице Pricing цена станет 150.00

-- 5) Проверка insert_supply_if_not_exists под merch (роль merchandiser_role):
--    SELECT insert_supply_if_not_exists(2, CURRENT_DATE, 3, 10);
-- Если (supplier=2, product=3, date=сегодня) ещё не существует, 
-- вернётся 'Success: new supply inserted.'
-- Если вызвать повторно, получим 'Error: Supply for this supplier, product, and date already exists.'
