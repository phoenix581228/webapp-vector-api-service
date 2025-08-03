#!/bin/bash

# 批次上傳 JSON 檔案腳本

API_URL="http://localhost:8100/api/v1/image-analyses/"

echo "📤 批次上傳 JSON 檔案..."

# 檢查是否有提供檔案路徑
if [ $# -eq 0 ]; then
    echo "使用方式: $0 <json檔案或目錄>"
    echo "範例: $0 /path/to/json/files/"
    echo "範例: $0 /path/to/single/file.json"
    exit 1
fi

# 上傳單一檔案函數
upload_file() {
    local file=$1
    local filename=$(basename "$file")
    
    echo -n "上傳 $filename... "
    
    response=$(curl -s -w "\n%{http_code}" -X POST \
        -F "file=@$file" \
        "$API_URL")
    
    http_code=$(echo "$response" | tail -1)
    body=$(echo "$response" | sed '$d')
    
    if [ "$http_code" = "200" ]; then
        echo "✅ 成功"
        # 顯示回應的 ID
        id=$(echo "$body" | jq -r '.id' 2>/dev/null)
        if [ ! -z "$id" ] && [ "$id" != "null" ]; then
            echo "  ID: $id"
        fi
    else
        echo "❌ 失敗 (HTTP $http_code)"
        echo "  錯誤: $body"
    fi
}

# 統計變數
total=0
success=0
failed=0

# 處理輸入
input=$1

if [ -f "$input" ]; then
    # 單一檔案
    if [[ "$input" == *.json ]]; then
        total=1
        upload_file "$input"
        if [ $? -eq 0 ]; then
            ((success++))
        else
            ((failed++))
        fi
    else
        echo "❌ 錯誤: 不是 JSON 檔案"
        exit 1
    fi
elif [ -d "$input" ]; then
    # 目錄
    echo "搜尋 JSON 檔案於: $input"
    
    # 找出所有 JSON 檔案
    json_files=$(find "$input" -name "*.json" -type f)
    
    if [ -z "$json_files" ]; then
        echo "❌ 找不到 JSON 檔案"
        exit 1
    fi
    
    # 計算總數
    total=$(echo "$json_files" | wc -l)
    echo "找到 $total 個 JSON 檔案"
    echo ""
    
    # 逐一上傳
    while IFS= read -r file; do
        upload_file "$file"
        if [ $? -eq 0 ]; then
            ((success++))
        else
            ((failed++))
        fi
        echo ""
    done <<< "$json_files"
else
    echo "❌ 錯誤: 找不到檔案或目錄: $input"
    exit 1
fi

# 顯示統計
echo ""
echo "📊 上傳統計："
echo "  總計: $total"
echo "  成功: $success"
echo "  失敗: $failed"

# 提供後續步驟
if [ $success -gt 0 ]; then
    echo ""
    echo "📝 下一步："
    echo "  - 查看所有資料: curl $API_URL | jq"
    echo "  - 搜尋測試: ./test.sh"
    echo "  - API 文檔: http://localhost:8100/docs"
fi