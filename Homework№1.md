
# 1. Концептуальная модель

## 1.1. Основные сущности

В бизнес-домене «онлайн-образование» выделены 5 основных сущностей:

| Сущность       | Назначение                                                    | Какое бизнес-требование привело к появлению сущности                                                                                  |
| -------------- | ------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------- |
| **app_user**   | Пользователь платформы: студент, преподаватель, администратор | Пользователи должны регистрироваться, входить на платформу, выбирать курсы, преподавать курсы, оставлять отзывы                       |
| **Course**     | Учебный курс как продукт платформы                            | Преподаватели могут создавать курсы, студенты могут выбирать курсы, курсы продаются                                                   |
| **Lesson**     | Урок внутри курса                                             | Каждый курс состоит из нескольких уроков                                                                                              |
| **Enrollment** | Запись студента на курс, факт обучения / покупки              | Студенты могут выбирать курсы и проходить обучение; также сущность используется как факт продажи для расчёта отчислений преподавателю |
| **Review**     | Отзыв и оценка курса студентом                                | Студенты могут оставлять отзывы на курсы и оценивать их по шкале от 1 до 5                                                            |

---

## 1.2. Связи между сущностями

| Связь                 | Описание                                                                                                  |
| --------------------- | --------------------------------------------------------------------------------------------------------- |
| `User — Course`       | Один пользователь-преподаватель может создать несколько курсов. Каждый курс имеет одного преподавателя.   |
| `User — Enrollment`   | Один пользователь может быть записан на несколько курсов. Каждая запись принадлежит одному пользователю.  |
| `Course — Enrollment` | Один курс может иметь много записей студентов. Каждая запись относится к одному курсу.                    |
| `Course — Lesson`     | Один курс содержит несколько уроков. Каждый урок относится только к одному курсу.                         |
| `Enrollment — Review` | Одна запись на курс может иметь не более одного отзыва. Отзыв возможен только при наличии записи на курс. |

---

## 1.3. Влияние бизнес-требований на концептуальную модель

| Бизнес-требование | Решение в концептуальной модели |
|---|---|
| Пользователи регистрируются на платформе | Введена сущность `User` |
| Есть студенты и преподаватели | Сущность `User` является общей для всех ролей, роль будет уточнена в логической модели |
| Преподаватели создают курсы | Добавлена связь `User — Course` |
| Курсы состоят из уроков | Введена сущность `Lesson` и связь `Course — Lesson` |
| Студенты выбирают курсы и проходят обучение | Введена сущность `Enrollment` как связь между пользователем и курсом |
| Преподаватели получают отчисления от продаж | `Enrollment` интерпретируется как факт продажи курса студенту |
| Студенты оставляют отзывы и оценки | Введена сущность `Review`, связанная с `Enrollment`, чтобы отзыв мог оставить только записанный студент |

---

# 2. Логическая модель

## 2.1.1. Сущность `User`

| Атрибут | Описание | Ключ / ограничение |
|---|---|---|
| `user_id` | Уникальный идентификатор пользователя | **PRIMARY KEY** |
| `email` | Электронная почта пользователя | **NOT NULL**, **UNIQUE** |
| `full_name` | Имя / ФИО пользователя | NOT NULL |
| `password_hash` | Хеш пароля | NOT NULL |
| `role` | Роль пользователя: студент, преподаватель, администратор | NOT NULL, CHECK |
| `created_at` | Дата регистрации | NOT NULL |


---

## 2.1.2. Сущность `Course`

| Атрибут | Описание | Ключ / ограничение |
|---|---|---|
| `course_id` | Уникальный идентификатор курса | **PRIMARY KEY** |
| `instructor_id` | Преподаватель, создавший курс | **FOREIGN KEY** → `User.user_id`, NOT NULL |
| `title` | Название курса | NOT NULL |
| `description` | Описание курса | — |
| `price` | Стоимость курса | NOT NULL, CHECK ≥ 0 |
| `royalty_rate` | Доля отчисления преподавателю от продажи | NOT NULL, CHECK от 0 до 1 |
| `is_published` | Признак публикации курса | NOT NULL |
| `created_at` | Дата создания курса | NOT NULL |

---

## 2.1.3. Сущность `Lesson`

| Атрибут | Описание | Ключ / ограничение |
|---|---|---|
| `course_id` | Идентификатор курса | **PRIMARY KEY**, **FOREIGN KEY** → `Course.course_id` |
| `lesson_number` | Порядковый номер урока в курсе | **PRIMARY KEY**, CHECK > 0 |
| `title` | Название урока | NOT NULL |
| `content_url` | Ссылка на контент урока | NOT NULL |
| `duration_minutes` | Длительность урока в минутах | NOT NULL, CHECK > 0 |


