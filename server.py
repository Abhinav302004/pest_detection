import os
import uuid
import shutil
from contextlib import asynccontextmanager
from typing import Dict, List

from fastapi import FastAPI, UploadFile, File
from fastapi.responses import JSONResponse

from ultralytics import YOLO

# Globals
model = None
THIS_DIR = os.path.dirname(os.path.abspath(__file__))
MODEL_PATH = os.getenv("MODEL_PATH", os.path.join(THIS_DIR, "best11.pt"))
TEMP_DIR = os.path.join(THIS_DIR, "temp_uploads")
os.makedirs(TEMP_DIR, exist_ok=True)


# Load model on startup
def load_model():
    _model = YOLO(MODEL_PATH)
    return _model


@asynccontextmanager
async def lifespan(app: FastAPI):
    global model
    model = load_model()
    yield


# FastAPI app
app = FastAPI(lifespan=lifespan, root_path=os.getenv("TFY_SERVICE_ROOT_PATH", ""))


@app.get("/health")
async def health() -> Dict[str, bool]:
    return {"healthy": True}


@app.post("/predict")
async def predict(file: UploadFile = File(...)):
    global model

    # Save uploaded image temporarily
    file_ext = file.filename.split(".")[-1]
    temp_filename = f"{uuid.uuid4()}.{file_ext}"
    temp_path = os.path.join(TEMP_DIR, temp_filename)

    with open(temp_path, "wb") as f:
        shutil.copyfileobj(file.file, f)

    try:
        # Inference
        results = model(temp_path)

        # Extract predictions
        all_predictions = []
        for r in results:
            for box in r.boxes.data.tolist():
                x1, y1, x2, y2, score, class_id = box
                all_predictions.append({
                    "class": r.names[int(class_id)],
                    "score": float(score),
                    "box": [round(x1, 2), round(y1, 2), round(x2, 2), round(y2, 2)]
                })

        return {"predictions": all_predictions}

    finally:
        # Clean up
        if os.path.exists(temp_path):
            os.remove(temp_path)
