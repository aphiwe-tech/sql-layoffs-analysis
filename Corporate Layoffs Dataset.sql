-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- DATA EXPLOARTION  Project (A Mbotho)
-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++



-- 0. Optional: Drop staging table if it already exists
DROP TABLE IF EXISTS layoffs_staging;

-- 1. Create staging table
CREATE TABLE layoffs_staging LIKE layoffs;

-- 2. Insert data into staging table

INSERT INTO layoffs_staging
SELECT *
FROM layoffs;

-- 3. Fix the `date` column


-- 3a. Add a temporary column for proper DATE conversion
ALTER TABLE layoffs_staging
ADD COLUMN date_fixed DATE;

-- 3b. Disable safe updates temporarily (avoids Error 1175)
SET SQL_SAFE_UPDATES = 0;

-- 3c. Convert existing `date` values to proper DATE, handling single-digit months/days
UPDATE layoffs_staging
SET date_fixed = STR_TO_DATE(`date`, '%c/%e/%Y')
WHERE `date` IS NOT NULL;

-- 3d. Re-enable safe updates
SET SQL_SAFE_UPDATES = 1;

-- 3e. Verify conversion
SELECT `date`, date_fixed
FROM layoffs_staging
LIMIT 10;

-- 3f. Drop old `date` column and rename the fixed column
ALTER TABLE layoffs_staging
DROP COLUMN `date`;

ALTER TABLE layoffs_staging
CHANGE COLUMN date_fixed `date` DATE;

-- 4. Verify final staging table

SELECT *
FROM layoffs_staging
LIMIT 10;

-- ============================
-- 5. Analysis Queries

-- Maximum people laid off, maximum percentage laid off
SELECT MAX(total_laid_off) AS max_laid_off, MAX(percentage_laid_off) AS max_percentage
FROM layoffs_staging;

--  Companies completely laid off
SELECT *
FROM layoffs_staging
WHERE percentage_laid_off = 1
ORDER BY total_laid_off DESC;
-- The Katerra company was completely laid off and had the most people laid off

--  Sum of total laid-off people by company
SELECT company, SUM(total_laid_off) AS total_laid_off
FROM layoffs_staging
GROUP BY company
ORDER BY total_laid_off DESC;
-- Amazon had the most laid-offs

--  Dates when layoffs started and ended for each company
SELECT company, MIN(`date`) AS start_date, MAX(`date`) AS end_date
FROM layoffs_staging
GROUP BY company;

--  Industry with the most layoffs
SELECT industry, SUM(total_laid_off) AS total_laid_off
FROM layoffs_staging
GROUP BY industry
ORDER BY total_laid_off DESC;
-- Consumer industry was the most laid off

--  Country with the most layoffs
SELECT country, SUM(total_laid_off) AS total_laid_off
FROM layoffs_staging
GROUP BY country
ORDER BY total_laid_off DESC;
-- USA had the most laid-offs

--  Individual date with the most layoffs
SELECT `date`, SUM(total_laid_off) AS total_laid_off
FROM layoffs_staging
GROUP BY `date`
ORDER BY total_laid_off DESC;
-- On 1/4/2023 the highest number of people got laid off

--  Stage at which companies got laid off
SELECT stage, SUM(total_laid_off) AS total_laid_off
FROM layoffs_staging
GROUP BY stage;

-- rollig total of layoffs based on months (calcualte the total month increases)
SELECT SUBSTRING(`date`, 1, 7) AS `Month`, sum(total_laid_off)
FROM layoffs_staging
where SUBSTRING(`date`, 1, 7)  is not null
group by `Month`
order by 1 asc;


-- how many were this companies laying out per year 
SELECT company, SUM(total_laid_off) 
FROM layoffs_staging
GROUP BY company
order by 2 desc;


SELECT company, Year(`date`), SUM(total_laid_off) 
FROM layoffs_staging
GROUP BY company, Year(`date`)
order by 3 desc;




































































