---

## 2.1.4. Сущность `Enrollment`

| Атрибут | Описание | Ключ / ограничение |
|---|---|---|
| `user_id` | Идентификатор студента | **PRIMARY KEY**, **FOREIGN KEY** → `User.user_id` |
| `course_id` | Идентификатор курса | **PRIMARY KEY**, **FOREIGN KEY** → `Course.course_id` |
| `enrolled_at` | Дата записи на курс | NOT NULL |
| `status` | Статус обучения | NOT NULL, CHECK |
| `progress_percent` | Прогресс прохождения курса | NOT NULL, CHECK 0–100 |
| `price_paid` | Фактически оплаченная сумма | NOT NULL, CHECK ≥ 0 |
| `royalty_amount` | Сумма отчисления преподавателю | NOT NULL, CHECK ≥ 0 и ≤ `price_paid` |

---

## 2.1.5. Сущность `Review`

| Атрибут | Описание | Ключ / ограничение |
|---|---|---|
| `user_id` | Идентификатор студента | **PRIMARY KEY**, часть составного ключа |
| `course_id` | Идентификатор курса | **PRIMARY KEY**, часть составного ключа |
| `rating` | Оценка курса | NOT NULL, CHECK от 1 до 5 |
| `comment` | Текст отзыва | может быть пустым |
| `created_at` | Дата создания отзыва | NOT NULL |

---

## 2.2. Сводная таблица первичных и внешних ключей

| Сущность | Первичный ключ | Внешние ключи |
|---|---|---|
| `User` | `user_id` | — |
| `Course` | `course_id` | `instructor_id` → `User.user_id` |
| `Lesson` | `(course_id, lesson_number)` | `course_id` → `Course.course_id` |
| `Enrollment` | `(user_id, course_id)` | `user_id` → `User.user_id`; `course_id` → `Course.course_id` |
| `Review` | `(user_id, course_id)` | `(user_id, course_id)` → `Enrollment(user_id, course_id)` |

---

## 2.3. Кардинальность связей в нотации Crow’s Foot

Ниже приведены кардинальности связей.

```text
USER ||--o{ COURSE       : "создаёт курс как преподаватель"
USER ||--o{ ENROLLMENT   : "записывается на курс"
COURSE ||--o{ ENROLLMENT : "имеет записи студентов"
COURSE ||--o{ LESSON     : "содержит уроки"
ENROLLMENT ||--o| REVIEW : "может иметь один отзыв"
```

Подробнее:

| Связь | Кардинальность | Обязательность | Пояснение |
|---|---|---|---|
| `User` → `Course` | 1:M | У пользователя может быть 0..M курсов. У курса обязательно 1 преподаватель. | Преподаватель может создать несколько курсов. Курс не может существовать без преподавателя. |
| `User` → `Enrollment` | 1:M | У пользователя может быть 0..M записей. Каждая запись обязательно принадлежит 1 пользователю. | Студент может записаться на несколько курсов. |
| `Course` → `Enrollment` | 1:M | У курса может быть 0..M записей. Каждая запись обязательно относится к 1 курсу. | На курс могут записаться много студентов. |
| `Course` → `Lesson` | 1:M | У курса может быть 0..M уроков в черновике, но для опубликованного курса ожидается не менее 1 урока. Каждый урок принадлежит ровно 1 курсу. | Курс состоит из нескольких уроков. |
| `Enrollment` → `Review` | 1:0..1 | У записи может быть 0 или 1 отзыв. Каждый отзыв обязательно относится к 1 записи. | Студент может оставить не более одного отзыва по своей записи на курс. |

Дополнительно через `Enrollment` логически возникают связи:

| Связь | Кардинальность | Пояснение |
|---|---|---|
| `User` → `Review` | 1:M | Один пользователь может оставить несколько отзывов на разные курсы. Каждый отзыв принадлежит одному пользователю. |
| `Course` → `Review` | 1:M | Один курс может иметь много отзывов. Каждый отзыв относится к одному курсу. |

---

## 2.4. Идентифицирующие и неидентифицирующие связи

В данной модели используются как идентифицирующие, так и неидентифицирующие связи.

Идентифицирующая связь означает, что внешний ключ родительской сущности входит в состав первичного ключа дочерней сущности.  
Неидентифицирующая связь означает, что внешний ключ не входит в первичный ключ дочерней сущности.

