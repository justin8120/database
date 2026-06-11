from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
import pymysql

app = FastAPI()

#===== 1. 解決 CORS 問題 (非常重要！) =====
#因為 Vue 預設跑在 localhost:5173，而 FastAPI 跑在 localhost:8000
#瀏覽器預設會阻擋不同 Port 之間的資料傳輸，所以必須設定允許名單。
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  #開發階段先允許所有來源，上線時再改為 ["http://localhost:5173"]
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

#===== 2. 資料庫連線設定 =====
#請將 user, password, db 替換成你本機 DBeaver 裡設定的資訊
def get_db_connection():
    return pymysql.connect(
        host='localhost',
        user='root',          #你的 MariaDB 帳號
        password='nfu', #你的 MariaDB 密碼
        db='NFU_database',    #你剛剛建好的資料庫名稱
        charset='utf8mb4',
        cursorclass=pymysql.cursors.DictCursor #讓撈出來的資料自動變成 Dictionary (JSON 格式)
    )

from pydantic import BaseModel
from typing import Optional

#定義前端傳送過來的客戶資料結構(Pydantic 資料驗證)
class CustomerCreate(BaseModel):
    customer_id: str
    customer_name: str
    contact_person: Optional[str] = None
    phone_number: Optional[str] = None
    shipping_address: str
    credit_limit: Optional[float] = None

#撰寫新增客戶的POST路由
@app.post("/api/customers")
def create_customer(customer: CustomerCreate):
    """將前端傳來的資料寫入 Customers 資料表"""
    connection = get_db_connection()
    try:
        with connection.cursor() as cursor:
            #檢查編號是否已經重複(防止Primary Key衝突)
            check_sql = "SELECT customer_id FROM Customers WHERE customer_id = %s"
            cursor.execute(check_sql, (customer.customer_id,))
            if cursor.fetchone():
                return {"status": "error", "message": f"客戶編號 '{customer.customer_id}' 已經存在！"}

            #執行INSERT INTO指令
            sql = """
                INSERT INTO Customers (customer_id, customer_name, contact_person, phone_number, shipping_address, credit_limit)
                VALUES (%s, %s, %s, %s, %s, %s)
            """
            cursor.execute(sql, (
                customer.customer_id,
                customer.customer_name,
                customer.contact_person,
                customer.phone_number,
                customer.shipping_address,
                customer.credit_limit
            ))
            
            #涉及資料變更(INSERT/UPDATE/DELETE)必須執行commit
            connection.commit()
            
            return {"status": "success", "message": "客戶資料新增成功！"}
            
    except Exception as e:
        #發生錯誤時反轉操作
        connection.rollback()
        return {"status": "error", "message": str(e)}
    finally:
        connection.close()

#定義產品資料結構Pydantic 資料驗證
class ProductCreate(BaseModel):
    product_id: str
    material_grade: str
    thread_system: str
    thread_size: str
    thread_pitch: str
    head_type: Optional[str] = None
    length_mm: float
    unit: str

#撰寫新增產品的POST路由
@app.post("/api/products")
def create_product(product: ProductCreate):
    """將前端傳來的資料寫入 Products 資料表"""
    connection = get_db_connection()
    try:
        with connection.cursor() as cursor:
            #檢查產品編號是否已經重複
            check_sql = "SELECT product_id FROM Products WHERE product_id = %s"
            cursor.execute(check_sql, (product.product_id,))
            if cursor.fetchone():
                return {"status": "error", "message": f"產品編號 '{product.product_id}' 已經存在！"}

            #執行INSERT INTO指令
            sql = """
                INSERT INTO Products (product_id, material_grade, thread_system, thread_size, thread_pitch, head_type, length_mm, unit)
                VALUES (%s, %s, %s, %s, %s, %s, %s, %s)
            """
            cursor.execute(sql, (
                product.product_id,
                product.material_grade,
                product.thread_system,
                product.thread_size,
                product.thread_pitch,
                product.head_type,
                product.length_mm,
                product.unit
            ))
            
            #寫入資料庫一定要commit
            connection.commit()
            
            return {"status": "success", "message": "產品規格新增成功！"}
            
    except Exception as e:
        connection.rollback()
        return {"status": "error", "message": str(e)}
    finally:
        connection.close()

