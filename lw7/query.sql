use db_lw7;

# 1. Добавить внешние ключи
ALTER TABLE lesson
    ADD CONSTRAINT fk_lesson_teacher
        FOREIGN KEY (id_teacher) REFERENCES teacher (id_teacher);

ALTER TABLE lesson
    ADD CONSTRAINT fk_lesson_subject
        FOREIGN KEY (id_subject) REFERENCES subject (id_subject);

ALTER TABLE lesson
    ADD CONSTRAINT fk_lesson_group
        FOREIGN KEY (id_group) REFERENCES `group` (id_group);

ALTER TABLE mark
    ADD CONSTRAINT fk_mark_lesson
        FOREIGN KEY (id_lesson) REFERENCES lesson (id_lesson);

ALTER TABLE mark
    ADD CONSTRAINT fk_mark_student
        FOREIGN KEY (id_student) REFERENCES student (id_student);

ALTER TABLE student
    ADD CONSTRAINT fk_student_group
        FOREIGN KEY (id_group) REFERENCES `group` (id_group);

# 2. Выдать оценки студентов по информатике если они обучаются данному
# Замечание: добавить view
DROP VIEW IF EXISTS results;
CREATE VIEW results AS
SELECT st.*, m.mark
FROM mark m
         LEFT JOIN lesson l ON l.id_lesson = m.id_lesson
         LEFT JOIN student st ON st.id_student = m.id_student
         LEFT JOIN subject s ON l.id_subject = s.id_subject
WHERE s.name = 'Информатика';

SELECT *
FROM results;

# 3. Дать информацию о должниках с указанием фамилии студента и названия предмета.
# Должниками считаются студенты, не имеющие оценки по предмету, который ведется в группе.
# Оформить в виде процедуры, на входе идентификатор группы.
# Замечание: есть сомнения - будут отображены все студенты у которых нет оценки
# хотя бы по одному предмету
DROP PROCEDURE IF EXISTS GetDebtors;
CREATE PROCEDURE GetDebtors(IN group_id INT)
BEGIN
    SELECT DISTINCT st.name, s.name
    FROM student st
             LEFT JOIN lesson l
                       ON st.id_group = l.id_group AND
                          l.id_lesson NOT IN
                          (SELECT DISTINCT m.id_lesson FROM mark m WHERE m.id_student = st.id_student)
             LEFT JOIN subject s ON l.id_subject = s.id_subject
    WHERE st.id_student IN (SELECT s.id_student FROM student s WHERE s.id_group = group_id);
END;

CALL GetDebtors(4);


# 4. Дать среднюю оценку студентов по каждому предмету для тех предметов,
# по которым занимается не менее 35 студентов.
# Замечание: занимается значит числится в группе, и не обязательно имеет оценку
SELECT subj.name AS subject_name, AVG(m.mark) AS average_mark
FROM subject subj
         JOIN lesson l ON subj.id_subject = l.id_subject
         JOIN mark m ON l.id_lesson = m.id_lesson
GROUP BY subj.name
HAVING COUNT(DISTINCT m.id_student) >= 35;


# 5. Дать оценки студентов специальности ВМ по всем проводимым предметам
# с указанием группы, фамилии, предмета, даты.
# При отсутствии оценки заполнить значениями NULL поля оценки.
SELECT g.name, st.name, s.name, l.date, m.mark
FROM `group` g
         INNER JOIN student st ON g.id_group = st.id_group
         INNER JOIN lesson l ON g.id_group = l.id_group
         INNER JOIN subject s ON l.id_subject = s.id_subject
         LEFT JOIN mark m ON l.id_lesson = m.id_lesson AND st.id_student = m.id_student
WHERE g.name = 'ВМ';


# 6. Всем студентам специальности ПС,
# получившим оценки меньшие 5 по предмету БД до 12.05, повысить эти оценки на 1 балл.
UPDATE mark m
    JOIN student st ON m.id_student = st.id_student
    JOIN lesson l ON m.id_lesson = l.id_lesson
    JOIN subject s ON l.id_subject = s.id_subject
    JOIN `group` g ON st.id_group = g.id_group
SET m.mark = m.mark + 1
WHERE g.name = 'ПС'
  AND s.name = 'БД'
  AND m.mark < 5
  AND l.date < '2019-05-12';


# 7. Добавить необходимые индексы.
CREATE INDEX idx_lesson_id_group ON lesson (id_group);
CREATE INDEX idx_mark_id_lesson ON mark (id_lesson);
CREATE INDEX idx_mark_id_student ON mark (id_student);
CREATE INDEX idx_lesson_id_teacher ON lesson (id_teacher);
CREATE INDEX idx_lesson_id_subject ON lesson (id_subject);
CREATE INDEX idx_student_id_group ON student (id_group);