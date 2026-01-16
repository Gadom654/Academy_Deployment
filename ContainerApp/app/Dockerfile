# --- STAGE 1: Builder ---
FROM python:3.11-slim AS builder

WORKDIR /app

# Install system dependencies needed for building/compiling
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    gcc \
    && rm -rf /var/lib/apt/lists/*

# Create a virtual environment to keep dependencies isolated
RUN python -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

# Install Python dependencies into the virtual environment
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt


# --- STAGE 2: Runtime ---
FROM python:3.11-slim

WORKDIR /app

# Copy ONLY the virtual environment from the builder stage
COPY --from=builder /opt/venv /opt/venv

# Ensure the app uses the virtual environment
ENV PATH="/opt/venv/bin:$PATH"

# Copy your application code
COPY app.py .

# Expose and Run
EXPOSE 8080
CMD ["python", "app.py"]