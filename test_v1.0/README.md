# NFU_Database

## 專案說明

本專案為「資料庫系統 Final Project Part III」的實作版本，主題為：

**傳統螺絲產業少量多樣化不鏽鋼扣件訂單管理系統**

本版本主要完成前端、FastAPI 後端與 MariaDB 資料庫的初步對接整理。
本次沒有重做 UI，只修正影響編譯、API 呼叫與資料庫連線的部分，使系統能夠正常編譯，並具備呼叫後端 API 的基本能力。

---

## 系統架構

```text
Vue 3 / Vite 前端
        ↓
FastAPI 後端 API
        ↓
MariaDB 資料庫
```

---

## 使用技術

### 前端

* Vue 3
* Vite
* JavaScript
* npm

### 後端

* Python
* FastAPI
* Uvicorn
* MariaDB Connector

### 資料庫

* MariaDB 12.3
* SQL Schema
* View

---

## 開發環境建議

建議使用：

* Visual Studio Code
* Vue Official 擴充套件

如果有安裝 Vetur，建議停用，避免與 Vue Official 擴充套件衝突。

---

## 資料庫說明

### 資料庫系統

```text
MariaDB 12.3
```

### 資料庫名稱

```text
screw_order_system
```

### 主要資料表

```text
customers
products
sales_orders
order_details
raw_material_purchases
```

### View

```text
product_order_summary
```

目前每張主要資料表皆已匯入至少 10 筆資料。

---

## 已建立 API

後端已建立以下 API：

```text
GET /api/health
GET /api/products
GET /api/customers
GET /api/orders
GET /api/orders/{order_id}/details
GET /api/purchases
GET /api/product-order-summary
```

---

## 更新內容

### 1. 後端更新

修改檔案：

```text
backend/main.py
backend/database.py
backend/.env.example
backend/requirements.txt
```

更新內容：

* 重建 FastAPI API。
* 使用 MariaDB 實際資料表名稱。
* 統一查詢小寫表名：

  * `products`
  * `customers`
  * `sales_orders`
  * `order_details`
  * `raw_material_purchases`
  * `product_order_summary`
* 新增 MariaDB 連線設定。
* 透過 `backend/.env` 讀取資料庫連線資訊。
* 改用官方 MariaDB Connector。

---

### 2. 前端更新

修改檔案：

```text
src/App.vue
src/components 或資料頁元件
.env.example
```

更新內容：

* 修復原本亂碼造成的 Vue 語法錯誤。
* 保留原本 UI，沒有重做畫面。
* API base URL 改為讀取環境變數。

前端環境變數範例：

```env
VITE_API_BASE_URL=http://127.0.0.1:8000
```

---

### 3. Git 忽略設定

修改檔案：

```text
.gitignore
```

加入：

```gitignore
node_modules/
.env
backend/.env
__pycache__/
*.pyc
dist/
```

目的：

* 避免上傳 `node_modules`
* 避免上傳本機 MariaDB 密碼
* 避免上傳 Python 暫存檔
* 避免上傳前端 build 產物

---

## 專案安裝與啟動

### 1. 安裝前端套件

```sh
npm install
```

---

### 2. 啟動前端開發伺服器

```sh
npm run dev
```

前端預設網址通常為：

```text
http://localhost:5173
```

---

### 3. 建置前端專案

```sh
npm run build
```

---

## 後端設定與啟動

### 1. 建立後端環境變數

請在 `backend/.env` 建立本機設定：

```env
DB_HOST=localhost
DB_PORT=3306
DB_USER=root
DB_PASSWORD=你的MariaDB密碼
DB_NAME=screw_order_system
```

注意：
`backend/.env` 只放在本機，不應上傳到 GitHub。

---

### 2. 安裝後端套件

```sh
cd backend
pip install -r requirements.txt
```

---

### 3. 啟動後端

```sh
cd backend
python -m uvicorn main:app --reload
```

後端預設網址：

```text
http://127.0.0.1:8000
```

---

### 4. 測試後端 API

```text
http://127.0.0.1:8000/api/health
http://127.0.0.1:8000/api/products
http://127.0.0.1:8000/api/customers
http://127.0.0.1:8000/api/orders
http://127.0.0.1:8000/api/purchases
http://127.0.0.1:8000/api/product-order-summary
```

---

## SQL 匯入狀態

MariaDB 已成功匯入：

```text
screw_order_system
```

資料表筆數：

```text
customers                  10
products                   10
sales_orders               10
order_details              10
raw_material_purchases     10
```

檢查 SQL：

```sql
USE screw_order_system;

SHOW TABLES;

SELECT 'customers' AS table_name, COUNT(*) AS total FROM customers
UNION ALL
SELECT 'products', COUNT(*) FROM products
UNION ALL
SELECT 'sales_orders', COUNT(*) FROM sales_orders
UNION ALL
SELECT 'order_details', COUNT(*) FROM order_details
UNION ALL
SELECT 'raw_material_purchases', COUNT(*) FROM raw_material_purchases;
```

---

## 測試結果

已完成測試：

```sh
python -m py_compile backend\main.py backend\database.py
npm run build
```

測試結果：

```text
Python 後端語法檢查通過
前端 npm run build 通過
MariaDB Connector 可正常載入
```

目前注意事項：

```text
/api/health 可執行。
若回傳 MariaDB Access denied，代表 backend/.env 的 DB_PASSWORD 尚未改成本機 MariaDB 真實密碼。
```

---

## 尚待處理

* 將 `backend/.env` 中的 `DB_PASSWORD` 改成本機 MariaDB 真實密碼。
* 啟動後端後確認 `/api/products` 是否能回傳資料。
* 啟動前端後確認頁面是否能正常顯示 API 資料。

---

## 版本紀錄

### test_v1.0

本版本完成：

* MariaDB 資料庫匯入
* FastAPI 後端 API 建立
* Vue 前端 API 呼叫整理
* `.env.example` 與 `.gitignore` 整理
* 前端 build 測試通過
* 後端 Python 語法檢查通過