### Идентифицирующие связи

| Связь | Почему связь идентифицирующая |
|---|---|
| `Course` → `Lesson` | Урок не может существовать без курса. `Lesson.course_id` входит в первичный ключ `(course_id, lesson_number)`. |
| `User` → `Enrollment` | Запись на курс не может существовать без пользователя. `Enrollment.user_id` входит в первичный ключ `(user_id, course_id)`. |
| `Course` → `Enrollment` | Запись на курс не может существовать без курса. `Enrollment.course_id` входит в первичный ключ `(user_id, course_id)`. |
| `Enrollment` → `Review` | Отзыв может существовать только при наличии записи на курс. Первичный ключ отзыва `(user_id, course_id)` совпадает с ключом `Enrollment`. |

### Неидентифицирующие связи

| Связь | Почему связь неидентифицирующая |
|---|---|
| `User` → `Course` как преподаватель | Курс имеет собственный первичный ключ `course_id`. Атрибут `instructor_id` является внешним ключом, но не входит в первичный ключ курса. |

---

## 2.5. Влияние бизнес-требований на логическую модель

| Бизнес-требование | Влияние на логическую модель |
|---|---|
| Регистрация пользователей | Сущность `User`, атрибуты `email`, `password_hash`, `created_at` |
| Разные роли пользователей | Атрибут `User.role` с допустимыми значениями `student`, `instructor`, `admin` |
| Преподаватели создают курсы | Атрибут `Course.instructor_id` как внешний ключ на `User.user_id` |
| Преподаватели получают отчисления от продаж | Атрибуты `Course.royalty_rate`, `Enrollment.price_paid`, `Enrollment.royalty_amount` |
| Курс состоит из нескольких уроков | Сущность `Lesson`, связь 1:M, составной ключ `(course_id, lesson_number)` |
| Студенты проходят обучение | Атрибуты `Enrollment.status`, `Enrollment.progress_percent` |
| Отзывы могут оставлять студенты, записанные на курс | Связь `Enrollment` → `Review`, внешний ключ из `Review` в `Enrollment` |
| Оценка курса по шкале от 1 до 5 | Атрибут `Review.rating` с ограничением `CHECK (rating BETWEEN 1 AND 5)` |
| Один пользователь может оставить только один отзыв на один курс | Первичный ключ `Review(user_id, course_id)` |

---

# 3. Физическая модель для PostgreSQL

Физическая модель оформлена воспроизводимым SQL-скриптом.

Используется отдельная схема `edtech`.  
Перед созданием таблицы удаляются с помощью `DROP TABLE IF EXISTS ... CASCADE`, поэтому повторный запуск скрипта даёт тот же результат.

---

## 3.1. SQL-скрипт

