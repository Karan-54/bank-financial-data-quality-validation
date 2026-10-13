# Project Documentation: Bank Financial Data Quality & Validation

## 1. Business problem
Bank financial information may be collected from annual reports, regulatory disclosures, vendor feeds, and structured data submissions. Differences in reporting periods, units, mappings, signs, missing values, and duplicate records can affect downstream analysis. This project simulates a quality-control workflow to detect and document such issues before data is used for analysis.

## 2. Scope and tools
- Excel: formulas, filters, exception tracking, KPI dashboard.
- PostgreSQL: structured storage, profiling, SQL rule checks, ratio calculations, and source reconciliation.
- Synthetic data: fictional bank names and figures only.

## 3. Data dictionary
| Field | Meaning |
|---|---|
| bank_id | Synthetic bank identifier |
| report_date | Financial reporting date |
| accounting_standard | Synthetic reporting basis label |
| source_name | Source label, such as Annual Report or Vendor Feed |
| total_assets | Reported assets |
| total_liabilities | Reported liabilities |
| total_equity | Reported equity |
| gross_loans | Gross loan portfolio |
| npl_amount | Non-performing loan amount |
| total_deposits | Customer deposits |
| interest_income | Interest income |
| interest_expense | Interest expense |
| net_income | Net income |
| risk_weighted_assets | Risk-weighted assets |
| regulatory_capital | Regulatory capital used for simplified CAR |
| *_reported | Ratios provided by the fictional source |
| allowance_for_loan_losses | Allowance/provision amount |

## 4. Validation rules
1. **Completeness:** flag missing total assets, equity, or net income.
2. **Uniqueness:** flag multiple records for the same bank and report date. In real systems, source, consolidation scope, currency, and accounting basis may be part of the natural key.
3. **Accounting equation:** compare total assets with total liabilities plus equity; flag absolute difference greater than 1 fictional currency unit.
4. **Plausibility:** NPL amount should not exceed gross loans; interest expense should be checked for negative values; deposits should be positive for this simplified dataset; risk-weighted assets should be positive.
5. **Ratio reconciliation:** recalculate ratios and compare with source-reported ratios using a 0.5 percentage-point tolerance.
6. **Source reconciliation:** compare Annual Report and Vendor Feed for assets, liabilities, equity, and net income.

A flagged value is not automatically incorrect. It is a cue to investigate the source, reporting scope, unit, sign convention, or mapping.

## 5. Banking ratios
- **NPL ratio** = NPL amount / gross loans.
- **CAR** = regulatory capital / risk-weighted assets.
- **ROA** = net income / total assets (simplified; average assets are often preferred).
- **ROE** = net income / total equity (simplified; average equity may be preferred).
- **NIM proxy** = (interest income − interest expense) / total assets. Proper net interest margin normally divides net interest income by average interest-earning assets. The proxy is used only because average earning assets are not supplied.

Use `NULLIF` in SQL or `IFERROR` in Excel to prevent divide-by-zero errors.

## 6. Expected seeded exceptions (by design)
- B003: missing total equity.
- B007: missing net income.
- B002: duplicate bank-period record from two source labels.
- B004: assets do not equal liabilities plus equity.
- B005: NPL amount exceeds gross loans.
- B006: negative interest expense requiring sign-convention/source review.
- B009: zero deposits.
- B008: Annual Report vs Vendor Feed asset discrepancy.
- B011: Annual Report vs Vendor Feed net income discrepancy.
- Other ratio mismatches may be detected based on the comparison tolerance and should be investigated, not automatically “fixed.”

These are test conditions intentionally embedded in the synthetic data, not findings about any real bank.

## 7. Beginner learning plan
### Session 1 — Understand the data (45–60 minutes)
Read this document and the workbook `Read_Me`. Explain each column in your own words. Identify the natural key and why bank ID alone is not enough.

### Session 2 — Excel checks (60–90 minutes)
Filter the Validation sheet. Click into formulas for missing values, duplicate detection, accounting equation, and ratio calculation. Change a test value in a copy of the workbook and observe whether the rule changes. Keep the original raw data intact.

### Session 3 — PostgreSQL (60–90 minutes)
Create the schema and tables. Import the CSVs. Run SQL queries one at a time. For every result, write: what was flagged, why it matters, what source should be checked, and what evidence is required to resolve it.

