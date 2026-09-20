
SET client_min_messages = NOTICE;

-- =============================================================
-- Демонстрация 1. Нарушение CHECK
-- =============================================================

DO $$
BEGIN
    INSERT INTO edtech.tag (name)
    VALUES ('x');

EXCEPTION
    WHEN check_violation THEN
        RAISE NOTICE 'Ошибка: Название тега должно содержать минимум 2 символа. Текст СУБД: %', SQLERRM;
END;
$$;

-- =============================================================
-- Демонстрация 2. Нарушение FOREIGN KEY
-- =============================================================

DO $$
DECLARE
    v_tag_name       TEXT := 'fk_demo_' || md5(random()::text);
    v_tag_id         BIGINT;
    v_fake_course_id BIGINT;
BEGIN
    -- Получаем заведомо несуществующий идентификатор курса.
    SELECT COALESCE(MAX(course_id), 0) + 1
    INTO v_fake_course_id
    FROM edtech.course;

    -- Создаём временный тег.
    INSERT INTO edtech.tag (name)
    VALUES (v_tag_name)
    RETURNING tag_id INTO v_tag_id;

    -- Пытаемся привязать тег к несуществующему курсу.
    INSERT INTO edtech.course_tag (course_id, tag_id)
    VALUES (v_fake_course_id, v_tag_id);

EXCEPTION
    WHEN foreign_key_violation THEN
        RAISE NOTICE 'Ошибка: Нельзя привязать тег к несуществующему курсу. Текст СУБД: %', SQLERRM;
END;
$$;

-- =============================================================
-- Демонстрация 3. Нарушение UNIQUE
-- =============================================================

DO $$
DECLARE
    v_tag_name TEXT := 'Тег_' || md5(random()::text);
BEGIN
    INSERT INTO edtech.tag (name)
    VALUES (v_tag_name);

    INSERT INTO edtech.tag (name)
    VALUES (v_tag_name);

EXCEPTION
    WHEN unique_violation THEN
        RAISE NOTICE 'Ошибка: Тег с таким названием уже существует. Текст СУБД: %', SQLERRM;
END;
$$;

-- =============================================================
-- Демонстрация 4. Нарушение NOT NULL
-- =============================================================

DO $$
BEGIN
    INSERT INTO edtech.tag (name)
    VALUES (NULL);

EXCEPTION
    WHEN not_null_violation THEN
        RAISE NOTICE 'Ошибка: Тег не может быть создан без названия. Текст СУБД: %', SQLERRM;
END;
$$;

-- =============================================================
-- Демонстрация 5. Нарушение PRIMARY KEY в таблице course_tag
-- =============================================================
DO $$
DECLARE
    v_email    TEXT := 'demo_' || md5(random()::text) || '@example.com';
    v_tag_name TEXT := 'Тег курса_' || md5(random()::text);

    v_user_id   BIGINT;
    v_course_id BIGINT;
    v_tag_id    BIGINT;
BEGIN
    -- Создаём тестового преподавателя.
    INSERT INTO edtech.app_user (email, full_name, password_hash, role)
    VALUES (v_email, 'Демо преподаватель', 'hash', 'instructor')
    RETURNING user_id INTO v_user_id;

    -- Создаём тестовый курс.
    INSERT INTO edtech.course (instructor_id, title, price)
    VALUES (v_user_id, 'Демо курс для тегов', 0)
    RETURNING course_id INTO v_course_id;

    -- Создаём тестовый тег.
    INSERT INTO edtech.tag (name)
    VALUES (v_tag_name)
    RETURNING tag_id INTO v_tag_id;

    -- Назначаем тег курсу первый раз.
    INSERT INTO edtech.course_tag (course_id, tag_id)
    VALUES (v_course_id, v_tag_id);

    -- Пытаемся назначить тот же тег тому же курсу второй раз.
    INSERT INTO edtech.course_tag (course_id, tag_id)
    VALUES (v_course_id, v_tag_id);

EXCEPTION
    WHEN unique_violation THEN
        RAISE NOTICE 'Ошибка: Один и тот же тег нельзя назначить одному курсу дважды. Текст СУБД: %', SQLERRM;
END;
$$;