USE `layoffs_dataset`;

SET SQL_SAFE_UPDATES = 0;

-- ==========================================
-- 1. REMOVE DUPLICATES
-- ==========================================
###Create a staging table to protect raw dataset
DROP TABLE IF EXISTS `layoff_staging`;
CREATE TABLE `layoff_staging` LIKE `layoffs_dataset`;

INSERT INTO `layoff_staging`
SELECT * FROM `layoffs_dataset`;

DROP TABLE IF EXISTS `layoff_staging2`;
CREATE TABLE `layoff_staging2` (
  `company` TEXT,
  `location` TEXT,
  `industry` TEXT,
  `total_laid_off` TEXT,
  `percentage_laid_off` TEXT,
  `date` TEXT,
  `stage` TEXT,
  `country` TEXT,
  `funds_raised_millions` TEXT,
  `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

INSERT INTO `layoff_staging2`
SELECT *,
  ROW_NUMBER() OVER(
    PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions
  ) AS row_num
FROM `layoff_staging`;
#Records with identical values across all available columns are treated as duplicates and only one record is retained.

DELETE FROM `layoff_staging2`
WHERE row_num > 1;

SELECT COUNT(*) FROM `layoff_staging2`
GROUP BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions
HAVING COUNT(*) > 1;

-- ==========================================
-- 2. STANDARDIZE THE DATA
-- ==========================================
UPDATE `layoff_staging2`
SET company = TRIM(company);

UPDATE `layoff_staging2`
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';

UPDATE `layoff_staging2`
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE 'United States%';

-- Làm sạch ký tự \r ẩn ở cuối dòng CSV và chuyển 'NULL' thành NULL thật 
UPDATE `layoff_staging2`
SET `date` = NULLIF(NULLIF(TRIM(REPLACE(`date`, '\r', '')), ''), 'NULL'),
    `total_laid_off` = NULLIF(NULLIF(TRIM(REPLACE(`total_laid_off`, '\r', '')), ''), 'NULL'),
    `funds_raised_millions` = NULLIF(NULLIF(TRIM(REPLACE(`funds_raised_millions`, '\r', '')), ''), 'NULL'),
    `industry` = NULLIF(NULLIF(TRIM(REPLACE(`industry`, '\r', '')), ''), 'NULL'),
    `percentage_laid_off` = NULLIF(NULLIF(TRIM(REPLACE(`percentage_laid_off`, '\r', '')), ''), 'NULL');

UPDATE `layoff_staging2`
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

ALTER TABLE `layoff_staging2`
MODIFY COLUMN `date` DATE,
MODIFY COLUMN `total_laid_off` INT,
MODIFY COLUMN `percentage_laid_off` DECIMAL,
MODIFY COLUMN `funds_raised_millions` DECIMAL;

-- ==========================================
-- 3. NULL AND BLANK VALUES
-- ==========================================
SELECT *
FROM `layoff_staging` 
WHERE industry IS NULL;

SELECT *
FROM `layoff_staging2` t1
JOIN `layoff_staging2` t2
  ON t1.company = t2.company
WHERE t1.industry IS NULL
  AND t2.industry IS NOT NULL;

UPDATE `layoff_staging2` t1
JOIN `layoff_staging2` t2
  ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry IS NULL
  AND t2.industry IS NOT NULL;

-- ==========================================
-- 4. REMOVE UNNECESSARY ROWS & COLUMNS
-- ==========================================
DELETE FROM `layoff_staging2`
WHERE total_laid_off IS NULL
  AND percentage_laid_off IS NULL;

ALTER TABLE `layoff_staging2`
DROP COLUMN row_num;

SET SQL_SAFE_UPDATES = 1;

-- Check cleaning table 
SELECT * FROM `layoff_staging2`;