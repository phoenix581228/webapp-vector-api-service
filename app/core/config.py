from pydantic_settings import BaseSettings
from typing import List
import os

class Settings(BaseSettings):
    # Application
    ENVIRONMENT: str = "development"
    DEBUG: bool = False
    HOST: str = "0.0.0.0"
    PORT: int = 8000
    
    # Database
    DATABASE_URL: str = "postgresql://webapp:webapp_secure_password_2024@localhost:5434/webapp_vectors"
    
    # CORS
    CORS_ORIGINS: List[str] = ["*"]
    
    # Vector Configuration
    VECTOR_DIMENSION: int = 1920
    VECTOR_INDEX_TYPE: str = "hnsw"
    VECTOR_DISTANCE_METRIC: str = "cosine"
    
    # Embedding Service
    EMBEDDING_PROVIDER: str = "lmstudio"
    LM_STUDIO_URL: str = "http://localhost:1234/v1"
    LM_STUDIO_EMBEDDING_MODEL: str = "text-embedding-qwen3-embedding-8b"
    LM_STUDIO_API_KEY: str = "lm-studio"
    
    # Logging
    LOG_LEVEL: str = "INFO"
    LOG_FORMAT: str = "json"
    
    class Config:
        env_file = ".env"
        case_sensitive = True

settings = Settings()