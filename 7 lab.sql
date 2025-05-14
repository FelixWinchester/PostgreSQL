DROP TABLE IF EXISTS clients CASCADE;
DROP TABLE IF EXISTS trainers CASCADE;
DROP TABLE IF EXISTS rooms CASCADE;
DROP TABLE IF EXISTS equipment CASCADE;
DROP TABLE IF EXISTS visits_history CASCADE;
DROP TABLE IF EXISTS reviews CASCADE;
DROP TABLE IF EXISTS discounts CASCADE;
DROP TABLE IF EXISTS payments CASCADE;
DROP TABLE IF EXISTS schedule CASCADE;
DROP TABLE IF EXISTS trainer_room CASCADE;
DROP TABLE IF EXISTS equipment_room CASCADE;

DROP TYPE IF EXISTS equipment_transfer CASCADE;
DROP FUNCTION get_trainer_stats(integer);


-- Создание таблиц

-- Таблица clients (Клиенты)
CREATE TABLE clients (
    id_client BIGSERIAL PRIMARY KEY,
    full_name TEXT NOT NULL,
    birth_date DATE NOT NULL,
    gender TEXT NOT NULL,
    phone TEXT NOT NULL
);

-- Таблица trainers (Тренеры)
CREATE TABLE trainers (
    id_trainer BIGSERIAL PRIMARY KEY,
    full_name TEXT NOT NULL,
    phone_number VARCHAR(20) NOT NULL,
    sport_type TEXT NOT NULL
);

-- Таблица rooms (Залы)
CREATE TABLE rooms (
    id_room BIGSERIAL PRIMARY KEY,
    capacity INTEGER NOT NULL,
    location TEXT NOT NULL
);

-- Таблица equipment (Оборудование)
CREATE TABLE equipment (
    id_equipment BIGSERIAL PRIMARY KEY,
    description TEXT NOT NULL,
    quantity INTEGER NOT NULL
);

-- Таблица visits_history (История посещений)
CREATE TABLE visits_history (
    id_visit BIGSERIAL PRIMARY KEY,
    id_client BIGINT NOT NULL,
    id_room BIGINT NOT NULL,
    visit_date DATE NOT NULL,
    start_time TIME NOT NULL,
    end_time TIME NOT NULL
);

-- Таблица reviews (Отзывы)
CREATE TABLE reviews (
    id_review BIGSERIAL PRIMARY KEY,
    id_client BIGINT NOT NULL,
    id_trainer BIGINT NOT NULL,
    rating FLOAT NOT NULL,
    comment TEXT NOT NULL,
    review_date DATE NOT NULL
);

-- Таблица discounts (Скидки)
CREATE TABLE discounts (
    id_discount BIGSERIAL PRIMARY KEY,
    id_client BIGINT NOT NULL,
    discount_amount FLOAT NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL
);

-- Таблица payments (Оплата)
CREATE TABLE payments (
    id_payment BIGSERIAL PRIMARY KEY,
    id_client BIGINT NOT NULL,
    amount FLOAT NOT NULL,
    payment_method TEXT NOT NULL,
    payment_date DATE NOT NULL
);

-- Таблица schedule (Расписание)
CREATE TABLE schedule (
    id_schedule BIGSERIAL PRIMARY KEY,
    id_client BIGINT NOT NULL,
    id_trainer BIGINT NOT NULL,
    start_time TIME NOT NULL,
    end_time TIME NOT NULL
);

-- Таблица trainer_room (Тренер - зал)
CREATE TABLE trainer_room (
    id_record BIGSERIAL PRIMARY KEY,
    id_room BIGINT NOT NULL,
    id_trainer BIGINT NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL
);

-- Таблица equipment_room (Оборудование - зал)
CREATE TABLE equipment_room (
    id_usage BIGSERIAL PRIMARY KEY,
    id_equipment BIGINT NOT NULL,
    id_room BIGINT NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL
);

-- Заполнение таблиц данными

