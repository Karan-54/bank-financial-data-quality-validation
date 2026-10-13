# Bank Financial Data Quality & Validation Project

## Objective
Build a beginner-friendly quality-control workflow for fictional bank financial statement data using Excel and PostgreSQL. The project mirrors common financial-data operations: profiling, validation, exception logging, source reconciliation, ratio recalculation, and documented remediation.

## Data ethics
All banks, figures, and defects in this package are synthetic and created for learning. This is not Moody's Analytics/BankFocus data, and it is not a regulatory reporting template.

## Files
- `bank_financial_raw.csv` — 13 raw rows, including a seeded duplicate.
- `source_comparison.csv` — paired Annual Report and Vendor Feed values for source reconciliation.
- `bank_data_quality.sql` — PostgreSQL schema and validation queries.
- `bank_data_quality_workbook.xlsx` — raw data, source comparison, formula checks, exception log, dashboard, and read-me.
- `PROJECT_DOCUMENTATION.md` — project method, rule definitions, ratio definitions, learning plan, interview prep.

## Beginner workflow
1. Open the workbook and read `Read_Me`.
2. Inspect `Raw_Data`; do not edit the source values to remove exceptions.
3. Review `Validation` and filter columns marked `EXCEPTION`, `CHECK`, or `REVIEW`.
4. Work through `Exception_Log`; leave status `Open` until you verify an authoritative source.
5. Import both CSVs into PostgreSQL using the schema in the SQL script. If using pgAdmin, create the schema/tables by running the DDL first, then use Import/Export for each table. Match CSV columns to table columns and treat blank cells as NULL.
6. Run each numbered SQL section and compare findings with Excel.
7. Reconcile source differences and write down why a source was selected. Never silently overwrite source data.
8. Refresh/check Excel formulas after opening in desktop Excel or LibreOffice; formula calculation may not be evaluated by every previewer.

## SQL import note
The SQL file includes commented `\copy` examples for `psql`. Replace the example paths with your local absolute paths. Because the raw table has a generated `record_id`, import only the CSV columns listed in the command.

## Important ratio caveats
- NPL ratio = NPL amount / gross loans.
- CAR = regulatory capital / risk-weighted assets. Actual regulatory CAR depends on applicable regulatory definitions and capital tiers.
- ROA = net income / total assets in this simple example. Many analyses use average assets.
- ROE = net income / total equity. Average equity may be preferred in formal analysis.
- NIM proxy = (interest income - interest expense) / total assets. Proper NIM typically uses average interest-earning assets; this proxy is explicitly labelled because the dataset does not provide them.
- All amounts are fictional currency units and ratios are stored as decimals.

## Suggested acceptance criteria
- Missing critical fields are flagged, not imputed automatically.
- Duplicate bank-period records are identified and traced to source.
- Accounting equation differences above the chosen tolerance are flagged.
- Logic/range checks catch impossible or suspicious relationships.
- Reported and calculated ratios are compared with a documented tolerance.
- Source-to-source discrepancies are identified and recorded.
- Every exception has severity, owner/reviewer, investigation note, action, and status.
- Raw data remains unchanged and all correction decisions are traceable.
