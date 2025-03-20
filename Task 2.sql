-- Создание таблицы для истории посещений
CREATE TABLE visit_history (
    id SERIAL PRIMARY KEY,
    visitor_name VARCHAR(255),
    location VARCHAR(255),
    start_date DATE,
    start_form VARCHAR(255)
);

-- Создание таблицы для списка оборудования
CREATE TABLE equipment_list (
    id SERIAL PRIMARY KEY,
    equipment_name VARCHAR(255),
    board VARCHAR(255)
);

-- Создание таблицы для залов
CREATE TABLE halls (
    id SERIAL PRIMARY KEY,
    hall_name VARCHAR(255),
    board VARCHAR(255)
);

-- Создание таблицы для отзывов
CREATE TABLE reviews (
    id SERIAL PRIMARY KEY,
    reviewer_name VARCHAR(255),
    rating INT,
    comment TEXT,
    dpp VARCHAR(255)
);

-- Создание таблицы для клиентов
CREATE TABLE clients (
    id SERIAL PRIMARY KEY,
    full_name VARCHAR(255),
    birth_date DATE,
    type VARCHAR(255),
    board VARCHAR(255)
);

-- Создание таблицы для складок
CREATE TABLE folds (
    id SERIAL PRIMARY KEY,
    fold_name VARCHAR(255),
    rector VARCHAR(255),
    exit_date DATE
);

-- Создание таблицы для оплаты
CREATE TABLE payments (
    id SERIAL PRIMARY KEY,
    payer_name VARCHAR(255),
    payment_list VARCHAR(255),
    amount DECIMAL(10, 2)
);

-- Создание таблицы для связи тренера и зала
CREATE TABLE trainer_hall (
    id SERIAL PRIMARY KEY,
    trainer_name VARCHAR(255),
    hall_name VARCHAR(255),
    start_date DATE
);

-- Создание таблицы для связи оборудования и зала
CREATE TABLE equipment_hall (
    id SERIAL PRIMARY KEY,
    equipment_name VARCHAR(255),
    hall_name VARCHAR(255),
    start_date DATE
);

-- Создание таблицы для расписания
CREATE TABLE schedule (
    id SERIAL PRIMARY KEY,
    event_name VARCHAR(255),
    hall_name VARCHAR(255),
    start_date DATE,
    start_form VARCHAR(255)
);


--------------------------------------

-- Добавление записи в таблицу visit_history
INSERT INTO visit_history (visitor_name, location, start_date, start_form)
VALUES ('Р.М. Лосевич', 'м.Хомяков', '2025-03-17', 'бланк начала');

-- Добавление записи в таблицу equipment_list
INSERT INTO equipment_list (equipment_name, board)
VALUES ('Отечество', '1st');

-- Добавление записи в таблицу reviews
INSERT INTO reviews (reviewer_name, rating, comment, dpp)
VALUES ('М.Сухинов', 5, 'Отличный сервис', '4б/м');
