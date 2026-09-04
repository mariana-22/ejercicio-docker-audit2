FROM python:3.14-slim

ENV DEBIAN_FRONTEND=noninteractive
WORKDIR /app

# Actualizar paquetes del sistema y limpiar caches
RUN apt-get update \
 && apt-get upgrade -y \
 && apt-get install -y --no-install-recommends ca-certificates \
 && rm -rf /var/lib/apt/lists/*

# Dependencias Python
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copiar código y ejecutar como usuario no root
COPY . /app
RUN groupadd -r app && useradd -r -g app app \
 && chown -R app:app /app
USER app

EXPOSE 5050
CMD ["python", "app.py"]