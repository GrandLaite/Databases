/******************************************************************
  0.  ПОДКЛЮЧЕНИЕ
      mongosh "mongodb://localhost:27017"
******************************************************************/

/*---------------------------------------------------------------
  1.  СОЗДАНИЕ/ВЫБОР БАЗЫ  +  КОЛЛЕКЦИЙ
----------------------------------------------------------------*/
use social_network              // база появится при первой записи
db.createCollection("users")    // можно опустить: создастся сама
db.createCollection("posts")

/*---------------------------------------------------------------
  2.  ВСТАВКА ПОЛЬЗОВАТЕЛЕЙ
----------------------------------------------------------------*/
db.users.insertMany([
/* ---------- alice ---------- */
{
  _id: ObjectId("664600000000000000000001"),
  username: "alice",
  email: "alice@social.local",
  full_name: "Алиса Смирнова",
  date_of_birth: ISODate("1998-05-12T00:00:00Z"),
  gender: "female",
  registration_date: ISODate("2024-02-11T10:05:00Z"),
  friends: [
    ObjectId("664600000000000000000002"),
    ObjectId("664600000000000000000003")
  ],
  interests: ["travel","photography","music"],
  location: { city: "Москва", country: "Россия" },
  status: "Feeling great today!"
},
/* ---------- bob ---------- */
{
  _id: ObjectId("664600000000000000000002"),
  username: "bob",
  email: "bob@social.local",
  full_name: "Борис Кузнецов",
  date_of_birth: ISODate("1995-11-03T00:00:00Z"),
  gender: "male",
  registration_date: ISODate("2024-03-01T08:45:00Z"),
  friends: [ObjectId("664600000000000000000001")],
  interests: ["music","gaming"],
  location: { city: "Санкт-Петербург", country: "Россия" },
  status: "Всем привет!"
},
/* ---------- chris ---------- */
{
  _id: ObjectId("664600000000000000000003"),
  username: "chris",
  email: "chris@social.local",
  full_name: "Кристина Павлова",
  date_of_birth: ISODate("2000-01-20T00:00:00Z"),
  gender: "female",
  registration_date: ISODate("2024-04-10T15:30:00Z"),
  friends: [ObjectId("664600000000000000000001")],
  interests: ["travel","art"],
  location: { city: "Новосибирск", country: "Россия" },
  status: "Готовлюсь к путешествию ✈️"
},
/* ---------- dasha ---------- */
{
  _id: ObjectId("664600000000000000000004"),
  username: "dasha",
  email: "dasha@social.local",
  full_name: "Дарья Орлова",
  date_of_birth: ISODate("1992-02-14T00:00:00Z"),
  gender: "female",
  registration_date: ISODate("2024-01-25T12:30:00Z"),
  friends: [ObjectId("664600000000000000000002")],
  interests: ["yoga","cooking"],
  location: { city: "Казань", country: "Россия" },
  status: "В поиске вдохновения ☕"
},
/* ---------- egor ---------- */
{
  _id: ObjectId("664600000000000000000005"),
  username: "egor",
  email: "egor@social.local",
  full_name: "Егор Лебедев",
  date_of_birth: ISODate("1989-08-09T00:00:00Z"),
  gender: "male",
  registration_date: ISODate("2024-01-03T09:00:00Z"),
  friends: [],
  interests: ["cycling","books"],
  location: { city: "Воронеж", country: "Россия" },
  status: "Буду offline до понедельника"
},
/* ---------- fiona ---------- */
{
  _id: ObjectId("664600000000000000000006"),
  username: "fiona",
  email: "fiona@social.local",
  full_name: "Фиона Морозова",
  date_of_birth: ISODate("1997-07-07T00:00:00Z"),
  gender: "female",
  registration_date: ISODate("2024-04-05T14:00:00Z"),
  friends: [ObjectId("664600000000000000000001")],
  interests: ["cinema","languages"],
  location: { city: "Самара", country: "Россия" },
  status: "Учу испанский 💃"
},
/* ---------- ivanov ---------- */
{
  _id: ObjectId("664600000000000000000007"),
  username: "ivanov",
  email: "ivanov@social.local",
  full_name: "Иван Иванов",
  date_of_birth: ISODate("1994-04-01T00:00:00Z"),
  gender: "male",
  registration_date: ISODate("2024-02-15T18:45:00Z"),
  friends: [ObjectId("664600000000000000000006")],
  interests: ["travel","history"],
  location: { city: "Екатеринбург", country: "Россия" },
  status: "Читаю Толстого 📚"
}
]);

