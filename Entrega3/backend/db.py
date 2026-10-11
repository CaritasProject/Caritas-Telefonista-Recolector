import pyodbc
from config import Config


def get_connection():

    required_values = [
        Config.SQLSERVER_HOST,
        Config.SQLSERVER_BASE,
        Config.SQLSERVER_USUARIO,
        Config.SQLSERVER_PASSWORD
    ]

    if not all(required_values):
        raise RuntimeError("Missing SQL Server configuration")
        
    connection_string = (
        f"DRIVER={{{Config.SQLSERVER_DRIVER}}};"
        f"SERVER={Config.SQLSERVER_HOST},{Config.SQLSERVER_PUERTO};"
        f"DATABASE={Config.SQLSERVER_BASE};"
        f"UID={Config.SQLSERVER_USUARIO};"
        f"PWD={Config.SQLSERVER_PASSWORD};"
        f"Encrypt=yes;"
        f"TrustServerCertificate={Config.SQLSERVER_TRUST_CERT};"
    )

    return pyodbc.connect(connection_string)
