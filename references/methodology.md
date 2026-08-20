# Methodology

## Scope

- Cash US Treasuries held at CNCBI One Account after structured-note physical delivery
- Historical coupons paid during note life and after conversion
- Closed conversion chains (e.g. UG12 sold)

## Cost basis

```
net_cost = sum(note_notional - conversion_residual_cash)
```

Residual cash is the small cash residual booked when the note matures into a round Treasury face amount.

## Valuation

Clean price for a fixed-coupon Treasury:

- Coupon frequency: semi-annual
- Discount rate: US 30Y yield (`^TYX` from Yahoo Finance; fallback constant or prior run)
- Maturity: bond final maturity date
- Market value = face × clean_price / 100

Dirty price / accrued interest is **not** mixed into MV when coupons are tracked as separate cash realizations.

## Coupons

Include:

1. Structured-note coupon payments before conversion  
2. Treasury coupon credits after conversion (ONE ACCOUNT / interest advices)

Exclude from total until confirmed:

- Theoretical coupon dates after the latest statement coverage (listed under 待确认)

## P&L bridges

```
price_pnl   = MV - net_cost
total_pnl   = price_pnl + realized_coupons
all_in_pnl  = open_total_pnl + closed_chain_pnl
```

## Closed chains

Example UG12:

```
total = sell_proceeds + coupons - (notional - residual)
```

## Archive naming

```
AI分析-YYYYMMDD/
```

One folder per valuation date. `LATEST.txt` points to the newest folder name.

## Operational caveats

- SafeNet/IRM encrypted workbooks must be decrypted before `openpyxl` can read them  
- Remote volumes should be mounted before schedule fire  
- Yield source moves daily; Monday runs reprice the open book  
