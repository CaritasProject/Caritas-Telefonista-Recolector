from flask import Blueprint, jsonify
from db import get_connection

donors_bp = Blueprint("donors", __name__)

@donors_bp.get("/donantes/<int:donor_id>")
def get_donor(donor_id):
    conn = get_connection()
    cursor = conn.cursor()

    cursor.execute("""
        SELECT
            ID_DONANTE,
            COALESCE(
                RAZON_SOCIAL,
                CONCAT_WS(' ', NOMBRE, A_PATERNO, A_MATERNO)
            ) AS NOMBRE_DONANTE
        FROM dbo.OPE_DONANTES
        WHERE ID_DONANTE = ?
    """, donor_id)

    row = cursor.fetchone()

    if row is None:
        cursor.close()
        conn.close()

        return jsonify({
            "error": "Donante no encontrado"
        }), 404

    donor = {
        "id": row[0],
        "nombre": row[1]
    }

    cursor.close()
    conn.close()

    return jsonify(donor), 200