-- Клиенты
INSERT INTO clients (full_name, birth_date, gender, phone)
SELECT
  'client' || gs AS full_name,
  DATE '1950-01-01' + (random() * (DATE '2008-12-31' - DATE '1950-01-01'))::int AS birth_date,
  CASE WHEN random() < 0.5 THEN 'Male' ELSE 'Female' END AS gender,
  '+7' || lpad((trunc(random() * 1000000000))::text, 10, '0') AS phone
FROM generate_series(1, 10000) AS gs;

-- Тренеры
INSERT INTO trainers (full_name, phone_number, sport_type)
SELECT
  'trainer' || gs AS full_name,
  '+7' || lpad((trunc(random() * 1000000000))::text, 10, '0') AS phone_number,
  (ARRAY['Football', 'Basketball', 'Tennis', 'Boxing', 'Swimming', 'Yoga', 'Running', 'Cycling', 'Strength Training', 'Pilates'])[ceil(random() * 10)] AS sport_type
FROM generate_series(1, 200) AS gs;

-- Залы
INSERT INTO rooms (capacity, location)
SELECT
  trunc(random() * 30 + 10),
  'Room ' || gs
FROM generate_series(1, 30) AS gs;

-- Оборудование
INSERT INTO equipment (description, quantity)
VALUES 
('Беговая дорожка', 5),
('Гантели', 20),
('Штанга', 10),
('Эспандер', 15),
('Гриф', 8),
('Гиря', 12),
('Степ-платформа', 6),
('Мяч для фитнеса', 25),
('Коврик для йоги', 30),
('Тренажер для пресса', 4),
('Велотренажер', 3),
('Резиновые петли', 20),
('Турник', 5),
('Боксерская груша', 7),
('Скамья для жима', 6);

-- История посещений
INSERT INTO visits_history (id_client, id_room, visit_date, start_time, end_time)
SELECT 
  ceil(random() * 10000)::int,
  ceil(random() * 30)::int,
  DATE '2023-01-01' + (random() * 365)::int,
  (TIME '08:00:00' + (random() * 12 * 60 * 60) * INTERVAL '1 second')::time,
  (TIME '08:00:00' + (random() * 12 * 60 * 60 + 3600) * INTERVAL '1 second')::time
FROM generate_series(1, 1000);

-- Отзывы 
INSERT INTO reviews (id_client, id_trainer, rating, comment, review_date)
SELECT 
  ceil(random() * 10000)::int,
  ceil(random() * 200)::int,
  (random() * 5)::numeric(2,1),
  CASE 
    WHEN random() < 0.2 THEN 'Отличный тренер!'
    WHEN random() < 0.4 THEN 'Очень профессионально'
    WHEN random() < 0.6 THEN 'Хорошие тренировки'
    WHEN random() < 0.8 THEN 'Могло быть лучше'
    ELSE 'Не понравилось'
  END,
  DATE '2023-01-01' + (random() * 365)::int
FROM generate_series(1, 500);

-- Скидки
INSERT INTO discounts (id_client, discount_amount, start_date, end_date)
SELECT 
  ceil(random() * 10000)::int,
  (random() * 0.3)::numeric(3,2),
  DATE '2023-01-01' + (random() * 300)::int,
  DATE '2023-01-01' + (random() * 300 + 30)::int
FROM generate_series(1, 200);

-- Платежи
INSERT INTO payments (id_client, amount, payment_method, payment_date)
SELECT 
  ceil(random() * 10000)::int,
  (random() * 2000 + 500)::numeric(10,2),
  CASE WHEN random() < 0.5 THEN 'Карта' ELSE 'Наличные' END,
  DATE '2023-01-01' + (random() * 365)::int
FROM generate_series(1, 1000);

-- Расписание
INSERT INTO schedule (id_client, id_trainer, start_time, end_time)
SELECT 
  ceil(random() * 10000)::int,
  ceil(random() * 200)::int,
  (TIME '08:00:00' + (random() * 12 * 60 * 60) * INTERVAL '1 second')::time,
  (TIME '08:00:00' + (random() * 12 * 60 * 60 + 3600) * INTERVAL '1 second')::time
FROM generate_series(1, 500);

