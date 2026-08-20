# mti-cncbi-ai-analysis-skill

MTI / CNCBI One Account **美债 + 结构票据兑换链路**周度 AI 分析 Skill。

- 生成 `AI分析-YYYYMMDD`（Markdown / HTML / PDF / JSON）
- 含票息综合盈亏（不仅是市值波动）
- macOS launchd：**每周一 11:00** 自动跑
- 可供 Cursor / Copilot / Pi 等 Agent 直接加载

## 安装

### GitHub

```bash
git clone https://github.com/lgh726-Git/mti-cncbi-ai-analysis-skill.git \
  ~/.agents/skills/mti-cncbi-ai-analysis
```

### Gitee

```bash
git clone https://gitee.com/<your-gitee-user>/mti-cncbi-ai-analysis-skill.git \
  ~/.agents/skills/mti-cncbi-ai-analysis
```

### 依赖

```bash
python3 -m pip install --user openpyxl
# PDF 导出需要本机 Google Chrome（headless）
```

### 配置

```bash
mkdir -p ~/.config/mti-ai-analysis
cp ~/.agents/skills/mti-cncbi-ai-analysis/assets/config.example.json \
   ~/.config/mti-ai-analysis/config.json
```

编辑 `ai_root` 或 `mti_finance_root`、明细表路径。

### 手动跑一次

```bash
python3 ~/.agents/skills/mti-cncbi-ai-analysis/scripts/mti_weekly_ust_analysis.py
```

### 安装周一 11 点定时任务

```bash
bash ~/.agents/skills/mti-cncbi-ai-analysis/scripts/install_schedule.sh
```

卸载：

```bash
bash ~/.agents/skills/mti-cncbi-ai-analysis/scripts/uninstall_schedule.sh
```

## 输出示例

```text
.../银行理财/AI分析/
  LATEST.txt
  AI分析-20260820/
    AI分析-20260820.md
    AI分析-20260820.html
    AI分析-20260820.pdf
    ust_full_pnl_with_coupons.json
    README.txt
```

## 口径摘要

| 项目 | 定义 |
|------|------|
| 净成本 | 票据本金 − 交割退回零头 |
| 市值 | Clean price × 面值 / 100，YTM=US30Y（^TYX） |
| 已收票息 | 结构期 + 现券期已入账利息 |
| 综合盈亏 | 市值 − 净成本 + 已收票息 |

详见 [references/methodology.md](references/methodology.md) 与 [SKILL.md](SKILL.md)。

## 仓库结构

```text
SKILL.md
README.md
scripts/mti_weekly_ust_analysis.py
scripts/install_schedule.sh
scripts/uninstall_schedule.sh
scripts/mti-ai-analysis-weekly.sh
launchd/com.lgh726.mti-ai-analysis.weekly.plist
assets/config.example.json
references/methodology.md
```

## License

MIT

## Disclaimer

内部持仓管理工具，不构成投资建议。请勿上传未脱敏的银行结单或加密前明文持仓文件。
