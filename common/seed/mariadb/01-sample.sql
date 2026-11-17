-- Sample relational data for evaluating orchestration tools.
-- MARIADB_DATABASE (eval) is created by the image; this runs inside it.
CREATE TABLE IF NOT EXISTS orders (
  id         INT AUTO_INCREMENT PRIMARY KEY,
  customer   VARCHAR(64)   NOT NULL,
  amount     DECIMAL(10,2) NOT NULL,
  status     VARCHAR(16)   NOT NULL,
  created_at TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO orders (customer, amount, status, created_at) VALUES
  ('acme',    120.50, 'paid',     '2026-11-01 09:00:00'),
  ('acme',     75.00, 'paid',     '2026-11-02 10:30:00'),
  ('globex',  300.00, 'pending',  '2026-11-02 11:15:00'),
  ('initech',  42.99, 'refunded', '2026-11-03 14:45:00'),
  ('globex',  210.10, 'paid',     '2026-11-04 08:20:00'),
  ('umbrella', 88.88, 'paid',     '2026-11-05 16:05:00');
