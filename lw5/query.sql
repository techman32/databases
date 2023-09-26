USE db_lw5;

# 1. Добавить внешние ключи.
ALTER TABLE booking
    ADD CONSTRAINT booking_client_id_client_fk
        FOREIGN KEY (id_client) REFERENCES client (id_client)
            ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE room
    ADD CONSTRAINT room_hotel_id_hotel_fk
        FOREIGN KEY (id_hotel) REFERENCES hotel (id_hotel)
            ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE room
    ADD CONSTRAINT room_room_category_id_room_category_fk
        FOREIGN KEY (id_room_category) REFERENCES room_category (id_room_category)
            ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE room_in_booking
    ADD CONSTRAINT room_in_booking_booking_id_booking_fk
        FOREIGN KEY (id_booking) REFERENCES booking (id_booking)
            ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE room_in_booking
    ADD CONSTRAINT room_in_booking_room_id_room_fk
        FOREIGN KEY (id_room) REFERENCES room (id_room)
            ON UPDATE CASCADE ON DELETE CASCADE;


# 2. Выдать информацию о клиентах гостиницы "Космос",
# проживающих в номерах категории "Люкс" на 1 апреля 2019г.
SELECT c.*
FROM room_in_booking rib
         LEFT JOIN room r ON r.id_room = rib.id_room
         LEFT JOIN hotel h ON h.id_hotel = r.id_hotel
         LEFT JOIN booking b ON rib.id_booking = b.id_booking
         LEFT JOIN client c ON c.id_client = b.id_client
         LEFT JOIN room_category rc ON r.id_room_category = rc.id_room_category
WHERE h.name = 'Космос'
  AND rc.name = 'Люкс'
  AND rib.checkin_date <= '2019-04-01'
  AND rib.checkout_date > '2019-04-01';


# 3. Дать список свободных номеров всех гостиниц на 22 апреля.
SELECT r.id_room
FROM room r
         LEFT JOIN room_in_booking rib ON r.id_room = rib.id_room
WHERE (rib.checkout_date < '2019-04-22' OR rib.checkin_date >= '2019-04-22')
   OR rib.id_room IS NULL;


# 4. Дать количество проживающих в гостинице "Космос" на 23 марта по каждой категории номеров
SELECT rc.id_room_category,
       COUNT(rib.id_room_in_booking) clients_amount
FROM room_in_booking rib
         LEFT JOIN room r ON r.id_room = rib.id_room
         LEFT JOIN hotel h ON r.id_hotel = h.id_hotel
         LEFT JOIN room_category rc ON r.id_room_category = rc.id_room_category
WHERE h.name = 'Космос'
  AND rib.checkin_date <= '2019-03-23'
  AND rib.checkout_date > '2019-03-23'
GROUP BY rc.id_room_category;


# 5. Дать список последних проживавших клиентов по всем комнатам гостиницы "Космос",
# выехавшим в апреле с указанием даты выезда.
SELECT room_last_checkout_date.id_room,
       room_last_checkout_date.last_checkout_date,
       c.*
FROM (SELECT r.id_room,
             MAX(rib.checkout_date) last_checkout_date
      FROM room_in_booking rib
               LEFT JOIN room r ON r.id_room = rib.id_room
               LEFT JOIN booking b ON rib.id_booking = b.id_booking
               LEFT JOIN hotel h ON r.id_hotel = h.id_hotel
      WHERE MONTH(rib.checkout_date) = 4
        AND h.name = 'Космос'
      GROUP BY r.id_room) room_last_checkout_date
         LEFT JOIN room_in_booking rib2
                   ON room_last_checkout_date.id_room = rib2.id_room AND
                      room_last_checkout_date.last_checkout_date = rib2.checkout_date
         LEFT OUTER JOIN booking b2 ON b2.id_booking = rib2.id_booking
         LEFT JOIN client c ON c.id_client = b2.id_client;


# 6. Продлить на 2 дня дату проживания в гостинице "Космос" всем клиентам комнат категории “Бизнес”,
# которые заселились 10 мая.
UPDATE
    room_in_booking rib
        LEFT JOIN room r ON r.id_room = rib.id_room
        LEFT JOIN hotel h ON h.id_hotel = r.id_hotel
        LEFT JOIN room_category rc ON rc.id_room_category = r.id_room_category
SET rib.checkout_date = DATE_ADD(rib.checkout_date, INTERVAL 2 DAY)
WHERE rib.checkin_date = '2019-05-10'
  AND h.name = 'Космос'
  AND rc.name = 'Бизнес';


# 7. Найти все "пересекающиеся" варианты проживания.
# Правильное состояние: не может быть забронирован один номер на одну дату несколько раз,
# т.к. нельзя заселиться нескольким клиентам в один номер.
SELECT rib.*,
       rib2.*
FROM room_in_booking rib
         INNER JOIN room_in_booking rib2 ON rib2.id_room = rib.id_room
WHERE (rib.checkin_date BETWEEN rib2.checkin_date AND rib2.checkout_date)
  AND rib.id_booking != rib2.id_booking;


# 8. Создать бронирование в транзакции.
START TRANSACTION;

INSERT INTO client (name, phone)
VALUES ('Человек Транзакция', '+79996669966');
SET @client_id = LAST_INSERT_ID();

INSERT INTO booking (id_client, booking_date)
VALUES (@client_id, NOW());
SET @booking_id = LAST_INSERT_ID();

INSERT INTO room_in_booking (id_booking, id_room, checkin_date, checkout_date)
VALUES (@booking_id, '4', '2023-08-23', '2023-08-29');

COMMIT;
# ROLLBACK;

# 9. Добавить необходимые индексы для всех таблиц.
CREATE INDEX idx_client_id ON client (id_client);
CREATE INDEX idx_room_id ON room (id_room);
CREATE INDEX idx_room_hotel_id ON room (id_hotel);
CREATE INDEX idx_room_category_id ON room (id_room_category);
CREATE INDEX idx_room_in_booking_booking_id ON room_in_booking (id_booking);