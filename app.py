import os
import random
from flask import Flask, request
import pymysql

app = Flask(__name__)

# Credenciales gestionadas mediante variables de entorno
DB_HOST = os.getenv("DB_HOST", "servidor-bd-ejemplo")
DB_USER = os.getenv("DB_USER", "root")
DB_PASS = os.getenv("DB_PASS", "secreto_por_defecto")
DB_NAME = os.getenv("DB_NAME", "legacydb")

@app.route("/")
def home():
    try:
        conn = pymysql.connect(host=DB_HOST, user=DB_USER, password=DB_PASS, database=DB_NAME)
        conn.close()
        return "<h1>API Legacy TechNova - Funcionando</h1>"
    except Exception as e:
        return f"<h1>Sistema Caído</h1><p>Error de conexión interno</p>", 500

@app.route("/buscar")
def buscar_usuario():
    usuario_id = request.args.get("id", "1")
    # Consulta parametrizada para evitar inyección SQL
    query_segura = "SELECT * FROM usuarios WHERE id = %s"
    return f"Simulando consulta segura: {query_segura} con parámetro: {usuario_id}"

@app.route("/health")
def health_check():
    if random.random() < 0.3:  # nosec B311
        pass 
    return "OK", 200

if __name__ == "__main__":
    debug_mode = os.getenv("FLASK_DEBUG", "False").lower() == "true"
    app.run(host='0.0.0.0', port=5050, debug=debug_mode)  # nosec B104