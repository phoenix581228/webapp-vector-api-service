#!/bin/bash

# WebApp Vector API 部署腳本
set -e

echo "🚀 WebApp Vector API 部署開始..."

# 檢查必要的服務
check_requirements() {
    echo "📋 檢查系統需求..."
    
    # 檢查 Docker
    if ! command -v docker &> /dev/null; then
        echo "❌ Docker 未安裝"
        exit 1
    fi
    
    # 檢查 Docker Compose
    if ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null; then
        echo "❌ Docker Compose 未安裝"
        exit 1
    fi
    
    echo "✅ 系統需求檢查通過"
}

# 建立必要的目錄
setup_directories() {
    echo "📁 建立必要目錄..."
    mkdir -p logs
    mkdir -p data
    echo "✅ 目錄建立完成"
}

# 複製環境變數檔案
setup_env() {
    echo "🔧 設定環境變數..."
    if [ ! -f .env ]; then
        cp .env.example .env
        echo "⚠️  已複製 .env.example 到 .env，請根據需要修改設定"
    else
        echo "✅ .env 檔案已存在"
    fi
}

# 建立 Docker 映像
build_images() {
    echo "🐳 建立 Docker 映像..."
    docker-compose build --no-cache
    echo "✅ Docker 映像建立完成"
}

# 啟動服務
start_services() {
    echo "🚀 啟動服務..."
    docker-compose up -d
    echo "✅ 服務啟動完成"
}

# 等待服務就緒
wait_for_services() {
    echo "⏳ 等待服務就緒..."
    
    # 等待 PostgreSQL
    echo -n "等待 PostgreSQL..."
    for i in {1..30}; do
        if docker-compose exec -T postgres pg_isready -U webapp &> /dev/null; then
            echo " ✅"
            break
        fi
        echo -n "."
        sleep 1
    done
    
    # 等待 API
    echo -n "等待 API 服務..."
    for i in {1..30}; do
        if curl -s http://localhost:8000/health > /dev/null; then
            echo " ✅"
            break
        fi
        echo -n "."
        sleep 1
    done
}

# 顯示服務狀態
show_status() {
    echo ""
    echo "📊 服務狀態："
    docker-compose ps
    echo ""
    echo "🌐 服務端點："
    echo "  - API: http://localhost:8000"
    echo "  - API 文檔: http://localhost:8000/docs"
    echo "  - PostgreSQL: localhost:5434"
    echo ""
}

# 主程序
main() {
    check_requirements
    setup_directories
    setup_env
    build_images
    start_services
    wait_for_services
    show_status
    
    echo "✅ 部署完成！"
    echo ""
    echo "📝 下一步："
    echo "  1. 確認 LM Studio 正在運行於 http://localhost:1234"
    echo "  2. 使用 ./test.sh 執行測試"
    echo "  3. 查看日誌: docker-compose logs -f"
}

main