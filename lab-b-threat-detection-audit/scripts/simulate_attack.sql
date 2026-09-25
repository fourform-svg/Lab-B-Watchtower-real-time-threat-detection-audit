CREATE TABLE IF NOT EXISTS customers (id SERIAL, name TEXT); INSERT INTO customers VALUES (1,'test'); SELECT * FROM customers; -- This should trigger detection
