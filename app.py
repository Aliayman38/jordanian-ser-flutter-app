import os
import shutil
import subprocess
import threading
import time
import re
from typing import Optional
import pandas as pd
import uvicorn
from fastapi import FastAPI, UploadFile, File, Form, HTTPException
from fastapi.middleware.cors import CORSMiddleware

UPLOAD_DIR = "/content/competition_audio_uploads"
MANIFEST_PATH = "/content/manifest_new.csv"
os.makedirs(UPLOAD_DIR, exist_ok=True)

app = FastAPI(title="Jordanian SER Data Collection")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get("/")
def root():
    return {"status": "running", "message": "SER Collection Server is Active"}

@app.post("/api/submit-audio")
async def submit_audio(
    file: UploadFile = File(...),
    speaker_id: str = Form(...),
    emotion: str = Form(...),
    text: Optional[str] = Form("")
):
    try:
        ext = os.path.splitext(file.filename)[1] or ".wav"
        filename = f"{speaker_id}_{emotion.lower()}_{os.urandom(4).hex()}{ext}"
        file_path = os.path.join(UPLOAD_DIR, filename)

        with open(file_path, "wb") as buffer:
            shutil.copyfileobj(file.file, buffer)

        # استخراج الجنس من معرف المتحدث (مثال: M2020 -> Male, F2020 -> Female)
        gender = "unknown"
        if speaker_id.upper().startswith("M"):
            gender = "male"
        elif speaker_id.upper().startswith("F"):
            gender = "female"

        # تسجيل البيانات المعتمدة صوتياً فقط دون نص لضمان دقة الـ Ground Truth
        record = {
            "id": f"{speaker_id}_{emotion}_{filename}",
            "audio_path": file_path,
            "speaker_id": speaker_id,
            "emotion": emotion.capitalize(),
            "gender": gender,
            "sample_rate": 16000,
            "channels": 1,
            "language": "ar-JO",
            "utt_id": filename,
        }

        df_new = pd.DataFrame([record])
        if os.path.exists(MANIFEST_PATH):
            df_existing = pd.read_csv(MANIFEST_PATH)
            df_updated = pd.concat([df_existing, df_new], ignore_index=True)
            df_updated.to_csv(MANIFEST_PATH, index=False)
        else:
            df_new.to_csv(MANIFEST_PATH, index=False)

        return {"status": "success", "file": filename}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

threading.Thread(
    target=lambda: uvicorn.run(app, host="127.0.0.1", port=8000, log_level="warning"),
    daemon=True
).start()

time.sleep(2)

cf_process = subprocess.Popen(
    ["./cloudflared", "tunnel", "--url", "http://127.0.0.1:8000"],
    stdout=subprocess.PIPE,
    stderr=subprocess.STDOUT,
    text=True
)

public_url = None
for _ in range(25):
    line = cf_process.stdout.readline()
    match = re.search(r'https://[a-zA-Z0-9-]+\.trycloudflare\.com', line)
    if match:
        public_url = match.group(0)
        break
    time.sleep(0.5)

print("\n" + "=" * 60)
if public_url:
    print(f"🔗 Public API Base URL: {public_url}")
    print(f"🔗 Submit Endpoint: {public_url}/api/submit-audio")
else:
    print("Error starting Cloudflare tunnel ❌")
print("=" * 60)