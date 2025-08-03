#!/bin/bash

# 停止 WebApp Vector API 服務

echo "🛑 停止 WebApp Vector API 服務..."

# 停止並移除容器
docker-compose down

# 詢問是否要刪除資料
read -p "是否要刪除資料卷？(y/N) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    docker-compose down -v
    echo "✅ 已刪除資料卷"
fi

echo "✅ 服務已停止"