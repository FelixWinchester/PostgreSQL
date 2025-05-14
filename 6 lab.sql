--- 1.1

CREATE OR REPLACE FUNCTION check_discount_overlap() 
RETURNS TRIGGER AS $$
BEGIN
    IF EXISTS (
        SELECT 1 FROM discounts
        WHERE id_client = NEW.id_client
        AND NEW.start_date <= end_date
        AND NEW.end_date >= start_date
    ) THEN
        RAISE EXCEPTION 'Клиент уже имеет активную скидку в указанный период.';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_check_discount_insert
BEFORE INSERT ON discounts
FOR EACH ROW
EXECUTE FUNCTION check_discount_overlap();

--- Успешно
INSERT INTO discounts (id_client, discount_amount, start_date, end_date)
VALUES (1, 10, '2025-01-01', '2025-01-31');

--Ошибка
INSERT INTO discounts (id_client, discount_amount, start_date, end_date)
VALUES (1, 15, '2025-01-15', '2025-02-15');


--- 1.2
CREATE OR REPLACE FUNCTION check_duplicate_review() 
RETURNS TRIGGER AS $$
BEGIN
    IF EXISTS (
        SELECT 1 
        FROM reviews
        WHERE id_client = NEW.id_client
          AND id_trainer = NEW.id_trainer
          AND review_date = NEW.review_date
    ) THEN
        RAISE EXCEPTION 'Клиент уже оставил отзыв этому тренеру в выбранную дату.';
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_check_duplicate_review_insert
BEFORE INSERT ON reviews
FOR EACH ROW
EXECUTE FUNCTION check_duplicate_review();
-- Корректно
INSERT INTO reviews (id_client, id_trainer, rating, comment, review_date)
VALUES (1, 5, 4.5, 'Great session!', '2025-05-06');
-- Ошибка
INSERT INTO reviews (id_client, id_trainer, rating, comment, review_date)
VALUES (1, 5, 3.0, 'Another review', '2025-05-06');

--- 2.1
CREATE OR REPLACE FUNCTION prevent_client_delete_if_payments_exist() 
RETURNS TRIGGER AS $$
BEGIN
    IF EXISTS (
        SELECT 1 FROM payments WHERE id_client = OLD.id_client
    ) THEN
        RAISE EXCEPTION 'Невозможно удалить клиента (ID=%), так как у него есть записи об оплате.', OLD.id_client;
    END IF;
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_prevent_client_delete_if_payments
BEFORE DELETE ON clients
FOR EACH ROW
EXECUTE FUNCTION prevent_client_delete_if_payments_exist();
-- Корректно
DELETE FROM clients WHERE id_client = 1;
-- Ошибка
SELECT id_client FROM payments LIMIT 1;
DELETE FROM clients WHERE id_client = 3299;

-- 2.2
CREATE OR REPLACE FUNCTION prevent_trainer_delete_if_scheduled() 
RETURNS TRIGGER AS $$
BEGIN
    IF EXISTS (
        SELECT 1 FROM schedule WHERE id_trainer = OLD.id_trainer
    ) THEN
        RAISE EXCEPTION 'Нельзя удалить тренера (ID=%), так как у него есть запланированные занятия.', OLD.id_trainer;
    END IF;
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_prevent_trainer_delete_if_scheduled
BEFORE DELETE ON trainers
FOR EACH ROW
EXECUTE FUNCTION prevent_trainer_delete_if_scheduled();
-- Корректно
SELECT id_trainer 
FROM trainers
WHERE id_trainer NOT IN (
    SELECT DISTINCT id_trainer 
    FROM schedule
)
LIMIT 1;

DELETE FROM trainers WHERE id_trainer = 201;
-- Ошибка
SELECT DISTINCT id_trainer FROM schedule LIMIT 1;
DELETE FROM trainers WHERE id_trainer = 58;

-- 3.1
CREATE OR REPLACE FUNCTION prevent_update_client_on_past_payment() 
RETURNS TRIGGER AS $$
BEGIN
    IF OLD.payment_date < CURRENT_DATE AND NEW.id_client <> OLD.id_client THEN
        RAISE EXCEPTION 'Нельзя изменить клиента в прошедшей оплате (ID оплаты = %)', OLD.id_payment;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_prevent_update_client_on_past_payment
BEFORE UPDATE ON payments
FOR EACH ROW
EXECUTE FUNCTION prevent_update_client_on_past_payment();

-- Корректно
UPDATE payments
SET id_client = 3299
WHERE id_payment = 1;

-- Ошибка
UPDATE payments
SET id_client = 3
WHERE id_payment = 42;

-- 3.2
CREATE OR REPLACE FUNCTION prevent_late_review_update() 
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.rating <> OLD.rating AND (CURRENT_DATE - OLD.review_date) > 30 THEN
        RAISE EXCEPTION 'Нельзя изменить рейтинг отзыва спустя более 30 дней (ID отзыва = %)', OLD.id_review;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_prevent_late_review_update
