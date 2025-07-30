-- Exploratory Data Analysis

SELECT *
FROM layoffs_staging2;

SELECT MAX(total_laid_off), MAX(percentage_laid_off)
FROM layoffs_staging2;

SELECT *
FROM layoffs_staging2
WHERE percentage_laid_off = 1
ORDER BY funds_raised_millions DESC;

SELECT company, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company
ORDER BY 2 DESC;

SELECT industry, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY industry
ORDER BY 2 DESC;

SELECT MIN('date'), MAX('date')
FROM layoffs_staging2;

SELECT *
FROM layoffs_staging2
ORDER BY total_laid_off DESC;

SELECT country, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY country
ORDER BY 2 DESC;

SELECT YEAR (date), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY YEAR (date)
ORDER BY 2 DESC;

SELECT company, SUM(percentage_laid_off)
FROM layoffs_staging2
GROUP BY company
ORDER BY 2 DESC;

SELECT industry, SUM(percentage_laid_off)
FROM layoffs_staging2
GROUP BY industry
ORDER BY 2 DESC;

SELECT country, SUM(percentage_laid_off)
FROM layoffs_staging2
GROUP BY country
ORDER BY 2 DESC;


SELECT industry, AVG(percentage_laid_off)
FROM layoffs_staging2
GROUP BY industry
ORDER BY 2 DESC;

SELECT SUBSTRING(date,1,7) AS MONTH, SUM(total_laid_off)
FROM layoffs_staging2
WHERE SUBSTRING(date,1,7) IS NOT NULL
GROUP BY MONTH
ORDER BY 1;


WITH Rolling_Total AS
(
SELECT SUBSTRING(date,1,7) AS MONTH, SUM(total_laid_off) AS total_off
FROM layoffs_staging2
WHERE SUBSTRING(date,1,7) IS NOT NULL
GROUP BY MONTH
ORDER BY 1
)
SELECT MONTH, total_off,
SUM(total_off) OVER(ORDER BY MONTH) AS rolling_total
FROM Rolling_Total;

SELECT company, YEAR(date), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company, YEAR(date)
ORDER BY company ASC;


SELECT company, YEAR(date), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company, YEAR(date)
ORDER BY 3 DESC;
 
-- Step 1: Create a Common Table Expression (CTE) named Company_Year
-- This CTE groups the data by company and year, 
-- then calculates the total layoffs per company per year

WITH Company_Year (company, years, total_laid_off) AS
(
SELECT company, YEAR(date), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company, YEAR(date)
), Company_Year_Rank AS
(SELECT *, 
DENSE_RANK() OVER (PARTITION BY years ORDER BY total_laid_off DESC) AS Ranking
FROM Company_Year
WHERE years IS NOT NULL
)
SELECT *
FROM Company_Year_Rank
WHERE Ranking <= 5
;

-- Basic snapshot of the dataset
SELECT COUNT(*) AS row_count, 
       COUNT(DISTINCT company) AS unique_companies,
       COUNT(DISTINCT industry) AS unique_industries,
       MIN(date) AS earliest_date,
       MAX(date) AS latest_date
FROM layoffs_staging2;

-- Overall scale
SELECT SUM(total_laid_off) AS total_laid_offs, 
       MAX(total_laid_off) AS max_layoff_in_single_event, 
       MAX(percentage_laid_off) AS max_layoff_percentage
FROM layoffs_staging2;

-- Companies with 100% layoffs
SELECT *
FROM layoffs_staging2
WHERE percentage_laid_off = 1
ORDER BY funds_raised_millions DESC;

-- Top 10 companies by total layoffs
SELECT company, SUM(total_laid_off) AS total
FROM layoffs_staging2
GROUP BY company
ORDER BY total DESC
LIMIT 10;

-- Industries hit hardest
SELECT industry, SUM(total_laid_off) AS total
FROM layoffs_staging2
GROUP BY industry
ORDER BY total DESC;

-- Layoffs by country
SELECT country, SUM(total_laid_off) AS total
FROM layoffs_staging2
GROUP BY country
ORDER BY total DESC;

-- Countries by average layoff severity
SELECT country, AVG(percentage_laid_off) AS avg_severity
FROM layoffs_staging2
GROUP BY country
ORDER BY avg_severity DESC;

-- Total layoffs by year
SELECT YEAR(date) AS year, SUM(total_laid_off) AS total
FROM layoffs_staging2
GROUP BY year
ORDER BY year;

-- Monthly trend of layoffs
SELECT DATE_FORMAT(date, '%Y-%m') AS month, 
       SUM(total_laid_off) AS monthly_layoffs
FROM layoffs_staging2
GROUP BY month
ORDER BY month;

-- Rolling total of layoffs by month
WITH Monthly_Sum AS (
    SELECT DATE_FORMAT(date, '%Y-%m') AS month, 
           SUM(total_laid_off) AS total
    FROM layoffs_staging2
    GROUP BY month
)
SELECT month, total,
       SUM(total) OVER (ORDER BY month) AS rolling_total
FROM Monthly_Sum;

-- Relationship between layoffs and funding
SELECT funds_raised_millions, total_laid_off, company
FROM layoffs_staging2
WHERE funds_raised_millions IS NOT NULL
ORDER BY total_laid_off DESC;

-- Companies with high funding but layoffs
SELECT company, SUM(funds_raised_millions) AS total_funding, 
       SUM(total_laid_off) AS total_laid_off
FROM layoffs_staging2
GROUP BY company
HAVING total_funding > 100 AND total_laid_off > 500
ORDER BY total_laid_off DESC;

-- Industry average layoff severity
SELECT industry, AVG(percentage_laid_off) AS avg_percentage
FROM layoffs_staging2
GROUP BY industry
ORDER BY avg_percentage DESC;

-- Companies with highest average layoff percentage
SELECT company, AVG(percentage_laid_off) AS avg_percentage
FROM layoffs_staging2
GROUP BY company
HAVING COUNT(*) > 1
ORDER BY avg_percentage DESC
LIMIT 10;