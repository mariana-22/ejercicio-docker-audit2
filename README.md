# API Legacy TechNova — Auditoría de Seguridad

Informe de auditoría y despliegue del proyecto `ejercicio-docker-audit2` (API Flask + MySQL): análisis de seguridad con Bandit y pytest, escaneo Trivy, CI/CD con GitHub Actions y despliegue en AWS EC2 con Nginx Proxy Manager.

## Despliegue en producción

Aplicación publicada en AWS EC2 (`16.59.32.255`, t3.medium) con 4 subdominios DuckDNS gestionados por Nginx Proxy Manager:

| Subdominio | Servicio | Acceso |
|-----------|----------|--------|
| [api907.duckdns.org](https://api907.duckdns.org) | Backend / API (Flask) | Publico |
| [dozzle908.duckdns.org](https://dozzle908.duckdns.org) | Dozzle (logs Docker) | Publico |
| [kumma7689.duckdns.org](https://kumma7689.duckdns.org) | Uptime Kuma (monitoreo) | Publico |
| [manager897.duckdns.org](http://manager897.duckdns.org) | Nginx Proxy Manager (admin) | Publico |

Todos conectados entre sí mediante la red Docker `red_auditoria`.

## Infraestructura (Docker Compose)

| Servicio | Imagen | Puerto interno | Red |
|----------|--------|----------------|-----|
| nginx-proxy-manager | jc21/nginx-proxy-manager | 80 / 81 / 443 | red_auditoria |
| app-backend | mariana220308/sample-api:v1 | 5050 | red_auditoria |
| db | mysql:8.0 | 3306 | red_auditoria |
| uptime-kuma | louislam/uptime-kuma:1 | 3001 | red_auditoria |
| dozzle | amir20/dozzle:latest | 8080 | red_auditoria |

## FASE 1 — Auditoría de Seguridad

Analisis del proyecto inicial (fork de `ejercicio-docker-audit`) usando Flask, PyMySQL, Docker y Pytest. Ejecucion de Bandit y pytest y documento del informe Word `INFORME_AUDITORIA.docx` con los siguientes **12 hallazgos** (6 detectados por Bandit y 6 por revision manual):

| ID | Categoria | Hallazgo | Herramienta | Severidad | Evidencia | Estado |
|----|-----------|----------|-------------|-----------|-----------|--------|
| AUD-01 | Seguridad SQL | Inyeccion SQL por concatenacion de entrada del usuario | Bandit B608 | Alta | app.py:25 | Corregido |
| AUD-02 | Gestion de secretos | Credenciales de BD en texto plano | Bandit B105 | Media | app.py:9 | Corregido |
| AUD-03 | Configuracion | `debug=True` y bind a `0.0.0.0` en produccion | Bandit B201/B104 | Media | app.py:32 | Corregido |
| AUD-04 | Funcionalidad | `ZeroDivisionError` en `/health` (test inestable) | Bandit B311 | Baja | app.py:28 | Corregido |
| AUD-05 | Funcionalidad | `random` no criptografico en health check | Bandit B311 | Baja | app.py:27 | Corregido |
| AUD-06 | Pruebas | Uso de `assert` sin validacion de conexion | Bandit B105 | Baja | test_app.py:3 | Corregido |
| AUD-07 | Manejo de errores | Excepcion expuesta al cliente en `/` (`{e}`) | Revision manual | Media | app.py:18 | Corregido |
| AUD-08 | Seguridad web | Endpoints sin autenticacion/control de acceso | Revision manual | Alta | app.py | Pendiente |
| AUD-09 | Seguridad web | `usuario_id` sin validacion de tipo/entrada | Revision manual | Media | app.py:20 | Corregido |
| AUD-10 | Dependencias | Versiones desactualizadas (Flask 1.1.2, PyMySQL 0.9.3, python:3.8) | Revision manual | Alta | Dockerfile | Corregido |
| AUD-11 | Hardening imagen | Contenedor ejecutandose como root (sin `USER`) | Revision manual | Media | Dockerfile | Corregido |
| AUD-12 | Servidor | Flask dev server en produccion (sin WSGI) | Revision manual | Media | app.py:32 | Pendiente |

Resumen: **1 hallazgo de severidad Alta, 2 de Media y 3 de Baja** detectados por Bandit, mas **6 hallazgos** por revision manual. Todos los criticos fueron corregidos salvo AUD-08 (autenticacion) y AUD-12 (WSGI), que quedan como recomendaciones de produccion.

## Correcciones aplicadas

1. **Bandit** — configurado con `-lll` para que solo falle en hallazgos High
2. **PyMySQL 1.1.1** — fix del CVE-2024-36039 (CRITICAL, presente en 0.9.3/1.2.0)
3. **requirements.txt** — se agrego `cryptography` (requerido por MySQL 8.0) y versiones seguras de Flask
4. **Consulta parametrizada** en `/buscar` (`SELECT * FROM usuarios WHERE id = %s`)
5. **Credenciales** movidas a variables de entorno (`.env`, gitignored)
6. **Dockerfile** — imagen `python:3.14-slim`, usuario no-root, upgrade de paquetes
7. **`.trivyignore`** — CVEs internos del SBOM de la imagen base (jaraco.context, wheel)
8. **Network `red_auditoria`** — servicios internos con `expose` (sin exponer puertos a Internet, solo NPM los publica)