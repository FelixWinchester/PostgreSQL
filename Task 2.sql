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
('Сергей Сидоров', '1992-12-10', 'Мужской', '+79176543212'),
('Мария Кузнецова', '1995-03-22', 'Женский', '+79876543213'),
('Алексей Морозов', '1988-07-14', 'Мужской', '+79176543214'),
('Екатерина Николаева', '1998-11-05', 'Женский', '+79876543215'),
('Дмитрий Андреев', '1993-09-18', 'Мужской', '+79876543216'),
('Ольга Васильева', '1987-02-28', 'Женский', '+79876543217'),
('Павел Зайцев', '1991-06-10', 'Мужской', '+79806543218'),
('Татьяна Федорова', '1994-04-25', 'Женский', '+79876543219'),
('Артем Соколов', '1989-08-12', 'Мужской', '+79876543220'),
('Ирина Лебедева', '1997-12-03', 'Женский', '+79876543221'),
('Максим Попов', '1996-05-19', 'Мужской', '+77876543222'),
('Наталья Ковалева', '1986-01-30', 'Женский', '+79876543223'),
('Андрей Волков', '1999-03-15', 'Мужской', '+77876543224');

-- Таблица trainers
INSERT INTO trainers (full_name, phone_number, sport_type)
VALUES 
('Александр Кузнецов', '+79001234567', 'Фитнес'),
('Елена Медведева', '+79001234568', 'Йога'),
('Дмитрий Николаев', '+79001234569', 'Бокс'),
('Ольга Смирнова', '+79001234570', 'Пилатес'),
('Игорь Петров', '+79001234571', 'Кроссфит'),
('Анна Козлова', '+79001234572', 'Стретчинг'),
('Сергей Иванов', '+79001234573', 'Бодибилдинг'),
('Мария Сидорова', '+79001234574', 'Аэробика'),
('Алексей Федоров', '+79001234575', 'Танцы'),
('Екатерина Андреева', '+79001234576', 'Карате'),
('Иван Ковалев', '+79001234577', 'Тайский бокс'),
('Татьяна Морозова', '+79001234578', 'Функциональный тренинг'),
('Андрей Васильев', '+79001234579', 'Бег'),
('Наталья Зайцева', '+79001234580', 'Силовой тренинг'),
('Артем Лебедев', '+79001234581', 'Гимнастика');

-- Таблица rooms
INSERT INTO rooms (capacity, location)
VALUES 
(50, 'Первый этаж'),
(30, 'Второй этаж'),
(20, 'Подвал'),
(40, 'Чердак'),
(60, 'Цокольный этаж'),
(25, 'Левое крыло'),
(35, 'Правое крыло'),
(15, 'Южное крыло'),
(55, 'Северное крыло'),
(45, 'Центральный зал'),
(10, 'Малый зал'),
(70, 'Большой зал'),
(80, 'Спортивная площадка'),
(100, 'Открытая терраса'),
(120, 'Уличная арена');

-- Таблица equipment
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

-- Таблица visits_history
INSERT INTO visits_history (id_client, id_room, visit_date, start_time, end_time)
VALUES 
(1, 1, '2023-10-01', '09:00:00', '10:00:00'),
(2, 2, '2023-10-02', '10:00:00', '11:00:00'),
(3, 3, '2023-10-03', '11:00:00', '12:00:00'),
(4, 4, '2023-10-04', '12:00:00', '13:00:00'),
(5, 5, '2023-10-05', '13:00:00', '14:00:00'),
(6, 6, '2023-10-06', '14:00:00', '15:00:00'),
(7, 7, '2023-10-07', '15:00:00', '16:00:00'),
(8, 8, '2023-10-08', '16:00:00', '17:00:00'),
(9, 9, '2023-10-09', '17:00:00', '18:00:00'),
(10, 10, '2023-10-10', '18:00:00', '19:00:00'),
(11, 11, '2023-10-11', '19:00:00', '20:00:00'),
(12, 12, '2023-10-12', '20:00:00', '21:00:00'),
(13, 13, '2023-10-13', '21:00:00', '22:00:00'),
(14, 14, '2023-10-14', '22:00:00', '23:00:00'),
(15, 15, '2023-10-15', '23:00:00', '00:00:00');

-- Таблица reviews
INSERT INTO reviews (id_client, id_trainer, rating, comment, review_date)
VALUES 
(1, 1, 4.5, 'Отличный тренер!', '2023-10-01'),
(2, 2, 5.0, 'Прекрасные занятия йогой!', '2023-10-02'),
(3, 3, 4.0, 'Хорошая подготовка к боксу.', '2023-10-03'),
(4, 4, 4.8, 'Профессиональный подход.', '2023-10-04'),
(5, 5, 4.2, 'Интересные упражнения.', '2023-10-05'),
(NULL, NULL, NULL, NULL, NULL),
(NULL, NULL, NULL, NULL, NULL),
(NULL, NULL, NULL, NULL, NULL),
(NULL, NULL, NULL, NULL, NULL),
(NULL, NULL, NULL, NULL, NULL),
(NULL, NULL, NULL, NULL, NULL),
(NULL, NULL, NULL, NULL, NULL),
(NULL, NULL, NULL, NULL, NULL),
(NULL, NULL, NULL, NULL, NULL),
(NULL, NULL, NULL, NULL, NULL);

