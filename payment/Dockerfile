# Build arguments
ARG PYTHON_VERSION=3.11
ARG ENVIRONMENT=production

# Base image
FROM python:${PYTHON_VERSION}-slim AS base

# Set environment variables
ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PIP_NO_CACHE_DIR=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1

WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    postgresql-client \
    curl \
    && rm -rf /var/lib/apt/lists/*


# Refresh certificate details
# RUN apt-get update \
#  && apt-get install -y --no-install-recommends ca-certificates \
#  && update-ca-certificates \
#  && rm -rf /var/lib/apt/lists/*

# Copy the SSL certificate into the container
# COPY ./cert-file/cert.cer /usr/local/share/ca-certificates/cert.crt

# Install the updated certificate
# RUN update-ca-certificates

# Set this so pip/requests reliably uses the CA/certificate bundle
# ENV REQUESTS_CA_BUNDLE=/etc/ssl/certs/ca-certificates.crt
# ENV PIP_CERT=/etc/ssl/certs/ca-certificates.crt


# Builder stage
FROM base AS builder

# Copy requirements
COPY payment/requirements.txt .

# Install Python dependencies
RUN pip install --user --no-warn-script-location -r requirements.txt

# Final stage
FROM base AS final

# Create non-root user
RUN useradd -m -u 1000 appuser && \
    chown -R appuser:appuser /app

# Copy 
COPY ./open-data-spaces-payment-public/ /app/

# Copy Python dependencies from builder
COPY --from=builder --chown=appuser:appuser /root/.local /home/appuser/.local

# Copy application code
COPY --chown=appuser:appuser ../open-data-spaces-payment-public/app/ /app/app/

# Copy Alembic migration files (alembic.ini is located in the migrations directory)
COPY --chown=appuser:appuser ../open-data-spaces-payment-public/migrations/ /app/migrations/

# Set PATH to include user's local bin
ENV PATH=/home/appuser/.local/bin:$PATH

# Switch to non-root user
USER appuser

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8000/health || exit 1

# Expose port
EXPOSE 8000

# Run the application
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
