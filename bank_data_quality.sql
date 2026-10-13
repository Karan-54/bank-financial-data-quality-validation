-- Bank Financial Data Quality & Validation Project
-- PostgreSQL | Synthetic fictional data only
-- Run sections in order. Import the two CSV files using pgAdmin Import/Export or \copy.

CREATE SCHEMA IF NOT EXISTS bank_dq;
SET search_path TO bank_dq;

DROP TABLE IF EXISTS source_comparison;
DROP TABLE IF EXISTS bank_financial_raw;

CREATE TABLE bank_financial_raw (
    record_id BIGSERIAL PRIMARY KEY,
    bank_id TEXT NOT NULL,
    bank_name TEXT,
    country TEXT,
    report_date DATE,
    accounting_standard TEXT,
    source_name TEXT,
    total_assets NUMERIC(18,2),
    total_liabilities NUMERIC(18,2),
    total_equity NUMERIC(18,2),
    gross_loans NUMERIC(18,2),
    npl_amount NUMERIC(18,2),
    total_deposits NUMERIC(18,2),
    interest_income NUMERIC(18,2),
    interest_expense NUMERIC(18,2),
    net_income NUMERIC(18,2),
    risk_weighted_assets NUMERIC(18,2),
    regulatory_capital NUMERIC(18,2),
    npl_ratio_reported NUMERIC(10,6),
    car_reported NUMERIC(10,6),
    roa_reported NUMERIC(10,6),
    roe_reported NUMERIC(10,6),
    nim_reported NUMERIC(10,6),
    allowance_for_loan_losses NUMERIC(18,2)
);

CREATE TABLE source_comparison (
    source_row_id BIGSERIAL PRIMARY KEY,
    bank_id TEXT,
    bank_name TEXT,
    report_date DATE,
    source_name TEXT,
    total_assets NUMERIC(18,2),
    total_liabilities NUMERIC(18,2),
    total_equity NUMERIC(18,2),
    net_income NUMERIC(18,2)
);

-- If using psql, update the paths to your local file paths and run:
-- \copy bank_dq.bank_financial_raw(bank_id,bank_name,country,report_date,accounting_standard,source_name,total_assets,total_liabilities,total_equity,gross_loans,npl_amount,total_deposits,interest_income,interest_expense,net_income,risk_weighted_assets,regulatory_capital,npl_ratio_reported,car_reported,roa_reported,roe_reported,nim_reported,allowance_for_loan_losses) FROM '/absolute/path/bank_financial_raw.csv' CSV HEADER NULL ''
-- \copy bank_dq.source_comparison(bank_id,bank_name,report_date,source_name,total_assets,total_liabilities,total_equity,net_income) FROM '/absolute/path/source_comparison.csv' CSV HEADER NULL ''

-- 1) Basic row count and coverage
SELECT COUNT(*) AS row_count,
       COUNT(DISTINCT bank_id) AS unique_banks,
       COUNT(DISTINCT report_date) AS reporting_dates
FROM bank_financial_raw;

-- 2) Missing critical values
SELECT bank_id, bank_name, report_date,
       CASE WHEN total_assets IS NULL THEN 'MISSING_TOTAL_ASSETS' END AS assets_issue,
       CASE WHEN total_equity IS NULL THEN 'MISSING_TOTAL_EQUITY' END AS equity_issue,
       CASE WHEN net_income IS NULL THEN 'MISSING_NET_INCOME' END AS income_issue
FROM bank_financial_raw
WHERE total_assets IS NULL OR total_equity IS NULL OR net_income IS NULL;

-- 3) Duplicate bank-period records (review source before deleting)
SELECT bank_id, report_date, COUNT(*) AS duplicate_count,
       STRING_AGG(source_name, ', ' ORDER BY source_name) AS sources
FROM bank_financial_raw
GROUP BY bank_id, report_date
HAVING COUNT(*) > 1;

-- 4) Accounting equation: assets should approximately equal liabilities + equity.
-- Tolerance of 1 unit is illustrative; real workflows should define policy by currency/rounding.
SELECT bank_id, bank_name, report_date, total_assets,
       total_liabilities + total_equity AS liabilities_plus_equity,
       total_assets - (total_liabilities + total_equity) AS difference
FROM bank_financial_raw
WHERE total_assets IS NOT NULL AND total_liabilities IS NOT NULL
  AND total_equity IS NOT NULL
  AND ABS(total_assets - (total_liabilities + total_equity)) > 1;

-- 5) Range and logic checks
SELECT bank_id, bank_name, report_date, 'NPL_EXCEEDS_GROSS_LOANS' AS issue_type
FROM bank_financial_raw
WHERE npl_amount > gross_loans
UNION ALL
SELECT bank_id, bank_name, report_date, 'NEGATIVE_INTEREST_EXPENSE'
FROM bank_financial_raw WHERE interest_expense < 0
UNION ALL
SELECT bank_id, bank_name, report_date, 'NONPOSITIVE_DEPOSITS'
FROM bank_financial_raw WHERE total_deposits <= 0
UNION ALL
SELECT bank_id, bank_name, report_date, 'NONPOSITIVE_RWA'
FROM bank_financial_raw WHERE risk_weighted_assets <= 0;

