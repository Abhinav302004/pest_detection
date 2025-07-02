FROM python:3.9-slim

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    MODEL_PATH=/best11.pt

# Set working directory
WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    libgl1-mesa-glx \
    git \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements and install
COPY requirements.txt .
RUN pip install --upgrade pip && pip install -r requirements.txt

# Copy model and app code
COPY best11.pt /best11.pt
COPY app/ . 

# Expose port
EXPOSE 8000

# Run the app
CMD ["uvicorn", "app.server:app", "--host", "0.0.0.0", "--port", "8000"]
