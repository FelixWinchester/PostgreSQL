-- 1. Запросы с использованием различных видов соединений таблиц

-- INNER JOIN: Получить клиентов и их посещения залов
SELECT c.full_name, v.visit_date
FROM clients c
INNER JOIN visits_history v ON c.id_client = v.id_client;

-- LEFT JOIN: Получить всех клиентов и их отзывы (если есть)
SELECT c.full_name, r.rating
FROM clients c
LEFT JOIN reviews r ON c.id_client = r.id_client;

-- RIGHT JOIN: Получить тренеров и их расписание (если есть)
SELECT t.full_name, s.start_time
FROM schedule s
RIGHT JOIN trainers t ON s.id_trainer = t.id_trainer;

-- FULL JOIN: Получить всех клиентов и их оплаты (если есть)
SELECT c.full_name, p.amount
FROM clients c
FULL JOIN payments p ON c.id_client = p.id_client;

-- CROSS JOIN: Получить все комбинации клиентов и залов
SELECT c.full_name, r.location
FROM clients c
CROSS JOIN rooms r;


-- 2. Реализация операций над множествами

-- UNION: Получить всех клиентов и тренеров
SELECT full_name FROM clients
UNION
SELECT full_name FROM trainers;

-- EXCEPT: Клиенты, которые не оставили отзыв
SELECT full_name FROM clients
EXCEPT
SELECT c.full_name FROM clients c
JOIN reviews r ON c.id_client = r.id_client;

-- INTERSECT: Клиенты, которые оставили отзыв и сделали оплату
SELECT full_name FROM clients
WHERE id_client IN (SELECT id_client FROM reviews)
INTERSECT
SELECT full_name FROM clients
WHERE id_client IN (SELECT id_client FROM payments);


-- 3. Фильтрация данных с использованием предикатов

-- EXISTS: Клиенты, у которых есть хотя бы одно посещение
SELECT full_name
FROM clients c
WHERE EXISTS (
    SELECT 1 FROM visits_history v WHERE v.id_client = c.id_client
);

-- IN: Клиенты, которые посетили зал с ID 1
SELECT full_name
FROM clients
WHERE id_client IN (
    SELECT id_client FROM visits_history WHERE id_room = 1
);

-- BETWEEN: Платежи, сделанные между 1 октября и 15 октября 2023 года
SELECT *
FROM payments
WHERE payment_date BETWEEN '2023-10-01' AND '2023-10-15';

-- LIKE: Клиенты, чье имя начинается на "Иван"
SELECT full_name
FROM clients
WHERE full_name ILIKE 'Иван%';

-- Клиенты, чьи телефоны начинаются с "+7987"
SELECT full_name
FROM clients
WHERE phone ~ '^\+7987';


-- 4. Запросы с использованием выражения CASE

-- Определить категорию возраста клиентов
SELECT full_name,
       CASE
           WHEN EXTRACT(YEAR FROM AGE(birth_date)) < 18 THEN 'Младше 18'
           WHEN EXTRACT(YEAR FROM AGE(birth_date)) BETWEEN 18 AND 60 THEN 'Взрослый'
           ELSE 'Пожилой'
       END AS age_category
FROM clients;


-- 5. Использование встроенных функций

-- CAST: Преобразовать возраст клиента в текст
SELECT full_name, CAST(EXTRACT(YEAR FROM AGE(birth_date)) AS TEXT) AS age_text
FROM clients;

-- COALESCE: Заменить NULL в комментариях отзывов на "Нет комментария"
SELECT id_review, COALESCE(comment, 'Нет комментария') AS comment
FROM reviews;

-- GREATEST: Найти максимальную сумму платежа для каждого клиента
SELECT id_client, GREATEST(amount, 500) AS max_amount
FROM payments;


-- 6. Запросы с использованием функций для работы со строками

-- LENGTH: Длина имени клиента
SELECT full_name, LENGTH(full_name) AS name_length
FROM clients;

-- UPPER: Вывести имена клиентов в верхнем регистре
SELECT UPPER(full_name) AS upper_name
FROM clients;

-- SUBSTRING: Вывести первые 5 символов имени клиента
SELECT full_name, SUBSTRING(full_name FROM 1 FOR 5) AS short_name
FROM clients;


-- 7. Запросы с использованием функций даты и времени

-- NOW(): Текущая дата и время
SELECT NOW();

-- AGE(): Возраст клиентов
SELECT full_name, AGE(birth_date) AS age
FROM clients;

-- EXTRACT(): Извлечь год из даты рождения
SELECT full_name, EXTRACT(YEAR FROM birth_date) AS birth_year
FROM clients;


-- 8. Запросы с использованием агр. функций

-- COUNT: Количество клиентов
SELECT COUNT(*) AS total_clients
FROM clients;

-- SUM: Общая сумма платежей
SELECT SUM(amount) AS total_payments
FROM payments;

-- GROUP BY: Сумма платежей по каждому клиенту
SELECT id_client, SUM(amount) AS total_amount
FROM payments
GROUP BY id_client;

-- HAVING: Клиенты, у которых общая сумма платежей больше 500
SELECT id_client, SUM(amount) AS total_amount
FROM payments
GROUP BY id_client
HAVING SUM(amount) > 500;
