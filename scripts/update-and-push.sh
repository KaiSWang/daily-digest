#!/bin/bash
# ============================================
# KS Daily Digest - 自動更新並推送到 GitHub
# ============================================
# 使用方式: ./scripts/update-and-push.sh
# 此腳本會：
# 1. 從 scheduleWork 複製最新報告到 data/ 資料夾
# 2. 更新 manifest.json（保留最近7天）
# 3. 自動 commit 並 push 到 GitHub
# ============================================

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SITE_DIR="$(dirname "$SCRIPT_DIR")"
REPORT_DIR="${REPORT_SOURCE:-$HOME/Coding/scheduleWork}"

cd "$SITE_DIR"

echo "📦 KS Daily Digest 更新中..."
echo "   報告來源: $REPORT_DIR"
echo "   網站目錄: $SITE_DIR"
echo ""

# --- 複製美股分析報告 ---
echo "📊 複製美股分析報告..."
mkdir -p data/stock
for f in "$REPORT_DIR"/每日美股分析*.md "$REPORT_DIR"/美股每日分析*.md; do
  if [ -f "$f" ]; then
    cp "$f" data/stock/
    echo "   ✓ $(basename "$f")"
  fi
done

# --- 複製 AI/GitHub 趨勢報告 ---
echo "🤖 複製 AI/GitHub 趨勢報告..."
mkdir -p data/ai-github
for f in "$REPORT_DIR"/AI_GitHub趨勢*.md; do
  if [ -f "$f" ]; then
    cp "$f" data/ai-github/
    echo "   ✓ $(basename "$f")"
  fi
done

# --- 更新 manifest.json ---
echo "📋 更新 manifest.json..."

# Collect all unique dates from stock reports (last 7 days)
DATES=$(ls -1 data/stock/*.md 2>/dev/null | grep -oP '\d{4}-\d{2}-\d{2}' | sort -ru | head -7)

if [ -z "$DATES" ]; then
  echo "   ⚠️ 未找到任何報告檔案"
  exit 1
fi

LATEST_DATE=$(echo "$DATES" | head -1)
DATE_ARRAY=$(echo "$DATES" | sed 's/^/    "/;s/$/"/' | paste -sd ',' | sed 's/,/,\n/g')

cat > data/manifest.json << MANIFEST
{
  "columns": [
    {
      "id": "stock",
      "title": "每日美股分析",
      "icon": "📊",
      "description": "美股三大變因、台股關注標的、重點公司追蹤、潛力股分析",
      "filePattern": "每日美股分析_{date}.md",
      "altPatterns": ["每日美股分析報告_{date}.md", "美股每日分析_{date}.md"]
    },
    {
      "id": "ai-github",
      "title": "AI / GitHub 趨勢",
      "icon": "🤖",
      "description": "最新 AI 資訊、GitHub 熱門專案、技術趨勢觀察",
      "filePattern": "AI_GitHub趨勢_{date}.md"
    }
  ],
  "dates": [
${DATE_ARRAY}
  ],
  "lastUpdated": "${LATEST_DATE}"
}
MANIFEST

echo "   ✓ manifest.json 已更新（最新: $LATEST_DATE，共 $(echo "$DATES" | wc -l) 天）"

# --- 清理超過 7 天的舊報告 ---
echo "🧹 清理舊報告..."
CUTOFF_DATE=$(date -d "7 days ago" +%Y-%m-%d 2>/dev/null || date -v-7d +%Y-%m-%d 2>/dev/null)
if [ -n "$CUTOFF_DATE" ]; then
  for f in data/stock/*.md data/ai-github/*.md; do
    if [ -f "$f" ]; then
      FILE_DATE=$(echo "$f" | grep -oP '\d{4}-\d{2}-\d{2}' || true)
      if [ -n "$FILE_DATE" ] && [[ "$FILE_DATE" < "$CUTOFF_DATE" ]]; then
        rm "$f"
        echo "   🗑 刪除 $(basename "$f")"
      fi
    fi
  done
fi

# --- Git commit and push ---
echo ""
echo "🚀 推送到 GitHub..."

git add -A
if git diff --cached --quiet; then
  echo "   ℹ️ 沒有變更需要推送"
else
  TODAY=$(date +%Y-%m-%d)
  git commit -m "📰 更新每日報告 $TODAY"
  git push origin main
  echo "   ✓ 已推送到 GitHub！"
fi

echo ""
echo "✅ 完成！網站將在幾分鐘內自動更新。"
