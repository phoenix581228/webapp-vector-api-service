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
        """Generate embedding for text using LM Studio with MRL support"""
        
        if not text:
            return None
        
        try:
            # 準備請求參數
            request_data = {
                "input": text,
                "model": self.model
            }
            
            # 嘗試使用 MRL dimensions 參數
            # Qwen3-Embedding 支援動態維度調整
            if self.dimension != 4096:  # 如果不是預設維度
                request_data["dimensions"] = self.dimension
            
            async with httpx.AsyncClient() as client:
                response = await client.post(
                    f"{self.base_url}/embeddings",
                    json=request_data,
                    headers={
                        "Authorization": f"Bearer {self.api_key}",
                        "Content-Type": "application/json"
                    },
                    timeout=30.0
                )
                
                if response.status_code == 200:
                    data = response.json()
                    embedding = data["data"][0]["embedding"]
                    
                    # 檢查維度是否正確
                    if len(embedding) != self.dimension:
                        logger.warning(
                            "Embedding dimension mismatch - MRL may not be supported",
                            expected=self.dimension,
                            actual=len(embedding),
                            info="Using first N dimensions as per MRL design"
                        )
                        # MRL 設計：前 N 個維度包含最重要的語義信息
                        # 如果 LM Studio 不支援 dimensions 參數，我們使用前 N 個維度
                        if len(embedding) > self.dimension:
                            # 使用前 N 個維度（MRL 的核心設計）
                            embedding = embedding[:self.dimension]
                        else:
                            # 這種情況不應該發生，但為了安全性還是處理
                            logger.error(
                                "Embedding dimension too small",
                                expected=self.dimension,
                                actual=len(embedding)
                            )
                            # 填充零值（不推薦，但確保系統不會崩潰）
                            embedding.extend([0.0] * (self.dimension - len(embedding)))
                    
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