-- Тренер-зал
INSERT INTO trainer_room (id_room, id_trainer, start_date, end_date)
SELECT 
  ceil(random() * 30)::int,
  ceil(random() * 200)::int,
  DATE '2023-01-01' + (random() * 200)::int,
  DATE '2023-01-01' + (random() * 200 + 30)::int
FROM generate_series(1, 300);

-- Оборудование-зал
INSERT INTO equipment_room (id_equipment, id_room, start_date, end_date)
SELECT 
  ceil(random() * 15)::int,
  ceil(random() * 30)::int,
  DATE '2023-01-01' + (random() * 200)::int,
  DATE '2023-01-01' + (random() * 200 + 30)::int
FROM generate_series(1, 200);

-----------------------
-- Процедуры и функции
-----------------------

-- Функция: Расчет общей выручки за период (возвращает базовый тип)
CREATE OR REPLACE FUNCTION calculate_total_revenue(
    start_date DATE DEFAULT '2023-01-01',
    end_date DATE DEFAULT '2023-12-31'
)
RETURNS DECIMAL(10,2) AS $$
DECLARE
    total DECIMAL(10,2);
BEGIN
    SELECT COALESCE(SUM(amount), 0) INTO total
    FROM payments
    WHERE payment_date BETWEEN start_date AND end_date;
    
    RETURN total;
END;
$$ LANGUAGE plpgsql;

-- Функция: Поиск клиентов по критериям (возвращает SETOF)
CREATE OR REPLACE FUNCTION find_clients_by_criteria(
    min_age INT DEFAULT 18,
    max_age INT DEFAULT 60,
    gender_filter TEXT DEFAULT NULL
)
RETURNS SETOF clients AS $$
BEGIN
    RETURN QUERY
    SELECT *
    FROM clients
    WHERE 
        EXTRACT(YEAR FROM AGE(birth_date)) BETWEEN min_age AND max_age
        AND (gender_filter IS NULL OR gender = gender_filter)
    ORDER BY full_name;
    
    IF NOT FOUND THEN
        RAISE NOTICE 'No clients found with the specified criteria';
    END IF;
END;
$$ LANGUAGE plpgsql;


-- Функция: Статистика по тренеру (возвращает TABLE)
CREATE OR REPLACE FUNCTION get_trainer_stats(
    trainer_id INT
)
RETURNS TABLE(
    total_clients BIGINT,  -- Возвращаем BIGINT
    avg_rating NUMERIC(3,1),
    total_sessions BIGINT, -- Возвращаем BIGINT
    most_popular_sport TEXT
) AS $$
BEGIN
    RETURN QUERY
    WITH trainer_data AS (
        SELECT 
            COUNT(DISTINCT s.id_client) AS clients,
            AVG(r.rating) AS rating,
            COUNT(s.id_schedule) AS sessions,
            t.sport_type
        FROM trainers t
        LEFT JOIN schedule s ON t.id_trainer = s.id_trainer
        LEFT JOIN reviews r ON t.id_trainer = r.id_trainer
        WHERE t.id_trainer = trainer_id
        GROUP BY t.sport_type
    )
    SELECT 
        SUM(clients)::BIGINT,
        AVG(rating)::NUMERIC(3,1),
        SUM(sessions)::BIGINT,
        sport_type
    FROM trainer_data
    GROUP BY sport_type;
    
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Trainer with ID % not found', trainer_id;
    END IF;
END;
$$ LANGUAGE plpgsql;

-- Процедура: Обновление цен с учетом инфляции (с транзакцией)
CREATE OR REPLACE PROCEDURE update_prices_with_inflation(
    inflation_rate NUMERIC(5,2) DEFAULT 5.0,
    max_increase NUMERIC(5,2) DEFAULT 20.0
)
AS $$
DECLARE
    affected_rows INT;
BEGIN
    -- Удаляем явное управление транзакциями (BEGIN/COMMIT/ROLLBACK)
    -- В процедурах PL/pgSQL транзакции управляются автоматически
    
    UPDATE payments
    SET amount = amount * (1 + LEAST(inflation_rate/100, max_increase/100))
    WHERE payment_date > CURRENT_DATE;
    
    GET DIAGNOSTICS affected_rows = ROW_COUNT;
    
    RAISE NOTICE 'Updated % payments: inflation = %, max increase = %', 
        affected_rows, inflation_rate, max_increase;
EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Error updating prices: %', SQLERRM;
END;
$$ LANGUAGE plpgsql;


--Процедура: Перенос оборудования между залами (составной тип)

CREATE TYPE equipment_transfer AS (
    equipment_id INT,
    from_room_id INT,
    to_room_id INT,
    transfer_date DATE
);

CREATE OR REPLACE PROCEDURE transfer_equipment_between_rooms(
    transfer equipment_transfer
)
AS $$
DECLARE
    eq_exists BOOLEAN;
    room_exists BOOLEAN;
BEGIN
    -- Проверка существования оборудования
    SELECT EXISTS(SELECT 1 FROM equipment WHERE id_equipment = transfer.equipment_id) INTO eq_exists;
    IF NOT eq_exists THEN
        RAISE EXCEPTION 'Equipment with ID % does not exist', transfer.equipment_id;
    END IF;
    
    -- Проверка существования залов
    SELECT EXISTS(SELECT 1 FROM rooms WHERE id_room = transfer.from_room_id) INTO room_exists;
    IF NOT room_exists THEN
        RAISE EXCEPTION 'Source room with ID % does not exist', transfer.from_room_id;
    END IF;
    
    SELECT EXISTS(SELECT 1 FROM rooms WHERE id_room = transfer.to_room_id) INTO room_exists;
    IF NOT room_exists THEN
        RAISE EXCEPTION 'Destination room with ID % does not exist', transfer.to_room_id;
    END IF;
    
    -- Обновление текущей записи (завершение использования в старом зале)
    UPDATE equipment_room
    SET end_date = transfer.transfer_date - INTERVAL '1 day'
    WHERE id_equipment = transfer.equipment_id 
    AND id_room = transfer.from_room_id
    AND end_date > transfer.transfer_date;
    
    -- Добавление новой записи (начало использования в новом зале)
    INSERT INTO equipment_room (id_equipment, id_room, start_date, end_date)
    VALUES (transfer.equipment_id, transfer.to_room_id, transfer.transfer_date, '9999-12-31');
    
    RAISE NOTICE 'Equipment % successfully transferred from room % to room % on %',
        transfer.equipment_id, transfer.from_room_id, transfer.to_room_id, transfer.transfer_date;
END;
$$ LANGUAGE plpgsql;

-- Пример вызова:
DO $$
BEGIN
    CALL transfer_equipment_between_rooms((1, 5, 10, '2023-11-01'));
END;
$$;

-- проверка работы

-- 1. Вызов функции расчета выручки
SELECT calculate_total_revenue('2023-10-01', '2023-10-15') AS half_october_revenue;

-- 2. Вызов функции поиска клиентов
SELECT id_client, full_name, birth_date FROM find_clients_by_criteria(25, 35, 'Male') LIMIT 10;

-- 3. Вызов функции статистики тренера
SELECT * FROM get_trainer_stats(10);

-- 4. Вызов процедуры обновления цен
-- Добавляем тестовые платежи с будущими датами
INSERT INTO payments (id_client, amount, payment_method, payment_date)
SELECT 
    ceil(random() * 10000)::int,
    (random() * 2000 + 500)::numeric(10,2),
    CASE WHEN random() < 0.5 THEN 'Карта' ELSE 'Наличные' END,
    CURRENT_DATE + (random() * 30)::int  -- Дата в ближайшие 30 дней
FROM generate_series(1, 20);  -- Добавляем 20 будущих платежей

CALL update_prices_with_inflation(7.5, 15.0);

-- Проверка
SELECT id_payment, amount, payment_date FROM payments WHERE payment_date > CURRENT_DATE;

-- 5. Вызов процедуры переноса оборудования
DO $$
DECLARE
    my_transfer equipment_transfer := (1, 5, 10, '2023-11-01');
BEGIN
    CALL transfer_equipment_between_rooms(my_transfer);
END;
$$;

-- Проверка
SELECT * FROM equipment_room WHERE id_equipment = 1 ORDER BY start_date;


