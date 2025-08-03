# WebApp Vector API 部署指南

## 快速部署

### 1. 前置需求

- Docker 20.10+
- Docker Compose 2.0+
- LM Studio 運行於 http://localhost:1234
- 至少 8GB RAM

### 2. 部署步驟

```bash
# 1. 執行部署腳本
./deploy.sh

# 2. 等待服務啟動完成（約 30 秒）

# 3. 執行測試
./test.sh
```

### 3. 服務端點

- **API 主服務**: http://localhost:8000
- **Swagger UI**: http://localhost:8000/docs
- **ReDoc**: http://localhost:8000/redoc
- **PostgreSQL**: localhost:5434

## 環境設定

### 修改環境變數

編輯 `.env` 檔案來自訂設定：

```env
# LM Studio 設定
LM_STUDIO_URL=http://host.docker.internal:1234/v1
LM_STUDIO_EMBEDDING_MODEL=text-embedding-qwen3-embedding-8b

# 資料庫設定
DATABASE_URL=postgresql://webapp:webapp_secure_password_2024@postgres:5432/webapp_vectors

# 向量維度
VECTOR_DIMENSION=1920
```

## 使用範例

### 上傳圖片分析資料

```bash
curl -X POST \
  -F "file=@your_analysis.json" \
  http://localhost:8000/api/v1/image-analyses
```

### 搜尋相似內容

```bash
curl -X POST \
  -H "Content-Type: application/json" \
  -d '{"caption_query": "搜尋文字", "limit": 10}' \
  http://localhost:8000/api/v1/image-analyses/search
```

### 標籤搜尋

```bash
curl -X POST \
  -H "Content-Type: application/json" \
  -d '{"tags": ["標籤1", "標籤2"], "limit": 10}' \
  http://localhost:8000/api/v1/image-analyses/search
```

## 管理命令

### 查看服務狀態
```bash
docker-compose ps
```

### 查看服務日誌
```bash
docker-compose logs -f
```

### 進入資料庫
```bash
docker-compose exec postgres psql -U webapp webapp_vectors
```

### 停止服務
```bash
./stop.sh
```

## 故障排除

### LM Studio 連線失敗

1. 確認 LM Studio 正在運行
2. 檢查端口 1234 是否可訪問
3. 確認已載入 embedding 模型

### 資料庫連線失敗

1. 檢查 PostgreSQL 容器狀態
2. 確認端口 5434 未被佔用
3. 查看資料庫日誌：`docker-compose logs postgres`

### API 回應緩慢

1. 檢查向量索引：連線資料庫後執行 `\d+ image_analyses`
2. 確認 LM Studio 效能
3. 調整 Docker 資源配置

## 生產環境注意事項

1. **安全性**
   - 修改預設密碼
   - 設定 CORS 白名單
   - 啟用 HTTPS

2. **效能優化**
   - 調整 PostgreSQL 配置
   - 設定連線池大小
   - 啟用快取機制

3. **監控**
   - 設定健康檢查告警
   - 監控資源使用率
   - 定期備份資料庫