-- Таблица discounts
INSERT INTO discounts (id_client, discount_amount, start_date, end_date)
VALUES 
(1, 0.15, '2023-10-01', '2023-10-31'),
(2, 0.10, '2023-10-01', '2023-10-31'),
(3, 0.20, '2023-10-01', '2023-10-31'),
(4, 0.12, '2023-10-02', '2023-11-01'),
(5, 0.18, '2023-10-03', '2023-11-02'),
(6, 0.25, '2023-10-04', '2023-11-03'),
(7, 0.14, '2023-10-05', '2023-11-04'),
(8, 0.16, '2023-10-06', '2023-11-05'),
(9, 0.19, '2023-10-07', '2023-11-06'),
(10, 0.22, '2023-10-08', '2023-11-07'),
(11, 0.13, '2023-10-09', '2023-11-08'),
(12, 0.17, '2023-10-10', '2023-11-09'),
(13, 0.21, '2023-10-11', '2023-11-10'),
(14, 0.23, '2023-10-12', '2023-11-11'),
(15, 0.24, '2023-10-13', '2023-11-12');

-- Таблица payments
INSERT INTO payments (id_client, amount, payment_method, payment_date)
VALUES 
(1, 500.00, 'Карта', '2023-10-01'),
(2, 600.00, 'Наличные', '2023-10-02'),
(3, 700.00, 'Карта', '2023-10-03'),
(4, 800.00, 'Карта', '2023-10-04'),
(5, 900.00, 'Наличные', '2023-10-05'),
(6, 1000.00, 'Карта', '2023-10-06'),
(7, 1100.00, 'Наличные', '2023-10-07'),
(8, 1200.00, 'Карта', '2023-10-08'),
(9, 1300.00, 'Наличные', '2023-10-09'),
(10, 1400.00, 'Карта', '2023-10-10'),
(11, 1500.00, 'Наличные', '2023-10-11'),
(12, 1600.00, 'Карта', '2023-10-12'),
(13, 1700.00, 'Наличные', '2023-10-13'),
(14, 1800.00, 'Карта', '2023-10-14'),
(15, 1900.00, 'Наличные', '2023-10-15');

-- Таблица schedule
INSERT INTO schedule (id_client, id_trainer, start_time, end_time)
VALUES 
(1, 1, '09:00:00', '10:00:00'),
(2, 2, '10:00:00', '11:00:00'),
(3, 3, '11:00:00', '12:00:00'),
(4, 4, '12:00:00', '13:00:00'),
(5, 5, '13:00:00', '14:00:00'),
(6, 6, '14:00:00', '15:00:00'),
(7, 7, '15:00:00', '16:00:00'),
(8, 8, '16:00:00', '17:00:00'),
(9, 9, '17:00:00', '18:00:00'),
(10, 10, '18:00:00', '19:00:00'),
(11, 11, '19:00:00', '20:00:00'),
(12, 12, '20:00:00', '21:00:00'),
(13, 13, '21:00:00', '22:00:00'),
(14, 14, '22:00:00', '23:00:00'),
(15, 15, '23:00:00', '00:00:00');

-- Таблица trainer_room
INSERT INTO trainer_room (id_room, id_trainer, start_date, end_date)
VALUES 
(1, 1, '2023-10-01', '2023-10-31'),
(2, 2, '2023-10-01', '2023-10-31'),
(3, 3, '2023-10-01', '2023-10-31'),
(4, 4, '2023-10-02', '2023-11-01'),
(5, 5, '2023-10-03', '2023-11-02'),
(6, 6, '2023-10-04', '2023-11-03'),
(7, 7, '2023-10-05', '2023-11-04'),
(8, 8, '2023-10-06', '2023-11-05'),
(9, 9, '2023-10-07', '2023-11-06'),
(10, 10, '2023-10-08', '2023-11-07'),
(11, 11, '2023-10-09', '2023-11-08'),
(12, 12, '2023-10-10', '2023-11-09'),
(13, 13, '2023-10-11', '2023-11-10'),
(14, 14, '2023-10-12', '2023-11-11'),
(15, 15, '2023-10-13', '2023-11-12');

-- Таблица equipment_room
INSERT INTO equipment_room (id_equipment, id_room, start_date, end_date)
VALUES 
(1, 1, '2023-10-01', '2023-10-31'),
(2, 2, '2023-10-01', '2023-10-31'),
(3, 3, '2023-10-01', '2023-10-31'),
(4, 4, '2023-10-02', '2023-11-01'),
(5, 5, '2023-10-03', '2023-11-02'),
(6, 6, '2023-10-04', '2023-11-03'),
(7, 7, '2023-10-05', '2023-11-04'),
(8, 8, '2023-10-06', '2023-11-05'),
(9, 9, '2023-10-07', '2023-11-06'),
(10, 10, '2023-10-08', '2023-11-07'),
(11, 11, '2023-10-09', '2023-11-08'),
(12, 12, '2023-10-10', '2023-11-09'),
(13, 13, '2023-10-11', '2023-11-10'),
(14, 14, '2023-10-12', '2023-11-11'),
(15, 15, '2023-10-13', '2023-11-12');

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