#API路由
@app.get("/api/products")
def get_products():
    #建立連線
    connection = get_db_connection()
    try:
        with connection.cursor() as cursor:
            sql = "SELECT * FROM Products"
            cursor.execute(sql)
            result = cursor.fetchall()

            return {"status": "success", "data": result}
    finally:
        connection.close()

#測試用路由
@app.get("/")
def read_root():
    return {"message": "進銷存系統 API 伺服器已啟動！"}

@app.get("/api/view/order-details")
def get_full_order_details():
    """
    撈取資料庫中已經做好的 View_Full_Order_Details 檢視表
    """
    connection = get_db_connection()
    try:
        with connection.cursor() as cursor:
            sql = "SELECT * FROM View_Full_Order_Details"
            cursor.execute(sql)
            result = cursor.fetchall()
            
            return {
                "status": "success",
                "total": len(result),
                "data": result
            }
    except Exception as e:
        return {"status": "error", "message": str(e)}
    finally:
        connection.close()

@app.get("/api/products")
def get_products():
    """撈取所有產品規格資料"""
    connection = get_db_connection()
    try:
        with connection.cursor() as cursor:
            sql = "SELECT * FROM Products"
            cursor.execute(sql)
            result = cursor.fetchall()
            return {"status": "success", "data": result}
    except Exception as e:
        return {"status": "error", "message": str(e)}
    finally:
        connection.close()

# --- 3. 撰寫編輯產品的 PUT 路由 ---
@app.put("/api/products/{product_id}")
def update_product(product_id: str, product: ProductCreate):
    """更新指定的產品資料"""
    connection = get_db_connection()
    try:
        with connection.cursor() as cursor:
            sql = """
                UPDATE Products 
                SET material_grade=%s, thread_system=%s, thread_size=%s, 
                    thread_pitch=%s, head_type=%s, length_mm=%s, unit=%s
                WHERE product_id=%s
            """
            cursor.execute(sql, (
                product.material_grade,
                product.thread_system,
                product.thread_size,
                product.thread_pitch,
                product.head_type,
                product.length_mm,
                product.unit,
                product_id # 條件：根據網址傳來的 ID 更新
            ))
            connection.commit()
            return {"status": "success", "message": "產品規格更新成功！"}
    except Exception as e:
        connection.rollback()
        return {"status": "error", "message": str(e)}
    finally:
        connection.close()

#刪除產品的DELETE路由
@app.delete("/api/products/{product_id}")
def delete_product(product_id: str):
    """刪除指定的產品資料"""
    connection = get_db_connection()
    try:
        with connection.cursor() as cursor:
            sql = "DELETE FROM Products WHERE product_id = %s"
            cursor.execute(sql, (product_id,))
            connection.commit()
            return {"status": "success", "message": "產品規格已刪除！"}
    except Exception as e:
        connection.rollback()
        error_msg = str(e)
        # 捕捉 Foreign Key 限制錯誤 (1451)
        if "1451" in error_msg:
            return {"status": "error", "message": "無法刪除！此產品已有進貨或訂單紀錄。"}
        return {"status": "error", "message": error_msg}
    finally:
        connection.close()

@app.get("/api/customers")
def get_customers():
    """撈取所有客戶資料"""
    connection = get_db_connection()
    try:
        with connection.cursor() as cursor:
            sql = "SELECT * FROM Customers"
            cursor.execute(sql)
            result = cursor.fetchall()
            return {"status": "success", "data": result}
    except Exception as e:
        return {"status": "error", "message": str(e)}
    finally:
        connection.close()

