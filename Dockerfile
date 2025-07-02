# Use a base image with PyTorch preinstalled to reduce size and simplify setup
FROM pytorch/pytorch:2.0.1-cuda11.7-cudnn8-runtime

# Set the working directory to root of copied repo
WORKDIR /app

# Copy all contents from current repo (host) into the container
COPY . .

# Install dependencies
RUN pip install --upgrade pip
RUN pip install --no-cache-dir -r requirements.txt

# Expose port FastAPI runs on
EXPOSE 8000

# Run the FastAPI app
CMD ["uvicorn", "server:app", "--host", "0.0.0.0", "--port", "8000"]
