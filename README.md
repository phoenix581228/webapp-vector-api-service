# WebApp Vector API Service

一個專門為 Web 應用程式提供向量資料庫服務的 API，基於 FastAPI + PostgreSQL + pgvector + LM Studio 架構。

## 技術架構

- **API Framework**: FastAPI
- **Database**: PostgreSQL with pgvector extension
- **Embedding Service**: LM Studio with Qwen3-embedding-8b (1920 dimensions)
- **Container**: Docker & Docker Compose
- **Language**: Python 3.11+

## 主要功能

1. **向量嵌入管理**
   - 文本轉換為向量嵌入
   - 向量存儲和索引
   - 相似度搜尋

2. **RESTful API**
   - 標準 REST 端點
   - OpenAPI 文檔
   - 認證和授權

3. **資料管理**
   - CRUD 操作
   - 批次處理
   - 資料匯入/匯出

## API 端點

- `POST /embeddings` - 創建新的嵌入
- `GET /search` - 向量相似度搜尋
- `GET /documents/{id}` - 取得文檔
- `PUT /documents/{id}` - 更新文檔
- `DELETE /documents/{id}` - 刪除文檔

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