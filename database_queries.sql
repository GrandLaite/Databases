/*
Задание к лабораторной работе №2
Создайте SQL-операторы, выполняющие указанные ниже действия к базам данных, разработанным в лабораторной работе №1. 
В зависимости от реализации базы данных в предыдущей работе добавьте два собственных запроса.
Вариант №1
1)Подсчитать количество товаров имеющих цену свыше 1500 руб.
2)Вывести список постоянных клиентов старше 50 лет, которым положена скидка 12%(за возраст).
3)Удалите из таблицы все записи о заказах сделанных до 31.12.2015
4)Вывести данные о покупателях не живущих в России.
5)Создайте запись о новом поставщике.
6)Определите максимальную стоимость товара за 2023-2024 год.
7)Вывести количество людей, родившихся после 1990 года
8)Вывести список всех уникальных городов, в которых находятся поставщики
*/


/* Подсчитать количество товаров имеющих цену свыше 1500 руб. */
SELECT COUNT(*) AS count_of_expensive_products
FROM Pricing
WHERE price > 1500;

/* Вывести список постоянных клиентов старше 50 лет, которым положена скидка 12%(за возраст) */
SELECT customer_id, last_name, first_name, middle_name, birth_date
FROM Customer
WHERE DATE_PART('year', AGE(birth_date)) > 50;

/* Удалите из таблицы все записи о заказах сделанных до 31.12.2015 */
DELETE FROM Customer_Order
WHERE order_date < '2016-01-01';


/* Вывести данные о покупателях не живущих в России. */
SELECT *
FROM Customer AS c
JOIN Customer_Address AS ca ON c.address_id = ca.address_id
JOIN Street AS s ON ca.street_id = s.street_id
JOIN City AS ci ON s.city_id = ci.city_id
JOIN Country AS co ON ci.country_id = co.country_id
WHERE co.country_name != 'Россия';

/* Создайте запись о новом поставщике. */
INSERT INTO Supplier (supplier_id, last_name, first_name, middle_name, phone, address_id)
VALUES (8, 'Сазонов', 'Виктор', 'Павлович', '513-612', 2);

/* Определите максимальную стоимость товара за 2023-2024 год. */
SELECT MAX(price) AS max_price
FROM Pricing
WHERE price_date BETWEEN '2023-01-01' AND '2024-12-31';


/* Вывести покупателей людей, родившихся после 1990 года */
SELECT COUNT(*) AS customers_born_after_1990
FROM Customer
WHERE birth_date > '1990-01-01';

/* Вывести список всех уникальных городов, в которых находятся поставщики */
SELECT DISTINCT ci.city_name
FROM Supplier AS s
JOIN Supplier_Address AS sa ON s.address_id = sa.address_id
JOIN Street AS st ON sa.street_id = st.street_id
JOIN City AS ci ON st.city_id = ci.city_id;

