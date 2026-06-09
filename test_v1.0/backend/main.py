from typing import Any

from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel

try:
    from database import close_connection, get_connection, ping_database
except ImportError:
    from .database import close_connection, get_connection, ping_database


app = FastAPI(title="NFU Database API")

app.add_middleware(
    CORSMiddleware,
    allow_origins=[
        "http://localhost:5173",
        "http://127.0.0.1:5173",
        "http://localhost:4173",
        "http://127.0.0.1:4173",
    ],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


class CustomerPayload(BaseModel):
    customer_id: str
    customer_name: str
    contact_person: str | None = None
    phone_number: str | None = None
    shipping_address: str
    credit_limit: float | None = None


class ProductPayload(BaseModel):
    product_id: str
    material_grade: str
    thread_system: str
    thread_size: str
    thread_pitch: str
    head_type: str | None = None
    length_mm: float
    unit: str


class PurchasePayload(BaseModel):
    purchase_id: str
    supplier_name: str
    product_id: str
    quantity: int
    total_amount: float
    purchase_time: str
    employee_id: str


def ok(data: Any = None, **extra: Any) -> dict[str, Any]:
    response: dict[str, Any] = {"status": "success"}
    if data is not None:
        response["data"] = data
        response["total"] = len(data) if isinstance(data, list) else 1
    response.update(extra)
    return response


def run_query(sql: str, params: tuple[Any, ...] = ()) -> list[dict[str, Any]]:
    connection = get_connection()
    try:
        cursor = connection.cursor(dictionary=True)
        cursor.execute(sql, params)
        return cursor.fetchall()
    except Exception as exc:
        raise HTTPException(status_code=500, detail=str(exc)) from exc
    finally:
        close_connection(connection)


def run_write(sql: str, params: tuple[Any, ...] = ()) -> None:
    connection = get_connection()
    try:
        cursor = connection.cursor()
        cursor.execute(sql, params)
        connection.commit()
    except Exception as exc:
        connection.rollback()
        raise HTTPException(status_code=500, detail=str(exc)) from exc
    finally:
        close_connection(connection)


@app.get("/")
def read_root() -> dict[str, str]:
    return {"message": "NFU Database API is running"}


@app.get("/api/health")
def health() -> dict[str, Any]:
    db = ping_database()
    return {
        "status": "ok" if db["connected"] else "error",
        "database": db,
    }


@app.get("/api/products")
def get_products() -> dict[str, Any]:
    rows = run_query("SELECT * FROM products ORDER BY product_id")
    return ok(rows)


@app.post("/api/products")
def create_product(product: ProductPayload) -> dict[str, Any]:
    run_write(
        """
        INSERT INTO products (
            product_id, material_grade, thread_system, thread_size,
            thread_pitch, head_type, length_mm, unit
        )
        VALUES (%s, %s, %s, %s, %s, %s, %s, %s)
        """,
        (
            product.product_id,
            product.material_grade,
            product.thread_system,
            product.thread_size,
            product.thread_pitch,
            product.head_type,
            product.length_mm,
            product.unit,
        ),
    )
    return ok(message="Product created")


@app.put("/api/products/{product_id}")
def update_product(product_id: str, product: ProductPayload) -> dict[str, Any]:
    run_write(
        """
        UPDATE products
        SET material_grade=%s, thread_system=%s, thread_size=%s,
            thread_pitch=%s, head_type=%s, length_mm=%s, unit=%s
        WHERE product_id=%s
        """,
        (
            product.material_grade,
            product.thread_system,
            product.thread_size,
            product.thread_pitch,
            product.head_type,
            product.length_mm,
            product.unit,
            product_id,
        ),
    )
    return ok(message="Product updated")


@app.delete("/api/products/{product_id}")
def delete_product(product_id: str) -> dict[str, Any]:
    run_write("DELETE FROM products WHERE product_id=%s", (product_id,))
    return ok(message="Product deleted")


@app.get("/api/customers")
def get_customers() -> dict[str, Any]:
    rows = run_query("SELECT * FROM customers ORDER BY customer_id")
    return ok(rows)


@app.post("/api/customers")
def create_customer(customer: CustomerPayload) -> dict[str, Any]:
    run_write(
        """
        INSERT INTO customers (
            customer_id, customer_name, contact_person, phone_number,
            shipping_address, credit_limit
        )
        VALUES (%s, %s, %s, %s, %s, %s)
        """,
        (
            customer.customer_id,
            customer.customer_name,
            customer.contact_person,
            customer.phone_number,
            customer.shipping_address,
            customer.credit_limit,
        ),
    )
    return ok(message="Customer created")


@app.put("/api/customers/{customer_id}")
def update_customer(customer_id: str, customer: CustomerPayload) -> dict[str, Any]:
    run_write(
        """
        UPDATE customers
        SET customer_name=%s, contact_person=%s, phone_number=%s,
            shipping_address=%s, credit_limit=%s
        WHERE customer_id=%s
        """,
        (
            customer.customer_name,
            customer.contact_person,
            customer.phone_number,
            customer.shipping_address,
            customer.credit_limit,
            customer_id,
        ),
    )
    return ok(message="Customer updated")


@app.delete("/api/customers/{customer_id}")
def delete_customer(customer_id: str) -> dict[str, Any]:
    run_write("DELETE FROM customers WHERE customer_id=%s", (customer_id,))
    return ok(message="Customer deleted")


@app.get("/api/orders")
def get_orders() -> dict[str, Any]:
    rows = run_query(
        """
        SELECT so.*, c.customer_name
        FROM sales_orders so
        JOIN customers c ON so.customer_id = c.customer_id
        ORDER BY so.order_date DESC, so.order_id
        """
    )
    return ok(rows)


@app.get("/api/orders/{order_id}/details")
def get_order_details(order_id: str) -> dict[str, Any]:
    rows = run_query(
        """
        SELECT od.*, p.material_grade, p.thread_system, p.thread_size,
               p.thread_pitch, p.head_type, p.length_mm, p.unit
        FROM order_details od
        JOIN products p ON od.product_id = p.product_id
        WHERE od.order_id = %s
        ORDER BY od.product_id
        """,
        (order_id,),
    )
    return ok(rows)


@app.get("/api/purchases")
def get_purchases() -> dict[str, Any]:
    rows = run_query(
        """
        SELECT rmp.*,
               CONCAT(p.material_grade, ' ', p.thread_system, ' ',
                      p.thread_size, 'x', p.length_mm, 'mm') AS product_spec,
               p.unit
        FROM raw_material_purchases rmp
        JOIN products p ON rmp.product_id = p.product_id
        ORDER BY rmp.purchase_time DESC, rmp.purchase_id
        """
    )
    return ok(rows)


@app.post("/api/purchases")
def create_purchase(purchase: PurchasePayload) -> dict[str, Any]:
    run_write(
        """
        INSERT INTO raw_material_purchases (
            purchase_id, supplier_name, product_id, quantity,
            total_amount, purchase_time, employee_id
        )
        VALUES (%s, %s, %s, %s, %s, %s, %s)
        """,
        (
            purchase.purchase_id,
            purchase.supplier_name,
            purchase.product_id,
            purchase.quantity,
            purchase.total_amount,
            purchase.purchase_time,
            purchase.employee_id,
        ),
    )
    return ok(message="Purchase created")


@app.put("/api/purchases/{purchase_id}")
def update_purchase(purchase_id: str, purchase: PurchasePayload) -> dict[str, Any]:
    run_write(
        """
        UPDATE raw_material_purchases
        SET supplier_name=%s, product_id=%s, quantity=%s,
            total_amount=%s, purchase_time=%s, employee_id=%s
        WHERE purchase_id=%s
        """,
        (
            purchase.supplier_name,
            purchase.product_id,
            purchase.quantity,
            purchase.total_amount,
            purchase.purchase_time,
            purchase.employee_id,
            purchase_id,
        ),
    )
    return ok(message="Purchase updated")


@app.delete("/api/purchases/{purchase_id}")
def delete_purchase(purchase_id: str) -> dict[str, Any]:
    run_write("DELETE FROM raw_material_purchases WHERE purchase_id=%s", (purchase_id,))
    return ok(message="Purchase deleted")


@app.get("/api/product-order-summary")
def get_product_order_summary() -> dict[str, Any]:
    rows = run_query("SELECT * FROM product_order_summary ORDER BY product_id")
    return ok(rows)


@app.get("/api/view/order-details")
def get_view_order_details() -> dict[str, Any]:
    rows = run_query(
        """
        SELECT so.order_id,
               c.customer_name,
               od.product_id,
               CONCAT(p.material_grade, ' ', p.thread_system, ' ',
                      p.thread_size, 'x', p.length_mm, 'mm') AS product_spec,
               od.quantity,
               od.unit_price,
               od.production_status
        FROM order_details od
        JOIN sales_orders so ON od.order_id = so.order_id
        JOIN customers c ON so.customer_id = c.customer_id
        JOIN products p ON od.product_id = p.product_id
        ORDER BY so.order_date DESC, so.order_id, od.product_id
        """
    )
    return ok(rows)