@app.get("/api/purchases")
def get_purchases():
    """撈取進貨紀錄，並 JOIN 產品規格讓資料更具可讀性"""
    connection = get_db_connection()
    try:
        with connection.cursor() as cursor:
            #這裡使用JOIN，並將進貨時間由最新到最舊排序
            sql = """
                SELECT 
                    pr.purchase_id,
                    pr.purchase_time,
                    pr.supplier_name,
                    pr.product_id,
                    CONCAT(p.material_grade, ' ', p.thread_system, ' ', p.thread_size, ' ', 'x', ' ', p.length_mm, 'mm') AS product_spec,
                    pr.quantity,
                    p.unit,
                    pr.total_amount,
                    pr.employee_id
                FROM Purchase_Records pr
                JOIN Products p ON pr.product_id = p.product_id
                ORDER BY pr.purchase_time DESC
            """
            cursor.execute(sql)
            result = cursor.fetchall()
            return {"status": "success", "data": result}
    except Exception as e:
        return {"status": "error", "message": str(e)}
    finally:
        connection.close()

#撰寫編輯客戶的PUT路由
@app.put("/api/customers/{customer_id}")
def update_customer(customer_id: str, customer: CustomerCreate):
    """更新指定的客戶資料"""
    connection = get_db_connection()
    try:
        with connection.cursor() as cursor:
            sql = """
                UPDATE Customers 
                SET customer_name=%s, contact_person=%s, phone_number=%s, 
                    shipping_address=%s, credit_limit=%s
                WHERE customer_id=%s
            """
            cursor.execute(sql, (
                customer.customer_name,
                customer.contact_person,
                customer.phone_number,
                customer.shipping_address,
                customer.credit_limit,
                customer_id # 條件：根據網址傳來的 ID 更新
            ))
            connection.commit()
            return {"status": "success", "message": "客戶資料更新成功！"}
    except Exception as e:
        connection.rollback()
        return {"status": "error", "message": str(e)}
    finally:
        connection.close()

#撰寫刪除客戶的DELETE路由
@app.delete("/api/customers/{customer_id}")
def delete_customer(customer_id: str):
    """刪除指定的客戶資料"""
    connection = get_db_connection()
    try:
        with connection.cursor() as cursor:
            sql = "DELETE FROM Customers WHERE customer_id = %s"
            cursor.execute(sql, (customer_id,))
            connection.commit()
            return {"status": "success", "message": "客戶資料已刪除！"}
    except Exception as e:
        connection.rollback()
        error_msg = str(e)
        # 捕捉 Foreign Key 限制錯誤 (1451)
        if "1451" in error_msg:
            return {"status": "error", "message": "無法刪除！此客戶已經有歷史訂單紀錄。"}
        return {"status": "error", "message": error_msg}
    finally:
        connection.close()

from datetime import datetime

# --- 1. 定義進貨紀錄資料結構 ---
class PurchaseCreate(BaseModel):
    purchase_id: str
    product_id: str
    employee_id: str
    supplier_name: str
    quantity: int
    total_amount: float
    purchase_time: datetime

# --- 2. 新增進貨紀錄 (POST) ---
@app.post("/api/purchases")
def create_purchase(purchase: PurchaseCreate):
    connection = get_db_connection()
    try:
        with connection.cursor() as cursor:
            # 檢查單號是否重複
            check_sql = "SELECT purchase_id FROM Purchase_Records WHERE purchase_id = %s"
            cursor.execute(check_sql, (purchase.purchase_id,))
            if cursor.fetchone():
                return {"status": "error", "message": f"進貨單號 '{purchase.purchase_id}' 已經存在！"}

            sql_insert = """
                INSERT INTO Purchase_Records (purchase_id, product_id, employee_id, supplier_name, quantity, total_amount, purchase_time)
                VALUES (%s, %s, %s, %s, %s, %s, %s)
            """
            cursor.execute(sql_insert, (purchase.purchase_id, purchase.product_id, purchase.employee_id, purchase.supplier_name, purchase.quantity, purchase.total_amount, purchase.purchase_time))

            # 💡 3. 連動更新庫存：將該產品的 stock 加上進貨數量
            sql_update_stock = """
                UPDATE Products 
                SET stock = stock + %s 
                WHERE product_id = %s
            """
            cursor.execute(sql_update_stock, (purchase.quantity, purchase.product_id))

            # 確保兩個動作都成功才 Commit
            connection.commit()
            return {"status": "success", "message": "進貨登記成功，庫存已同步同步增加！"}
    except Exception as e:
        connection.rollback()
        return {"status": "error", "message": str(e)}
    finally:
        connection.close()

