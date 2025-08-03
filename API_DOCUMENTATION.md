# WebApp Vector API 技術參數文檔

## API 基本資訊

- **基礎 URL**: `http://localhost:8100`
- **API 版本**: v1
- **內容類型**: `application/json` (除檔案上傳外)
- **編碼**: UTF-8

## API 端點詳細說明

### 1. 健康檢查

**端點**: `GET /health`

**描述**: 檢查服務健康狀態

**請求範例**:
```bash
curl http://localhost:8100/health
```

**回應範例**:
```json
{
  "status": "healthy",
  "services": {
    "database": "healthy",
    "lm_studio": "healthy",
    "vector_dimension": 1920
  }
}
```

**狀態碼**:
- `200 OK`: 服務正常
- `503 Service Unavailable`: 服務異常

---

### 2. 上傳圖片分析資料

**端點**: `POST /api/v1/image-analyses/`

**描述**: 上傳圖片分析 JSON 檔案並儲存到資料庫

**請求參數**:
- **Content-Type**: `multipart/form-data`
- **file**: JSON 檔案 (必填)

**JSON 檔案結構**:
```json
{
  "metadata": {
    "imageName": "圖片檔名.jpg",
    "baseImageName": "基礎圖片名稱",
    "analysisTimestamp": "2025-06-11T05:40:02.769Z",
    "analysisDate": "2025/06/11 13:40:02",
    "eventBackground": "活動背景描述",
    "enabledFeatures": {
      "caption": true,
      "tags": true,
      "score": false
    },
    "version": "1.0"
  },
  "analysis": {
    "caption": "圖片描述文字",
    "tags": ["標籤1", "標籤2", "標籤3"],
    "tagsStructured": {
      "類別": "分類名稱",
      "屬性": "屬性值"
    }
  },
  "summary": {
    "captionLength": 20,
    "totalTags": 3
  }
}
```

**請求範例**:
```bash
curl -X POST \
  -F "file=@analysis.json" \
  http://localhost:8100/api/v1/image-analyses/
```

**回應範例**:
```json
{
  "id": "899dd02f-2724-4bd1-8a5d-c575754b6bf7",
  "image_name": "20230319-Foto_1__6-陳俊賓_A2831473.jpg",
  "base_image_name": "20230319-Foto_1__6-陳俊賓_A2831473",
  "analysis_timestamp": "2023-03-19T16:00:00.000Z",
  "analysis_date": "2023/03/19 16:00:00",
  "event_background": "棉蘭慈濟志工活動",
  "caption": "2023年3月19日，八十一位棉蘭慈濟志工...",
  "tags": ["慈濟", "醫療", "志工"],
  "tags_structured": {
    "地點": "北蘇門答臘省棉蘭市",
    "活動": "義診"
  },
  "caption_length": 120,
  "total_tags": 3,
  "full_json": {...},
  "created_at": "2025-08-03T14:42:00.000Z",
  "updated_at": "2025-08-03T14:42:00.000Z"
}
```

**狀態碼**:
- `200 OK`: 上傳成功
- `400 Bad Request`: 檔案格式錯誤
- `422 Unprocessable Entity`: JSON 結構不符

---

### 3. 取得所有分析資料

**端點**: `GET /api/v1/image-analyses/`

**描述**: 列出所有圖片分析資料

**查詢參數**:
- **skip**: 跳過筆數 (預設: 0)
- **limit**: 限制筆數 (預設: 100, 最大: 1000)

**請求範例**:
```bash
curl http://localhost:8100/api/v1/image-analyses/?skip=0&limit=10
```

**回應範例**:
```json
[
  {
    "id": "899dd02f-2724-4bd1-8a5d-c575754b6bf7",
    "image_name": "20230319-Foto_1__6-陳俊賓_A2831473.jpg",
    "caption": "2023年3月19日，八十一位棉蘭慈濟志工...",
    "tags": ["慈濟", "醫療", "志工"],
    "created_at": "2025-08-03T14:42:00.000Z"
  }
]
```

