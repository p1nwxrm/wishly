from pydantic import BaseModel, Field, ConfigDict
from typing import Optional

# ==========================================
# TAG SCHEMAS
# ==========================================

class TagCreate(BaseModel):
    """
    Properties to receive via API on tag creation.
    """
    name: str = Field(..., min_length=1, max_length=50, description="Name of the tag (e.g., 'Birthday', 'Tech')")
    description: Optional[str] = Field(default=None, description="Optional details about the tag")
    created_by_user_id: int = Field(..., description="ID of the user who created the tag")


class TagUpdate(BaseModel):
    """
    Properties to receive via API on tag update.
    """
    name: Optional[str] = Field(default=None, min_length=1, max_length=50)
    description: Optional[str] = None


class Tag(BaseModel):
    """
    Response model for Tag.
    Represents the tag entity returned by the API.
    """
    id: int
    name: str = Field(..., description="Name of the tag")
    description: Optional[str] = Field(default=None, description="Optional details about the tag")

    model_config = ConfigDict(from_attributes=True)