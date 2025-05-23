INSERT INTO Country (country_id, country_name) VALUES
(1, 'Россия'),
(2, 'США');

INSERT INTO City (city_id, country_id, city_name) VALUES
(1, 1, 'Москва'),
(2, 1, 'Санкт-Петербург'),
(3, 1, 'Новосибирск'),
(4, 1, 'Казань'),
(5, 2, 'Нью-Йорк'),
(6, 2, 'Лос-Анджелес'),
(7, 2, 'Чикаго'),
(8, 2, 'Сан-Франциско');

INSERT INTO Street (street_id, city_id, street_name) VALUES
(1, 1, 'Тверская'),
(2, 1, 'Арбат'),
(3, 2, 'Невский проспект'),
(4, 3, 'Красный проспект'),
(5, 3, 'Ленина'),
(6, 4, 'Пушкина'),
(7, 5, 'Бродвей'),
(8, 6, 'Голливудский бульвар'),
(9, 7, 'Мичиган авеню'),
(10, 8, 'Маркет-стрит');

INSERT INTO Supplier_Address (address_id, street_id, building) VALUES
(1, 1, '10А'),
(2, 2, '5'),
(3, 7, '100'),
(4, 8, '50'),
(5, 9, '3A'),
(6, 10, '22B');

INSERT INTO Supplier (supplier_id, last_name, first_name, middle_name, phone, address_id) VALUES
(1, 'Иванов', 'Иван', 'Иванович', '123-456', 1),
(2, 'Петров', 'Петр', 'Петрович', '654-321', 2),
(3, 'Смирнов', 'Сергей', 'Сергеевич', '555-555', 3),
(4, 'Кузьмина', 'Ольга', 'Николаевна', '333-999', 4),
(5, 'Сидоров', 'Александр', 'Иванович', '444-888', 5),
(6, 'Джонсон', 'Майкл', 'Эдвардович', '555-777', 6),
(7, 'Новиков', 'Денис', 'Викторович', '123-789', 1);  

INSERT INTO Product (product_id, product_name) VALUES
(1, 'Ноутбук'),
(2, 'Смартфон'),
(3, 'Планшет'),
(4, 'Телевизор'),
(5, 'Игровая консоль'),
(6, 'Наушники');

INSERT INTO Pricing (pricing_id, product_id, price, price_date) VALUES
(1, 1, 50000.00, '2024-01-01'),
(2, 2, 30000.00, '2024-01-01'),
(3, 3, 20000.00, '2024-01-01'),
(4, 4, 45000.00, '2024-01-01'),
(5, 5, 25000.00, '2024-02-01'),
(6, 6, 7000.00, '2024-03-01'),
(7, 1, 52000.00, '2024-04-01'),
(8, 2, 28000.00, '2024-04-15'),
(9, 3, 22000.00, '2024-07-01'),
(10, 4, 46000.00, '2024-08-01'),
(11, 5, 26000.00, '2024-08-15'),
(12, 1, 1600.00, '2023-05-01'),  
(13, 2, 1800.00, '2024-03-10');  

INSERT INTO Customer_Address (address_id, street_id, building) VALUES
(1, 3, '20'),
(2, 5, '40'),
(3, 6, '18A'),
(4, 9, '15'),
(5, 10, '10');

INSERT INTO Customer (customer_id, last_name, first_name, middle_name, birth_date, address_id) VALUES
(1, 'Сидоров', 'Алексей', 'Алексеевич', '1980-05-20', 1),
(2, 'Кузнецов', 'Владимир', 'Владимирович', '1990-10-12', 2),
(3, 'Морозов', 'Дмитрий', 'Дмитриевич', '1975-12-30', 3),
(4, 'Павлов', 'Егор', 'Ильич', '1988-07-15', 4),
(5, 'Зайцев', 'Максим', 'Олегович', '1991-01-22', 5),
(6, 'Лебедев', 'Виктор', 'Павлович', '1965-04-12', 2),  
(7, 'Вонг', 'Ли', 'Сун', '1970-11-05', 3);              

INSERT INTO Customer_Order (order_id, order_date, customer_id, product_id, quantity) VALUES
(1, '2024-02-15', 1, 1, 2),
(2, '2024-03-10', 2, 2, 1),
(3, '2024-04-05', 3, 3, 5),
(4, '2024-06-12', 4, 1, 2),
(5, '2024-06-18', 5, 2, 5),
(6, '2014-06-15', 1, 1, 3),  
(7, '2013-11-23', 2, 2, 2);   

INSERT INTO Supply (supply_id, supplier_id, supply_date, product_id, quantity) VALUES
(1, 1, '2024-01-15', 1, 100),
(2, 2, '2024-02-20', 2, 200),
(3, 3, '2024-03-25', 3, 300),
(4, 4, '2024-04-10', 2, 500),
(5, 5, '2024-05-22', 3, 300),
(6, 6, '2024-06-15', 1, 400),
(7, 3, '2024-07-25', 1, 200),
(8, 4, '2024-08-01', 5, 120),
(9, 7, '2023-07-20', 1, 100),  
(10, 7, '2024-02-15', 2, 50);  

-- 1. Добавляем страну
INSERT INTO Country (country_id, country_name) VALUES (1, 'Россия');

-- 2. Добавляем город, ссылаясь на страну
INSERT INTO City (city_id, country_id, city_name) VALUES (1, 1, 'Москва');

