# Bank Financial Data Quality & Validation Project

**Tools:** Microsoft Excel, PostgreSQL SQL  
**Project Type:** Financial Data Quality, Validation & Reconciliation  
**Dataset:** Synthetic banking financial statement data

## 1. Project Overview

This project demonstrates a financial data quality and validation workflow using Microsoft Excel and PostgreSQL. It focuses on checking the completeness, accuracy, consistency, and reliability of fictional bank financial statement data.

The project simulates common data quality tasks performed in financial data operations, including identifying missing values, duplicate records, invalid financial figures, accounting equation mismatches, and discrepancies between data sources.

It also calculates key banking financial ratios and maintains an exception log to document data quality issues and their investigation status.

## 2. Project Objectives

- Identify missing values and duplicate bank-period records.
- Validate financial figures and accounting relationships.
- Check the accounting equation: Assets = Liabilities + Equity.
- Reconcile financial values between two independent sources.
- Calculate and validate key banking financial ratios.
- Document exceptions, severity, investigation notes, and resolution status.
- Compare Excel-based validation results with PostgreSQL SQL queries.

## 3. Key Features

### Data Quality Checks
- Completeness checks for critical fields.
- Duplicate record identification.
- Data type, range, and logical consistency checks.
- Identification of missing, negative, or suspicious financial values.
- Accounting equation validation with a defined tolerance.

### Financial Ratio Analysis
- **NPL Ratio:** Non-performing loans / Gross loans.
- **CAR:** Regulatory capital / Risk-weighted assets.
- **ROA:** Net income / Total assets.
- **ROE:** Net income / Total equity.
- **NIM Proxy:** (Interest income − Interest expense) / Total assets.

### Source Reconciliation
- Comparison of financial figures from an Annual Report source and a Vendor Feed source.
- Identification of mismatched values.
- Documentation of differences and investigation decisions.
- Traceable exception handling without silently overwriting original data.

### Reporting and Documentation
- Excel validation workbook and dashboard.
- PostgreSQL queries for repeatable data quality checks.
- Centralized exception log for issue tracking.
- Documented validation rules, ratio definitions, and limitations.

## 4. Project Files

| File | Description |
|---|---|
| `README.md` | Project overview, setup instructions, and usage guide. |
| `bank_financial_raw.csv` | Synthetic bank financial statement records, including a seeded duplicate for testing. |
| `source_comparison.csv` | Financial values from two fictional sources for reconciliation. |
| `bank_data_quality.sql` | PostgreSQL table definitions and validation queries. |
| `bank_data_quality_workbook.xlsx` | Excel workbook containing raw data, validation checks, source comparison, exception log, dashboard, and instructions. |
| `PROJECT_DOCUMENTATION.md` | Detailed methodology, validation rules, ratio definitions, learning notes, and interview preparation. |

## 5. Dataset and Data Ethics

All banks, financial figures, source records, and data quality issues in this project are synthetic and created for educational purposes.

The project does not use confidential data, BankFocus, bank customer, or proprietary financial data. The fictional source labels are used only to demonstrate reconciliation techniques.

This project is an independent learning exercise and is not affiliated.

## 6. How to Run the Project

### Step 1: Review the Excel Workbook
1. Open `bank_data_quality_workbook.xlsx` in Microsoft Excel or a compatible spreadsheet application.
2. Start with the `Read_Me` sheet.
3. Review the `Raw_Data` sheet to understand the source records.
4. Open the `Validation` sheet and filter for flags such as `EXCEPTION`, `CHECK`, or `REVIEW`.
5. Review the `Exception_Log` and investigate the recorded issues.
6. Explore the source comparison and dashboard sheets.

**Important:** Keep the original raw data unchanged. Record investigation findings and proposed corrections separately.

### Step 2: Set Up PostgreSQL
1. Install PostgreSQL and open pgAdmin or the `psql` command-line tool.
2. Create a database for the project, for example, `bank_data_quality`.
3. Open `bank_data_quality.sql`.
4. Execute the table definitions and schema setup statements.
5. Import `bank_financial_raw.csv` and `source_comparison.csv` into their corresponding tables.
6. Map the CSV columns correctly and import blank cells as `NULL` where appropriate.