**狀態碼**:
- `200 OK`: 成功取得資料

---

### 4. 取得單筆分析資料

**端點**: `GET /api/v1/image-analyses/{id}`

**描述**: 根據 ID 取得特定的圖片分析資料

**路徑參數**:
- **id**: 資料 UUID (必填)

**請求範例**:
```bash
curl http://localhost:8100/api/v1/image-analyses/899dd02f-2724-4bd1-8a5d-c575754b6bf7
```

**回應範例**:
```json
{
  "id": "899dd02f-2724-4bd1-8a5d-c575754b6bf7",
  "image_name": "20230319-Foto_1__6-陳俊賓_A2831473.jpg",
  "base_image_name": "20230319-Foto_1__6-陳俊賓_A2831473",
  "analysis_timestamp": "2023-03-19T16:00:00.000Z",
  "analysis_date": "2023/03/19 16:00:00",
  "event_background": "棉蘭慈濟志工活動",
  "caption": "2023年3月19日，八十一位棉蘭慈濟志工...",
  "tags": ["慈濟", "醫療", "志工"],
  "tags_structured": {
    "地點": "北蘇門答臘省棉蘭市",
    "活動": "義診"
  },
  "caption_length": 120,
  "total_tags": 3,
  "full_json": {
    "metadata": {...},
    "analysis": {...},
    "summary": {...}
  },
  "created_at": "2025-08-03T14:42:00.000Z",
  "updated_at": "2025-08-03T14:42:00.000Z"
}
```

**狀態碼**:
- `200 OK`: 成功取得資料
- `404 Not Found`: 找不到指定 ID 的資料

---

### 5. 搜尋圖片分析資料

**端點**: `POST /api/v1/image-analyses/search`

**描述**: 根據文字相似度或標籤搜尋圖片分析資料

**請求本體**: JSON 格式

#### 5.1 文字相似度搜尋

**請求結構**:
```json
{
  "caption_query": "搜尋文字",
  "limit": 10
}
```

**請求範例**:
```bash
curl -X POST \
  -H "Content-Type: application/json" \
  -d '{"caption_query": "慈濟志工", "limit": 5}' \
  http://localhost:8100/api/v1/image-analyses/search
```

#### 5.2 標籤搜尋

**請求結構**:
```json
{
  "tags": ["標籤1", "標籤2"],
  "limit": 10
}
```

**請求範例**:
```bash
curl -X POST \
  -H "Content-Type: application/json" \
  -d '{"tags": ["慈濟", "醫療"], "limit": 5}' \
  http://localhost:8100/api/v1/image-analyses/search
```

**回應範例**:
```json
[
  {
    "id": "899dd02f-2724-4bd1-8a5d-c575754b6bf7",
    "image_name": "20230319-Foto_1__6-陳俊賓_A2831473.jpg",
    "caption": "2023年3月19日，八十一位棉蘭慈濟志工...",
    "tags": ["慈濟", "醫療", "志工"],
    "similarity_score": 0.89  // 僅在文字相似度搜尋時出現
  }
]
```

**狀態碼**:
- `200 OK`: 搜尋成功
- `400 Bad Request`: 請求參數錯誤

**注意事項**:
- `caption_query` 和 `tags` 只能擇一使用，不可同時提供
- `limit` 預設值為 10，最大值為 100
- 文字相似度搜尋會使用向量嵌入進行語意搜尋
- 標籤搜尋為精確匹配，需包含所有指定標籤

---

## 資料模型說明

### ImageAnalysisResponse 模型

