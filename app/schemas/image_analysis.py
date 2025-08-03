from pydantic import BaseModel
from typing import List, Optional, Dict, Any
from datetime import datetime
import uuid

class ImageAnalysisBase(BaseModel):
    image_name: str
    base_image_name: str
    analysis_timestamp: datetime
    analysis_date: str
    event_background: Optional[str] = None
    caption: Optional[str] = None
    tags: List[str] = []
    tags_structured: Dict[str, str] = {}
    caption_length: Optional[int] = None
    total_tags: Optional[int] = None

class ImageAnalysisCreate(ImageAnalysisBase):
    full_json: Dict[str, Any]

class ImageAnalysisResponse(ImageAnalysisBase):
    id: uuid.UUID
    full_json: Dict[str, Any]
    created_at: datetime
    updated_at: datetime
    
    class Config:
        from_attributes = True

class ImageAnalysisSearch(BaseModel):
    caption_query: Optional[str] = None
    tags: Optional[List[str]] = None
    limit: int = 10