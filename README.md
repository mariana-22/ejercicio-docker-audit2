# API Legacy TechNova — Auditoría de Seguridad

Informe de auditoría del proyecto `ejercicio-docker-audit2` (API Flask + MySQL), ejercicios: Docker Hub, Trivy, despliegue CI/CD a servidor cloud.

## Resultado de la auditoría

| ID | Categoría | Prueba / Evidencia | Herramienta | Resultado obtenido | Estado |
|----|-----------|--------------------|-------------|--------------------|--------|
| AUD-01 | Funcionalidad | `test_health_check`: 5 peticiones consecutivas a `/health` (test_app.py:3) | pytest | 5/5 respuestas 200 OK; 1 passed in 0.32s | ✅ Aprobado |
| AUD-02 | Análisis estático | Escaneo de app.py y test_app.py | Bandit | No issues identified — 0 vulnerabilidades | ✅ Aprobado |
| AUD-03 | Análisis estático | Hallazgos suprimidos con `#nosec` (B311, B104, B101) | Bandit | 3 supresiones justificadas, no omiten fallos reales | ✅ Aprobado |
| AUD-04 | Seguridad SQL | `/buscar` usa consulta parametrizada (`SELECT * FROM usuarios WHERE id = %s` con parámetro) (app.py:27-28) | Revisión de código | Sin concatenación de entrada del usuario | ✅ Aprobado |
| AUD-05 | Gestión de secretos | Credenciales de BD desde variables de entorno (`os.getenv`, app.py:9-12) | Revisión de código | Sin credenciales en texto plano en el código | ✅ Aprobado |
| AUD-06 | Configuración | `debug` solo habilitado si `FLASK_DEBUG=true`; bandit no reporta `run(debug=True)` sin control (app.py:37) | Bandit + revisión | debug=False por defecto | ✅ Aprobado |