-- 6) Recalculate ratios. Amounts are in fictional currency units; ratios are decimals.
SELECT bank_id, bank_name, report_date,
       npl_amount / NULLIF(gross_loans,0) AS npl_ratio_calculated,
       regulatory_capital / NULLIF(risk_weighted_assets,0) AS car_calculated,
       net_income / NULLIF(total_assets,0) AS roa_calculated,
       net_income / NULLIF(total_equity,0) AS roe_calculated,
       (interest_income - interest_expense) / NULLIF(total_assets,0) AS nim_proxy_calculated
FROM bank_financial_raw;

-- 7) Compare calculated ratios to reported values; 0.005 = 0.5 percentage-point tolerance.
WITH ratios AS (
 SELECT *,
   npl_amount / NULLIF(gross_loans,0) AS npl_calc,
   regulatory_capital / NULLIF(risk_weighted_assets,0) AS car_calc,
   net_income / NULLIF(total_assets,0) AS roa_calc,
   net_income / NULLIF(total_equity,0) AS roe_calc,
   (interest_income - interest_expense) / NULLIF(total_assets,0) AS nim_proxy_calc
 FROM bank_financial_raw
)
SELECT bank_id, bank_name, report_date,
       CASE WHEN npl_calc IS NOT NULL AND npl_ratio_reported IS NOT NULL
                 AND ABS(npl_calc-npl_ratio_reported) > 0.005 THEN 'NPL_RATIO_MISMATCH' END AS npl_check,
       CASE WHEN car_calc IS NOT NULL AND car_reported IS NOT NULL
                 AND ABS(car_calc-car_reported) > 0.005 THEN 'CAR_MISMATCH' END AS car_check,
       CASE WHEN roa_calc IS NOT NULL AND roa_reported IS NOT NULL
                 AND ABS(roa_calc-roa_reported) > 0.005 THEN 'ROA_MISMATCH' END AS roa_check,
       CASE WHEN roe_calc IS NOT NULL AND roe_reported IS NOT NULL
                 AND ABS(roe_calc-roe_reported) > 0.005 THEN 'ROE_MISMATCH' END AS roe_check,
       CASE WHEN nim_proxy_calc IS NOT NULL AND nim_reported IS NOT NULL
                 AND ABS(nim_proxy_calc-nim_reported) > 0.005 THEN 'NIM_PROXY_MISMATCH' END AS nim_check
FROM ratios;

-- 8) Source reconciliation: compare Annual Report vs Vendor Feed.
SELECT a.bank_id, a.bank_name, a.report_date,
       a.total_assets AS annual_report_assets, v.total_assets AS vendor_assets,
       a.total_assets - v.total_assets AS assets_difference,
       a.net_income AS annual_report_net_income, v.net_income AS vendor_net_income,
       a.net_income - v.net_income AS net_income_difference
FROM source_comparison a
JOIN source_comparison v
  ON a.bank_id = v.bank_id AND a.report_date = v.report_date
WHERE a.source_name = 'Annual Report' AND v.source_name = 'Vendor Feed'
  AND (
      a.total_assets IS DISTINCT FROM v.total_assets OR
      a.total_liabilities IS DISTINCT FROM v.total_liabilities OR
      a.total_equity IS DISTINCT FROM v.total_equity OR
      a.net_income IS DISTINCT FROM v.net_income
  );

-- 9) Exception register (one row per rule hit; review before remediation)
WITH exceptions AS (
 SELECT bank_id, report_date, 'MISSING_CRITICAL_VALUE' AS issue_type, 'High' AS severity
 FROM bank_financial_raw
 WHERE total_assets IS NULL OR total_equity IS NULL OR net_income IS NULL
 UNION ALL
 SELECT bank_id, report_date, 'DUPLICATE_BANK_PERIOD', 'High'
 FROM bank_financial_raw
 GROUP BY bank_id, report_date HAVING COUNT(*) > 1
 UNION ALL
 SELECT bank_id, report_date, 'BALANCE_SHEET_MISMATCH', 'High'
 FROM bank_financial_raw
 WHERE total_assets IS NOT NULL AND total_liabilities IS NOT NULL AND total_equity IS NOT NULL
   AND ABS(total_assets-total_liabilities-total_equity) > 1
 UNION ALL
 SELECT bank_id, report_date, 'NPL_EXCEEDS_GROSS_LOANS', 'High'
 FROM bank_financial_raw WHERE npl_amount > gross_loans
 UNION ALL
 SELECT bank_id, report_date, 'NEGATIVE_INTEREST_EXPENSE', 'Medium'
 FROM bank_financial_raw WHERE interest_expense < 0
 UNION ALL
 SELECT bank_id, report_date, 'NONPOSITIVE_DEPOSITS', 'High'
 FROM bank_financial_raw WHERE total_deposits <= 0
)
SELECT * FROM exceptions ORDER BY severity, bank_id, issue_type;

-- Important: do not automatically overwrite or delete source data.
-- Keep raw inputs immutable, log the issue, verify against an authoritative source,
-- record the reviewer/action, and publish a corrected/approved layer separately.
