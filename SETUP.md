# KS Daily Digest - 設定指南

## 快速開始

### 1. 建立 GitHub Repo

```bash
cd daily-digest-site
git init
git add -A
git commit -m "🚀 初始化 KS Daily Digest"
git branch -M main
git remote add origin https://github.com/<你的帳號>/daily-digest.git
git push -u origin main
```

### 2. 啟用 GitHub Pages

1. 到 GitHub repo → **Settings** → **Pages**
2. Source 選 **GitHub Actions**
3. 等待部署完成（約 1-2 分鐘）
4. 你的網站網址：`https://<你的帳號>.github.io/daily-digest/`

### 3. 每日更新

每天排程任務產出報告後，執行：

```bash
./scripts/update-and-push.sh
```

或手動複製報告檔案到 `data/` 後 git push。

## 資料夾結構

```
daily-digest-site/
├── index.html              # 主頁面
├── data/
│   ├── manifest.json       # 資料索引（日期、專欄設定）
│   ├── stock/              # 美股分析報告 (.md)
│   └── ai-github/          # AI/GitHub 趨勢報告 (.md)
├── scripts/
│   └── update-and-push.sh  # 自動更新腳本
└── .github/
    └── workflows/
        └── deploy.yml      # GitHub Pages 自動部署
```

## 新增專欄

1. 在 `data/` 下新增資料夾
2. 在 `manifest.json` 的 `columns` 陣列加入新專欄
3. 在 `index.html` 中新增對應的 tab 和 content area

## 費用

**完全免費！** GitHub Pages 對公開 repo 免費，無流量限制。
