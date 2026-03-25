import shutil
import uuid
from pathlib import Path
from fastapi import UploadFile # type: ignore

# Define the base directory for all uploaded media
UPLOAD_DIR = Path("uploads")


def save_upload_file(upload_file: UploadFile, subfolder: str) -> str:
	"""
	Saves an uploaded file to the specified subfolder and returns its relative URL.
	Generates a unique UUID filename to prevent naming collisions.
	"""
	# 1. Ensure the target subdirectory exists
	target_dir = UPLOAD_DIR / subfolder
	target_dir.mkdir(parents=True, exist_ok=True)

	# 2. Extract the file extension (e.g., '.jpg' or '.png')
	# If the file has no extension, default to '.jpg'
	extension = Path(upload_file.filename).suffix if upload_file.filename else ".jpg"

	# 3. Generate a secure, unique filename using UUID4
	unique_filename = f"{uuid.uuid4()}{extension}"
	file_path = target_dir / unique_filename

	# 4. Save the file to the hard drive using standard shutil
	# This efficiently copies the file buffer to the disk
	with open(file_path, "wb") as buffer:
		shutil.copyfileobj(upload_file.file, buffer)

	# 5. Return the URL path that will be saved in the database
	# This matches the "/static" mount we configured in main.py
	return f"/static/{subfolder}/{unique_filename}"