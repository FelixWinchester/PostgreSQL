-- 1 Автономный подзапрос --

-- Клиенты, которые делали больше среднего количества оплат
SELECT full_name
FROM clients
WHERE id_client IN (
    SELECT id_client
    FROM payments
    GROUP BY id_client
    HAVING COUNT(*) > (
        SELECT AVG(cnt)
        FROM (
            SELECT COUNT(*) AS cnt
            FROM payments
            GROUP BY id_client
        ) AS sub_avg
    )
);

-- 2 Коррелированный подзапрос --

-- Средний рейтинг по каждому тренеру, только для тренеров с более чем 5 отзывами
SELECT t.full_name,
       (SELECT AVG(rating)
        FROM reviews r
        WHERE r.id_trainer = t.id_trainer) AS avg_rating
FROM trainers t
WHERE (SELECT COUNT(*) FROM reviews r WHERE r.id_trainer = t.id_trainer) > 5;

-- 3 Временная таблица --

-- Временная таблица с количеством посещений по клиентам
CREATE TEMP TABLE temp_visits AS
SELECT id_client, COUNT(*) AS visit_count
FROM visits_history
GROUP BY id_client;

-- Используем временную таблицу
SELECT c.full_name, tv.visit_count
FROM clients c
JOIN temp_visits tv ON c.id_client = tv.id_client
ORDER BY tv.visit_count DESC
LIMIT 10;

-- 4 Запросы с использованием оконных функций --

