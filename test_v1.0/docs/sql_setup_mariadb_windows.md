# MariaDB Windows 匯入說明

目前你使用的是 MariaDB，不是 MySQL。若 PowerShell 找不到 `mysql.exe`，不代表 MariaDB 不能用；MariaDB 通常使用 `mariadb.exe`。

本專案建議匯入的 SQL：

```powershell
C:\Users\justi\Desktop\NFU_Database\資料庫系統SQL (1).sql
```

資料庫名稱：

```sql
screw_order_system
```

後端 `DB_NAME` 應設定為：

```text
screw_order_system
```

## MariaDB 語法相容性

SQL 使用的語法包含：

- `ENUM`
- `DECIMAL`
- `PRIMARY KEY`
- `FOREIGN KEY`
- `CHECK`
- `CREATE VIEW`

MariaDB 可接受以上語法。`CHECK` constraint 建議使用 MariaDB 10.2 以上；如果版本太舊，可能不支援或不會正確執行檢查。

## A. 找 MariaDB 執行檔

在 PowerShell 執行：

```powershell
Get-ChildItem "C:\Program Files\MariaDB" -Recurse -Filter mariadb.exe -ErrorAction SilentlyContinue
```

## B. 進入 MariaDB

如果找到 `mariadb.exe`，例如：

```powershell
C:\Program Files\MariaDB 11.4\bin\mariadb.exe
```

使用 PowerShell 進入 MariaDB：

```powershell
& "C:\Program Files\MariaDB 11.4\bin\mariadb.exe" -u root -p
```

## C. 匯入 SQL

使用你指定的 SQL 路徑：

```powershell
& "C:\Program Files\MariaDB 11.4\bin\mariadb.exe" -u root -p < "C:\Users\justi\Downloads\資料庫系統SQL (1).sql"
```

如果要匯入目前專案內已修正的 SQL：

```powershell
& "C:\Program Files\MariaDB 11.4\bin\mariadb.exe" -u root -p < "C:\Users\justi\Desktop\NFU_Database\資料庫系統SQL (1).sql"
```

## D. 匯入後檢查

進入 MariaDB 後執行：

```sql
SHOW DATABASES;
USE screw_order_system;
SHOW TABLES;

SELECT COUNT(*) FROM Customers;
SELECT COUNT(*) FROM Products;
SELECT COUNT(*) FROM Sales_Orders;
SELECT COUNT(*) FROM Order_Details;
SELECT COUNT(*) FROM Raw_Material_Purchases;

DESC Products;
SELECT * FROM Products LIMIT 10;
```

預期每張表的 `COUNT(*)` 都會是 `10`。

## /api/products 仍然 500 時

不要先改前端，優先檢查：

- MariaDB service 是否有啟動。
- `screw_order_system` 是否存在。
- `Products` 表是否存在。
- 後端 `DB_NAME` 是否等於 `screw_order_system`。
- 後端帳號密碼是否能登入 MariaDB。

可先在 MariaDB 執行：

```sql
USE screw_order_system;
SHOW TABLES;
DESC Products;
SELECT COUNT(*) FROM Products;
```

## Backend DB_NAME 檢查結果

目前可找到的 backend 候選檔案沒有 `DB_NAME`：

```powershell
C:\Users\justi\Desktop\project\backend\.env
C:\Users\justi\Desktop\project\backend\app\main.py
```

該候選 backend 看起來不是此訂單資料庫 API，且沒有 `/api/products`。如果之後找到真正的 NFU backend，請確認 `.env` 或設定檔中：

```text
DB_NAME=screw_order_system
```
