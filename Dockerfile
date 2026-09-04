FROM python:3.14-slim

# Evitar interacciones en apt
ENV DEBIAN_FRONTEND=noninteractive
WORKDIR /app

# Actualizar paquetes del sistema a versiones parcheadas, instalar solo lo necesario
RUN apt-get update \
 && apt-get upgrade -y \
 && apt-get install -y --no-install-recommends ca-certificates \
 && rm -rf /var/lib/apt/lists/*

# Copiar e instalar dependencias de Python
COPY requirements.txt .
RUN pip install --no-cache-dir --upgrade pip setuptools
RUN pip install --no-cache-dir -r requirements.txt

# Copiar código y ejecutar como usuario no root
COPY . /app
# Crear un usuario no-root (opcional, mejora seguridad)
RUN groupadd -r app && useradd -r -g app app \
 && chown -R app:app /app
USER app

EXPOSE 5050
CMD ["python", "app.py"]