SELECT
    COUNT(*) AS total_employees,
    COUNT(*) FILTER (WHERE Status IN ('Resigned', 'Terminated')) AS attrited_employees,
    ROUND(100.0 * COUNT(*) FILTER (WHERE Status IN ('Resigned', 'Terminated')) / COUNT(*), 2) AS attrition_rate_pct
FROM hr_cleaned;
SELECT Department,
    COUNT(*) AS total_employees,
    COUNT(*) FILTER (WHERE Status IN ('Resigned', 'Terminated')) AS attrited_employees,
    ROUND(100.0 * COUNT(*) FILTER (WHERE Status IN ('Resigned', 'Terminated')) / COUNT(*), 2) AS attrition_rate_pct
FROM hr_cleaned
GROUP BY Department
ORDER BY attrition_rate_pct DESC;

SELECT Job_Level, COUNT(*) AS total_employees,
count(*) FILTER(WHERE Status IN ('Terminated','Resigned'))as attrited_employee,
ROUND(100* COUNT(*)FILTER(WHERE Status IN ('Terminated','Resigned'))/COUNT(*),2)AS attrition_rate_pct
FROM hr_cleaned
Group by Job_Level
ORDER BY attrition_rate_pct DESC;

SELECT Work_Mode ,COUNT(*)AS total_employees,
count(*) FILTER(WHERE Status IN ('Terminated','Resigned'))as attrited_employees,
ROUND(100*COUNT(*) FILTER(WHERE Status IN ('Terminated','Resigned'))/COUNT(*),2)AS attrited_rate_pct
FROM hr_cleaned 
GROUP BY Work_Mode
ORDER BY attrited_rate_pct DESC;

select Performance_Rating ,COUNT(*)AS total_employees,
count(*) FILTER(WHERE Status IN ('Terminated','Resigned'))as attrited_employee,
ROUND(100 * COUNT(*) FILTER(WHERE Status IN ('Terminated','Resigned'))/COUNT(*),2)AS attrited_rate_pct
FROM hr_cleaned
Group by Performance_Rating
ORDER BY attrited_rate_pct DESC;

SELECT
    Hire_Year,
    COUNT(*) AS total_employees,
    COUNT(*) FILTER (WHERE Status IN ('Resigned', 'Terminated')) AS attrited,
    ROUND(100.0 * COUNT(*) FILTER (WHERE Status IN ('Resigned', 'Terminated')) / COUNT(*), 2) AS attrition_rate_pct
FROM hr_cleaned
GROUP BY Hire_Year
ORDER BY Hire_Year;

SELECT
    Department,
    Job_Level,
    COUNT(*) AS total_employees,
    COUNT(*) FILTER (WHERE Status IN ('Resigned', 'Terminated')) AS attrited,
    ROUND(100.0 * COUNT(*) FILTER (WHERE Status IN ('Resigned', 'Terminated')) / COUNT(*), 2) AS attrition_rate_pct
FROM hr_cleaned
GROUP BY Department, Job_Level
ORDER BY Department, attrition_rate_pct DESC;

WITH attrition_groups AS (
    SELECT
        CASE 
            WHEN Status IN ('Resigned', 'Terminated') THEN 'Left'
            ELSE 'Stayed'
        END AS employee_group,
        Salary,
        Experience_Years,
        Age
    FROM hr_cleaned
)
SELECT
    employee_group,
    COUNT(*) AS total,
    ROUND(AVG(Salary)::NUMERIC, 2) AS avg_salary,
    ROUND(AVG(Experience_Years)::NUMERIC, 1) AS avg_experience,
    ROUND(AVG(Age)::NUMERIC, 1) AS avg_age
FROM attrition_groups
GROUP BY employee_group;

SELECT Country,
COUNT(*) AS total_employee,
COUNT(*) FILTER (WHERE Status IN ('Terminated','Resigned'))as attrited_employee,
ROUND(100.0 * COUNT(*)FILTER(WHERE Status IN ('Terminated','Resigned'))/COUNT(*),2)AS attrited_rate_pct
FROM hr_cleaned
GROUP BY Country
HAVING COUNT(*) > 100
ORDER BY attrited_rate_pct DESC
LIMIT 5;

SELECT Department,Job_Level,Work_Mode
,COUNT(*) AS total_employee,
COUNT(*) FILTER(WHERE Status IN('Terminated','Resigned'))AS attrited,
ROUND(100.0 * COUNT(*) filter(where Status IN('Terminated','Resigned'))/count(*),2)as attrited_pct,
RANK() OVER(ORDER BY ROUND(100.0 * COUNT(*) filter(where Status IN('Terminated','Resigned'))/count(*),2))AS RNK
FROM hr_cleaned
GROUP BY Department,Job_Level,Work_Mode
ORDER BY attrited_pct DESC;
