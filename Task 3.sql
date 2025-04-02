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

-- LATERAL: Получить клиентов и их последний платеж
SELECT c.full_name, p.latest_payment
FROM clients c
LEFT JOIN LATERAL (
    SELECT amount AS latest_payment
    FROM payments p
    WHERE p.id_client = c.id_client
    ORDER BY payment_date DESC
    LIMIT 1
) p ON true;

-- САМОСОЕДИНЕНИЕ: Найти пары тренеров, которые работают в одном зале
SELECT t1.full_name AS trainer1, t2.full_name AS trainer2
FROM trainers t1
JOIN trainers t2 ON t1.id_trainer <> t2.id_trainer
JOIN trainer_room tr1 ON t1.id_trainer = tr1.id_trainer
JOIN trainer_room tr2 ON t2.id_trainer = tr2.id_trainer
WHERE tr1.id_room = tr2.id_room;


-- 2. Реализация операций над множествами

-- UNION: Получить всех клиентов и тренеров
SELECT full_name FROM clients
UNION
SELECT full_name FROM trainers;

-- UNION ALL: Получить всех клиентов и тренеров (с дубликатами)
SELECT full_name FROM clients
UNION ALL
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


-- 3. Фильтрация данных в запросах с использованием предикатов

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

-- Регулярные выражения POSIX ILIKE: Клиенты, чьи телефоны начинаются с "+7987"
SELECT full_name
FROM clients
WHERE phone ~* '^\+7987';

-- SIMILAR TO: Клиенты, чье имя соответствует шаблону "Иван" или "Анна"
SELECT full_name
FROM clients
WHERE full_name SIMILAR TO '(Иван|Анна)%';

-- ALL: Клиенты, чьи платежи больше всех платежей клиента с ID 1
SELECT full_name
FROM clients c
WHERE (SELECT amount FROM payments WHERE id_client = c.id_client)
> ALL (SELECT amount FROM payments WHERE id_client = 1);

-- SOME/ANY: Клиенты, у которых хотя бы один платеж больше 600
SELECT full_name
FROM clients c
WHERE EXISTS (
    SELECT 1 FROM payments p
    WHERE p.id_client = c.id_client AND p.amount > SOME (SELECT amount FROM payments WHERE amount > 600)
);


-- 4. Использование встроенных функций

-- CAST: Преобразовать возраст клиента в текст
SELECT full_name, CAST(EXTRACT(YEAR FROM AGE(birth_date)) AS TEXT) AS age_text
FROM clients;

-- COALESCE: Заменить NULL в комментариях отзывов на "Нет комментария"
SELECT id_review, COALESCE(comment, 'Нет комментария') AS comment
FROM reviews;

-- GREATEST: Найти максимальную сумму платежа для каждого клиента
SELECT id_client, GREATEST(amount, 500) AS max_amount
FROM payments;

-- LEAST: Найти минимальную сумму платежа для каждого клиента
SELECT id_client, LEAST(amount, 500) AS min_amount
FROM payments;

-- NULLIF: Заменить количество оборудования на NULL, если оно равно 0
SELECT description, NULLIF(quantity, 0) AS quantity
FROM equipment;

-- CHR(n): Вывести символ по ASCII-коду
SELECT CHR(65) AS symbol; -- Выведет 'A'

-- ASCII: Получить ASCII-код первого символа имени клиента
SELECT full_name, ASCII(full_name) AS ascii_code
FROM clients;


-- 5. Запросы с использованием функций для работы со строками

-- LENGTH: Длина имени клиента
SELECT full_name, LENGTH(full_name) AS name_length
FROM clients;

-- UPPER: Вывести имена клиентов в верхнем регистре
SELECT UPPER(full_name) AS upper_name
FROM clients;

-- LOWER
SELECT LOWER(full_name) AS lower_name
FROM clients;

-- SUBSTRING: Вывести первые 5 символов имени клиента
SELECT full_name, SUBSTRING(full_name FROM 1 FOR 5) AS short_name
FROM clients;

-- STRPOS: Найти позицию символа 'а' в имени клиента
SELECT full_name, STRPOS(full_name, 'а') AS position
FROM clients;

-- OVERLAY: Заменить часть строки
SELECT full_name, OVERLAY(full_name PLACING 'XXX' FROM 1 FOR 3) AS modified_name
FROM clients;

-- POSITION: Найти позицию подстроки "Иван" в имени клиента
SELECT full_name, POSITION('Иван' IN full_name) AS position
FROM clients;

-- REPLACE: Заменить "Иван" на "Петр" в имени клиента
SELECT full_name, REPLACE(full_name, 'Иван', 'Петр') AS replaced_name
FROM clients;

-- BTRIM/LTRIM: Удалить пробелы в начале и конце строки
SELECT BTRIM('  Привет  ') AS trimmed_string;
SELECT LTRIM('  Привет  ') AS left_trimmed_string;


-- 6. Запросы с использованием функций даты и времени

-- NOW(): Текущая дата и время
SELECT NOW();

-- CURRENT_DATE: Текущая дата
SELECT CURRENT_DATE;

-- CURRENT_TIME: Текущее время
SELECT CURRENT_TIME;

-- CURRENT_TIMESTAMP: Текущая дата и время
SELECT CURRENT_TIMESTAMP;

-- LOCALTIMESTAMP: Локальная дата и время без часового пояса
SELECT LOCALTIMESTAMP;

-- AGE(): Возраст клиентов
SELECT full_name, AGE(birth_date) AS age
FROM clients;

-- DATE_PART(): Извлечь месяц из даты рождения
SELECT full_name, DATE_PART('month', birth_date) AS birth_month
FROM clients;

-- EXTRACT(): Извлечь год из даты рождения
SELECT full_name, EXTRACT(YEAR FROM birth_date) AS birth_year
FROM clients;


-- 7. Запросы с использованием агрегатных функций

-- COUNT: Количество клиентов
SELECT COUNT(*) AS total_clients
FROM clients;

-- SUM: Общая сумма платежей
SELECT SUM(amount) AS total_payments
FROM payments;

-- MIN: Минимальная сумма платежа
SELECT MIN(amount) AS min_payment
FROM payments;

-- MAX: Максимальная сумма платежа
SELECT MAX(amount) AS max_payment
FROM payments;

-- AVG: Средняя сумма платежа
SELECT AVG(amount) AS avg_payment
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
