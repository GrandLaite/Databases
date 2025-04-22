users
[
  {
    "_id": { "$oid": "664600000000000000000001" },
    "username": "alice",
    "email": "alice@social.local",
    "full_name": "Алиса Смирнова",
    "date_of_birth": { "$date": "1998-05-12T00:00:00Z" },
    "gender": "female",
    "registration_date": { "$date": "2024-02-11T10:05:00Z" },
    "friends": [
      { "$oid": "664600000000000000000002" },
      { "$oid": "664600000000000000000003" }
    ],
    "interests": ["travel", "photography", "music"],
    "location": { "city": "Москва", "country": "Россия" },
    "status": "Feeling great today!"
  },
  {
    "_id": { "$oid": "664600000000000000000002" },
    "username": "bob",
    "email": "bob@social.local",
    "full_name": "Борис Кузнецов",
    "date_of_birth": { "$date": "1995-11-03T00:00:00Z" },
    "gender": "male",
    "registration_date": { "$date": "2024-03-01T08:45:00Z" },
    "friends": [{ "$oid": "664600000000000000000001" }],
    "interests": ["music", "gaming"],
    "location": { "city": "Санкт‑Петербург", "country": "Россия" },
    "status": "Всем привет!"
  },
  {
    "_id": { "$oid": "664600000000000000000003" },
    "username": "chris",
    "email": "chris@social.local",
    "full_name": "Кристина Павлова",
    "date_of_birth": { "$date": "2000-01-20T00:00:00Z" },
    "gender": "female",
    "registration_date": { "$date": "2024-04-10T15:30:00Z" },
    "friends": [{ "$oid": "664600000000000000000001" }],
    "interests": ["travel", "art"],
    "location": { "city": "Новосибирск", "country": "Россия" },
    "status": "Готовлюсь к путешествию ✈️"
  },
  {
    "_id": { "$oid": "664600000000000000000004" },
    "username": "dasha",
    "email": "dasha@social.local",
    "full_name": "Дарья Орлова",
    "date_of_birth": { "$date": "1992-02-14T00:00:00Z" },
    "gender": "female",
    "registration_date": { "$date": "2024-01-25T12:30:00Z" },
    "friends": [{ "$oid": "664600000000000000000002" }],
    "interests": ["yoga", "cooking"],
    "location": { "city": "Казань", "country": "Россия" },
    "status": "В поиске вдохновения ☕"
  },
  {
    "_id": { "$oid": "664600000000000000000005" },
    "username": "egor",
    "email": "egor@social.local",
    "full_name": "Егор Лебедев",
    "date_of_birth": { "$date": "1989-08-09T00:00:00Z" },
    "gender": "male",
    "registration_date": { "$date": "2024-01-03T09:00:00Z" },
    "friends": [],
    "interests": ["cycling", "books"],
    "location": { "city": "Воронеж", "country": "Россия" },
    "status": "Буду offline до понедельника"
  },
  {
    "_id": { "$oid": "664600000000000000000006" },
    "username": "fiona",
    "email": "fiona@social.local",
    "full_name": "Фиона Морозова",
    "date_of_birth": { "$date": "1997-07-07T00:00:00Z" },
    "gender": "female",
    "registration_date": { "$date": "2024-04-05T14:00:00Z" },
    "friends": [{ "$oid": "664600000000000000000001" }],
    "interests": ["cinema", "languages"],
    "location": { "city": "Самара", "country": "Россия" },
    "status": "Учу испанский 💃"
  },
  {
    "_id": { "$oid": "664600000000000000000007" },
    "username": "ivanov",
    "email": "ivanov@social.local",
    "full_name": "Иван Иванов",
    "date_of_birth": { "$date": "1994-04-01T00:00:00Z" },
    "gender": "male",
    "registration_date": { "$date": "2024-02-15T18:45:00Z" },
    "friends": [{ "$oid": "664600000000000000000006" }],
    "interests": ["travel", "history"],
    "location": { "city": "Екатеринбург", "country": "Россия" },
    "status": "Читаю Толстого 📚"
  }
]

