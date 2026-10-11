import os
from pathlib import Path


def load_environment_file():
    environment_path = Path(__file__).resolve().parent / ".env"

    if not environment_path.exists():
        return

    for raw_line in environment_path.read_text(encoding="utf-8").splitlines():
        line = raw_line.strip()

        if not line or line.startswith("#") or "=" not in line:
            continue

        key, value = line.removeprefix("export ").split("=", 1)
        key = key.strip()
        value = value.strip()

        if len(value) >= 2 and value[0] == value[-1] and value[0] in {"'", '"'}:
            value = value[1:-1]

        os.environ.setdefault(key, value)


load_environment_file()


class Config:
    SQLSERVER_HOST = os.getenv("SQLSERVER_HOST")
    SQLSERVER_PUERTO = os.getenv("SQLSERVER_PUERTO", "1433")
    SQLSERVER_BASE = os.getenv("SQLSERVER_BASE")
    SQLSERVER_USUARIO = os.getenv("SQLSERVER_USUARIO")
    SQLSERVER_PASSWORD = os.getenv("SQLSERVER_PASSWORD")

    SQLSERVER_DRIVER = os.getenv(
        "SQLSERVER_DRIVER",
        "ODBC Driver 18 for SQL Server"
    )

    SQLSERVER_TRUST_CERT = os.getenv(
        "SQLSERVER_TRUST_CERT",
        "yes"
    )
