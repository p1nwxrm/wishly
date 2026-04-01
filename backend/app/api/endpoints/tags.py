from typing import List
from fastapi import APIRouter, Depends, HTTPException, status # type: ignore
from sqlalchemy.ext.asyncio import AsyncSession

from app import crud, schemas
from app.models.models import User
from app.api.dependencies import get_db, get_current_user

# Initialize the router for tag-related endpoints
router = APIRouter(prefix="/tags", tags=["Tags"])

# ==========================================
# TAG ENDPOINTS
# ==========================================

@router.post("/", response_model=schemas.tag.TagResponse, status_code=status.HTTP_201_CREATED)
async def create_new_tag(
		tag_in: schemas.tag.TagBase,
		db: AsyncSession = Depends(get_db),
		current_user: User = Depends(get_current_user)
):
	"""
	Creates a new custom tag.
	Securely injects the current user's ID as the creator.
	"""
	# 1. Securely inject the creator ID into the complete Create schema
	full_tag_data = schemas.tag.TagCreate(
		**tag_in.model_dump(),
		created_by_user_id=int(current_user.id)  # type: ignore
	)

	# 2. Save the tag to the database
	new_tag = await crud.tag.create_tag(db=db, tag_in=full_tag_data)
	return new_tag


@router.get("/me", response_model=List[schemas.tag.TagResponse])
async def read_my_tags(
		db: AsyncSession = Depends(get_db),
		current_user: User = Depends(get_current_user)
):
	"""
	Retrieves all tags created by the currently authenticated user.
	"""
	tags = await crud.tag.get_tags_by_user(db=db, user_id=int(current_user.id))  # type: ignore
	return tags


@router.get("/{tag_id}", response_model=schemas.tag.TagResponse)
async def read_tag(
		tag_id: int,
		db: AsyncSession = Depends(get_db),
		current_user: User = Depends(get_current_user)
):
	"""
	Retrieves a specific tag by its ID.
	Ensures that only the creator can view it.
	"""
	tag = await crud.tag.get_tag(db=db, tag_id=tag_id)
	if not tag:
		raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Tag not found")

	# Security check: Ensure the user owns this tag
	if tag.created_by_user_id != current_user.id:
		raise HTTPException(
			status_code=status.HTTP_403_FORBIDDEN,
			detail="Not enough permissions to view this tag"
		)

	return tag


@router.patch("/{tag_id}", response_model=schemas.tag.TagResponse)
async def update_existing_tag(
		tag_id: int,
		tag_in: schemas.tag.TagUpdate,
		db: AsyncSession = Depends(get_db),
		current_user: User = Depends(get_current_user)
):
	"""
	Updates a tag's name or description.
	Only the creator is allowed to modify it.
	"""
	tag = await crud.tag.get_tag(db=db, tag_id=tag_id)
	if not tag:
		raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Tag not found")

	# Security check: Ensure the user owns this tag
	if tag.created_by_user_id != current_user.id:
		raise HTTPException(
			status_code=status.HTTP_403_FORBIDDEN,
			detail="Not enough permissions to modify this tag"
		)

	updated_tag = await crud.tag.update_tag(db=db, db_tag=tag, tag_in=tag_in)
	return updated_tag


@router.delete("/{tag_id}", status_code=status.HTTP_200_OK)
async def delete_existing_tag(
		tag_id: int,
		db: AsyncSession = Depends(get_db),
		current_user: User = Depends(get_current_user)
):
	"""
	Deletes a tag.
	Only the creator is allowed to delete it.
	"""
	tag = await crud.tag.get_tag(db=db, tag_id=tag_id)
	if not tag:
		raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Tag not found")

	# Security check: Ensure the user owns this tag
	if tag.created_by_user_id != current_user.id:
		raise HTTPException(
			status_code=status.HTTP_403_FORBIDDEN,
			detail="Not enough permissions to delete this tag"
		)

	await crud.tag.delete_tag(db=db, tag_id=tag_id)

	return {"status": "success", "message": "Tag successfully deleted"}