# --- 3. 編輯進貨紀錄 (PUT) ---
@app.put("/api/purchases/{purchase_id}")
def update_purchase(purchase_id: str, purchase: PurchaseCreate):
    connection = get_db_connection()
    try:
        with connection.cursor() as cursor:
            # 取得舊的進貨紀錄
            cursor.execute("SELECT product_id, quantity FROM Purchase_Records WHERE purchase_id = %s", (purchase_id,))
            old_record = cursor.fetchone()
            if not old_record:
                return {"status": "error", "message": "找不到該筆進貨紀錄"}
            
            # 扣除舊的庫存 (等於撤銷先前的進貨)
            cursor.execute("UPDATE Products SET stock = stock - %s WHERE product_id = %s", (old_record['quantity'], old_record['product_id']))

            sql = """
                UPDATE Purchase_Records 
                SET product_id=%s, employee_id=%s, supplier_name=%s, 
                    quantity=%s, total_amount=%s, purchase_time=%s
                WHERE purchase_id=%s
            """
            cursor.execute(sql, (
                purchase.product_id, purchase.employee_id, purchase.supplier_name, 
                purchase.quantity, purchase.total_amount, purchase.purchase_time, purchase_id
            ))

            # 加上新的進貨庫存
            cursor.execute("UPDATE Products SET stock = stock + %s WHERE product_id = %s", (purchase.quantity, purchase.product_id))

            connection.commit()
            return {"status": "success", "message": "進貨紀錄更新成功！"}
    except Exception as e:
        connection.rollback()
        return {"status": "error", "message": str(e)}
    finally:
        connection.close()

# --- 4. 刪除進貨紀錄 (DELETE) ---
@app.delete("/api/purchases/{purchase_id}")
def delete_purchase(purchase_id: str):
    connection = get_db_connection()
    try:
        with connection.cursor() as cursor:
            # 取得即將刪除的進貨紀錄，以便扣除庫存
            cursor.execute("SELECT product_id, quantity FROM Purchase_Records WHERE purchase_id = %s", (purchase_id,))
            old_record = cursor.fetchone()
            if old_record:
                cursor.execute("UPDATE Products SET stock = stock - %s WHERE product_id = %s", (old_record['quantity'], old_record['product_id']))

            sql = "DELETE FROM Purchase_Records WHERE purchase_id = %s"
            cursor.execute(sql, (purchase_id,))
            connection.commit()
            return {"status": "success", "message": "進貨紀錄已刪除！"}
    except Exception as e:
        connection.rollback()
        return {"status": "error", "message": str(e)}
    finally:
        connection.close()

from typing import List

# --- 1. 定義訂單明細結構 ---
class OrderDetailCreate(BaseModel):
    product_id: str
    quantity: int
    unit_price: float
    packaging_type: str = "一箱"

# --- 2. 定義訂單主檔結構（包含明細陣列） ---
class SalesOrderCreate(BaseModel):
    order_id: str
    customer_id: str
    employee_id: str
    order_date: datetime
    required_date: datetime
    details: List[OrderDetailCreate] # 💡 關鍵：允許包進多筆產品明細