```sql
-- Создаём отдельную схему для базы данных
CREATE SCHEMA IF NOT EXISTS edtech;

-- Удаляем существующие таблицы в правильном порядке
DROP TABLE IF EXISTS edtech.review CASCADE;
DROP TABLE IF EXISTS edtech.enrollment CASCADE;
DROP TABLE IF EXISTS edtech.lesson CASCADE;
DROP TABLE IF EXISTS edtech.course CASCADE;
DROP TABLE IF EXISTS edtech.app_user CASCADE;

-- =============================================================
-- Таблица пользователей
-- Сущность: User
-- Название таблицы выбрано как app_user, потому что пользователь
-- в PostgreSQL имеет зарезервированное слово user.
-- =============================================================
CREATE TABLE edtech.app_user (
    user_id        BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    email          VARCHAR(255) NOT NULL,
    full_name      VARCHAR(200) NOT NULL,
    password_hash  TEXT NOT NULL,
    role           VARCHAR(20) NOT NULL DEFAULT 'student',
    created_at     TIMESTAMPTZ NOT NULL DEFAULT now(),

    -- Пользователь с таким email не должен дублироваться.
    -- Бизнес-требование: регистрация и вход по уникальному email.
    CONSTRAINT uq_app_user_email UNIQUE (email),

    -- Упрощённая проверка формата email.
    CONSTRAINT chk_app_user_email CHECK (email LIKE '%@%.%'),

    -- Бизнес-требование: на платформе есть студенты, преподаватели и администраторы.
    CONSTRAINT chk_app_user_role CHECK (role IN ('student', 'instructor', 'admin'))
);

-- =============================================================
-- Таблица курсов
-- Сущность: Course
-- =============================================================
CREATE TABLE edtech.course (
    course_id      BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    -- Бизнес-требование: преподаватели создают курсы.
    instructor_id  BIGINT NOT NULL,

    title          VARCHAR(200) NOT NULL,
    description    TEXT NOT NULL DEFAULT '',

    -- Бизнес-требование: курсы продаются.
    price          NUMERIC(10, 2) NOT NULL,

    -- Бизнес-требование: преподаватели получают отчисления от продаж.
    -- Хранится доля отчисления, например 0.100 = 10%.
    royalty_rate   NUMERIC(4, 3) NOT NULL DEFAULT 0.100,

    -- Позволяет различать черновики курса и опубликованные курсы.
    is_published   BOOLEAN NOT NULL DEFAULT FALSE,

    created_at     TIMESTAMPTZ NOT NULL DEFAULT now(),

    -- Курс не может существовать без преподавателя.
    CONSTRAINT fk_course_instructor
        FOREIGN KEY (instructor_id)
        REFERENCES edtech.app_user (user_id)
        ON DELETE RESTRICT,

    -- Цена курса не может быть отрицательной.
    CONSTRAINT chk_course_price CHECK (price >= 0),

    -- Доля отчисления должна находиться в диапазоне от 0 до 1.
    CONSTRAINT chk_course_royalty_rate
        CHECK (royalty_rate >= 0 AND royalty_rate <= 1)
);

-- =============================================================
-- Таблица уроков
-- Сущность: Lesson
-- Бизнес-требование: каждый курс состоит из нескольких уроков.
-- =============================================================
CREATE TABLE edtech.lesson (
    course_id       BIGINT NOT NULL,
    lesson_number   INTEGER NOT NULL,
    title           VARCHAR(200) NOT NULL,
    content_url     TEXT NOT NULL,
    duration_minutes INTEGER NOT NULL,

    -- Составной первичный ключ.
    -- Номера уроков уникальны в пределах одного курса.
    PRIMARY KEY (course_id, lesson_number),

    -- Урок принадлежит курсу и не может существовать без курса.
    CONSTRAINT fk_lesson_course
        FOREIGN KEY (course_id)
        REFERENCES edtech.course (course_id)
        ON DELETE CASCADE,

    -- Номер урока должен быть положительным.
    CONSTRAINT chk_lesson_number CHECK (lesson_number > 0),

    -- Длительность урока должна быть положительной.
    CONSTRAINT chk_lesson_duration CHECK (duration_minutes > 0)
);

-- =============================================================
-- Таблица записей студентов на курс
-- Сущность: Enrollment
-- Разрешает связь многие-ко-многим между User и Course.
-- Также фиксирует факт продажи и отчисление преподавателю.
-- =============================================================
CREATE TABLE edtech.enrollment (
    user_id          BIGINT NOT NULL,
    course_id        BIGINT NOT NULL,
    enrolled_at      TIMESTAMPTZ NOT NULL DEFAULT now(),

    -- Бизнес-требование: студент проходит обучение.
    status           VARCHAR(20) NOT NULL DEFAULT 'active',
    progress_percent SMALLINT NOT NULL DEFAULT 0,

    -- Бизнес-требование: платформа фиксирует оплату курса.
    price_paid       NUMERIC(10, 2) NOT NULL,

    -- Бизнес-требование: преподаватель получает отчисление от продажи.
    royalty_amount   NUMERIC(10, 2) NOT NULL,

    -- Один пользователь может быть записан на один курс максимум один раз.
    PRIMARY KEY (user_id, course_id),

    -- Запись не может существовать без пользователя.
    CONSTRAINT fk_enrollment_user
        FOREIGN KEY (user_id)
        REFERENCES edtech.app_user (user_id)
        ON DELETE RESTRICT,

    -- Запись не может существовать без курса.
    CONSTRAINT fk_enrollment_course
        FOREIGN KEY (course_id)
        REFERENCES edtech.course (course_id)
        ON DELETE RESTRICT,

    -- Допустимые статусы обучения.
    CONSTRAINT chk_enrollment_status
        CHECK (status IN ('active', 'completed', 'cancelled')),

    -- Прогресс прохождения курса должен быть в диапазоне от 0 до 100.
    CONSTRAINT chk_enrollment_progress
        CHECK (progress_percent BETWEEN 0 AND 100),

    -- Оплаченная сумма не может быть отрицательной.
    CONSTRAINT chk_enrollment_price
        CHECK (price_paid >= 0),

    -- Отчисление преподавателю не может быть отрицательным
    -- и не может превышать фактическую оплату курса.
    CONSTRAINT chk_enrollment_royalty
        CHECK (royalty_amount >= 0 AND royalty_amount <= price_paid)
);

-- =============================================================
-- Таблица отзывов
-- Сущность: Review
-- Бизнес-требование: студенты могут оставлять отзывы на курсы
-- и оценивать их по шкале от 1 до 5.
-- =============================================================
CREATE TABLE edtech.review (
    user_id      BIGINT NOT NULL,
    course_id    BIGINT NOT NULL,
    rating       SMALLINT NOT NULL,
    comment      TEXT,
    created_at   TIMESTAMPTZ NOT NULL DEFAULT now(),

    -- Один пользователь может оставить только один отзыв на один курс.
    PRIMARY KEY (user_id, course_id),

    -- Отзыв может быть оставлен только при наличии записи на курс.
    -- Это ограничивает возможность оставлять отзывы случайными пользователями.
    CONSTRAINT fk_review_enrollment
        FOREIGN KEY (user_id, course_id)
        REFERENCES edtech.enrollment (user_id, course_id)
        ON DELETE CASCADE,

    -- Бизнес-требование: оценка курса по шкале от 1 до 5.
    CONSTRAINT chk_review_rating
        CHECK (rating BETWEEN 1 AND 5)
);

-- =============================================================
-- Индексы на внешние ключи
-- =============================================================

-- Индекс для поиска курсов по преподавателю.
CREATE INDEX idx_course_instructor_id
    ON edtech.course (instructor_id);

-- Индекс для поиска уроков по курсу.
-- Формально внешний ключ уже поддерживается первичным ключом
-- (course_id, lesson_number), но индекс оставлен явно.
CREATE INDEX idx_lesson_course_id
    ON edtech.lesson (course_id);

-- Индекс для поиска записей по пользователю.
-- Также покрывается первичным ключом (user_id, course_id),
-- но оставлен явно для наглядности требования по внешним ключам.
CREATE INDEX idx_enrollment_user_id
    ON edtech.enrollment (user_id);

-- Индекс для поиска записей по курсу.
-- Необходим, так как первичный ключ начинается с user_id.
CREATE INDEX idx_enrollment_course_id
    ON edtech.enrollment (course_id);

-- Индекс для внешнего ключа отзыва на запись.
-- Совпадает с первичным ключом, но оставлен явно.
CREATE INDEX idx_review_enrollment_fk
    ON edtech.review (user_id, course_id);

-- Дополнительный индекс для выборки отзывов по курсу.
-- Полезен для бизнес-задач: показать отзывы о курсе.
CREATE INDEX idx_review_course_id
    ON edtech.review (course_id);
```