### Session 4 — Reconciliation (45–60 minutes)
Compare Annual Report with Vendor Feed. A source hierarchy should be defined by the business, but public filings are often an authoritative reference for the reported statement. Confirm the same period, consolidation level, currency, units, and line-item definition before choosing a value.

### Session 5 — Dashboard and presentation (45 minutes)
Review the Dashboard, then prepare a 3-minute explanation of the pipeline, seeded defects, key rules, limitations, and how you would prevent recurring errors.

## 8. Operational best practices
- Keep immutable raw data and use a separate curated/approved layer.
- Log rule ID, bank ID, period, source, severity, detected timestamp, reviewer, evidence, proposed action, status, and resolution timestamp.
- Do not delete duplicates until you establish whether they are duplicate ingestion, different source records, restatements, or different consolidation scopes.
- Never fill missing values based on guesses.
- Document units, currency, accounting standard, period, consolidation scope, and sign convention.
- Use thresholds agreed by the business, not arbitrary universal thresholds.
- Make the validation process repeatable and re-run checks after any approved correction.

## 9. Resume bullets — use only after you personally run and verify the project
- Built a synthetic bank financial data quality workflow using Excel and PostgreSQL to validate completeness, duplicate records, accounting equation consistency, financial ratios, and source-to-source discrepancies.
- Developed SQL checks and an Excel exception tracker/dashboard to prioritize missing values, implausible figures, and reconciliation differences while preserving raw-data lineage.
- Recalculated NPL ratio, CAR, ROA, ROE, and a clearly labelled NIM proxy; documented assumptions, thresholds, and investigation steps for each exception.

Do not add a quantified impact claim unless you measure it yourself and can explain the calculation.

## 10. Interview questions and answer outlines
**Q1. What is data quality in bank financial data?**  
Completeness, validity, consistency, uniqueness, timeliness, and traceability of financial fields across reporting periods and sources.

**Q2. How would you validate total assets?**  
Check presence, numeric type, units/currency, period, sign/plausibility, accounting equation, historical trend, and agreement with an authoritative source.

**Q3. How do you detect duplicates in SQL?**  
Group by the business key and use `HAVING COUNT(*) > 1`. First define the key correctly; bank ID and period may need source, currency, consolidation scope, or filing version.

**Q4. Why not delete duplicate rows immediately?**  
They may represent separate source lineage, restatements, or different reporting scopes. Investigate and preserve audit trail before selecting the canonical record.

**Q5. What does an accounting equation mismatch indicate?**  
Possible missing line items, sign/units errors, mapping issues, rounding, different statement scopes, or an actual source error. It should be investigated rather than automatically corrected.

**Q6. How would you reconcile two sources?**  
Align entity, reporting date, currency, unit scale, accounting basis, consolidation scope, and definition; compare field by field; review the original documents; record source hierarchy and decision.

**Q7. Explain NPL ratio and CAR.**  
NPL ratio measures non-performing loans relative to gross loans. CAR compares eligible regulatory capital with risk-weighted assets. Exact definitions depend on disclosure and regulation.

**Q8. Explain ROA, ROE, and NIM.**  
ROA relates earnings to assets; ROE relates earnings to equity; NIM relates net interest income to average interest-earning assets. This project’s NIM is only a proxy due to missing average earning assets.

**Q9. How do you handle missing data?**  
Flag it, assess criticality, check source documents or another approved source, record evidence and action, and leave it unresolved if evidence is unavailable. Never guess a financial value.

**Q10. What would you do if a ratio differs from the reported ratio?**  
Check numerator/denominator definitions, average vs closing balances, units, period, sign convention, rounding, and source methodology before raising or closing the exception.

**Q11. How do Excel and SQL complement each other?**  
SQL provides repeatable scalable checks and structured reconciliation; Excel supports quick review, formula-based controls, filtering, exception notes, and communication with nontechnical reviewers.

**Q12. How would you explain a data issue to a stakeholder?**  
State the entity and period, field and source, expected vs observed value, business impact, evidence needed, owner, due date, and current status in clear language.

## 11. Suggested portfolio presentation
1. Problem and scope (synthetic data).
2. Data model and source fields.
3. Validation rules and thresholds.
4. SQL examples and result interpretation.
5. Excel dashboard and exception log.
6. Two-source reconciliation example.
7. Limitations and next improvements: automated import, audit history, trend checks, currency/unit normalization, and tests across reporting periods.
