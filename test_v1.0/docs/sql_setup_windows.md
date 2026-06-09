# Windows SQL Setup

目前若 PowerShell 顯示 `mysql` 無法辨識，代表本機尚未安裝 MySQL CLI，或 `mysql.exe` 沒有加入 PATH。

你目前執行：

```powershell
Get-ChildItem "C:\Program Files\MySQL" -Recurse -Filter mysql.exe -ErrorAction SilentlyContinue
```

沒有找到 `mysql.exe`，因此需要先安裝 MySQL Server 8.0，或使用 MySQL Workbench 匯入 SQL。

## 資料庫名稱

SQL 使用的資料庫名稱：

```sql
screw_order_system
```

整理後建議匯入的 SQL 檔：

```powershell
C:\Users\justi\Desktop\NFU_Database\screw_order_system.sql
```

此 SQL 已包含：

```sql
CREATE DATABASE IF NOT EXISTS screw_order_system
CHARACTER SET utf8mb4
COLLATE utf8mb4_unicode_ci;

USE screw_order_system;
```

## 方法 A：使用 MySQL Workbench

1. 安裝 MySQL Server 8.0 / MySQL Workbench。
2. 開啟 MySQL Workbench。
3. 建立或選擇 `localhost` 連線。
4. 選擇 `File > Open SQL Script`。
5. 選擇 SQL 檔，建議使用：

```powershell
C:\Users\justi\Desktop\NFU_Database\screw_order_system.sql
```

6. 按閃電圖示執行全部 SQL。
7. 執行檢查指令：

```sql
SHOW DATABASES;
USE screw_order_system;
SHOW TABLES;
SELECT COUNT(*) FROM Customers;
SELECT COUNT(*) FROM Products;
SELECT COUNT(*) FROM Sales_Orders;
SELECT COUNT(*) FROM Order_Details;
SELECT COUNT(*) FROM Raw_Material_Purchases;
```

預期每張表筆數都是 `10`。

## 方法 B：安裝 MySQL 後使用完整路徑

如果 `mysql.exe` 存在於：

```powershell
C:\Program Files\MySQL\MySQL Server 8.0\bin\mysql.exe
```

則 PowerShell 匯入指令為：

```powershell
& "C:\Program Files\MySQL\MySQL Server 8.0\bin\mysql.exe" -u root -p < "C:\Users\justi\Downloads\資料庫系統SQL (1).sql"
```

若要匯入目前已整理好的版本，請改用：

```powershell
& "C:\Program Files\MySQL\MySQL Server 8.0\bin\mysql.exe" -u root -p < "C:\Users\justi\Desktop\NFU_Database\screw_order_system.sql"
```

## /api/products 出現 500 時先檢查

不要先改前端。SQL 端需要先確認：

- MySQL Server 已安裝並啟動。
- 資料庫 `screw_order_system` 已建立。
- SQL 已成功匯入。
- `Products` 表存在。
- 後端 `DB_NAME` 跟 SQL 的資料庫名稱一致。

可執行：

```sql
USE screw_order_system;
SHOW TABLES;
DESC Products;
SELECT COUNT(*) FROM Products;
```

## Backend DB_NAME 檢查結果

目前在可搜尋到的 backend 候選檔案中，沒有找到 MySQL 連線設定、`DB_NAME`、`database.py`、`config.py` 或 `/api/products`。

已檢查到的候選檔案位於：

```powershell
C:\Users\justi\Desktop\project\backend\.env
C:\Users\justi\Desktop\project\backend\app\main.py
```

該 backend 看起來是 Smart Diet Recommendation API，沒有使用本 SQL 的五張資料表。因此目前 SQL 先以 `screw_order_system` 作為資料庫名稱；若之後找到真正的 NFU backend，請確認其 `DB_NAME` 也設定為 `screw_order_system`。

## 資料表

SQL 包含以下資料表：

- `Customers`
- `Products`
- `Sales_Orders`
- `Order_Details`
- `Raw_Material_Purchases`

每張表都已準備 10 筆測試資料。
