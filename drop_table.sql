-- Создание ролей
CREATE ROLE supplier1 LOGIN PASSWORD 'supplier1pass';
CREATE ROLE customer1 LOGIN PASSWORD 'customer1pass';

-- Таблицы соответствия пользователей поставщикам и заказчикам
CREATE TABLE users_suppliers (
    login TEXT PRIMARY KEY,
    supplier_id INT UNIQUE
);

CREATE TABLE users_customers (
    login TEXT PRIMARY KEY,
    customer_id INT UNIQUE
);

-- Добавление пользователей
INSERT INTO users_suppliers VALUES ('supplier1', 1);
INSERT INTO users_customers VALUES ('customer1', 1);

-- Таблица поставок
CREATE TABLE Supply (
    id SERIAL PRIMARY KEY,
    product_name TEXT,
    quantity INT,
    supplier_id INT,
    CONSTRAINT fk_supplier FOREIGN KEY (supplier_id) REFERENCES users_suppliers(supplier_id)
);

-- Таблица заказов
CREATE TABLE Customer_Order (
    id SERIAL PRIMARY KEY,
    product_name TEXT,
    quantity INT,
    customer_id INT,
    CONSTRAINT fk_customer FOREIGN KEY (customer_id) REFERENCES users_customers(customer_id)
);

-- Включение RLS для таблицы Supply
ALTER TABLE Supply ENABLE ROW LEVEL SECURITY;

-- Политики RLS для поставщика
CREATE POLICY supply_select
ON Supply
FOR SELECT
TO supplier1
USING (
    supplier_id = (
        SELECT supplier_id
        FROM users_suppliers
        WHERE login = current_user
    )
);

CREATE POLICY supply_update
ON Supply
FOR UPDATE
TO supplier1
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

CREATE POLICY supply_delete
ON Supply
FOR DELETE
TO supplier1
USING (
    supplier_id = (
        SELECT supplier_id
        FROM users_suppliers
        WHERE login = current_user
    )
);

CREATE POLICY supply_insert
ON Supply
FOR INSERT
TO supplier1
WITH CHECK (
    supplier_id = (
        SELECT supplier_id
        FROM users_suppliers
        WHERE login = current_user
    )
);

-- Выдача прав поставщику
GRANT SELECT, INSERT, UPDATE, DELETE ON Supply TO supplier1;
GRANT SELECT ON users_suppliers TO supplier1;

-- Включение RLS для таблицы Customer_Order
ALTER TABLE Customer_Order ENABLE ROW LEVEL SECURITY;

-- Политики RLS для заказчика
CREATE POLICY customer_order_select
ON Customer_Order
FOR SELECT
TO customer1
USING (
    customer_id = (
        SELECT customer_id
        FROM users_customers
        WHERE login = current_user
    )
);

CREATE POLICY customer_order_update
ON Customer_Order
FOR UPDATE
TO customer1
USING (
    customer_id = (
        SELECT customer_id
        FROM users_customers
        WHERE login = current_user
    )
)
WITH CHECK (
    customer_id = (
        SELECT customer_id
        FROM users_customers
        WHERE login = current_user
    )
);

CREATE POLICY customer_order_delete
ON Customer_Order
FOR DELETE
TO customer1
USING (
    customer_id = (
        SELECT customer_id
        FROM users_customers
        WHERE login = current_user
    )
);

CREATE POLICY customer_order_insert
ON Customer_Order
FOR INSERT
TO customer1
WITH CHECK (
    customer_id = (
        SELECT customer_id
        FROM users_customers
        WHERE login = current_user
    )
);

-- Выдача прав заказчику
GRANT SELECT, INSERT, UPDATE, DELETE ON Customer_Order TO customer1;
GRANT SELECT ON users_customers TO customer1;

-- Тестовые данные (добавлять от имени администратора)
INSERT INTO Supply (product_name, quantity, supplier_id) VALUES
('Screws', 100, 1),
('Bolts', 200, 2);

INSERT INTO Customer_Order (product_name, quantity, customer_id) VALUES
('Screws', 20, 1),
('Nuts', 50, 2);

-- Тестовые SELECT-запросы (выполнять от имени пользователей)
-- От имени supplier1:
-- Должен видеть только supply с supplier_id = 1
-- SELECT * FROM Supply;

-- Попытка вставки (успешная)
-- INSERT INTO Supply (product_name, quantity, supplier_id)
-- VALUES ('Washers', 150, 1);

-- Попытка вставки (неуспешная)
-- INSERT INTO Supply (product_name, quantity, supplier_id)
-- VALUES ('Washers', 150, 2);

-- От имени customer1:
-- SELECT * FROM Customer_Order;

-- Вставка заказа (успешная)
-- INSERT INTO Customer_Order (product_name, quantity, customer_id)
-- VALUES ('Screws', 10, 1);

-- Вставка заказа (неуспешная)
-- INSERT INTO Customer_Order (product_name, quantity, customer_id)
-- VALUES ('Screws', 10, 2);
