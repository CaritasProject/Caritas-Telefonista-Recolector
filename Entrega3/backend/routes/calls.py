from flask import Blueprint, jsonify, request
from db import get_connection
from services.call_service import register_call

calls_bp = Blueprint("calls", __name__)


@calls_bp.get("/llamadas/form-options")
def get_form_options():
    conn = get_connection()
    cursor = conn.cursor()

    try:
        cursor.execute("""
            SELECT ID_FORMA_PAGO, NOMBRE
            FROM dbo.CAT_FORMA_PAGO
            ORDER BY ID_FORMA_PAGO
        """)
        payment_methods = [
            {
                "id": row[0],
                "nombre": row[1]
            }
            for row in cursor.fetchall()
        ]

        cursor.execute("""
            SELECT ID_FRECUENCIA, NOMBRE
            FROM dbo.CAT_FRECUENCIA
            ORDER BY ID_FRECUENCIA
        """)
        frequencies = [
            {
                "id": row[0],
                "nombre": row[1]
            }
            for row in cursor.fetchall()
        ]

        cursor.execute("""
            SELECT ID_TIPO_FRECUENCIA, NOMBRE
            FROM dbo.CAT_TIPO_FRECUENCIA
            ORDER BY ID_TIPO_FRECUENCIA
        """)
        frequency_types = [
            {
                "id": row[0],
                "nombre": row[1]
            }
            for row in cursor.fetchall()
        ]

        return jsonify({
            "formas_pago": payment_methods,
            "frecuencias": frequencies,
            "tipos_frecuencia": frequency_types
        }), 200

    finally:
        cursor.close()
        conn.close()

@calls_bp.post("/donantes/<int:donor_id>/llamadas")
def create_call(donor_id):
    data = request.get_json()

    if not data:
        return jsonify({
            "error": "El cuerpo de la solicitud es requerido"
        }), 400

    try:
        result = register_call(
            donor_id=donor_id,
            data=data
        )

        return jsonify(result), 201

    except ValueError as error:
        return jsonify({
            "error": str(error)
        }), 400
