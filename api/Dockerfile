FROM python:3.13.3-slim AS builder

WORKDIR /app

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc libpq-dev build-essential \
    && rm -rf /var/lib/apt/lists/*

COPY requirements.txt .

RUN pip install --upgrade pip && \
    pip install --user --no-cache-dir -r requirements.txt

FROM python:3.13.3-slim AS runtime

WORKDIR /app

ENV PATH="/root/.local/bin:$PATH"
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

RUN apt-get update && apt-get install -y --no-install-recommends \
    libpq-dev curl netcat-openbsd \
    && rm -rf /var/lib/apt/lists/*

COPY --from=builder /root/.local /root/.local

COPY . /app/

RUN python manage.py collectstatic --noinput || true

EXPOSE 8000

# this for normal startup
# CMD ["python", "manage.py", "runserver", "0.0.0.0:8000"]  

# this is for wsgi application with gunicorn and unix sock
# RUN mkdir -p /app/socket && chown -R www-data:www-data /app/socket
# CMD ["gunicorn", "--workers", "4", "--bind", "unix:/app/socket/gunicorn.sock", "--access-logfile", "-", "--error-logfile", "-", "main.wsgi:application"]

# this is for wsgi application with Start Gunicorn on TCP instead of UNIX socket
# CMD ["gunicorn", "--workers", "4", "--bind", "0.0.0.0:8000", "--access-logfile", "-", "--error-logfile", "-", "main.wsgi:application"]

# Use Daphne for ASGI applications using daphne with tcp
CMD ["daphne", "-b", "0.0.0.0", "-p", "8000", "main.asgi:application"]

