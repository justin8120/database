/*M!999999\- enable the sandbox mode */ 
-- MariaDB dump 10.19-11.7.2-MariaDB, for Win64 (AMD64)
--
-- Host: localhost    Database: nfu_database
-- ------------------------------------------------------
-- Server version	12.3.2-MariaDB

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*M!100616 SET @OLD_NOTE_VERBOSITY=@@NOTE_VERBOSITY, NOTE_VERBOSITY=0 */;

--
-- Table structure for table `customers`
--

DROP TABLE IF EXISTS `customers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `customers` (
  `customer_id` varchar(20) NOT NULL,
  `customer_name` varchar(100) NOT NULL,
  `contact_person` varchar(50) DEFAULT NULL,
  `phone_number` varchar(20) DEFAULT NULL,
  `shipping_address` varchar(255) NOT NULL,
  `credit_limit` decimal(12,2) DEFAULT NULL,
  PRIMARY KEY (`customer_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `customers`
--

LOCK TABLES `customers` WRITE;
/*!40000 ALTER TABLE `customers` DISABLE KEYS */;
INSERT INTO `customers` VALUES
('CUST-2026-001','Fastener World Inc.','John Smith','+1-555-0198','123 Industrial Pkwy, Cleveland, OH, USA',500000.00),
('CUST-2026-002','EuroBolt GmbH','Hans Müller','+49-30-123456','Kaiserstrasse 45, Frankfurt, Germany',800000.00),
('CUST-2026-003','Asia Express Hardware','陳志明','02-27123456','台北市中山區民生東路三段100號',3000000.00),
('CUST-2026-004','Global Screw Supply','Sarah Jenkins','+1-212-555-0143','789 Commerce Way, Houston, TX, USA',1200000.00),
('CUST-2026-005','Nordic Fastening AB','Erik Larsson','+46-8-7654321','Storgatan 12, Stockholm, Sweden',450000.00),
('CUST-2026-006','大順工業螺絲行','林建國','07-3812345','高雄市三民區建工路500號',1500000.00),
('CUST-2026-007','Pacific Rim Components','David Lee','+65-6123-4567','10 Changi Business Park, Singapore',600000.00),
('CUST-2026-008','Oz Screw & Bolt','Mark Warner','+61-2-9876-5432','45 George St, Sydney, NSW, Australia',350000.00),
('CUST-2026-009','Nippon Fasteners Co.','佐藤健','+81-3-5555-1234','1-2-3 Marunouchi, Chiyoda-ku, Tokyo, Japan',2000000.00),
('CUST-2026-010','聯發精密五金','張美玲','04-23456789','台中市烏日區溪南路一段200號',2500000.00),
('CUST-2026-011','UK Screw Solutions','James Wong','+44-20-7946-0192','56 Industrial Estate, Birmingham, UK',700000.00),
('CUST-2026-012','Canada Bolt Depot','Robert Tremblay','+1-514-555-0177','999 Rue du Rhone, Montreal, QC, Canada',550000.00),
('CUST-2026-013','Latam Hardware S.A.','Carlos Gomez','+52-55-1234-5678','Av. Reforma 456, Mexico City, Mexico',400000.00),
('CUST-2026-014','東台設備製造','王大同','06-2112345','台南市永康區中正北路800號',1800000.00),
('CUST-2026-015','Alpine Fixings SA','Pierre Dubois','+41-22-333-4455','Route de Chêne 30, Geneva, Switzerland',900000.00);
/*!40000 ALTER TABLE `customers` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `order_details`
--

DROP TABLE IF EXISTS `order_details`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `order_details` (
  `order_id` varchar(20) NOT NULL,
  `product_id` varchar(20) NOT NULL,
  `quantity` int(11) NOT NULL,
  `unit_price` decimal(10,4) NOT NULL,
  `packaging_type` enum('一箱','一包','散裝') DEFAULT '一箱',
  `production_status` enum('待進料','打頭中','搓牙中','待包裝','已完成') DEFAULT '待進料',
  PRIMARY KEY (`order_id`,`product_id`),
  KEY `product_id` (`product_id`),
  CONSTRAINT `1` FOREIGN KEY (`order_id`) REFERENCES `sales_orders` (`order_id`) ON DELETE CASCADE,
  CONSTRAINT `2` FOREIGN KEY (`product_id`) REFERENCES `products` (`product_id`),
  CONSTRAINT `chk_order_qty` CHECK (`quantity` > 0),
  CONSTRAINT `chk_price` CHECK (`unit_price` > 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `order_details`
--

LOCK TABLES `order_details` WRITE;
/*!40000 ALTER TABLE `order_details` DISABLE KEYS */;
INSERT INTO `order_details` VALUES
('ORD-2026-001','PROD-SS-001',50,1.2550,'一箱','打頭中'),
('ORD-2026-001','PROD-SS-002',20,2.4100,'一箱','待進料'),
('ORD-2026-001','PROD-SS-003',15,4.8500,'一包','待進料'),
('ORD-2026-002','PROD-SS-004',100,8.1255,'一箱','搓牙中'),
('ORD-2026-002','PROD-SS-005',30,3.1500,'一箱','打頭中'),
('ORD-2026-003','PROD-SS-006',250,120.0000,'散裝','待包裝'),
('ORD-2026-004','PROD-SS-007',200,0.9500,'一箱','打頭中'),
('ORD-2026-006','PROD-SS-008',500,45.0000,'散裝','已完成'),
('ORD-2026-007','PROD-SS-009',300,35.2000,'散裝','搓牙中'),
('ORD-2026-009','PROD-SS-010',80,0.7850,'一包','待包裝'),
('ORD-2026-010','PROD-SS-011',150,115.5000,'散裝','打頭中'),
('ORD-2026-011','PROD-SS-012',40,2.8800,'一箱','待進料'),
('ORD-2026-014','PROD-SS-013',50,0.5200,'一包','搓牙中'),
('ORD-2026-014','PROD-SS-014',100,85.0000,'散裝','打頭中'),
('ORD-2026-015','PROD-SS-015',70,3.6200,'一箱','待進料');
/*!40000 ALTER TABLE `order_details` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `products`
--

DROP TABLE IF EXISTS `products`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `products` (
  `product_id` varchar(20) NOT NULL,
  `material_grade` varchar(10) NOT NULL,
  `thread_system` enum('公制','英制','美制') NOT NULL,
  `thread_size` varchar(10) NOT NULL,
  `thread_pitch` enum('粗牙','細牙','自攻牙') NOT NULL,
  `head_type` varchar(30) DEFAULT NULL,
  `length_mm` decimal(6,2) NOT NULL,
  `unit` enum('千隻','公斤','件') NOT NULL,
  PRIMARY KEY (`product_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `products`
--

LOCK TABLES `products` WRITE;
/*!40000 ALTER TABLE `products` DISABLE KEYS */;
INSERT INTO `products` VALUES
('PROD-SS-001','304','英制','M5','粗牙','',20.00,'件'),
('PROD-SS-002','304','公制','M6','粗牙','內六角凹端緊定 (Socket Set)',25.00,'千隻'),
('PROD-SS-003','316','公制','M8','粗牙','盤頭十字螺絲 (Pan Phillips)',30.00,'千隻'),
('PROD-SS-004','316','公制','M10','細牙','六角承穴頭螺絲 (Socket Cap)',40.00,'千隻'),
('PROD-SS-005','304','英制','1/4','粗牙','外六角螺絲 (Hex Bolt)',38.10,'千隻'),
('PROD-SS-006','316','英制','3/8','粗牙','馬車螺絲 (Carriage Bolt)',50.80,'公斤'),
('PROD-SS-007','304','公制','#10','粗牙','',19.05,'千隻'),
('PROD-SS-008','304','美制','1/2','粗牙','重型六角螺絲 (Heavy Hex)',76.20,'件'),
('PROD-SS-009','316','公制','M12','粗牙','吊環螺絲 (Eye Bolt)',50.00,'件'),
('PROD-SS-010','304','公制','M4','細牙','大扁頭十字螺絲 (Truss Phillips)',15.00,'千隻'),
('PROD-SS-011','304','公制','M16','粗牙','外六角鋼結構螺絲',100.00,'公斤'),
('PROD-SS-012','316','美制','1/4-20','粗牙','內六角鈕扣頭 (Button Socket)',25.40,'千隻'),
('PROD-SS-013','304','公制','M3','自攻牙','圓頭喇叭口自攻螺絲',12.00,'千隻'),
('PROD-SS-014','316','公制','M20','粗牙','高強度六角螺栓',150.00,'件'),
('PROD-SS-015','304','英制','5/16','細牙','半圓頭內六角螺絲',31.75,'千隻');
/*!40000 ALTER TABLE `products` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `purchase_records`
--

DROP TABLE IF EXISTS `purchase_records`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `purchase_records` (
  `purchase_id` varchar(20) NOT NULL,
  `product_id` varchar(20) NOT NULL,
  `employee_id` varchar(20) NOT NULL,
  `supplier_name` varchar(100) NOT NULL,
  `quantity` int(11) NOT NULL,
  `total_amount` decimal(12,2) NOT NULL,
  `purchase_time` datetime NOT NULL,
  PRIMARY KEY (`purchase_id`),
  KEY `product_id` (`product_id`),
  CONSTRAINT `1` FOREIGN KEY (`product_id`) REFERENCES `products` (`product_id`),
  CONSTRAINT `chk_purchase_qty` CHECK (`quantity` > 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `purchase_records`
--

LOCK TABLES `purchase_records` WRITE;
/*!40000 ALTER TABLE `purchase_records` DISABLE KEYS */;
INSERT INTO `purchase_records` VALUES
('PUR-2026-001','PROD-SS-001','EMP-PUR-01','華新麗華股份有限公司',500,45000.00,'2026-05-15 09:00:00'),
('PUR-2026-002','PROD-SS-003','EMP-PUR-01','燁興企業股份有限公司',300,38000.00,'2026-05-16 10:30:00'),
('PUR-2026-003','PROD-SS-004','EMP-PUR-02','大成不鏽鋼工業',1000,125000.00,'2026-05-18 14:15:00'),
('PUR-2026-004','PROD-SS-006','EMP-PUR-01','官田鋼鐵',800,72000.00,'2026-05-20 11:00:00'),
('PUR-2026-005','PROD-SS-008','EMP-PUR-02','強新工業',200,29000.00,'2026-05-22 16:45:00'),
('PUR-2026-006','PROD-SS-011','EMP-PUR-01','華新麗華股份有限公司',1200,144000.00,'2026-05-25 08:30:00'),
('PUR-2026-007','PROD-SS-014','EMP-PUR-02','燁興企業股份有限公司',150,31000.00,'2026-05-26 13:10:00'),
('PUR-2026-008','PROD-SS-002','EMP-PUR-01','晉禾企業',400,32000.00,'2026-05-28 10:00:00'),
('PUR-2026-009','PROD-SS-005','EMP-PUR-02','大成不鏽鋼工業',600,58000.00,'2026-05-29 15:20:00'),
('PUR-2026-010','PROD-SS-007','EMP-PUR-01','官田鋼鐵',350,24500.00,'2026-06-01 09:45:00'),
('PUR-2026-011','PROD-SS-009','EMP-PUR-02','強新工業',500,61000.00,'2026-06-02 11:15:00'),
('PUR-2026-012','PROD-SS-010','EMP-PUR-01','華新麗華股份有限公司',250,19500.00,'2026-06-03 14:00:00'),
('PUR-2026-013','PROD-SS-012','EMP-PUR-02','燁興企業股份有限公司',450,41000.00,'2026-06-04 16:00:00'),
('PUR-2026-014','PROD-SS-013','EMP-PUR-01','東明不鏽鋼',300,21000.00,'2026-06-05 10:30:00'),
('PUR-2026-015','PROD-SS-015','EMP-PUR-02','大成不鏽鋼工業',700,78000.00,'2026-06-06 13:45:00');
/*!40000 ALTER TABLE `purchase_records` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sales_orders`
--

DROP TABLE IF EXISTS `sales_orders`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `sales_orders` (
  `order_id` varchar(20) NOT NULL,
  `customer_id` varchar(20) NOT NULL,
  `employee_id` varchar(20) NOT NULL,
  `order_date` datetime NOT NULL,
  `required_date` datetime NOT NULL,
  `order_status` enum('草稿','排產中','待出貨','已出貨') DEFAULT '草稿',
  PRIMARY KEY (`order_id`),
  KEY `customer_id` (`customer_id`),
  CONSTRAINT `1` FOREIGN KEY (`customer_id`) REFERENCES `customers` (`customer_id`),
  CONSTRAINT `chk_dates` CHECK (`order_date` <= `required_date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sales_orders`
--

LOCK TABLES `sales_orders` WRITE;
/*!40000 ALTER TABLE `sales_orders` DISABLE KEYS */;
INSERT INTO `sales_orders` VALUES
('ORD-2026-001','CUST-2026-001','EMP-SALES-01','2026-06-01 09:30:00','2026-07-15 17:00:00','排產中'),
('ORD-2026-002','CUST-2026-002','EMP-SALES-02','2026-06-01 14:15:22','2026-07-30 12:00:00','排產中'),
('ORD-2026-003','CUST-2026-003','EMP-SALES-01','2026-06-02 10:00:11','2026-06-25 18:00:00','待出貨'),
('ORD-2026-004','CUST-2026-004','EMP-SALES-03','2026-06-03 11:45:00','2026-08-05 17:00:00','排產中'),
('ORD-2026-005','CUST-2026-005','EMP-SALES-02','2026-06-04 16:20:35','2026-07-20 16:30:00','草稿'),
('ORD-2026-006','CUST-2026-006','EMP-SALES-01','2026-06-05 08:55:12','2026-06-20 12:00:00','已出貨'),
('ORD-2026-007','CUST-2026-007','EMP-SALES-03','2026-06-05 13:40:00','2026-07-10 17:00:00','排產中'),
('ORD-2026-008','CUST-2026-008','EMP-SALES-02','2026-06-06 10:10:00','2026-08-10 17:00:00','草稿'),
('ORD-2026-009','CUST-2026-009','EMP-SALES-01','2026-06-06 15:30:45','2026-07-05 12:00:00','待出貨'),
('ORD-2026-010','CUST-2026-010','EMP-SALES-03','2026-06-07 09:00:00','2026-06-30 18:00:00','排產中'),
('ORD-2026-011','CUST-2026-011','EMP-SALES-02','2026-06-07 11:22:19','2026-08-01 17:00:00','排產中'),
('ORD-2026-012','CUST-2026-012','EMP-SALES-01','2026-06-08 14:05:00','2026-07-25 17:00:00','草稿'),
('ORD-2026-013','CUST-2026-013','EMP-SALES-03','2026-06-08 16:50:33','2026-08-15 12:00:00','草稿'),
('ORD-2026-014','CUST-2026-014','EMP-SALES-01','2026-06-09 10:30:00','2026-06-28 17:00:00','排產中'),
('ORD-2026-015','CUST-2026-015','EMP-SALES-02','2026-06-09 13:15:00','2026-07-18 16:00:00','排產中');
/*!40000 ALTER TABLE `sales_orders` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Temporary table structure for view `view_factory_production`
--

DROP TABLE IF EXISTS `view_factory_production`;
/*!50001 DROP VIEW IF EXISTS `view_factory_production`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8mb4;
/*!50001 CREATE VIEW `view_factory_production` AS SELECT
 1 AS `order_id`,
  1 AS `product_id`,
  1 AS `material_grade`,
  1 AS `thread_size`,
  1 AS `head_type`,
  1 AS `quantity`,
  1 AS `packaging_type`,
  1 AS `production_status` */;
