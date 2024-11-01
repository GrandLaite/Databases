/* 
Вариант №1
Создать триггеры:
1.Проверка во время вставки значения стоимости товара, чтобы цена у товара была не ниже 10 руб. 
2.Организовать каскадное удаление из таблицы "Товар".
*/


/* 1.Проверка во время вставки значения стоимости товара, чтобы цена у товара была не ниже 10 руб.  */
CREATE OR REPLACE FUNCTION check_min_price()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.price < 10 THEN
        RAISE EXCEPTION 'Цена товара не может быть ниже 10 рублей.';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER check_min_price_trigger
BEFORE INSERT OR UPDATE ON Pricing
FOR EACH ROW
EXECUTE FUNCTION check_min_price();

/* Два вида проверочных данных:
1.1.Вставка новых данных с низкой ценой.
1.2.Обновление данных с изменением обычной цены на недопустимо низкую 
*/

/* 1.1.Вставка новых данных с низкой ценой.*/
INSERT INTO Pricing (pricing_id, product_id, price, price_date) 
VALUES (14, 1, 5.00, '2024-10-01');

/* 1.2.Обновление данных с изменением обычной цены на недопустимо низкую */
UPDATE Pricing
SET price = 8.00 
WHERE pricing_id = 1;


/* 2.Организовать каскадное удаление из таблицы "Товар". */
ALTER TABLE Pricing
DROP CONSTRAINT pricing_product_id_fkey,  
ADD CONSTRAINT pricing_product_id_fkey
FOREIGN KEY (product_id) REFERENCES Product(product_id) ON DELETE CASCADE;

ALTER TABLE Customer_Order
DROP CONSTRAINT customer_order_product_id_fkey,  
ADD CONSTRAINT customer_order_product_id_fkey
FOREIGN KEY (product_id) REFERENCES Product(product_id) ON DELETE CASCADE;

ALTER TABLE Supply
DROP CONSTRAINT supply_product_id_fkey,  
ADD CONSTRAINT supply_product_id_fkey
FOREIGN KEY (product_id) REFERENCES Product(product_id) ON DELETE CASCADE;

/* Проверяем удаление */

/* Удаляем товар с id 1 */
DELETE FROM Product
WHERE product_id = 1;

/* Проверяем, остались ли связанные с товаром записи */
SELECT * FROM Pricing WHERE product_id = 1;
SELECT * FROM Customer_Order WHERE product_id = 1;
SELECT * FROM Supply WHERE product_id = 1;