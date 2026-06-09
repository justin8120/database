# Windows MySQL 匯入說明

本專案整理後的可匯入 SQL 檔案：

```powershell
C:\Users\justi\Desktop\NFU_Database\screw_order_system.sql
```

資料庫名稱：

```sql
screw_order_system
```

## 匯入前確認

原始檔 `資料庫系統SQL (1).sql` 有表格結構，但缺少 `CREATE DATABASE` / `USE`，而且目前讀取結果出現亂碼與部分 `ENUM` 字串引號不完整，可能無法直接匯入。

已整理版本 `screw_order_system.sql` 已包含：

- `CREATE DATABASE IF NOT EXISTS screw_order_system`
- `USE screw_order_system`
- 五張資料表：`Products`、`Customers`、`Sales_Orders`、`Order_Details`、`Raw_Material_Purchases`
- 每張資料表至少 10 筆 `INSERT INTO` 測試資料
- `PRIMARY KEY`
- `FOREIGN KEY`
- `CHECK`
- `ON DELETE CASCADE` / `ON DELETE RESTRICT`

## 方式 1：mysql 指令可用時

在 PowerShell 執行：

```powershell
mysql -u root -p < "C:\Users\justi\Desktop\NFU_Database\screw_order_system.sql"
```

輸入 root 密碼後等待匯入完成。

## 方式 2：mysql 指令不可用時

如果 PowerShell 顯示：

```text
mysql : 無法辨識 'mysql' 詞彙是否為 Cmdlet、函數、指令檔或可執行程式的名稱
```

代表 `mysql.exe` 沒有加入 PATH，請改用完整路徑：

```powershell
& "C:\Program Files\MySQL\MySQL Server 8.0\bin\mysql.exe" -u root -p < "C:\Users\justi\Desktop\NFU_Database\screw_order_system.sql"
```

如果你的 MySQL 安裝位置不同，先到 `C:\Program Files\MySQL\` 底下找實際版本資料夾，再替換上面的 `mysql.exe` 路徑。

## 方式 3：MySQL Workbench 匯入

1. 開啟 MySQL Workbench。
2. 連線 `localhost`。
3. 選擇 `File > Open SQL Script`。
4. 選擇 `C:\Users\justi\Desktop\NFU_Database\screw_order_system.sql`。
5. 按閃電圖示執行全部 SQL。
6. 用下方檢查 SQL 確認資料庫、資料表和筆數。

## 匯入後檢查 SQL

```sql
SHOW DATABASES;
USE screw_order_system;
SHOW TABLES;
DESC Products;
SELECT COUNT(*) FROM Products;
SELECT COUNT(*) FROM Customers;
SELECT COUNT(*) FROM Sales_Orders;
SELECT COUNT(*) FROM Order_Details;
SELECT COUNT(*) FROM Raw_Material_Purchases;
```

預期每個 `SELECT COUNT(*)` 都會回傳 `10`。

## /api/products 500 時先檢查 SQL 與連線

不要先改前端。先檢查：

1. 後端連線的資料庫名稱是否為 `screw_order_system`。
2. MySQL 裡是否存在 `Products` 表。
3. `Products` 欄位是否包含 `product_id`、`material_grade`、`thread_system`、`thread_size`、`thread_pitch`、`head_type`、`length_mm`、`unit`。
4. SQL 是否已匯入成功。
5. 後端環境變數或設定檔中的 `DB_NAME` 是否也是 `screw_order_system`。

可在 MySQL 裡執行：

```sql
USE screw_order_system;
SHOW TABLES;
DESC Products;
SELECT COUNT(*) FROM Products;
```
