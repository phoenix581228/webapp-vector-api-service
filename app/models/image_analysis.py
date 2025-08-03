from sqlalchemy import Column, String, Text, Integer, DateTime, JSON
from sqlalchemy.dialects.postgresql import UUID, JSONB
from sqlalchemy.sql import func
from pgvector.sqlalchemy import Vector
from app.core.database import Base
import uuid

class ImageAnalysis(Base):
    __tablename__ = "image_analyses"
    
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    
    # Basic metadata
    image_name = Column(Text, nullable=False, index=True)
    base_image_name = Column(Text, nullable=False, index=True)
    analysis_timestamp = Column(DateTime(timezone=True), nullable=False, index=True)
    analysis_date = Column(Text, nullable=False)
    
    # Event background
    event_background = Column(Text)
    
    # Full JSON data
    full_json = Column(JSONB, nullable=False)
    
    # Analysis data
    caption = Column(Text)
    caption_embedding = Column(Vector(1920))
    
    # Tags
    tags = Column(JSONB, default=list)
    tags_structured = Column(JSONB, default=dict)
    
    # Summary
    caption_length = Column(Integer)
    total_tags = Column(Integer)
    
    # Timestamps
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now())