# Qwen3-Embedding MRL 配置指南

## 什麼是 MRL (Matryoshka Representation Learning)

MRL 是 Qwen3-Embedding 採用的先進技術，允許模型在推理時動態調整向量維度，而無需重新訓練或手動降維。

### 核心優勢

1. **動態維度調整**：可在 API 請求時指定任意維度（如 64、128、1024、1920、4096）
2. **語義品質保證**：模型訓練時針對多種維度設計損失函數，確保各維度都有優良效果
3. **前 N 維度設計**：較小維度的向量是較大維度向量的前綴，保證語義一致性

## 配置方式

### 方式一：API 原生支援（推薦）

如果您的嵌入服務支援 `dimensions` 參數：

```json
{
  "model": "text-embedding-qwen3-embedding-8b",
  "input": "要嵌入的文字",
  "dimensions": 1920
}
```

### 方式二：使用前 N 個維度

如果服務不支援 `dimensions` 參數（如某些版本的 LM Studio），可以安全地使用前 N 個維度：

```python
# 獲取 4096 維度的完整向量
full_embedding = get_embedding(text)  # [4096 dimensions]

# 使用前 1920 個維度
mrl_embedding = full_embedding[:1920]  # [1920 dimensions]
```

這種方式是安全的，因為 MRL 的設計確保了前 N 個維度包含最重要的語義信息。

## WebApp Vector API 的實現

本專案採用混合策略：

1. **優先嘗試 API 參數**：發送請求時包含 `dimensions: 1920`
2. **降級使用前綴策略**：如果服務返回 4096 維度，自動使用前 1920 個維度

```python
# app/services/embedding.py 中的實現
if self.dimension != 4096:
    request_data["dimensions"] = self.dimension

# 如果返回維度不匹配，使用 MRL 前綴策略
if len(embedding) > self.dimension:
    embedding = embedding[:self.dimension]  # MRL 設計保證這是安全的
```

## 維度選擇建議

| 維度 | 使用場景 | 儲存空間 | 檢索速度 |
|------|----------|----------|----------|
| 128  | 快速原型、低精度需求 | 極小 | 極快 |
| 512  | 一般搜尋應用 | 小 | 快 |
| 1024 | 平衡精度與效能 | 中 | 中 |
| 1920 | 高精度檢索（本專案選擇） | 較大 | 較慢 |
| 4096 | 最高精度 | 大 | 慢 |

## 驗證 MRL 功能

### 測試腳本

```bash
# 測試不同維度的向量相似度
curl -X POST http://localhost:1234/v1/embeddings \
  -H "Content-Type: application/json" \
  -d '{
    "model": "text-embedding-qwen3-embedding-8b",
    "input": "測試文字",
    "dimensions": 1920
  }'
```

### 檢查日誌

如果看到以下警告，表示正在使用前綴策略：
```
Embedding dimension mismatch - MRL may not be supported
expected=1920, actual=4096
info=Using first N dimensions as per MRL design
```

這是正常的，不影響檢索品質。

## 未來優化

1. **升級嵌入服務**：當 LM Studio 或其他服務支援 `dimensions` 參數時，自動使用原生 MRL
2. **動態維度配置**：根據不同的使用場景動態調整維度
3. **效能監控**：追蹤不同維度對檢索效果的影響

## 參考資料

- [Matryoshka Representation Learning 論文](https://arxiv.org/abs/2205.13147)
- [Qwen3-Embedding 官方文檔](https://github.com/QwenLM/Qwen)
- [pgvector 維度限制說明](https://github.com/pgvector/pgvector#dimensions)