from fastapi import APIRouter, Depends
from sqlalchemy import text
from sqlalchemy.ext.asyncio import AsyncSession
from app.core.database import get_db
import httpx
from app.core.config import settings

router = APIRouter()

@router.get("/health")
async def health_check(db: AsyncSession = Depends(get_db)):
    """Health check endpoint"""
    try:
        # Check database connection
        await db.execute(text("SELECT 1"))
        db_status = "healthy"
    except Exception as e:
        db_status = f"unhealthy: {str(e)}"
    
    # Check LM Studio connection
    try:
        async with httpx.AsyncClient() as client:
            response = await client.get(f"{settings.LM_STUDIO_URL}/models")
            lm_studio_status = "healthy" if response.status_code == 200 else "unhealthy"
    except Exception as e:
        lm_studio_status = f"unhealthy: {str(e)}"
    
    return {
        "status": "healthy" if db_status == "healthy" else "degraded",
        "services": {
            "database": db_status,
            "lm_studio": lm_studio_status,
            "vector_dimension": settings.VECTOR_DIMENSION
        }
    }