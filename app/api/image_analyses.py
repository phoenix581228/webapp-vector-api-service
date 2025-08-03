from fastapi import APIRouter, Depends, HTTPException, UploadFile, File
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, text
from typing import List, Optional
from datetime import datetime
import json
import uuid

from app.core.database import get_db
from app.models.image_analysis import ImageAnalysis
from app.services.embedding import EmbeddingService
from app.schemas.image_analysis import (
    ImageAnalysisCreate, 
    ImageAnalysisResponse, 
    ImageAnalysisSearch
)

router = APIRouter()
embedding_service = EmbeddingService()

@router.post("/", response_model=ImageAnalysisResponse)
async def create_image_analysis(
    file: UploadFile = File(...),
    db: AsyncSession = Depends(get_db)
):
    """Upload and process image analysis JSON file"""
    
    # Validate file type
    if not file.filename.endswith('.json'):
        raise HTTPException(status_code=400, detail="Only JSON files are accepted")
    
    # Read and parse JSON
    try:
        content = await file.read()
        data = json.loads(content)
    except json.JSONDecodeError:
        raise HTTPException(status_code=400, detail="Invalid JSON format")
    
    # Extract fields from JSON
    metadata = data.get("metadata", {})
    analysis = data.get("analysis", {})
    summary = data.get("summary", {})
    
    # Generate embedding for caption
    caption = analysis.get("caption", "")
    caption_embedding = None
    if caption:
        caption_embedding = await embedding_service.generate_embedding(caption)
    
    # Create database record
    db_analysis = ImageAnalysis(
        image_name=metadata.get("imageName", ""),
        base_image_name=metadata.get("baseImageName", ""),
        analysis_timestamp=datetime.fromisoformat(
            metadata.get("analysisTimestamp", "").replace("Z", "+00:00")
        ),
        analysis_date=metadata.get("analysisDate", ""),
        event_background=metadata.get("eventBackground", ""),
        full_json=data,
        caption=caption,
        caption_embedding=caption_embedding,
        tags=analysis.get("tags", []),
        tags_structured=analysis.get("tagsStructured", {}),
        caption_length=summary.get("captionLength", 0),
        total_tags=summary.get("totalTags", 0)
    )
    
    db.add(db_analysis)
    await db.commit()
    await db.refresh(db_analysis)
    
    return db_analysis

@router.get("/{analysis_id}", response_model=ImageAnalysisResponse)
async def get_image_analysis(
    analysis_id: uuid.UUID,
    db: AsyncSession = Depends(get_db)
):
    """Get a specific image analysis by ID"""
    
    result = await db.execute(
        select(ImageAnalysis).where(ImageAnalysis.id == analysis_id)
    )
    analysis = result.scalar_one_or_none()
    
    if not analysis:
        raise HTTPException(status_code=404, detail="Image analysis not found")
    
    return analysis

@router.get("/", response_model=List[ImageAnalysisResponse])
async def list_image_analyses(
    skip: int = 0,
    limit: int = 100,
    db: AsyncSession = Depends(get_db)
):
    """List all image analyses with pagination"""
    
    result = await db.execute(
        select(ImageAnalysis)
        .offset(skip)
        .limit(limit)
        .order_by(ImageAnalysis.created_at.desc())
    )
    analyses = result.scalars().all()
    
    return analyses

@router.post("/search", response_model=List[ImageAnalysisResponse])
async def search_image_analyses(
    search: ImageAnalysisSearch,
    db: AsyncSession = Depends(get_db)
):
    """Search image analyses by caption similarity or tags"""
    
    if search.caption_query:
        # Generate embedding for search query
        query_embedding = await embedding_service.generate_embedding(search.caption_query)
        
        # Perform vector similarity search
        result = await db.execute(
            text("""
                SELECT *, 
                       caption_embedding <=> :embedding as distance
                FROM image_analyses
                WHERE caption_embedding IS NOT NULL
                ORDER BY distance
                LIMIT :limit
            """),
            {
                "embedding": str(query_embedding),
                "limit": search.limit
            }
        )
        analyses = result.fetchall()
        
        return analyses
    
    elif search.tags:
        # Search by tags
        query = select(ImageAnalysis)
        
        for tag in search.tags:
            query = query.where(ImageAnalysis.tags.contains([tag]))
        
        result = await db.execute(query.limit(search.limit))
        analyses = result.scalars().all()
        
        return analyses
    
    else:
        raise HTTPException(
            status_code=400, 
            detail="Either caption_query or tags must be provided"
        )