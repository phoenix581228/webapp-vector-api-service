# Changelog

All notable changes to WebApp Vector API will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2025-08-03

### 🎉 Initial Release

#### Added
- **Core Features**
  - FastAPI-based REST API service
  - PostgreSQL with pgvector extension for vector storage
  - Integration with LM Studio for text embeddings
  - Support for 1920-dimension vectors (via MRL truncation)
  
- **API Endpoints**
  - `GET /health` - Health check endpoint
  - `POST /api/v1/image-analyses/` - Upload image analysis JSON data
  - `GET /api/v1/image-analyses/` - List all image analyses
  - `GET /api/v1/image-analyses/{id}` - Get specific analysis by ID
  - `POST /api/v1/image-analyses/search` - Search by text similarity or tags

- **Features**
  - JSONB storage for flexible JSON data
  - Vector similarity search using cosine distance
  - Tag-based exact match search
  - Automatic embedding generation for captions
  - GIN and HNSW indexes for optimized queries

- **Deployment**
  - Docker Compose configuration
  - Automated deployment scripts
  - Health check monitoring
  - Port configuration (8100)

- **Documentation**
  - Complete API documentation
  - Deployment guide
  - Test scripts
  - Integration examples (Python & JavaScript)

#### Technical Stack
- Python 3.11
- FastAPI
- PostgreSQL 15 with pgvector
- LM Studio (Qwen3-embedding)
- Docker & Docker Compose
- SQLAlchemy with async support

#### Known Issues
- LM Studio currently outputs 4096 dimensions, automatically truncated to 1920
- Pending proper MRL configuration for native 1920-dimension output

---

### Milestone: WebApp Vector API v1.0.0
**Release Date**: 2025-08-03  
**Status**: Production Ready  
**Description**: First stable release of the WebApp Vector API service, providing vector database capabilities for web applications with image analysis JSON data storage and semantic search functionality.