/*---------------------------------------------------------------
  3.  ВСТАВКА ПОСТОВ
----------------------------------------------------------------*/
db.posts.insertMany([
{
  _id: ObjectId("664700000000000000000010"),
  user_id: ObjectId("664600000000000000000001"),
  content: "Моё утро началось с пробежки в парке!",
  media_urls: ["https://cdn.social.local/pics/run1.jpg"],
  created_at: ISODate("2025-04-20T06:15:00Z"),
  likes: [
    ObjectId("664600000000000000000002"),
    ObjectId("664600000000000000000003")
  ],
  comments: [
    {
      comment_id: ObjectId("664700000000000000000101"),
      user_id: ObjectId("664600000000000000000002"),
      content: "Круто! Сколько км пробежала?",
      created_at: ISODate("2025-04-20T06:20:00Z"),
      likes: []
    }
  ]
},
{
  _id: ObjectId("664700000000000000000011"),
  user_id: ObjectId("664600000000000000000002"),
  content: "Новый кавер на любимую песню уже на канале!",
  media_urls: [],
  created_at: ISODate("2025-04-20T18:45:00Z"),
  likes: [ObjectId("664600000000000000000001")],
  comments: []
},
{
  _id: ObjectId("664700000000000000000012"),
  user_id: ObjectId("664600000000000000000003"),
  content: "Собрала 10 лайф-хаков для бюджетных путешествий ✈️",
  media_urls: ["https://cdn.social.local/pics/travel.jpg"],
  created_at: ISODate("2025-04-21T09:10:00Z"),
  likes: [
    ObjectId("664600000000000000000001"),
    ObjectId("664600000000000000000002")
  ],
  comments: [
    {
      comment_id: ObjectId("664700000000000000000102"),
      user_id: ObjectId("664600000000000000000001"),
      content: "Очень полезно, спасибо!",
      created_at: ISODate("2025-04-21T09:30:00Z"),
      likes: [ObjectId("664600000000000000000003")]
    }
  ]
},
{
  _id: ObjectId("664700000000000000000013"),
  user_id: ObjectId("664600000000000000000004"),
  content: "Сегодня был потрясающий день — готовила лазанью и пела в душе 🎶",
  media_urls: [],
  created_at: ISODate("2025-04-21T11:00:00Z"),
  likes: [],
  comments: []
},
{
  _id: ObjectId("664700000000000000000014"),
  user_id: ObjectId("664600000000000000000005"),
  content: "Читаю книгу по философии. Думаю, каждый должен раз в жизни её открыть.",
  media_urls: [],
  created_at: ISODate("2025-04-21T21:15:00Z"),
  likes: [ObjectId("664600000000000000000004")],
  comments: []
},
{
  _id: ObjectId("664700000000000000000015"),
  user_id: ObjectId("664600000000000000000006"),
  content: "Кто хочет на вечер кино? Я устрою мини-кинотеатр 🎬",
  media_urls: [],
  created_at: ISODate("2025-04-21T19:45:00Z"),
  likes: [
    ObjectId("664600000000000000000001"),
    ObjectId("664600000000000000000007"),
    ObjectId("664600000000000000000004")
  ],
  comments: [
    {
      comment_id: ObjectId("664700000000000000000103"),
      user_id: ObjectId("664600000000000000000001"),
      content: "Я с попкорном! 🍿",
      created_at: ISODate("2025-04-21T20:00:00Z"),
      likes: []
    },
    {
      comment_id: ObjectId("664700000000000000000104"),
      user_id: ObjectId("664600000000000000000007"),
      content: "Фильм будет на испанском? 😄",
      created_at: ISODate("2025-04-21T20:05:00Z"),
      likes: [ObjectId("664600000000000000000006")]
    }
  ]
},
{
  _id: ObjectId("664700000000000000000016"),
  user_id: ObjectId("664600000000000000000007"),
  content: "Поделитесь идеями: куда поехать в мае на пару дней?",
  media_urls: [],
  created_at: ISODate("2025-04-22T08:30:00Z"),
  likes: [],
  comments: [
    {
      comment_id: ObjectId("664700000000000000000105"),
      user_id: ObjectId("664600000000000000000003"),
      content: "Анапа? Тихо и море рядом",
      created_at: ISODate("2025-04-22T08:45:00Z"),
      likes: []
    }
  ]
},
{
  _id: ObjectId("664700000000000000000017"),
  user_id: ObjectId("664600000000000000000003"),
  content: "Поделилась гидами по Тбилиси. Кто был — что скажете?",
  media_urls: [],
  created_at: ISODate("2025-04-22T10:10:00Z"),
  likes: [
    ObjectId("664600000000000000000002"),
    ObjectId("664600000000000000000004"),
    ObjectId("664600000000000000000005"),
    ObjectId("664600000000000000000006")
  ],
  comments: []
}
]);

/*---------------------------------------------------------------
  4.  АНАЛИТИЧЕСКИЕ ЗАПРОСЫ
----------------------------------------------------------------*/

// 4.1  Топ-10 популярных постов
db.posts.aggregate([
  {
    $project: {
      content: 1,
      author: "$user_id",
      likes_count: { $size: { $ifNull: ["$likes", []] } },
      comments_count: { $size: { $ifNull: ["$comments", []] } },
      popularity: {
        $add: [
          { $size: { $ifNull: ["$likes", []] } },
          { $size: { $ifNull: ["$comments", []] } }
        ]
      }
    }
  },
  { $sort: { popularity: -1 } },
  { $limit: 10 }
]);

// 4.2  Активность пользователей по времени суток
db.posts.aggregate([
  {
    $group: {
      _id: { hour: { $hour: { date: "$created_at", timezone: "+03:00" } } },
      posts_count: { $sum: 1 }
    }
  },
  {
    $addFields: {
      timeslot: {
        $switch: {
          branches: [
            { case: { $in: ["$_id.hour", [0,1,2,3,4,5]] }, then: "ночь" },
            { case: { $in: ["$_id.hour", [6,7,8,9,10]] }, then: "утро" },
            { case: { $in: ["$_id.hour", [11,12,13,14,15,16]] }, then: "день" },
            { case: { $in: ["$_id.hour", [17,18,19,20,21,22,23]] }, then: "вечер" }
          ],
          default: "неизвестно"
        }
      }
    }
  },
  {
    $group: { _id: "$timeslot", posts: { $sum: "$posts_count" } }
  },
  { $sort: { posts: -1 } }
]);

// 4.3  Взаимные дружеские связи
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

/******************************************************************
  ГОТОВО!  Данные загружены, запросы работают.
******************************************************************/
