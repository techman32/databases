USE db_lw6;

# 1. Добавить внешние ключи.
ALTER TABLE dealer
    ADD CONSTRAINT fk_dealer_company
        FOREIGN KEY (id_company)
            REFERENCES company (id_company);

ALTER TABLE `order`
    ADD CONSTRAINT fk_order_production
        FOREIGN KEY (id_production)
            REFERENCES production (id_production);

ALTER TABLE `order`
    ADD CONSTRAINT fk_order_dealer
        FOREIGN KEY (id_dealer)
            REFERENCES dealer (id_dealer);

ALTER TABLE `order`
    ADD CONSTRAINT fk_order_pharmacy
        FOREIGN KEY (id_pharmacy)
            REFERENCES pharmacy (id_pharmacy);

ALTER TABLE production
    ADD CONSTRAINT fk_production_company
        FOREIGN KEY (id_company)
            REFERENCES company (id_company);

ALTER TABLE production
    ADD CONSTRAINT fk_production_medicine
        FOREIGN KEY (id_medicine)
            REFERENCES medicine (id_medicine);


# 2. Выдать информацию по всем заказам лекарства “Кордеон” компании “Аргус”
# c указанием названий аптек, дат, объема заказов.
SELECT ph.name,
       o.date,
       o.quantity
FROM production p
         LEFT JOIN company c ON c.id_company = p.id_company
         LEFT JOIN medicine m ON m.id_medicine = p.id_medicine
         LEFT JOIN `order` o ON p.id_production = o.id_production
         LEFT JOIN pharmacy ph ON ph.id_pharmacy = o.id_pharmacy
WHERE c.name = 'Аргус'
  AND m.name = 'Кордеон';


# 3. Дать список лекарств компании “Фарма”, на которые не были сделаны заказы до 25 января.
SELECT p.id_production,
       m.*
FROM production p
         LEFT JOIN medicine m ON m.id_medicine = p.id_medicine
         LEFT JOIN company c ON c.id_company = p.id_company
WHERE c.name = 'Фарма'
  AND p.id_production NOT IN
      (SELECT p2.id_production
       FROM `order` o
                LEFT JOIN production p2 ON p2.id_production = o.id_production
                LEFT JOIN company c2 ON c2.id_company = p2.id_company
       WHERE o.date < '2019-01-25');


# 4. Дать минимальный и максимальный баллы лекарств каждой фирмы, которая оформила не менее 120 заказов.
SELECT c.id_company, MIN(p.rating), MAX(p.rating)
FROM `order` o
         LEFT JOIN production p ON p.id_production = o.id_production
         LEFT JOIN company c ON c.id_company = p.id_company
GROUP BY c.id_company
HAVING COUNT(o.id_order) >= 120;


# 5. Дать списки сделавших заказы аптек по всем дилерам компании“AstraZeneca”.
SELECT DISTINCT d.id_dealer, ph.name
FROM dealer d
         INNER JOIN company c ON c.id_company = d.id_company AND c.name = 'AstraZeneca'
         LEFT JOIN `order` o ON d.id_dealer = o.id_dealer
         LEFT JOIN pharmacy ph ON ph.id_pharmacy = o.id_pharmacy;


# 6. Уменьшить на 20% стоимость всех лекарств, если она превышает 3000,
# а длительность лечения не более 7 дней.
START TRANSACTION;
UPDATE production p
    LEFT JOIN medicine m ON m.id_medicine = p.id_medicine
SET p.price = 0.8 * p.price
WHERE p.price > 3000.00
  AND m.cure_duration <= 7;
ROLLBACK;


# 7. Добавить необходимые индексы.
CREATE INDEX idx_company_id_company ON company (id_company);
CREATE INDEX idx_dealer_id_dealer ON dealer (id_dealer);
CREATE INDEX idx_dealer_id_company ON dealer (id_company);
CREATE INDEX idx_medicine_id_medicine ON medicine (id_medicine);
CREATE INDEX idx_order_id_order ON `order` (id_order);
CREATE INDEX idx_order_id_production ON `order` (id_production);
CREATE INDEX idx_order_id_dealer ON `order` (id_dealer);
CREATE INDEX idx_order_id_pharmacy ON `order` (id_pharmacy);
CREATE INDEX idx_pharmacy_id_pharmacy ON pharmacy (id_pharmacy);
CREATE INDEX idx_production_id_production ON production (id_production);
CREATE INDEX idx_production_id_company ON production (id_company);
CREATE INDEX idx_production_id_medicine ON production (id_medicine);