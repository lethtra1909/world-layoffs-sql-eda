# World Layoffs — SQL Data Cleaning & Exploratory Data Analysis

## Overview
End-to-end SQL project cleaning and analyzing global tech layoff trends using MySQL. The workflow covers raw data standardization, deduplication, null handling, and multi-dimensional exploratory & time-series analysis.

## Repository Structure
    world-layoffs-sql-eda/
    ├── data/
    │   └── layoffs_dataset.csv          # Raw dataset
    ├── sql/
    │   ├── 01_data_cleaning.sql         # Staging tables, deduplication, standardization
    │   ├── 02_exploratory_analysis.sql  # Aggregations by company, industry, country, stage
    │   └── 03_advanced_analysis.sql     # Rolling totals, yearly top-N rankings (CTEs & Window Functions)
    ├── reports/
    │   ├── eda_findings.md              # Key analytical insights & summary
    │   └── visualizations/              # Charts exported from BI tools / Python
    └── README.md

## Workflow & Methodology
1. **Data Cleaning (`01_data_cleaning.sql`)**:
   - Created staging tables to preserve raw data integrity.
   - Removed duplicate records using `ROW_NUMBER()` partitioned across key attributes.
   - Standardized text fields (trimmed whitespace, unified industry labels like `Crypto`, cleaned trailing punctuation in country names) and converted `date` strings to `DATE` format.
   - Imputed missing `industry` values via self-joins and removed unanalyzable rows where both `total_laid_off` and `percentage_laid_off` were null.
2. **Exploratory Analysis (`02_exploratory_analysis.sql`)**:
   - Analyzed layoff distribution across companies, industries, countries, funding stages, and time periods.
3. **Advanced Analysis (`03_advanced_analysis.sql`)**:
   - Computed monthly rolling totals of layoffs and ranked top 5 companies by layoffs per year using CTEs and `DENSE_RANK()`.

## Key Findings
See [`reports/eda_findings.md`](reports/eda_findings.md) for detailed metrics and takeaways.
