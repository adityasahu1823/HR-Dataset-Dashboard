SELECT 
Performance_Rating,
COUNT(*) AS total_employees,
ROUND(100.0* COUNT(*)/SUM(COUNT(*)) OVER(),2)AS Percentage
from hr_cleaned
GROUP BY Performance_Rating
ORDER BY total_employees DESC; 

SELECT 
	Department,
	Performance_Rating,
	ROUND(100.0* COUNT(*)/SUM(COUNT(*))OVER(),2)AS Percentage,
	COUNT(*) AS total_employees
FROM hr_cleaned
GROUP BY Department,Performance_Rating
ORDER BY total_employees DESC;

SELECT Performance_Rating,
	   Job_Level,
	   count(*) AS total_employees,
	   ROUND(100.0*COUNT(*)/SUM(COUNT(*))OVER(),2)AS Percentage
FROM hr_cleaned
GROUP BY Job_Level,Performance_Rating
ORDER BY total_employees DESC;

SELECT Performance_Rating,
COUNT(*)AS total_employees,
ROUND(AVG(Salary)::numeric,2)as avg_salary,
ROUND(MIN(Salary)::numeric,2)as min_salary,
ROUND(MAX(Salary)::numeric,2)as max_salary
FROM hr_cleaned
GROUP BY Performance_Rating
ORDER BY total_employees DESC;

SELECT 
	Work_Mode,
	Performance_Rating,
	COUNT(*)AS total_employees,
	ROUND(AVG(Salary)::numeric,2)as avg_salary,
	ROUND(MIN(Salary)::numeric,2)as min_salary,
	ROUND(MAX(Salary)::numeric,2)as max_salary
FROM hr_cleaned
GROUP BY Work_Mode,Performance_Rating
ORDER BY total_employees DESC;

SELECT
    CASE
        WHEN Experience_Years < 5  THEN '0-5 years'
        WHEN Experience_Years < 10 THEN '5-10 years'
        WHEN Experience_Years < 15 THEN '10-15 years'
        WHEN Experience_Years < 20 THEN '15-20 years'
        ELSE 'Above 20 years'
    END AS experience_band,
    Performance_Rating,
    COUNT(*) AS total_employees,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER(
        PARTITION BY CASE
            WHEN Experience_Years < 5  THEN '0-5 years'
            WHEN Experience_Years < 10 THEN '5-10 years'
            WHEN Experience_Years < 15 THEN '10-15 years'
            WHEN Experience_Years < 20 THEN '15-20 years'
            ELSE 'Above 20 years'
        END
    ), 2) AS pct_within_band
FROM hr_cleaned
GROUP BY experience_band, Performance_Rating
ORDER BY MIN(Experience_Years), total_employees DESC;

SELECT 
	Department,
	COUNT(*)AS total_employees,
	COUNT(*) FILTER(WHERE Performance_Rating='Excellent')as Excellent_Performance,
	ROUND(100.0 * COUNT(*) FILTER(WHERE Performance_Rating='Excellent')/count(*),2)as excellent_pct
FROM hr_cleaned
GROUP BY Department
ORDER BY excellent_pct DESC;


SELECT
    Performance_Rating,
    COUNT(*) AS total_employees,
    COUNT(*) FILTER (WHERE Status IN ('Resigned', 'Terminated')) AS attrited,
    ROUND(100.0 * COUNT(*) FILTER (WHERE Status IN ('Resigned', 'Terminated')) / COUNT(*), 2) AS attrition_rate_pct,
    ROUND(AVG(Salary)::NUMERIC, 2) AS avg_salary
FROM hr_cleaned
GROUP BY Performance_Rating
ORDER BY attrition_rate_pct DESC;

WITH top_performers AS (
    SELECT
        Employee_ID,
        Full_Name,
        Department,
        Job_Level,
        Salary,
        Experience_Years,
        Performance_Rating
    FROM hr_cleaned
    WHERE Performance_Rating = 'Excellent'
),
dept_summary AS (
    SELECT
        Department,
        COUNT(*) AS excellent_employees,
        ROUND(AVG(Salary)::NUMERIC, 2) AS avg_salary_top_performers,
        ROUND(AVG(Experience_Years)::NUMERIC, 1) AS avg_experience
    FROM top_performers
    GROUP BY Department
)
SELECT * FROM dept_summary
ORDER BY excellent_employees DESC;


SELECT
    Department,
    Performance_Rating,
    COUNT(*) AS total,
    RANK() OVER (
        PARTITION BY Department 
        ORDER BY COUNT(*) DESC
    ) AS performance_rank,
    ROUND(AVG(Salary)::NUMERIC, 2) AS avg_salary
FROM hr_cleaned
GROUP BY Department, Performance_Rating
ORDER BY Department, performance_rank;


WITH perf_summary AS (
    SELECT
        Department,
        Job_Level,
        Performance_Rating,
        COUNT(*) AS total_employees,
        ROUND(AVG(Salary)::NUMERIC, 2) AS avg_salary,
        ROUND(AVG(Experience_Years)::NUMERIC, 1) AS avg_experience,
        COUNT(*) FILTER (WHERE Status IN ('Resigned','Terminated')) AS attrited
    FROM hr_cleaned
    GROUP BY Department, Job_Level, Performance_Rating
)
SELECT
    *,
    ROUND(100.0 * attrited / total_employees, 2) AS attrition_pct,
    RANK() OVER (PARTITION BY Department ORDER BY avg_salary DESC) AS salary_rank
FROM perf_summary
ORDER BY Department, avg_salary DESC;