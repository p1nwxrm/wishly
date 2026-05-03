from pydantic import BaseModel, Field, ConfigDict
from typing import Optional

# ==========================================
# LOOKUP / REFERENCE SCHEMAS
# ==========================================

class SubscriptionPlan(BaseModel):
    """
    Response model for the subscription plan (tier).
    Represents the capabilities available to the user in the app.
    """
    id: int
    name: str = Field(..., description="Name of the plan (e.g., Free, Premium)")
    description: Optional[str] = Field(default=None, description="Details about the plan's features")

    model_config = ConfigDict(from_attributes=True)