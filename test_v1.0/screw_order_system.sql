CREATE DATABASE IF NOT EXISTS screw_order_system
CHARACTER SET utf8mb4
COLLATE utf8mb4_unicode_ci;

USE screw_order_system;

SET FOREIGN_KEY_CHECKS = 0;
DROP VIEW IF EXISTS Product_Order_Summary;
DROP TABLE IF EXISTS Order_Details;
DROP TABLE IF EXISTS Sales_Orders;
DROP TABLE IF EXISTS Raw_Material_Purchases;
DROP TABLE IF EXISTS Products;
DROP TABLE IF EXISTS Customers;
SET FOREIGN_KEY_CHECKS = 1;

-- Customers table.
CREATE TABLE Customers (
    customer_id VARCHAR(20) PRIMARY KEY,
    customer_name VARCHAR(100) NOT NULL,
    contact_person VARCHAR(50),
    phone_number VARCHAR(20) NOT NULL,
    shipping_address VARCHAR(255) NOT NULL,
    credit_limit DECIMAL(19,4) NOT NULL,
    CONSTRAINT chk_credit CHECK (credit_limit > 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Products table.
CREATE TABLE Products (
    product_id VARCHAR(20) PRIMARY KEY,
    material_grade VARCHAR(10) NOT NULL,
    thread_system ENUM('metric', 'imperial', 'custom') NOT NULL,
    thread_size VARCHAR(10) NOT NULL,
    thread_pitch ENUM('coarse', 'fine', 'extra_fine') NOT NULL,
    head_type VARCHAR(30),
    length_mm DECIMAL(6,2) NOT NULL,
    unit ENUM('piece', 'box', 'kg') NOT NULL,
    CONSTRAINT chk_pur_len CHECK (length_mm > 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Raw material purchase records.
CREATE TABLE Raw_Material_Purchases (
    purchase_id VARCHAR(20) PRIMARY KEY,
    supplier_name VARCHAR(100) NOT NULL,
    product_id VARCHAR(20) NOT NULL,
    quantity INT NOT NULL,
    total_amount DECIMAL(14,4) NOT NULL,
    purchase_time DATETIME NOT NULL,
    employee_id VARCHAR(20) NOT NULL,
    CONSTRAINT fk_raw_material_product
        FOREIGN KEY (product_id) REFERENCES Products(product_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
    CONSTRAINT chk_pur_qty CHECK (quantity > 0),
    CONSTRAINT chk_pur_amount CHECK (total_amount > 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Sales order headers.
CREATE TABLE Sales_Orders (
    order_id VARCHAR(20) PRIMARY KEY,
    customer_id VARCHAR(20) NOT NULL,
    employee_id VARCHAR(20) NOT NULL,
    order_date DATETIME NOT NULL,
    required_date DATETIME NOT NULL,
    order_status ENUM('pending', 'processing', 'shipped', 'completed', 'cancelled') NOT NULL DEFAULT 'pending',
    CONSTRAINT fk_sales_order_customer
        FOREIGN KEY (customer_id) REFERENCES Customers(customer_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
    CONSTRAINT chk_dates CHECK (order_date <= required_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Sales order details.
CREATE TABLE Order_Details (
    order_id VARCHAR(20) NOT NULL,
    product_id VARCHAR(20) NOT NULL,
    quantity INT NOT NULL,
    unit_price DECIMAL(10,4) NOT NULL,
    packaging_type ENUM('bag', 'box', 'carton') NOT NULL DEFAULT 'box',
    production_status ENUM('not_started', 'in_progress', 'paused', 'completed', 'cancelled') NOT NULL DEFAULT 'not_started',
    PRIMARY KEY (order_id, product_id),
    CONSTRAINT fk_order_details_order
        FOREIGN KEY (order_id) REFERENCES Sales_Orders(order_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT fk_order_details_product
        FOREIGN KEY (product_id) REFERENCES Products(product_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
    CONSTRAINT chk_quantity CHECK (quantity > 0),
    CONSTRAINT chk_price CHECK (unit_price > 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO Customers (
    customer_id, customer_name, contact_person, phone_number, shipping_address, credit_limit
) VALUES
('C001', 'North Fastener Co.', 'Alice Wang', '02-2345-1001', 'Taipei City Xinyi District No. 1', 300000.0000),
('C002', 'Precision Bolt Ltd.', 'Ben Lin', '03-4567-1002', 'Taoyuan City Zhongli District No. 22', 250000.0000),
('C003', 'Chia Yi Hardware', 'Carol Chen', '05-2222-1003', 'Chiayi City East District No. 35', 180000.0000),
('C004', 'Tainan Assembly Works', 'David Huang', '06-3333-1004', 'Tainan City Yongkang District No. 18', 220000.0000),
('C005', 'Kaohsiung Machinery', 'Eva Tsai', '07-5555-1005', 'Kaohsiung City Sanmin District No. 91', 400000.0000),
('C006', 'Hsinchu Tooling Inc.', 'Frank Wu', '03-5777-1006', 'Hsinchu City East District No. 12', 320000.0000),
('C007', 'Taichung Metals', 'Grace Liu', '04-2468-1007', 'Taichung City Xitun District No. 77', 280000.0000),
('C008', 'Miaoli Components', 'Henry Hsu', '037-333-108', 'Miaoli County Zhunan Township No. 8', 160000.0000),
('C009', 'Yunlin Farm Machines', 'Ivy Yeh', '05-6333-109', 'Yunlin County Douliu City No. 66', 210000.0000),
('C010', 'Keelung Ship Supply', 'Jack Pan', '02-2422-1010', 'Keelung City Renai District No. 5', 190000.0000);

INSERT INTO Products (
    product_id, material_grade, thread_system, thread_size, thread_pitch, head_type, length_mm, unit
) VALUES
('P001', '304', 'metric', 'M4', 'coarse', 'pan', 12.00, 'piece'),
('P002', '304', 'metric', 'M5', 'coarse', 'flat', 16.00, 'piece'),
('P003', '316', 'metric', 'M6', 'fine', 'hex', 20.00, 'piece'),
('P004', '316', 'metric', 'M8', 'coarse', 'socket', 25.00, 'box'),
('P005', '410', 'metric', 'M10', 'fine', 'hex', 30.00, 'box'),
('P006', '304', 'imperial', '1/4', 'coarse', 'pan', 19.05, 'piece'),
('P007', '316', 'imperial', '5/16', 'fine', 'flat', 22.00, 'piece'),
('P008', '304', 'custom', 'M3', 'extra_fine', 'socket', 10.00, 'piece'),
('P009', '316', 'metric', 'M12', 'coarse', 'hex', 40.00, 'kg'),
('P010', '410', 'metric', 'M6', 'coarse', 'truss', 18.00, 'box');

INSERT INTO Raw_Material_Purchases (
    purchase_id, supplier_name, product_id, quantity, total_amount, purchase_time, employee_id
) VALUES
('RM001', 'Taiwan Steel Supply', 'P001', 1000, 4500.0000, '2026-06-01 09:00:00', 'E001'),
('RM002', 'Ever Alloy Co.', 'P002', 1200, 6200.0000, '2026-06-01 10:00:00', 'E002'),
('RM003', 'Shin Metal Works', 'P003', 900, 8100.0000, '2026-06-02 09:30:00', 'E001'),
('RM004', 'Central Stainless', 'P004', 700, 9800.0000, '2026-06-02 11:00:00', 'E003'),
('RM005', 'Formosa Wire Rod', 'P005', 600, 7600.0000, '2026-06-03 13:00:00', 'E004'),
('RM006', 'Pacific Fastener Metal', 'P006', 1500, 5300.0000, '2026-06-03 15:00:00', 'E002'),
('RM007', 'Best Alloy Taiwan', 'P007', 800, 8800.0000, '2026-06-04 09:20:00', 'E005'),
('RM008', 'Nan Steel Trading', 'P008', 2000, 6900.0000, '2026-06-04 14:10:00', 'E006'),
('RM009', 'Harbor Steel', 'P009', 500, 11200.0000, '2026-06-05 10:40:00', 'E003'),
('RM010', 'Union Material Co.', 'P010', 1100, 7300.0000, '2026-06-05 16:00:00', 'E004');

INSERT INTO Sales_Orders (
    order_id, customer_id, employee_id, order_date, required_date, order_status
) VALUES
('SO001', 'C001', 'E001', '2026-06-01 09:30:00', '2026-06-08 17:00:00', 'pending'),
('SO002', 'C002', 'E002', '2026-06-01 10:30:00', '2026-06-09 17:00:00', 'processing'),
('SO003', 'C003', 'E001', '2026-06-02 11:00:00', '2026-06-10 17:00:00', 'shipped'),
('SO004', 'C004', 'E003', '2026-06-02 13:20:00', '2026-06-11 17:00:00', 'completed'),
('SO005', 'C005', 'E004', '2026-06-03 09:10:00', '2026-06-12 17:00:00', 'pending'),
('SO006', 'C006', 'E002', '2026-06-03 14:40:00', '2026-06-13 17:00:00', 'processing'),
('SO007', 'C007', 'E005', '2026-06-04 09:15:00', '2026-06-14 17:00:00', 'pending'),
('SO008', 'C008', 'E006', '2026-06-04 15:45:00', '2026-06-15 17:00:00', 'processing'),
('SO009', 'C009', 'E003', '2026-06-05 10:25:00', '2026-06-16 17:00:00', 'shipped'),
('SO010', 'C010', 'E004', '2026-06-05 16:30:00', '2026-06-17 17:00:00', 'completed');

INSERT INTO Order_Details (
    order_id, product_id, quantity, unit_price, packaging_type, production_status
) VALUES
('SO001', 'P001', 300, 4.5000, 'box', 'not_started'),
('SO002', 'P002', 250, 5.2000, 'carton', 'in_progress'),
('SO003', 'P003', 180, 8.8000, 'box', 'completed'),
('SO004', 'P004', 120, 13.5000, 'carton', 'completed'),
('SO005', 'P005', 100, 15.2000, 'box', 'not_started'),
('SO006', 'P006', 400, 4.1000, 'bag', 'in_progress'),
('SO007', 'P007', 160, 9.9000, 'box', 'not_started'),
('SO008', 'P008', 500, 3.8000, 'bag', 'paused'),
('SO009', 'P009', 90, 22.5000, 'carton', 'completed'),
('SO010', 'P010', 220, 6.7000, 'box', 'completed');

-- Product order summary view.
CREATE OR REPLACE VIEW Product_Order_Summary AS
SELECT
    p.product_id,
    p.material_grade,
    p.thread_system,
    p.thread_size,
    p.thread_pitch,
    COUNT(od.order_id) AS order_line_count,
    COALESCE(SUM(od.quantity), 0) AS total_order_quantity,
    COALESCE(SUM(od.quantity * od.unit_price), 0) AS total_order_amount
FROM Products p
LEFT JOIN Order_Details od ON p.product_id = od.product_id
GROUP BY
    p.product_id,
    p.material_grade,
    p.thread_system,
    p.thread_size,
    p.thread_pitch;

SHOW DATABASES;
USE screw_order_system;
SHOW TABLES;
DESC Products;
SELECT COUNT(*) FROM Products;
SELECT COUNT(*) FROM Customers;
SELECT COUNT(*) FROM Sales_Orders;
SELECT COUNT(*) FROM Order_Details;
SELECT COUNT(*) FROM Raw_Material_Purchases;