SET character_set_client = @saved_cs_client;

--
-- Temporary table structure for view `view_full_order_details`
--

DROP TABLE IF EXISTS `view_full_order_details`;
/*!50001 DROP VIEW IF EXISTS `view_full_order_details`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8mb4;
/*!50001 CREATE VIEW `view_full_order_details` AS SELECT
 1 AS `訂單編號`,
  1 AS `客戶名稱`,
  1 AS `下單時間`,
  1 AS `產品編號`,
  1 AS `產品規格`,
  1 AS `數量`,
  1 AS `單價`,
  1 AS `生產進度` */;
SET character_set_client = @saved_cs_client;

--
-- Temporary table structure for view `view_order_financial_summary`
--

DROP TABLE IF EXISTS `view_order_financial_summary`;
/*!50001 DROP VIEW IF EXISTS `view_order_financial_summary`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8mb4;
/*!50001 CREATE VIEW `view_order_financial_summary` AS SELECT
 1 AS `order_id`,
  1 AS `customer_name`,
  1 AS `order_status`,
  1 AS `total_order_amount` */;
SET character_set_client = @saved_cs_client;

--
-- Dumping routines for database 'nfu_database'
--

--
-- Final view structure for view `view_factory_production`
--

/*!50001 DROP VIEW IF EXISTS `view_factory_production`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_uca1400_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `view_factory_production` AS select `d`.`order_id` AS `order_id`,`p`.`product_id` AS `product_id`,`p`.`material_grade` AS `material_grade`,`p`.`thread_size` AS `thread_size`,`p`.`head_type` AS `head_type`,`d`.`quantity` AS `quantity`,`d`.`packaging_type` AS `packaging_type`,`d`.`production_status` AS `production_status` from (`order_details` `d` join `products` `p` on(`d`.`product_id` = `p`.`product_id`)) where `d`.`production_status` <> '已完成' */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `view_full_order_details`
--