Follow the import instructions and column mapping in the SQL script. If using `psql`, update the example file paths in the commented `\copy` commands to match your local paths.

### Step 3: Run the SQL Validation Checks
Execute the numbered SQL sections to identify:
- Missing critical values.
- Duplicate bank-period records.
- Accounting equation mismatches.
- Invalid or suspicious financial values.
- Financial ratio discrepancies.
- Differences between source records.

Compare the SQL results with the corresponding Excel validation outputs.

### Step 4: Investigate and Document Exceptions
For each exception:
1. Identify the affected bank, reporting period, and financial field.
2. Record the validation rule that failed.
3. Investigate the discrepancy against the available source evidence.
4. Document the proposed action and reviewer or owner.
5. Update the status only after the issue has been investigated and the outcome documented.

Do not automatically replace missing values, delete duplicate records, or overwrite conflicting source figures without verification.

### Step 5: Review the Dashboard
Use the Excel dashboard to review the recorded data quality issues and validation results. Check the underlying formulas and refresh or recalculate them in desktop Excel or LibreOffice if necessary.

## 7. Financial Ratio Definitions and Limitations

| Ratio | Calculation | Important Note |
|---|---|---|
| NPL Ratio | Non-performing loans / Gross loans | Assumes both figures use consistent definitions and reporting periods. |
| CAR | Regulatory capital / Risk-weighted assets | Actual regulatory calculations depend on applicable rules and capital definitions. |
| ROA | Net income / Total assets | Uses period-end assets for simplicity; average assets may be more appropriate for performance analysis. |
| ROE | Net income / Total equity | Uses period-end equity for simplicity; average equity may be preferred. |
| NIM Proxy | (Interest income − Interest expense) / Total assets | A simplified proxy, not a formal net interest margin calculation. |

All monetary amounts are expressed in fictional currency units. Ratios are represented as decimals unless the workbook or report explicitly displays them as percentages.

The calculations are intended for learning and should not be interpreted as official regulatory or investment analysis.

## 8. Validation and Acceptance Criteria

The project aims to demonstrate the following controls:

- Critical missing values are flagged rather than automatically imputed.
- Duplicate bank-period records are identified and traceable.
- Accounting equation differences exceeding the configured tolerance are flagged.
- Invalid values and suspicious financial relationships are identified.
- Calculated ratios are compared with reported ratios using documented tolerances where applicable.
- Source-to-source differences are recorded for investigation.
- Exceptions include relevant details, severity, owner or reviewer, investigation notes, proposed action, and status.
- Original source data is preserved so that validation and correction decisions remain traceable.

The presence of an exception does not automatically mean a source figure is incorrect. Each issue requires appropriate investigation and supporting evidence.

## 9. Skills Demonstrated

- Microsoft Excel formulas and data validation.
- Data cleaning and quality checks.
- PostgreSQL SQL queries and aggregations.
- Duplicate and missing-value detection.
- Financial statement reconciliation.
- Accounting equation validation.
- Banking financial ratio calculations.
- Exception logging and issue tracking.
- Financial data analysis and documentation.

## 10. AI Assistance and Learning

AI tools assisted with project planning, synthetic dataset creation, drafting validation formulas and SQL queries, and preparing the documentation.

I used this project as a practical learning exercise to understand how financial data quality checks can support reliable financial datasets. I reviewed the workflow and used it to practise validation, source reconciliation, exception tracking, and banking ratio calculations.

AI-generated formulas, queries, and calculations should be independently tested and verified before use in real financial reporting or production systems.

## 11. Disclaimer

This is an educational portfolio project based on synthetic data. It is not an official data or BankFocus project, a regulatory reporting template, or a production-ready banking validation system.

The project demonstrates foundational financial data quality concepts and is intended for learning and portfolio purposes only.