# --- 3. 撰寫新增訂單的 POST 路由 ---
@app.post("/api/orders")
def create_sales_order(order: SalesOrderCreate):
    """同步寫入訂單總檔與明細表，落實資料庫 Transaction 機制"""
    connection = get_db_connection()
    try:
        with connection.cursor() as cursor:
            # A. 檢查訂單編號是否已存在
            check_sql = "SELECT order_id FROM Sales_Orders WHERE order_id = %s"
            cursor.execute(check_sql, (order.order_id,))
            if cursor.fetchone():
                return {"status": "error", "message": f"訂單單號 '{order.order_id}' 已經存在！"}

            for detail in order.details:
                cursor.execute("SELECT stock FROM Products WHERE product_id = %s", (detail.product_id,))
                prod = cursor.fetchone()
                if not prod:
                    return {"status": "error", "message": f"產品 {detail.product_id} 不存在"}
                
                if prod['stock'] < detail.quantity:
                    # 庫存不足，直接中斷回傳錯誤，不寫入任何資料！
                    return {"status": "error", "message": f"商品 {detail.product_id} 庫存不足！目前庫存: {prod['stock']}，需求: {detail.quantity}"}
            
            # B. 寫入銷售訂單總檔（預設狀態為草稿）
            order_sql = """
                INSERT INTO Sales_Orders (order_id, customer_id, employee_id, order_date, required_date, order_status)
                VALUES (%s, %s, %s, %s, %s, '草稿')
            """
            cursor.execute(order_sql, (
                order.order_id, order.customer_id, order.employee_id, 
                order.order_date, order.required_date
            ))

            # C. 迴圈寫入該訂單旗下的所有明細（預設生產狀態為待進料）
            detail_sql = """
                INSERT INTO Order_Details (order_id, product_id, quantity, unit_price, packaging_type, production_status)
                VALUES (%s, %s, %s, %s, %s, '待進料')
            """
            update_stock_sql = "UPDATE Products SET stock = stock - %s WHERE product_id = %s" # 扣庫存

            for detail in order.details:
                # 寫入明細
                cursor.execute(detail_sql, (order.order_id, detail.product_id, detail.quantity, detail.unit_price, detail.packaging_type))
                # 扣除庫存
                cursor.execute(update_stock_sql, (detail.quantity, detail.product_id))

            connection.commit()
            return {"status": "success", "message": "訂單建立成功！"}
    except Exception as e:
        connection.rollback()
        return {"status": "error", "message": str(e)}
    finally:
        connection.close()

# --- 4. 取得單筆訂單的完整資料 (GET) ---
@app.get("/api/orders/{order_id}")
def get_order(order_id: str):
    """回傳包含主檔與明細陣列的完整訂單資料，供前端編輯使用"""
    connection = get_db_connection()
    try:
        with connection.cursor() as cursor:
            # 先撈主檔
            cursor.execute("SELECT * FROM Sales_Orders WHERE order_id = %s", (order_id,))
            order = cursor.fetchone()
            if not order:
                return {"status": "error", "message": "找不到此訂單"}
            
            # 再撈明細
            cursor.execute("SELECT * FROM Order_Details WHERE order_id = %s", (order_id,))
            details = cursor.fetchall()
            
            # 將明細塞入主檔字典中一併回傳
            order['details'] = details
            return {"status": "success", "data": order}
    except Exception as e:
        return {"status": "error", "message": str(e)}
    finally:
        connection.close()

# --- 5. 編輯訂單 (PUT) ---
@app.put("/api/orders/{order_id}")
def update_sales_order(order_id: str, order: SalesOrderCreate):
    """更新訂單：採用更新主檔，並「洗掉舊明細、寫入新明細」的安全作法"""
    connection = get_db_connection()
    try:
        with connection.cursor() as cursor:
            # 0. 把舊明細的庫存先加回來
            cursor.execute("SELECT product_id, quantity FROM Order_Details WHERE order_id = %s", (order_id,))
            old_details = cursor.fetchall()
            for old_detail in old_details:
                cursor.execute("UPDATE Products SET stock = stock + %s WHERE product_id = %s", (old_detail['quantity'], old_detail['product_id']))

            # 1. 更新主檔
            update_sql = """
                UPDATE Sales_Orders 
                SET customer_id=%s, employee_id=%s, order_date=%s, required_date=%s
                WHERE order_id=%s
            """
            cursor.execute(update_sql, (
                order.customer_id, order.employee_id, order.order_date, 
                order.required_date, order_id
            ))

            # 2. 刪除該訂單原有的所有明細
            cursor.execute("DELETE FROM Order_Details WHERE order_id = %s", (order_id,))

            # 3. 檢查新明細的庫存，並扣除庫存
            for detail in order.details:
                cursor.execute("SELECT stock FROM Products WHERE product_id = %s", (detail.product_id,))
                prod = cursor.fetchone()
                if not prod:
                    raise Exception(f"產品 {detail.product_id} 不存在")
                if prod['stock'] < detail.quantity:
                    raise Exception(f"商品 {detail.product_id} 庫存不足！目前庫存: {prod['stock']}，需求: {detail.quantity}")

            # 4. 重新寫入前端傳來的新明細陣列
            detail_sql = """
                INSERT INTO Order_Details (order_id, product_id, quantity, unit_price, packaging_type, production_status)
                VALUES (%s, %s, %s, %s, %s, '待進料')
            """
            for detail in order.details:
                cursor.execute(detail_sql, (
                    order_id, detail.product_id, detail.quantity, 
                    detail.unit_price, detail.packaging_type
                ))
                cursor.execute("UPDATE Products SET stock = stock - %s WHERE product_id = %s", (detail.quantity, detail.product_id))

            connection.commit()
            return {"status": "success", "message": "訂單更新成功！"}

    except Exception as e:
        connection.rollback()
        return {"status": "error", "message": str(e)}
    finally:
        connection.close()