/*!50001 DROP VIEW IF EXISTS `view_full_order_details`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_uca1400_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `view_full_order_details` AS select `o`.`order_id` AS `訂單編號`,`c`.`customer_name` AS `客戶名稱`,`o`.`order_date` AS `下單時間`,`p`.`product_id` AS `產品編號`,concat(`p`.`thread_system`,' ',`p`.`thread_size`,' ',`p`.`thread_pitch`) AS `產品規格`,`d`.`quantity` AS `數量`,`d`.`unit_price` AS `單價`,`d`.`production_status` AS `生產進度` from (((`sales_orders` `o` join `customers` `c` on(`o`.`customer_id` = `c`.`customer_id`)) join `order_details` `d` on(`o`.`order_id` = `d`.`order_id`)) join `products` `p` on(`d`.`product_id` = `p`.`product_id`)) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `view_order_financial_summary`
--

/*!50001 DROP VIEW IF EXISTS `view_order_financial_summary`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_uca1400_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `view_order_financial_summary` AS select `o`.`order_id` AS `order_id`,`c`.`customer_name` AS `customer_name`,`o`.`order_status` AS `order_status`,sum(`d`.`quantity` * `d`.`unit_price`) AS `total_order_amount` from ((`sales_orders` `o` join `customers` `c` on(`o`.`customer_id` = `c`.`customer_id`)) join `order_details` `d` on(`o`.`order_id` = `d`.`order_id`)) group by `o`.`order_id`,`c`.`customer_name`,`o`.`order_status` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*M!100616 SET NOTE_VERBOSITY=@OLD_NOTE_VERBOSITY */;

-- Dump completed on 2026-06-09 22:02:33