-- Допустим, анализируем оценки тренеров
SELECT 
    id_trainer,
    id_review,
    rating,
    
    -- Нумерация
    ROW_NUMBER() OVER (PARTITION BY id_trainer ORDER BY review_date) AS row_num,
    RANK() OVER (PARTITION BY id_trainer ORDER BY rating DESC) AS rank,
    DENSE_RANK() OVER (PARTITION BY id_trainer ORDER BY rating DESC) AS dense_rank,
    CUME_DIST() OVER (PARTITION BY id_trainer ORDER BY rating DESC) AS cume_dist,
    NTILE(4) OVER (PARTITION BY id_trainer ORDER BY rating DESC) AS quartile,

    -- Соседние значения
    LAG(rating, 1) OVER (PARTITION BY id_trainer ORDER BY review_date) AS prev_rating,
    LEAD(rating, 1) OVER (PARTITION BY id_trainer ORDER BY review_date) AS next_rating,

    -- Первая/последняя/по порядку
    FIRST_VALUE(rating) OVER (PARTITION BY id_trainer ORDER BY review_date) AS first_rating,
    LAST_VALUE(rating) OVER (PARTITION BY id_trainer ORDER BY review_date
        ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS last_rating,
    NTH_VALUE(rating, 2) OVER (PARTITION BY id_trainer ORDER BY review_date) AS second_rating

FROM reviews;

-- 5 With (CTE) --

-- Клиенты, оплатившие более 10 раз
WITH payment_counts AS (
    SELECT id_client, COUNT(*) AS cnt
    FROM payments
    GROUP BY id_client
)
SELECT c.full_name, pc.cnt
FROM payment_counts pc
JOIN clients c ON c.id_client = pc.id_client
WHERE pc.cnt > 10;

-- 6 Слияние данных --

MERGE INTO discounts AS d
USING (
    SELECT id_client, 10.0 AS discount_amount, CURRENT_DATE AS start_date, CURRENT_DATE + INTERVAL '30 days' AS end_date
    FROM clients
    WHERE gender = 'Female'
    LIMIT 1
) AS new_discount
ON d.id_client = new_discount.id_client
WHEN MATCHED THEN
    UPDATE SET discount_amount = new_discount.discount_amount
WHEN NOT MATCHED THEN
    INSERT (id_client, discount_amount, start_date, end_date)
    VALUES (new_discount.id_client, new_discount.discount_amount, new_discount.start_date, new_discount.end_date);

-- Проверка --
SELECT d.*
FROM discounts d
JOIN clients c ON d.id_client = c.id_client
WHERE c.gender = 'Female';


-- 2 запрос --

MERGE INTO discounts AS d
USING (
    SELECT id_client, 15.0 AS discount_amount,
           CURRENT_DATE AS start_date,
           CURRENT_DATE + INTERVAL '30 days' AS end_date
    FROM clients
    WHERE full_name = 'Иванов Иван'
) AS new_data
ON d.id_client = new_data.id_client
WHEN MATCHED THEN
    UPDATE SET discount_amount = new_data.discount_amount,
               start_date = new_data.start_date,
               end_date = new_data.end_date
WHEN NOT MATCHED THEN
    INSERT (id_client, discount_amount, start_date, end_date)
    VALUES (new_data.id_client, new_data.discount_amount, new_data.start_date, new_data.end_date);

-- Проверка --

SELECT d.*
FROM discounts d
JOIN clients c ON d.id_client = c.id_client
WHERE c.full_name = 'Иванов Иван';


-- 7 PIVOT CROSSTAB --

-- Не забудьте создать расширение:
CREATE EXTENSION IF NOT EXISTS tablefunc;

-- Сначала создаём view
CREATE VIEW payments_view AS
SELECT c.full_name, p.payment_method, SUM(p.amount) AS total
FROM payments p
JOIN clients c ON c.id_client = p.id_client
GROUP BY c.full_name, p.payment_method;

-- Затем CROSSTAB
SELECT * FROM crosstab(
    'SELECT full_name, payment_method, total FROM payments_view ORDER BY 1,2',
    'SELECT DISTINCT payment_method FROM payments_view ORDER BY 1'
) AS ct (
    full_name TEXT,
    "Cash" FLOAT,
    "Card" FLOAT,
    "Online" FLOAT
);

-- 8 UNNEST и CROSS JOIN LATERAL --

-- Преобразование массива в строки: список клиентов с их телефонами и символьно разбитым номером
SELECT full_name, part
FROM clients,
LATERAL unnest(string_to_array(phone, '')) AS part;

-- 9 Запрос с использованием GROUP BY с операторами ROLLUP, CUBE и GROUPING SETS в одном из вариантов нужно использовать функцию GROUPING. --

--ROLLUP + GROUPING()--

SELECT
    gender,
    birth_date,
    COUNT(*) AS client_count,
    GROUPING(gender) AS gender_grouping,
    GROUPING(birth_date) AS birthdate_grouping
FROM clients
GROUP BY ROLLUP (gender, birth_date);

--CUBE + GROUPING()--

SELECT
    gender,
    birth_date,
    COUNT(*) AS client_count,
    GROUPING(gender) AS gender_grouping,
    GROUPING(birth_date) AS birthdate_grouping
FROM clients
GROUP BY CUBE (gender, birth_date);

--GROUPING SETS + GROUPING()--

SELECT
    gender,
    birth_date,
    COUNT(*) AS client_count,
    GROUPING(gender) AS gender_grouping,
    GROUPING(birth_date) AS birthdate_grouping
FROM clients
GROUP BY GROUPING SETS (
    (gender, birth_date),
    (gender),
    (birth_date),
    ()
);

-- 10 LIMIT OFFSET --

-- Постраничный вывод отзывов (страница 3, по 10 записей)
SELECT *
FROM reviews
ORDER BY review_date DESC
LIMIT 10 OFFSET 20;

-- 11 Управление транзакциями, ошибки, стек вызова --

CREATE TABLE IF NOT EXISTS error_logs (
    id SERIAL PRIMARY KEY,
    error_message TEXT,
    pg_exception_context TEXT,
    pg_context TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

BEGIN;
SAVEPOINT before_error;

-- ОШИБКА --
INSERT INTO clients (full_name, birth_date, gender, phone)
VALUES (NULL, NULL, 'Unknown', NULL);

ROLLBACK TO SAVEPOINT before_error;

INSERT INTO clients (full_name, birth_date, gender, phone)
VALUES ('хочу питсы', '1990-01-01', 'Male', '+79991112233');

COMMIT;

CREATE OR REPLACE FUNCTION test_transaction_error()
RETURNS void AS $$
DECLARE
    stacked_context TEXT;
    current_context TEXT;
BEGIN
    BEGIN
        -- Ошибочная вставка
        INSERT INTO clients (full_name, birth_date, gender, phone)
        VALUES (NULL, NULL, 'Error', NULL);
    EXCEPTION
        WHEN OTHERS THEN
            GET STACKED DIAGNOSTICS stacked_context = PG_EXCEPTION_CONTEXT;
            GET DIAGNOSTICS current_context = PG_CONTEXT;

            -- Логируем в таблицу
            INSERT INTO error_logs (error_message, pg_exception_context, pg_context)
            VALUES (SQLERRM, stacked_context, current_context);

            RAISE NOTICE 'Ошибка: %', SQLERRM;
            RAISE NOTICE 'PG_EXCEPTION_CONTEXT: %', stacked_context;
            RAISE NOTICE 'PG_CONTEXT: %', current_context;
    END;
END;
$$ LANGUAGE plpgsql;

SELECT test_transaction_error();

SELECT * FROM error_logs ORDER BY created_at DESC LIMIT 1;