posts 
[
  {
    "_id": { "$oid": "664700000000000000000010" },
    "user_id": { "$oid": "664600000000000000000001" },
    "content": "Моё утро началось с пробежки в парке!",
    "media_urls": ["https://cdn.social.local/pics/run1.jpg"],
    "created_at": { "$date": "2025-04-20T06:15:00Z" },
    "likes": [
      { "$oid": "664600000000000000000002" },
      { "$oid": "664600000000000000000003" }
    ],
    "comments": [
      {
        "comment_id": { "$oid": "664700000000000000000101" },
        "user_id": { "$oid": "664600000000000000000002" },
        "content": "Круто! Сколько км пробежала?",
        "created_at": { "$date": "2025-04-20T06:20:00Z" },
        "likes": []
      }
    ]
  },
  {
    "_id": { "$oid": "664700000000000000000011" },
    "user_id": { "$oid": "664600000000000000000002" },
    "content": "Новый кавер на любимую песню уже на канале!",
    "media_urls": [],
    "created_at": { "$date": "2025-04-20T18:45:00Z" },
    "likes": [{ "$oid": "664600000000000000000001" }],
    "comments": []
  },
  {
    "_id": { "$oid": "664700000000000000000012" },
    "user_id": { "$oid": "664600000000000000000003" },
    "content": "Собрала 10 лайф‑хаков для бюджетных путешествий ✈️",
    "media_urls": ["https://cdn.social.local/pics/travel.jpg"],
    "created_at": { "$date": "2025-04-21T09:10:00Z" },
    "likes": [
      { "$oid": "664600000000000000000001" },
      { "$oid": "664600000000000000000002" }
    ],
    "comments": [
      {
        "comment_id": { "$oid": "664700000000000000000102" },
        "user_id": { "$oid": "664600000000000000000001" },
        "content": "Очень полезно, спасибо!",
        "created_at": { "$date": "2025-04-21T09:30:00Z" },
        "likes": [{ "$oid": "664600000000000000000003" }]
      }
    ]
  },
  {
    "_id": { "$oid": "664700000000000000000013" },
    "user_id": { "$oid": "664600000000000000000004" },
    "content": "Сегодня был потрясающий день — готовила лазанью и пела в душе 🎶",
    "media_urls": [],
    "created_at": { "$date": "2025-04-21T11:00:00Z" },
    "likes": [],
    "comments": []
  },
  {
    "_id": { "$oid": "664700000000000000000014" },
    "user_id": { "$oid": "664600000000000000000005" },
    "content": "Читаю книгу по философии. Думаю, каждый должен раз в жизни её открыть.",
    "media_urls": [],
    "created_at": { "$date": "2025-04-21T21:15:00Z" },
    "likes": [{ "$oid": "664600000000000000000004" }],
    "comments": []
  },
  {
    "_id": { "$oid": "664700000000000000000015" },
    "user_id": { "$oid": "664600000000000000000006" },
    "content": "Кто хочет на вечер кино? Я устрою мини-кинотеатр 🎬",
    "media_urls": [],
    "created_at": { "$date": "2025-04-21T19:45:00Z" },
    "likes": [
      { "$oid": "664600000000000000000001" },
      { "$oid": "664600000000000000000007" },
      { "$oid": "664600000000000000000004" }
    ],
    "comments": [
      {
        "comment_id": { "$oid": "664700000000000000000103" },
        "user_id": { "$oid": "664600000000000000000001" },
        "content": "Я с попкорном! 🍿",
        "created_at": { "$date": "2025-04-21T20:00:00Z" },
        "likes": []
      },
      {
        "comment_id": { "$oid": "664700000000000000000104" },
        "user_id": { "$oid": "664600000000000000000007" },
        "content": "Фильм будет на испанском? 😄",
        "created_at": { "$date": "2025-04-21T20:05:00Z" },
        "likes": [{ "$oid": "664600000000000000000006" }]
      }
    ]
  },
  {
    "_id": { "$oid": "664700000000000000000016" },
    "user_id": { "$oid": "664600000000000000000007" },
    "content": "Поделитесь идеями: куда поехать в мае на пару дней?",
    "media_urls": [],
    "created_at": { "$date": "2025-04-22T08:30:00Z" },
    "likes": [],
    "comments": [
      {
        "comment_id": { "$oid": "664700000000000000000105" },
        "user_id": { "$oid": "664600000000000000000003" },
        "content": "Анапа? Тихо и море рядом",
        "created_at": { "$date": "2025-04-22T08:45:00Z" },
        "likes": []
      }
    ]
  },
  {
    "_id": { "$oid": "664700000000000000000017" },
    "user_id": { "$oid": "664600000000000000000003" },
    "content": "Поделилась гидами по Тбилиси. Кто был — что скажете?",
    "media_urls": [],
    "created_at": { "$date": "2025-04-22T10:10:00Z" },
    "likes": [
      { "$oid": "664600000000000000000002" },
      { "$oid": "664600000000000000000004" },
      { "$oid": "664600000000000000000005" },
      { "$oid": "664600000000000000000006" }
    ],
    "comments": []
  }
]

