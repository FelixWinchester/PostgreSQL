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

-- Таблица clients
INSERT INTO clients (full_name, birth_date, gender, phone)
VALUES 
('Иван Иванов', '1990-05-15', 'Мужской', '+79876543210'),
('Анна Петрова', '1985-08-20', 'Женский', '+79876543211'),
('Сергей Сидоров', '1992-12-10', 'Мужской', '+79876543212');

-- Таблица trainers
INSERT INTO trainers (full_name, phone_number, sport_type)
VALUES 
('Александр Кузнецов', '+79001234567', 'Фитнес'),
('Елена Медведева', '+79001234568', 'Йога'),
('Дмитрий Николаев', '+79001234569', 'Бокс');

-- Таблица rooms
INSERT INTO rooms (capacity, location)
VALUES 
(50, 'Первый этаж'),
(30, 'Второй этаж'),
(20, 'Подвал');

-- Таблица equipment
INSERT INTO equipment (description, quantity)
VALUES 
('Беговая дорожка', 5),
('Гантели', 20),
('Штанга', 10);

-- Таблица visits_history
INSERT INTO visits_history (id_client, id_room, visit_date, start_time, end_time)
VALUES 
(1, 1, '2023-10-01', '09:00:00', '10:00:00'),
(2, 2, '2023-10-02', '10:00:00', '11:00:00'),
(3, 3, '2023-10-03', '11:00:00', '12:00:00');

-- Таблица reviews
INSERT INTO reviews (id_client, id_trainer, rating, comment, review_date)
VALUES 
(1, 1, 4.5, 'Отличный тренер!', '2023-10-01'),
(2, 2, 5.0, 'Прекрасные занятия йогой!', '2023-10-02'),
(3, 3, 4.0, 'Хорошая подготовка к боксу.', '2023-10-03');

-- Таблица discounts
INSERT INTO discounts (id_client, discount_amount, start_date, end_date)
VALUES 
(1, 0.15, '2023-10-01', '2023-10-31'),
(2, 0.10, '2023-10-01', '2023-10-31'),
(3, 0.20, '2023-10-01', '2023-10-31');

-- Таблица payments
INSERT INTO payments (id_client, amount, payment_method, payment_date)
VALUES 
(1, 500.00, 'Карта', '2023-10-01'),
(2, 600.00, 'Наличные', '2023-10-02'),
(3, 700.00, 'Карта', '2023-10-03');

-- Таблица schedule
INSERT INTO schedule (id_client, id_trainer, start_time, end_time)
VALUES 
(1, 1, '09:00:00', '10:00:00'),
(2, 2, '10:00:00', '11:00:00'),
(3, 3, '11:00:00', '12:00:00');

-- Таблица trainer_room
INSERT INTO trainer_room (id_room, id_trainer, start_date, end_date)
VALUES 
(1, 1, '2023-10-01', '2023-10-31'),
(2, 2, '2023-10-01', '2023-10-31'),
(3, 3, '2023-10-01', '2023-10-31');

-- Таблица equipment_room
INSERT INTO equipment_room (id_equipment, id_room, start_date, end_date)
VALUES 
(1, 1, '2023-10-01', '2023-10-31'),
(2, 2, '2023-10-01', '2023-10-31'),
(3, 3, '2023-10-01', '2023-10-31');

-- Вывод данных из всех таблиц

SELECT 'clients' AS table_name, * FROM clients;
SELECT 'trainers' AS table_name, * FROM trainers;
SELECT 'rooms' AS table_name, * FROM rooms;
SELECT 'equipment' AS table_name, * FROM equipment;
SELECT 'visits_history' AS table_name, * FROM visits_history;
SELECT 'reviews' AS table_name, * FROM reviews;
SELECT 'discounts' AS table_name, * FROM discounts;
SELECT 'payments' AS table_name, * FROM payments;
SELECT 'schedule' AS table_name, * FROM schedule;
SELECT 'trainer_room' AS table_name, * FROM trainer_room;
SELECT 'equipment_room' AS table_name, * FROM equipment_room;