BEFORE UPDATE ON reviews
FOR EACH ROW
EXECUTE FUNCTION prevent_late_review_update();
-- Корректно
SELECT id_review 
FROM reviews
WHERE review_date >= CURRENT_DATE - INTERVAL '30 days'
LIMIT 1;

UPDATE reviews
SET rating = 4.5
WHERE id_review = 5001;
-- Ошибка
SELECT id_review 
FROM reviews
WHERE review_date < CURRENT_DATE - INTERVAL '30 days'
LIMIT 1;

UPDATE reviews
SET rating = 2.0
WHERE id_review = 1;
-- 4.1
-- Удаляем старые объекты, если они есть
DROP TRIGGER IF EXISTS trg_insert_client_schedule_view ON client_schedule_view;
DROP FUNCTION IF EXISTS insert_client_schedule;
DROP VIEW IF EXISTS client_schedule_view;

-- Создание представления
CREATE OR REPLACE VIEW client_schedule_view AS
SELECT 
    s.id_schedule, 
    c.full_name, 
    s.start_time, 
    s.end_time
FROM schedule s
JOIN clients c ON s.id_client = c.id_client;

-- Функция для INSTEAD OF INSERT
CREATE OR REPLACE FUNCTION insert_client_schedule()
RETURNS TRIGGER AS $$
DECLARE
    client_id BIGINT;
BEGIN
    -- Найти ID клиента по имени
    SELECT id_client INTO client_id
    FROM clients
    WHERE full_name = NEW.full_name
    LIMIT 1;

    -- Проверка: клиент найден
    IF client_id IS NULL THEN
        RAISE EXCEPTION 'Клиент с именем "%" не найден.', NEW.full_name;
    END IF;

    -- Проверка: корректное время
    IF NEW.start_time >= NEW.end_time THEN
        RAISE EXCEPTION 'Время начала не может быть позже или равно времени окончания.';
    END IF;

    -- Вставка в расписание
    INSERT INTO schedule (id_client, id_trainer, start_time, end_time)
    VALUES (client_id, 1, NEW.start_time, NEW.end_time);

    RETURN NULL;  -- ничего не вставлять в представление
END;
$$ LANGUAGE plpgsql;

-- Создание триггера
CREATE TRIGGER trg_insert_client_schedule_view
INSTEAD OF INSERT ON client_schedule_view
FOR EACH ROW
EXECUTE FUNCTION insert_client_schedule();

-- Корректно
-- Вставка нового расписания через представление
INSERT INTO client_schedule_view (full_name, start_time, end_time)
VALUES ('client2', '10:00:00', '11:00:00');

-- Проверка добавленных записей
SELECT * FROM schedule 
WHERE id_client = (
    SELECT id_client FROM clients WHERE full_name = 'client2'
);
-- Ошибка
INSERT INTO client_schedule_view (full_name, start_time, end_time)
VALUES ('client2', '12:00', '11:00');

-- 4.2
-- Удаляем триггер, если он существует
DROP TRIGGER IF EXISTS trg_update_equipment_view ON equipment_view;

-- Удаляем функцию, если она существует
DROP FUNCTION IF EXISTS trg_update_equipment_quantity();

-- Удаляем представление, если оно существует
DROP VIEW IF EXISTS equipment_view;

-- Создание представления для оборудования
CREATE OR REPLACE VIEW equipment_view AS
SELECT 
    id_equipment, 
    description, 
    quantity 
FROM equipment;

-- Создание функции для обновления количества оборудования
CREATE OR REPLACE FUNCTION trg_update_equipment_quantity() 
RETURNS TRIGGER AS $$
BEGIN
    -- Проверка, что количество не отрицательное
    IF NEW.quantity < 0 THEN
        RAISE EXCEPTION 'Количество оборудования не может быть отрицательным';
    END IF;

    -- Обновление количества в основной таблице
    UPDATE equipment
    SET quantity = NEW.quantity
    WHERE id_equipment = NEW.id_equipment; -- Обновляем строку по id_equipment

    RETURN NEW; -- Возвращаем NEW, чтобы триггер сработал корректно
END;
$$ LANGUAGE plpgsql;

-- Создание триггера для представления
CREATE TRIGGER trg_update_equipment_view
INSTEAD OF UPDATE ON equipment_view
FOR EACH ROW
EXECUTE FUNCTION trg_update_equipment_quantity();

-- Корректно
UPDATE equipment_view
SET quantity = 5
WHERE id_equipment = 1;

-- Ошибка
UPDATE equipment_view
SET quantity = -10
WHERE id_equipment = 1;
-- 4.3
-- Функция для удаления зала
CREATE OR REPLACE FUNCTION instead_of_delete_room()
RETURNS TRIGGER AS $$
BEGIN
    -- Проверка наличия оборудования в зале
    IF EXISTS (
        SELECT 1 FROM equipment_room
        WHERE id_room = OLD.id_room
    ) THEN
        -- Вывод ошибки, если оборудование связано с залом
        RAISE EXCEPTION 'Нельзя удалить зал (ID=%), так как в нем размещено оборудование.', OLD.id_room;
    END IF;

    -- Если оборудования нет, то удаляем зал из основной таблицы
    DELETE FROM rooms WHERE id_room = OLD.id_room;

    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