| 欄位 | 類型 | 說明 | 必填 |
|------|------|------|------|
| id | UUID | 唯一識別碼 | 是 |
| image_name | string | 圖片檔名 | 是 |
| base_image_name | string | 基礎圖片名稱 | 是 |
| analysis_timestamp | datetime | 分析時間戳記 | 是 |
| analysis_date | string | 分析日期字串 | 是 |
| event_background | string | 活動背景 | 否 |
| caption | string | 圖片描述 | 否 |
| tags | array[string] | 標籤陣列 | 否 |
| tags_structured | object | 結構化標籤 | 否 |
| caption_length | integer | 描述長度 | 否 |
| total_tags | integer | 標籤總數 | 否 |
| full_json | object | 完整 JSON 資料 | 是 |
| created_at | datetime | 建立時間 | 是 |
| updated_at | datetime | 更新時間 | 是 |

### ImageAnalysisSearch 模型

| 欄位 | 類型 | 說明 | 必填 |
|------|------|------|------|
| caption_query | string | 文字搜尋查詢 | 否* |
| tags | array[string] | 標籤搜尋陣列 | 否* |
| limit | integer | 結果數量限制 | 否 |

*註：`caption_query` 和 `tags` 必須擇一提供

---

## 錯誤回應格式

所有錯誤回應均採用以下格式：

```json
{
  "detail": "錯誤訊息描述"
}
```

常見錯誤碼：
- `400`: 請求格式錯誤
- `404`: 資源不存在
- `422`: 請求內容無法處理
- `500`: 伺服器內部錯誤
- `503`: 服務暫時無法使用

---

## 整合範例

### Python 整合範例

```python
import requests
import json

# API 基礎 URL
BASE_URL = "http://localhost:8100"

# 1. 健康檢查
response = requests.get(f"{BASE_URL}/health")
print(response.json())

# 2. 上傳 JSON 檔案
with open("analysis.json", "rb") as f:
    files = {"file": f}
    response = requests.post(f"{BASE_URL}/api/v1/image-analyses/", files=files)
    uploaded_data = response.json()
    print(f"上傳成功，ID: {uploaded_data['id']}")

# 3. 搜尋資料
search_data = {
    "caption_query": "慈濟志工",
    "limit": 5
}
response = requests.post(
    f"{BASE_URL}/api/v1/image-analyses/search",
    json=search_data
)
results = response.json()
print(f"找到 {len(results)} 筆相關資料")
```

### JavaScript 整合範例

```javascript
const BASE_URL = 'http://localhost:8100';

// 1. 健康檢查
fetch(`${BASE_URL}/health`)
  .then(res => res.json())
  .then(data => console.log(data));

// 2. 上傳檔案
const formData = new FormData();
formData.append('file', fileInput.files[0]);

fetch(`${BASE_URL}/api/v1/image-analyses/`, {
  method: 'POST',
  body: formData
})
  .then(res => res.json())
  .then(data => console.log('上傳成功:', data.id));

// 3. 搜尋資料
fetch(`${BASE_URL}/api/v1/image-analyses/search`, {
  method: 'POST',
  headers: {
    'Content-Type': 'application/json'
  },
  body: JSON.stringify({
    caption_query: '慈濟志工',
    limit: 5
  })
})
  .then(res => res.json())
  .then(results => console.log(`找到 ${results.length} 筆資料`));
```

---

## 注意事項

1. **向量維度**: 系統預設使用 1920 維度向量，若 LM Studio 產生不同維度，系統會自動截斷或填充
2. **檔案大小**: 建議單一 JSON 檔案不超過 10MB
3. **並發限制**: API 預設最大並發連線數為 100
4. **速率限制**: 無預設速率限制，但建議批次操作時適當控制請求頻率
5. **字元編碼**: 所有文字資料必須使用 UTF-8 編碼
6. **CORS**: 預設允許所有來源 (`*`)，生產環境請設定特定來源

---

## Swagger UI 互動式文檔

訪問 http://localhost:8100/docs 可使用 Swagger UI 進行互動式 API 測試。

## ReDoc 文檔

訪問 http://localhost:8100/redoc 可查看更詳細的 API 規格文檔。