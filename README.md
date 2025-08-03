# WebApp Vector API Service

一個專門為 Web 應用程式提供向量資料庫服務的 API，基於 FastAPI + PostgreSQL + pgvector + LM Studio 架構。專門設計用於儲存和搜尋圖片分析 JSON 資料。

## 技術架構

- **API Framework**: FastAPI
- **Database**: PostgreSQL with pgvector extension
- **Embedding Service**: LM Studio with Qwen3-embedding-8b (1920 dimensions)
- **Container**: Docker & Docker Compose
- **Language**: Python 3.11+

## 主要功能

1. **圖片分析資料管理**
   - 儲存圖片分析 JSON 資料
   - 自動擷取結構化欄位
   - 保留完整 JSON 資料供查詢

2. **向量嵌入搜尋**
   - 圖片描述文字轉換為向量嵌入 (1920維度)
   - 相似度搜尋功能
   - 支援標籤搜尋

3. **PostgreSQL JSONB 支援**
   - 原生 JSONB 資料類型
   - GIN 索引加速 JSON 查詢
   - 彈性的資料結構

## API 端點

### 圖片分析資料
- `POST /api/v1/image-analyses` - 上傳圖片分析 JSON 檔案
- `GET /api/v1/image-analyses/{id}` - 取得特定分析資料
- `GET /api/v1/image-analyses` - 列出所有分析資料
- `POST /api/v1/image-analyses/search` - 搜尋分析資料（文字相似度或標籤）

### 系統狀態
- `GET /health` - 健康檢查
- `GET /` - API 資訊
- `GET /docs` - Swagger UI 文檔
- `GET /redoc` - ReDoc 文檔

## 快速開始

```bash
# 啟動服務
docker-compose up -d

# 檢查服務狀態
curl http://localhost:8000/health

# 查看 API 文檔
open http://localhost:8000/docs
```

## 環境需求

- Docker 20.10+
- Docker Compose 2.0+
- 8GB+ RAM (建議 16GB)
- 10GB+ 可用磁碟空間

## 授權

MIT License