-- Удаление триггера, если он уже существует
DROP TRIGGER IF EXISTS trg_instead_of_delete_room ON rooms_view;

-- Создание триггера для представления
CREATE TRIGGER trg_instead_of_delete_room
INSTEAD OF DELETE ON rooms_view
FOR EACH ROW
EXECUTE FUNCTION instead_of_delete_room();

-- Корректно
DELETE FROM rooms_view WHERE id_room = 32;  
-- Ошибка
DELETE FROM rooms_view WHERE id_room = 3;  

-- 5.1
-- Создание функции для проверки временного интервала посещения
CREATE OR REPLACE FUNCTION check_visit_time_valid()
RETURNS TRIGGER AS $$
BEGIN
    -- Проверка что время начала раньше времени окончания
    IF NEW.start_time >= NEW.end_time THEN
        RAISE EXCEPTION 
            'Ошибка: время начала (%), должно быть раньше времени окончания (%)',
            NEW.start_time, 
            NEW.end_time;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Удаление триггера если он уже существует (для безопасного пересоздания)
DROP TRIGGER IF EXISTS trg_check_visit_time_valid ON visits_history;

-- Создание триггера для проверки временного интервала
CREATE TRIGGER trg_check_visit_time_valid
AFTER INSERT ON visits_history
FOR EACH ROW
EXECUTE FUNCTION check_visit_time_valid();

-- Корректно
-- Добавление записи о посещении
INSERT INTO visits_history (
    id_client, 
    id_room, 
    visit_date, 
    start_time, 
    end_time
)
VALUES (
    1,               -- ID клиента
    1,               -- ID зала
    CURRENT_DATE,    -- Дата посещения (текущая дата)
    '10:00',         -- Время начала (10:00)
    '11:00'          -- Время окончания (11:00)
);
-- Ошибка
INSERT INTO visits_history (
    id_client, 
    id_room, 
    visit_date, 
    start_time, 
    end_time
)
VALUES (
    1,               -- ID клиента
    1,               -- ID зала
    CURRENT_DATE,    -- Дата посещения
    '11:00',        -- НЕПРАВИЛЬНОЕ время начала (11:00)
    '10:00'         -- Время окончания (10:00)
);

-- 5.2
-- Создание функции для предотвращения редактирования старых отзывов
CREATE OR REPLACE FUNCTION prevent_late_review_edit()
RETURNS TRIGGER AS $$
BEGIN
    -- Проверка, что с даты отзыва прошло более 7 дней
    IF (CURRENT_DATE - OLD.review_date) > 7 THEN
        RAISE EXCEPTION 
            'Ошибка: редактирование отзыва (ID=%) невозможно, так как прошло более 7 дней (% дней)',
            OLD.id_review, 
            (CURRENT_DATE - OLD.review_date);
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Удаление триггера, если он уже существует
DROP TRIGGER IF EXISTS trg_prevent_late_review_edit ON reviews;

-- Создание триггера для проверки срока редактирования
CREATE TRIGGER trg_prevent_late_review_edit
AFTER UPDATE ON reviews
FOR EACH ROW
WHEN (OLD.rating IS DISTINCT FROM NEW.rating) -- Срабатывает только при изменении рейтинга
EXECUTE FUNCTION prevent_late_review_edit();
-- корректно
-- Обновление рейтинга отзыва с проверкой даты
UPDATE reviews
SET rating = 4.5
WHERE id_review = 5003 
  AND review_date >= CURRENT_DATE - INTERVAL '7 days';

-- ошибка
-- Попытка обновить старый отзыв
UPDATE reviews
SET rating = 2.0
WHERE id_review = 1 
  AND review_date < CURRENT_DATE - INTERVAL '10 days';

-- 5.3
-- Создание функции для проверки истории посещений при удалении клиента
CREATE OR REPLACE FUNCTION check_client_visits_on_delete()
RETURNS TRIGGER AS $$
BEGIN
    -- Проверка наличия записей о посещениях клиента
    IF EXISTS (
        SELECT 1 
        FROM visits_history 
        WHERE id_client = OLD.id_client
    ) THEN
        RAISE EXCEPTION 
            'Нельзя удалить клиента с ID=%, так как у него есть история посещений.', 
            OLD.id_client;
    END IF;

    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

-- Создание триггера для проверки перед удалением клиента
CREATE TRIGGER trg_check_client_visits_before_delete
BEFORE DELETE ON clients
FOR EACH ROW
EXECUTE FUNCTION check_client_visits_on_delete();
-- корректно
DELETE FROM clients WHERE id_client = 10001;
--ошибка
DELETE FROM clients WHERE id_client = 123;