# --- 6. 刪除訂單 (DELETE) ---
@app.delete("/api/orders/{order_id}")
def delete_sales_order(order_id: str):
    """透過 ON DELETE CASCADE，刪除主檔時資料庫會自動清空明細"""
    connection = get_db_connection()
    try:
        with connection.cursor() as cursor:
            # 取得即將被刪除的訂單明細，以便把庫存加回去
            cursor.execute("SELECT product_id, quantity FROM Order_Details WHERE order_id = %s", (order_id,))
            old_details = cursor.fetchall()
            for old_detail in old_details:
                cursor.execute("UPDATE Products SET stock = stock + %s WHERE product_id = %s", (old_detail['quantity'], old_detail['product_id']))

            cursor.execute("DELETE FROM Sales_Orders WHERE order_id = %s", (order_id,))
            connection.commit()
            return {"status": "success", "message": "訂單已徹底刪除！"}
    except Exception as e:
        connection.rollback()
        return {"status": "error", "message": str(e)}
    finally:
        connection.close()

# --- 7. 工廠端視角 (GET) ---
@app.get("/api/view/factory-production")
def get_factory_production():
    """撈取工廠生產檢視表資料"""
    connection = get_db_connection()
    try:
        with connection.cursor() as cursor:
            sql = "SELECT * FROM view_factory_production"
            cursor.execute(sql)
            result = cursor.fetchall()
            return {"status": "success", "data": result}
    except Exception as e:
        return {"status": "error", "message": str(e)}
    finally:
        connection.close()

# --- 8. 會計端視角 (GET) ---
@app.get("/api/view/order-financial-summary")
def get_order_financial_summary():
    """撈取財務檢視表資料"""
    connection = get_db_connection()
    try:
        with connection.cursor() as cursor:
            sql = "SELECT * FROM view_order_financial_summary"
            cursor.execute(sql)
            result = cursor.fetchall()
            return {"status": "success", "data": result}
    except Exception as e:
        return {"status": "error", "message": str(e)}
    finally:
        connection.close()

class ProductionStatusUpdate(BaseModel):
    production_status: str

# --- 9. 更新生產進度 (PUT) ---
@app.put("/api/orders/{order_id}/details/{product_id}/production-status")
def update_production_status(order_id: str, product_id: str, status_update: ProductionStatusUpdate):
    """更新訂單明細的生產進度"""
    connection = get_db_connection()
    try:
        with connection.cursor() as cursor:
            sql = """
                UPDATE Order_Details 
                SET production_status = %s 
                WHERE order_id = %s AND product_id = %s
            """
            cursor.execute(sql, (status_update.production_status, order_id, product_id))
            connection.commit()
            return {"status": "success", "message": "生產進度已更新！"}
    except Exception as e:
        connection.rollback()
        return {"status": "error", "message": str(e)}
    finally:
        connection.close()