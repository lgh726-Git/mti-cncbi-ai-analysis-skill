---
name: mti-cncbi-ai-analysis
description: Weekly MTI/CNCBI UST and converted structured-note P&L analysis with coupons. Builds dated AI分析-YYYYMMDD packages (md/html/pdf/json) under the MTI 银行理财/AI分析 folder, prices cash US Treasuries with US30Y, and supports Monday 11:00 launchd scheduling. Use when user asks about MTI美债盈亏, CNCBI One Account holdings, 被兑换的国债, UC08/UE63 coupon income, or weekly AI analysis archive.
---

# MTI CNCBI AI Analysis

对 MERIT TALENT INT'L / CNCBI One Account 的**美债现券 + 结构票据兑换链路**做含票息综合盈亏分析，并按日归档到 `AI分析-YYYYMMDD`。

## When to use

- MTI / 中信国际美债、被兑换国债、UC08/UE63 盈亏
- 需要把结论写入 `银行理财/AI分析/AI分析-年月日`
- 设置或运行「每周一 11:00」自动分析
- 生成可发给干系人的 PDF/HTML 报告

## Quick start

```bash
# 1) Install skill (agent skills dir or clone)
git clone https://github.com/lgh726-Git/mti-cncbi-ai-analysis-skill.git \
  ~/.agents/skills/mti-cncbi-ai-analysis

# 2) Config
mkdir -p ~/.config/mti-ai-analysis
cp ~/.agents/skills/mti-cncbi-ai-analysis/assets/config.example.json \
   ~/.config/mti-ai-analysis/config.json
# edit paths: ai_root / mti_finance_root / detail workbook

# 3) Dependencies
python3 -m pip install --user openpyxl

# 4) Run once
python3 ~/.agents/skills/mti-cncbi-ai-analysis/scripts/mti_weekly_ust_analysis.py

# 5) Install Monday 11:00 schedule (macOS)
bash ~/.agents/skills/mti-cncbi-ai-analysis/scripts/install_schedule.sh
```

## Outputs

Under `<ai_root>/AI分析-YYYYMMDD/`:

| File | Content |
|------|---------|
| `AI分析-YYYYMMDD.md` | 中文结论摘要 |
| `AI分析-YYYYMMDD.html` | 彩色表格报告 |
| `AI分析-YYYYMMDD.pdf` | Chrome headless 导出（若可用） |
| `ust_full_pnl_with_coupons.json` | 机器可读结果 |
| `README.txt` | 一句话摘要 |
| `../LATEST.txt` | 指向最新一期 |

## Methodology

1. **成本**：结构票据认购本金 − 实物交割退回零头  
2. **估值**：US Treasury clean price，YTM = Yahoo `^TYX`（30Y）；失败则 fallback  
3. **票息**：明细表 + ONE ACCOUNT 已确认入账；理论票息单列「待确认」  
4. **综合盈亏** = 市值 − 净成本 + 已收票息（含结构期票息）  
5. **已结清**：UG12/RCN8 卖出链路 + SN36  

Details: [references/methodology.md](references/methodology.md)

## Agent workflow

When user asks to run analysis:

1. Read `~/.config/mti-ai-analysis/config.json` if present  
2. Ensure Drobo/network volume mounted when `mti_finance_root` is remote  
3. If workbook is SafeNet-encrypted, ask user to decrypt to Desktop `待解密/`  
4. Run:

```bash
python3 "$SKILL_DIR/scripts/mti_weekly_ust_analysis.py"
```

5. Report summary numbers + path to `AI分析-YYYYMMDD`  
6. Optional: send PDF via WeChat skill to designated contact  

## Schedule (macOS launchd)

- Label: `com.lgh726.mti-ai-analysis.weekly`  
- Trigger: **Monday 11:00** local time  
- Installer: `scripts/install_schedule.sh`  
- Logs: `~/Library/Logs/mti-ai-analysis/`  

## Config keys

See `assets/config.example.json`:

- `ai_root` — archive folder (preferred)  
- `mti_finance_root` — MTI `财务类` path; skill uses `银行理财/AI分析` under it  
- `detail_workbook_candidates` — decrypted xlsx paths  
- `workdir` — local scratch JSON/PDF baseline  
- `account` / `entity` — report labels  
- `fallback_y30` — decimal yield fallback  

## CLI

```bash
python3 scripts/mti_weekly_ust_analysis.py --help
python3 scripts/mti_weekly_ust_analysis.py --asof 2026-08-20
python3 scripts/mti_weekly_ust_analysis.py --y30 0.05181
python3 scripts/mti_weekly_ust_analysis.py --config /path/to/config.json
```

## Security notes

- Do **not** commit decrypted holdings xlsx, ONE ACCOUNT PDFs, or PII  
- Config paths are local-only; example config uses placeholders  
- Reports are for internal portfolio ops, not investment advice  
