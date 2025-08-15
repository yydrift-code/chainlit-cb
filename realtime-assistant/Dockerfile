# Use Python 3.11 slim image as base
FROM python:3.11-alpine

# Set working directory
WORKDIR /app

# Install system dependencies
RUN apk add --no-cache \
    gcc \
    g++ \
    musl-dev \
    libffi-dev \
    curl

# Copy requirements first for better caching
COPY requirements.txt .

# Install Python dependencies with caching for faster builds
RUN --mount=type=cache,target=/root/.cache/pip pip install -r requirements.txt

# Copy only the necessary application files
COPY app.py .
COPY chainlit.md .
COPY realtime/ ./realtime/

# Expose the port Chainlit runs on
EXPOSE 8888

# Set environment variables
ENV CHAINLIT_HOST=0.0.0.0
ENV CHAINLIT_PORT=8888

# Health check
HEALTHCHECK --interval=30s --timeout=30s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8888/health || exit 1

# Run the application
CMD ["chainlit", "run", "app.py", "--host", "0.0.0.0", "--port", "8888"]