--salary information 

select 
count(*) as total_employee
, ROUND(AVG(Salary)::numeric,2)as avg_salary,
  ROUND(MIN(Salary)::numeric,2)as min_salary,
  ROUND(MAX(Salary)::numeric,2)as max_salary,
  ROUND(PERCENTILE_CONT(0.5) WITHIN GROUP(ORDER BY Salary)::numeric,2)AS median_salary
  FROM hr_cleaned;

select 
	Department,
	COUNT(*)AS total_employee,
	ROUND(AVG(Salary)::numeric,2)as avg_salary,
	ROUND(MIN(Salary)::numeric,2)as min_salary,
	ROUND(MAX(Salary)::numeric,2)as max_salary,
	ROUND(PERCENTILE_CONT(0.5) WITHIN GROUP(ORDER BY Salary)::numeric,2)as median_salary
FROM hr_cleaned 
GROUP BY Department;

SELECT 
	Job_Level,
	COUNT(*)AS total_employee,
	ROUND(AVG(Salary)::numeric,2)as avg_salary,
	ROUND(MIN(Salary)::numeric,2)as min_salary,
	ROUND(MAX(Salary)::numeric,2)as max_salary,
	ROUND(PERCENTILE_CONT(0.5) WITHIN GROUP(ORDER BY Salary)::numeric,2)as median_salary
FROM hr_cleaned
GROUP BY Job_Level;

SELECT 
	Job_Level,
	Department,
	COUNT(*) AS total_employee,
	ROUND(AVG(Salary)::numeric,2)AS avg_salary,
	ROUND(MIN(Salary)::numeric,2)as min_salary,
	ROUND(MAX(Salary)::numeric,2)as max_salary,
	ROUND(PERCENTILE_CONT(0.5) WITHIN GROUP(ORDER BY Salary)::numeric,2)as median_salary
FROM hr_cleaned
GROUP BY Department,Job_Level
ORDER BY Department,AVG(Salary) DESC;

SELECT
    Performance_Rating,
    COUNT(*) AS total_employees,
    ROUND(AVG(Salary)::NUMERIC, 2) AS avg_salary,
    ROUND(MIN(Salary)::NUMERIC, 2) AS min_salary,
    ROUND(MAX(Salary)::NUMERIC, 2) AS max_salary
FROM hr_cleaned
GROUP BY Performance_Rating
ORDER BY avg_salary DESC;

SELECT
    CASE
        WHEN Salary < 50000  THEN 'Below 50K'
        WHEN Salary < 100000 THEN '50K - 100K'
        WHEN Salary < 150000 THEN '100K - 150K'
        WHEN Salary < 200000 THEN '150K - 200K'
        ELSE 'Above 200K'
    END AS salary_band,
    COUNT(*) AS total_employees,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS percentage
FROM hr_cleaned
GROUP BY salary_band
ORDER BY MIN(Salary);

SELECT 
      Job_Title,
      Department,
      COUNT(*) AS total_employee,
      ROUND(AVG(Salary)::numeric,2)as avg_salary
FROM hr_cleaned
GROUP BY Job_Title,Department
ORDER BY AVG(salary)DESC
LIMIT 10;


SELECT 
      CASE
          WHEN Experience_Years < 5 THEN 'Less than 5'
          WHEN Experience_Years<10 THEN '5-10'
          WHEN Experience_Years<15 THEN '10-15'  
          WHEN Experience_Years<20 THEN '15-20'
      ELSE 'MORE THAN 20'
END AS Experience_Band,
COUNT(*) AS total_employee,
ROUND(AVG(Salary)::numeric,2)as avg_salary
FROM hr_cleaned
GROUP BY Experience_Band
ORDER BY AVG(Salary) DESC;


SELECT
    Employee_ID,
    Full_Name,
    Department,
    Job_Level,
    Salary,
    RANK() OVER (PARTITION BY Department ORDER BY Salary DESC) AS salary_rank,
    ROUND(AVG(Salary) OVER (PARTITION BY Department)::NUMERIC, 2) AS dept_avg_salary,
    ROUND((Salary - AVG(Salary) OVER (PARTITION BY Department))::NUMERIC, 2) AS diff_from_dept_avg
FROM hr_cleaned
ORDER BY Department, salary_rank;
                     
SELECT * FROM (
    SELECT
        Employee_ID,
        Full_Name,
        Department,
        Job_Level,
        Salary,
        NTILE(10) OVER (PARTITION BY Department ORDER BY Salary DESC) AS salary_decile
    FROM hr_cleaned
) ranked
WHERE salary_decile = 1
ORDER BY Department, Salary DESC;


WITH salary_groups AS (
    SELECT
        CASE
            WHEN Status IN ('Resigned', 'Terminated') THEN 'Left'
            ELSE 'Stayed'
        END AS employee_group,
        Department,
        Salary
    FROM hr_cleaned
)
SELECT
    Department,
    employee_group,
    COUNT(*) AS total,
    ROUND(AVG(Salary)::NUMERIC, 2) AS avg_salary
FROM salary_groups
GROUP BY Department, employee_group
ORDER BY Department, employee_group;