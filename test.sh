#!/bin/bash

# WebApp Vector API 測試腳本
set -e

API_URL="http://localhost:8000"

echo "🧪 WebApp Vector API 測試開始..."

# 顏色定義
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# 測試函數
test_endpoint() {
    local method=$1
    local endpoint=$2
    local data=$3
    local expected_status=$4
    local description=$5
    
    echo -n "測試: $description... "
    
    if [ "$method" = "GET" ]; then
        response=$(curl -s -o /dev/null -w "%{http_code}" "$API_URL$endpoint")
    elif [ "$method" = "POST" ]; then
        response=$(curl -s -o /dev/null -w "%{http_code}" -X POST \
            -H "Content-Type: application/json" \
            -d "$data" \
            "$API_URL$endpoint")
    elif [ "$method" = "POST_FILE" ]; then
        response=$(curl -s -o /dev/null -w "%{http_code}" -X POST \
            -F "file=@$data" \
            "$API_URL$endpoint")
    fi
    
    if [ "$response" = "$expected_status" ]; then
        echo -e "${GREEN}✅ 通過${NC} (HTTP $response)"
    else
        echo -e "${RED}❌ 失敗${NC} (預期: $expected_status, 實際: $response)"
    fi
}

# 1. 健康檢查
echo ""
echo "1️⃣ 健康檢查測試"
test_endpoint "GET" "/health" "" "200" "健康檢查端點"

# 2. API 資訊
echo ""
echo "2️⃣ API 資訊測試"
test_endpoint "GET" "/" "" "200" "根端點"

# 3. 準備測試資料
echo ""
echo "3️⃣ 準備測試資料"
cat > test_image_analysis.json << 'EOF'
{
  "metadata": {
    "imageName": "test_image_001.jpg",
    "baseImageName": "test_image_001",
    "analysisTimestamp": "2025-06-11T05:40:02.769Z",
    "analysisDate": "2025/06/11 13:40:02",
    "eventBackground": "測試活動背景",
    "enabledFeatures": {
      "caption": true,
      "tags": true,
      "score": false
    },
    "version": "1.0"
  },
  "analysis": {
    "caption": "這是一個測試圖片的描述，用於測試向量搜尋功能",
    "tags": [
      "測試",
      "範例",
      "API"
    ],
    "tagsStructured": {
      "類別": "測試",
      "用途": "API測試"
    }
  },
  "summary": {
    "captionLength": 20,
    "totalTags": 3
  }
}
EOF

echo "✅ 測試資料準備完成"

# 4. 上傳測試
echo ""
echo "4️⃣ 上傳圖片分析資料"
echo "上傳測試檔案..."
upload_response=$(curl -s -X POST \
    -F "file=@test_image_analysis.json" \
    "$API_URL/api/v1/image-analyses")

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ 上傳成功${NC}"
    echo "回應內容："
    echo "$upload_response" | jq '.' 2>/dev/null || echo "$upload_response"
    
    # 擷取 ID
    analysis_id=$(echo "$upload_response" | jq -r '.id' 2>/dev/null)
else
    echo -e "${RED}❌ 上傳失敗${NC}"
fi

# 5. 列表測試
echo ""
echo "5️⃣ 列出所有分析資料"
list_response=$(curl -s "$API_URL/api/v1/image-analyses")
echo "資料筆數: $(echo "$list_response" | jq '. | length' 2>/dev/null || echo "無法解析")"

# 6. 取得單筆資料
if [ ! -z "$analysis_id" ] && [ "$analysis_id" != "null" ]; then
    echo ""
    echo "6️⃣ 取得單筆資料"
    test_endpoint "GET" "/api/v1/image-analyses/$analysis_id" "" "200" "取得 ID: $analysis_id"
fi

# 7. 搜尋測試
echo ""
echo "7️⃣ 搜尋測試"

# 文字相似度搜尋
echo "測試文字相似度搜尋..."
search_response=$(curl -s -X POST \
    -H "Content-Type: application/json" \
    -d '{"caption_query": "測試圖片", "limit": 5}' \
    "$API_URL/api/v1/image-analyses/search")

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ 搜尋成功${NC}"
    echo "搜尋結果筆數: $(echo "$search_response" | jq '. | length' 2>/dev/null || echo "無法解析")"
else
    echo -e "${RED}❌ 搜尋失敗${NC}"
fi

# 標籤搜尋
echo "測試標籤搜尋..."
tag_search_response=$(curl -s -X POST \
    -H "Content-Type: application/json" \
    -d '{"tags": ["測試"], "limit": 5}' \
    "$API_URL/api/v1/image-analyses/search")

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ 標籤搜尋成功${NC}"
    echo "搜尋結果筆數: $(echo "$tag_search_response" | jq '. | length' 2>/dev/null || echo "無法解析")"
else
    echo -e "${RED}❌ 標籤搜尋失敗${NC}"
fi

# 清理測試檔案
rm -f test_image_analysis.json

echo ""
echo "✅ 測試完成！"
echo ""
echo "📝 提示："
echo "  - 查看 API 文檔: http://localhost:8000/docs"
echo "  - 查看服務日誌: docker-compose logs -f"