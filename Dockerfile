# Use a PyTorch base image (with CUDA if needed)
FROM pytorch/pytorch:2.0.1-cuda11.7-cudnn8-runtime

# Set working directory in container
WORKDIR /app

# Copy only requirements first to leverage Docker cache
COPY requirements.txt .

# Upgrade pip & install dependencies early
RUN pip install --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

# Copy rest of the app files (code, model, etc.)
COPY . .

# Set env variable for model path (adjust if stored elsewhere)
ENV MODEL_PATH=/app/best11.pt

# Expose the FastAPI port
EXPOSE 8000

# Run the app
CMD ["uvicorn", "server:app", "--host", "0.0.0.0", "--port", "8000"]
