INSERT INTO clients (full_name, birth_date, gender, phone)
SELECT
  'client' || gs AS full_name,
  DATE '1950-01-01' + (random() * (DATE '2008-12-31' - DATE '1950-01-01'))::int AS birth_date,
  CASE WHEN random() < 0.5 THEN 'Male' ELSE 'Female' END AS gender,
  '+7' || lpad((trunc(random() * 1000000000))::text, 10, '0') AS phone
FROM generate_series(1, 10000) AS gs;


INSERT INTO trainers (full_name, phone_number, sport_type)
SELECT
  'trainer' || gs AS full_name,
  '+7' || lpad((trunc(random() * 1000000000))::text, 10, '0') AS phone_number,
  (ARRAY['Football', 'Basketball', 'Tennis', 'Boxing', 'Swimming', 'Yoga', 'Running', 'Cycling', 'Strength Training', 'Pilates'])[ceil(random() * 10)] AS sport_type
FROM generate_series(1, 200) AS gs;

INSERT INTO rooms (capacity, location)
SELECT
  trunc(random() * 30 + 10),  -- Вместо случайной вместимости от 10 до 40
  'Room ' || gs  -- Простое имя зала
FROM generate_series(1, 30) AS gs;  -- Например, 30 залов

INSERT INTO equipment (description, quantity)
SELECT
  'equipment' || gs,
  trunc(random() * 20 + 1)  -- Количество от 1 до 20
FROM generate_series(1, 100) AS gs;  -- Например, 100 единиц оборудования

INSERT INTO visits_history (id_client, id_room, visit_date, start_time, end_time)
SELECT
  trunc(random() * 10000 + 1)::bigint AS id_client,  -- Ссылки на клиентов
  trunc(random() * 30 + 1)::bigint AS id_room,  -- Ссылки на залы
  DATE '2023-01-01' + (random() * 365)::int,  -- Случайная дата
  time '06:00' + ((trunc(random() * 12) * interval '1 hour') + (trunc(random() * 4) * interval '15 minutes')),
  time '06:00' + ((trunc(random() * 12) * interval '1 hour') + (trunc(random() * 4 + 4) * interval '15 minutes'))
FROM generate_series(1, 25000);  -- 25,000 посещений

INSERT INTO reviews (id_client, id_trainer, rating, comment, review_date)
SELECT
  trunc(random() * 10000 + 1)::bigint,  -- Ссылка на клиента
  trunc(random() * 200 + 1)::bigint,  -- Ссылка на тренера
  round((random() * 4 + 1)::numeric, 1),  -- Оценка от 1 до 5 с точностью до 1 знака
  'Review text ' || md5(gen_random_uuid()::text),  -- Комментарий (случайный текст)
  DATE '2023-01-01' + (random() * 365)::int  -- Случайная дата
FROM generate_series(1, 5000);  -- 5,000 отзывов


INSERT INTO discounts (id_client, discount_amount, start_date, end_date)
SELECT
  trunc(random() * 10000 + 1)::bigint,  -- Ссылка на клиента
  round((random() * 50 + 5)::numeric, 2),  -- Скидка от 5% до 50% с точностью до 2 знаков
  DATE '2023-01-01' + (random() * 180)::int,  -- Случайная дата начала
  DATE '2023-07-01' + (random() * 180)::int  -- Случайная дата окончания
FROM generate_series(1, 2000);  -- 2,000 скидок


INSERT INTO payments (id_client, amount, payment_method, payment_date)
SELECT
  trunc(random() * 10000 + 1)::bigint,  -- Ссылка на клиента
  round((random() * 2000 + 500)::numeric, 2),  -- Сумма оплаты от 500 до 2500 с точностью до 2 знаков
  (ARRAY['Cash', 'Card', 'Online'])[floor(random() * 3 + 1)],  -- Случайный способ оплаты
  DATE '2023-01-01' + (random() * 365)::int  -- Случайная дата
FROM generate_series(1, 15000);  -- 15,000 оплат


INSERT INTO schedule (id_client, id_trainer, start_time, end_time)
SELECT
  trunc(random() * 10000 + 1)::bigint,  -- Ссылка на клиента
  trunc(random() * 200 + 1)::bigint,  -- Ссылка на тренера
  time '08:00' + ((trunc(random() * 10) * interval '1 hour')),  -- Время начала
  time '09:00' + ((trunc(random() * 10) * interval '1 hour'))  -- Время окончания
FROM generate_series(1, 3000);  -- 3,000 записей в расписании

INSERT INTO trainer_room (id_room, id_trainer, start_date, end_date)
SELECT
  trunc(random() * 30 + 1)::bigint,  -- Ссылка на зал
  trunc(random() * 200 + 1)::bigint,  -- Ссылка на тренера
  DATE '2023-01-01' + (random() * 90)::int,  -- Случайная дата начала
  DATE '2023-07-01' + (random() * 180)::int  -- Случайная дата окончания
FROM generate_series(1, 800);  -- 800 записей



INSERT INTO equipment_room (id_equipment, id_room, start_date, end_date)
SELECT
  trunc(random() * 100 + 1)::bigint,  -- Ссылка на оборудование
  trunc(random() * 30 + 1)::bigint,  -- Ссылка на зал
  DATE '2023-01-01' + (random() * 90)::int,  -- Случайная дата начала
  DATE '2023-06-01' + (random() * 180)::int  -- Случайная дата окончания
FROM generate_series(1, 1000);  -- 1,000 записей