-- 3. Добавляем улицу, ссылаясь на город
INSERT INTO Street (street_id, city_id, street_name) VALUES (1, 1, 'Ленина');

-- 4. Добавляем адрес поставщика, ссылаясь на улицу
INSERT INTO Supplier_Address (address_id, street_id, building) VALUES (1, 1, '25А');

-- 5. Добавляем поставщика, ссылаясь на адрес
INSERT INTO Supplier (supplier_id, last_name, first_name, middle_name, phone, address_id)
VALUES (1, 'Иванов', 'Иван', 'Иванович', '+79421512561', 1);

-- 6. Добавляем товар
INSERT INTO Product (product_id, product_name) VALUES (1, 'Молоко');

-- 7. Добавляем поставку, ссылаясь на поставщика и товар
INSERT INTO Supply (supply_id, supplier_id, supply_date, product_id, quantity)
VALUES (10, 1, CURRENT_DATE, 1, 50);

-- 8. Добавляем цену товара
INSERT INTO Pricing (pricing_id, product_id, price, price_date)
VALUES (1, 1, 120.00, CURRENT_DATE);

-- 9. Добавляем адрес покупателя, ссылаясь на улицу
INSERT INTO Customer_Address (address_id, street_id, building) VALUES (2, 1, '30Б');

-- 10. Добавляем покупателя, ссылаясь на адрес
INSERT INTO Customer (customer_id, last_name, first_name, middle_name, birth_date, address_id)
VALUES (1, 'Петров', 'Пётр', 'Петрович', '1985-02-03', 2);

-- 11. Добавляем заказ покупателя на товар
INSERT INTO Customer_Order (order_id, order_date, customer_id, product_id, quantity)
VALUES (1, CURRENT_DATE, 1, 1, 10);

/*************************************************************
* 1. ДОБАВЛЕНИЕ НОВЫХ ПОЛЬЗОВАТЕЛЕЙ С ВЗАИМНОЙ ДРУЖБОЙ
*************************************************************/
db.users.insertMany([
  {
    _id: ObjectId("664600000000000000000008"),
    username: "vera",
    email: "vera@social.local",
    full_name: "Вера Зайцева",
    date_of_birth: ISODate("1996-12-21T00:00:00Z"),
    gender: "female",
    registration_date: ISODate("2024-04-16T11:10:00Z"),
    friends: [
      ObjectId("664600000000000000000009"), // nikita
      ObjectId("664600000000000000000002")  // bob
    ],
    interests: ["music", "photography"],
    location: { city: "Калуга", country: "Россия" },
    status: "На позитиве!"
  },
  {
    _id: ObjectId("664600000000000000000009"),
    username: "nikita",
    email: "nikita@social.local",
    full_name: "Никита Сергеев",
    date_of_birth: ISODate("1998-09-13T00:00:00Z"),
    gender: "male",
    registration_date: ISODate("2024-04-16T11:12:00Z"),
    friends: [
      ObjectId("664600000000000000000008"), // vera
      ObjectId("664600000000000000000001")  // alice
    ],
    interests: ["gaming", "travel"],
    location: { city: "Омск", country: "Россия" },
    status: "Жду выходных!"
  }
]);


/*************************************************************
* 2. ОБНОВЛЕНИЕ FRIENDS ДЛЯ СУЩЕСТВУЮЩИХ ПОЛЬЗОВАТЕЛЕЙ
*************************************************************/

// vera <-> bob взаимная
db.users.updateOne(
  { _id: ObjectId("664600000000000000000002") }, // bob
  { $addToSet: { friends: ObjectId("664600000000000000000008") } }
);
db.users.updateOne(
  { _id: ObjectId("664600000000000000000008") }, // vera
  { $addToSet: { friends: ObjectId("664600000000000000000002") } }
);

// nikita <-> alice взаимная
db.users.updateOne(
  { _id: ObjectId("664600000000000000000001") }, // alice
  { $addToSet: { friends: ObjectId("664600000000000000000009") } }
);

// fiona <-> ivanov взаимная
db.users.updateOne(
  { _id: ObjectId("664600000000000000000006") }, // fiona
  { $addToSet: { friends: ObjectId("664600000000000000000007") } }
);

// dasha <-> bob взаимная
db.users.updateOne(
  { _id: ObjectId("664600000000000000000002") }, // bob
  { $addToSet: { friends: ObjectId("664600000000000000000004") } }
);
db.users.updateOne(
  { _id: ObjectId("664600000000000000000004") }, // dasha
  { $addToSet: { friends: ObjectId("664600000000000000000002") } }
);


/*************************************************************
* 3. ВЫПОЛНЕНИЕ ЗАПРОСА НА ВЗАИМНЫХ ДРУЗЕЙ
*************************************************************/
db.users.aggregate([
  { $unwind: "$friends" },
  {
    $lookup: {
      from: "users",
      localField: "friends",
      foreignField: "_id",
      as: "friend_doc"
    }
  },
  { $unwind: "$friend_doc" },
  {
    $match: { $expr: { $in: ["$_id", "$friend_doc.friends"] } }
  },
  {
    $project: { _id:0, user1:"$username", user2:"$friend_doc.username" }
  },
  {
    $addFields: {
      pair: {
        $cond: [
          { $gt: ["$user1","$user2"] },
          ["$user2","$user1"],
          ["$user1","$user2"]
        ]
      }
    }
  },
  { $group: { _id: "$pair" } },
  { $project: { _id:0, mutual_friends:"$_id" } }
]);
