CREATE ROLE supplier1 LOGIN PASSWORD 'supplier1pass';
CREATE ROLE customer1 LOGIN PASSWORD 'customer1pass';

CREATE TABLE users_suppliers (
    login text,
    supplier_id int
);

CREATE TABLE users_customers (
    login text,
    customer_id int
);

INSERT INTO users_suppliers VALUES ('supplier1', 1);
INSERT INTO users_customers VALUES ('customer1', 1);

ALTER TABLE Supply ENABLE ROW LEVEL SECURITY;

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

GRANT SELECT, INSERT, UPDATE, DELETE ON Supply TO supplier1;
GRANT SELECT ON users_suppliers TO supplier1;

ALTER TABLE Customer_Order ENABLE ROW LEVEL SECURITY;

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

GRANT SELECT, INSERT, UPDATE, DELETE ON Customer_Order TO customer1;
GRANT SELECT ON users_customers TO customer1;
