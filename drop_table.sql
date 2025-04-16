-- Создание ролей поставщиков
CREATE ROLE supplier1 LOGIN PASSWORD 'supplier1pass';
CREATE ROLE supplier2 LOGIN PASSWORD 'supplier2pass';

-- Таблица соответствия логинов и поставщиков
CREATE TABLE users_suppliers (
    login TEXT PRIMARY KEY,
    supplier_id INT UNIQUE
);

-- Добавление логинов и supplier_id
INSERT INTO users_suppliers VALUES ('supplier1', 1), ('supplier2', 2);

-- Таблица поставок
CREATE TABLE Supply (
    id SERIAL PRIMARY KEY,
    product_name TEXT,
    quantity INT,
    supplier_id INT
);

-- Включение RLS
ALTER TABLE Supply ENABLE ROW LEVEL SECURITY;

-- Политика SELECT: каждый видит только свои строки
CREATE POLICY supply_select_policy
ON Supply
FOR SELECT
TO PUBLIC
USING (
    supplier_id = (
        SELECT supplier_id
        FROM users_suppliers
        WHERE login = current_user
    )
);

-- Политика INSERT: вставлять можно только строки со своим supplier_id
CREATE POLICY supply_insert_policy
ON Supply
FOR INSERT
TO PUBLIC
WITH CHECK (
    supplier_id = (
        SELECT supplier_id
        FROM users_suppliers
        WHERE login = current_user
    )
);

-- Политика UPDATE: можно обновлять только свои строки, и новые данные должны оставаться «своими»
CREATE POLICY supply_update_policy
ON Supply
FOR UPDATE
TO PUBLIC
USING (
    supplier_id = (
        SELECT supplier_id
        FROM users_suppliers
        WHERE login = current_user
    )
)
WITH CHECK (
    supplier_id = (
        SELECT supplier_id
        FROM users_suppliers
        WHERE login = current_user
    )
);

-- Выдача прав на таблицу
GRANT SELECT, INSERT, UPDATE ON Supply TO supplier1, supplier2;
GRANT SELECT ON users_suppliers TO supplier1, supplier2;

-- Добавление тестовых данных (выполнять от администратора)
INSERT INTO Supply (product_name, quantity, supplier_id)
VALUES 
('Screws', 100, 1),    -- принадлежит supplier1
('Nails', 200, 2);     -- принадлежит supplier2

-- Примеры проверки:

-- Под supplier1:
--     SELECT * FROM Supply;
--     UPDATE Supply SET quantity = 150 WHERE id = 1; -- успешно
--     UPDATE Supply SET quantity = 999 WHERE id = 2; -- ошибка, строка не видна

-- Под supplier2:
--     SELECT * FROM Supply;
--     UPDATE Supply SET product_name = 'Big Nails' WHERE id = 2; -- успешно
--     UPDATE Supply SET quantity = 0 WHERE id = 1; -- ошибка, строка не видна

-- Попытка обновить supplier_id (например, чужой или NULL) также будет заблокирована благодаря WITH CHECK