## 3.1.1 ER-диаграмма
![[ER.png]]
---

## 3.2. Пояснение к физическим ограничениям

| Ограничение | Где используется | Бизнес-причина |
|---|---|---|
| `PRIMARY KEY` | Все таблицы | Каждая сущность должна быть однозначно идентифицируема |
| `FOREIGN KEY` | `Course.instructor_id`, `Lesson.course_id`, `Enrollment.user_id`, `Enrollment.course_id`, `Review(user_id, course_id)` | Обеспечивается ссылочная целостность между пользователями, курсами, уроками, записями и отзывами |
| `NOT NULL` | `email`, `title`, `price`, `rating` и другие важные поля | Объекты не должны существовать без обязательных характеристик |
| `UNIQUE` | `app_user.email` | Пользователь не может зарегистрировать несколько аккаунтов с одним и тем же email |
| `CHECK` | `role`, `price`, `royalty_rate`, `rating`, `progress_percent`, `status` | Реализуются бизнес-правила домена |
| `ON DELETE RESTRICT` | `Course.instructor_id`, `Enrollment.user_id`, `Enrollment.course_id` | Запрещается удалять пользователей или курсы, если уже есть курсы или записи, связанные с финансовыми данными |
| `ON DELETE CASCADE` | `Lesson.course_id`, `Review.user_id/course_id → Enrollment` | Уроки удаляются вместе с курсом; отзыв удаляется при удалении записи на курс |

---

## 3.3. Пояснение к индексам

| Индекс | Назначение |
|---|---|
| `idx_course_instructor_id` | Поиск курсов по преподавателю |
| `idx_lesson_course_id` | Поиск уроков по курсу |
| `idx_enrollment_user_id` | Поиск записей студента |
| `idx_enrollment_course_id` | Поиск студентов, записанных на курс |
| `idx_review_enrollment_fk` | Поддержка внешнего ключа отзыва к записи на курс |
| `idx_review_course_id` | Быстрая выборка отзывов по курсу |

---

# 4. Частые запросы
