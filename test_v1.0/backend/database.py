import os
from pathlib import Path
from typing import Any

import mariadb
from dotenv import load_dotenv


load_dotenv(Path(__file__).with_name(".env"))


def get_db_config() -> dict[str, Any]:
    return {
        "host": os.getenv("DB_HOST", "localhost"),
        "port": int(os.getenv("DB_PORT", "3306")),
        "user": os.getenv("DB_USER", "root"),
        "password": os.getenv("DB_PASSWORD", ""),
        "database": os.getenv("DB_NAME", "screw_order_system"),
    }


def get_connection() -> mariadb.Connection:
    return mariadb.connect(**get_db_config())


def close_connection(connection: mariadb.Connection | None) -> None:
    if connection:
        connection.close()


def ping_database() -> dict[str, Any]:
    config = get_db_config()
    try:
        connection = get_connection()
        try:
            cursor = connection.cursor(dictionary=True)
            cursor.execute("SELECT DATABASE() AS db_name, VERSION() AS version")
            row = cursor.fetchone()
            return {
                "connected": True,
                "host": config["host"],
                "port": config["port"],
                "db_name": row["db_name"],
                "version": row["version"],
            }
        finally:
            close_connection(connection)
    except Exception as exc:
        return {
            "connected": False,
            "host": config["host"],
            "port": config["port"],
            "db_name": config["database"],
            "error": str(exc),
        }
