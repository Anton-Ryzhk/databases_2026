
CREATE SCHEMA IF NOT EXISTS edtech;

BEGIN;


DROP TABLE IF EXISTS edtech.course_tag CASCADE;
DROP TABLE IF EXISTS edtech.tag CASCADE;

-- Таблица тегов

CREATE TABLE edtech.tag (
    tag_id      BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name        VARCHAR(100) NOT NULL,
    description TEXT NOT NULL DEFAULT '',
    created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),

    -- Название тега должно быть уникальным.
    -- Бизнес-смысл: два одинаковых тега не имеют смысла.
    CONSTRAINT uq_tag_name UNIQUE (name),

    -- Название тега должно быть осмысленным.
    -- Бизнес-смысл: нельзя создать тег из одного символа.
    CONSTRAINT chk_tag_name_length
        CHECK (char_length(trim(name)) BETWEEN 2 AND 100)
);


-- Таблица связи курса и тега

CREATE TABLE edtech.course_tag (
    course_id   BIGINT NOT NULL,
    tag_id      BIGINT NOT NULL,
    assigned_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    -- Запрещаем назначить один и тот же тег одному курсу дважды.
    PRIMARY KEY (course_id, tag_id),

    -- Нельзя привязать тег к несуществующему курсу.
    CONSTRAINT fk_course_tag_course
        FOREIGN KEY (course_id)
        REFERENCES edtech.course (course_id)
        ON DELETE CASCADE,

    -- Нельзя привязать курс к несуществующему тегу.
    CONSTRAINT fk_course_tag_tag
        FOREIGN KEY (tag_id)
        REFERENCES edtech.tag (tag_id)
        ON DELETE CASCADE
);

-- Индексы для новых таблиц

CREATE INDEX IF NOT EXISTS idx_course_tag_tag_id
    ON edtech.course_tag (tag_id);

-- ------------------------------------------------------------
-- Индексы для поддержки частых запросов из ДЗ №1
-- ------------------------------------------------------------

-- Личный кабинет студента:
-- получить записи студента с фильтром по статусу обучения.
CREATE INDEX IF NOT EXISTS idx_enrollment_user_status
    ON edtech.enrollment (user_id, status);

-- Каталог курсов:
-- опубликованные курсы с сортировкой по дате создания.
CREATE INDEX IF NOT EXISTS idx_course_published_created_at
    ON edtech.course (created_at DESC)
    WHERE is_published;

-- Каталог и страница курса:
-- расчёт среднего рейтинга и количества отзывов.
-- Индекс полезен для запросов вида:
-- SELECT course_id, AVG(rating) FROM review GROUP BY course_id;
CREATE INDEX IF NOT EXISTS idx_review_course_rating
    ON edtech.review (course_id, rating);

-- Количество записей на курс.
CREATE INDEX IF NOT EXISTS idx_enrollment_course_id
    ON edtech.enrollment (course_id);

-- Статистика преподавателя:
-- записи по курсу и дате записи.
CREATE INDEX IF NOT EXISTS idx_enrollment_course_enrolled_at
    ON edtech.enrollment (course_id, enrolled_at DESC);

-- Курсы преподавателя.
CREATE INDEX IF NOT EXISTS idx_course_instructor_id
    ON edtech.course (instructor_id);

COMMIT;