import httpx
import numpy as np
from typing import List, Optional
from app.core.config import settings
import structlog

logger = structlog.get_logger()

class EmbeddingService:
    def __init__(self):
        self.base_url = settings.LM_STUDIO_URL
        self.model = settings.LM_STUDIO_EMBEDDING_MODEL
        self.api_key = settings.LM_STUDIO_API_KEY
        self.dimension = settings.VECTOR_DIMENSION
    
    async def generate_embedding(self, text: str) -> Optional[List[float]]:
        """Generate embedding for text using LM Studio"""
        
        if not text:
            return None
        
        try:
            async with httpx.AsyncClient() as client:
                response = await client.post(
                    f"{self.base_url}/embeddings",
                    json={
                        "input": text,
                        "model": self.model
                    },
                    headers={
                        "Authorization": f"Bearer {self.api_key}",
                        "Content-Type": "application/json"
                    },
                    timeout=30.0
                )
                
                if response.status_code == 200:
                    data = response.json()
                    embedding = data["data"][0]["embedding"]
                    
                    # Ensure embedding has correct dimension
                    if len(embedding) != self.dimension:
                        logger.warning(
                            "Embedding dimension mismatch",
                            expected=self.dimension,
                            actual=len(embedding)
                        )
                        # Pad or truncate to match expected dimension
                        if len(embedding) < self.dimension:
                            embedding.extend([0.0] * (self.dimension - len(embedding)))
                        else:
                            embedding = embedding[:self.dimension]
                    
                    return embedding
                else:
                    logger.error(
                        "Failed to generate embedding",
                        status_code=response.status_code,
                        response=response.text
                    )
                    return None
                    
        except Exception as e:
            logger.error("Error generating embedding", error=str(e))
            return None
    
    async def generate_embeddings_batch(self, texts: List[str]) -> List[Optional[List[float]]]:
        """Generate embeddings for multiple texts"""
        embeddings = []
        
        for text in texts:
            embedding = await self.generate_embedding(text)
            embeddings.append(embedding)
        
        return embeddings