CREATE TABLE hr_raw (
    Employee_ID VARCHAR(15),
    Full_Name VARCHAR(100),
    Department VARCHAR(50),
    Job_Title VARCHAR(100),
    Hire_Date VARCHAR(20),
    Performance_Rating VARCHAR(30),
    Experience_Years FLOAT,
    Status VARCHAR(20),
    Work_Mode VARCHAR(20),
    Salary FLOAT,
    Year INT,
    Country VARCHAR(50),
    City VARCHAR(50),
    Age INT,
    Job_Level VARCHAR(20)
    
);
DROP TABLE hr_raw;
copy hr_raw FROM 'C:\Data Analyst Projects' DELIMITER ',' CSV HEADER;
select * from hr_raw order by salary desc limit 5;
select count(*) from hr_raw;
-- Check NULLs in each column
SELECT
  COUNT(*) FILTER (WHERE Employee_ID IS NULL)        AS null_emp_id,
  COUNT(*) FILTER (WHERE Salary IS NULL)             AS null_salary,
  COUNT(*) FILTER (WHERE Performance_Rating IS NULL) AS null_rating,
  COUNT(*) FILTER (WHERE Department IS NULL)         AS null_dept,
  COUNT(*) FILTER (WHERE Age IS NULL)                AS null_age,
  COUNT(*) FILTER (WHERE Experience_Years IS NULL)   AS null_exp
FROM hr_raw;
--negative salary
select count(*)as bad_salary from hr_raw where salary <=0;
--age error
select count(*) as age_issue from hr_raw where Age <(Experience_Years +18); 
select Employee_ID,COUNT(*)AS duplicate_employee
from hr_raw 
GROUP BY Employee_ID 
HAVING count(*) >1;
	  
CREATE TABLE hr_cleaned AS
SELECT
    Employee_ID,
    Full_Name,

    -- Fix NULL departments with 'Unknown'
    COALESCE(Department, 'Unknown') AS Department,

    Job_Title,

    -- Fix date column properly
    TO_DATE(Hire_Date, 'YYYY-MM-DD') AS Hire_Date,

    -- Fix NULL performance rating with 'Unknown'
    COALESCE(Performance_Rating, 'Unknown') AS Performance_Rating,

    -- Fix negative experience years
    ABS(Experience_Years) AS Experience_Years,

    COALESCE(Status, 'Unknown') AS Status,
    COALESCE(Work_Mode, 'Unknown') AS Work_Mode,

    -- Fix negative/zero salary → set to NULL first, fix in next step
    CASE WHEN Salary <= 0 THEN NULL ELSE Salary END AS Salary,

    Year,
    Country,
    City,

    -- Fix age-experience logical gap
    CASE
        WHEN Age < (Experience_Years + 18)
        THEN CAST(Experience_Years + 22 AS INT)
        ELSE Age
    END AS Age,

    Job_Level

FROM hr_raw
WHERE Employee_ID IS NOT NULL;

UPDATE hr_cleaned AS c
SET Salary = sub.median_salary
FROM (
    SELECT
        Department,
        Job_Level,
        PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY Salary) AS median_salary
    FROM hr_cleaned
    WHERE Salary IS NOT NULL
    GROUP BY Department, Job_Level
) sub
WHERE c.Salary IS NULL
AND c.Department = sub.Department
AND c.Job_Level = sub.Job_Level;

ALTER TABLE hr_cleaned ADD COLUMN Hire_Year INT ;

UPDATE hr_cleaned 
SET Hire_Year=EXTRACT(Year from Hire_Date);

-- Compare raw vs cleaned
SELECT 'Raw - bad salaries' AS check_name, COUNT(*) AS count FROM hr_raw WHERE Salary <= 0
UNION ALL
SELECT 'Cleaned - bad salaries', COUNT(*) FROM hr_cleaned WHERE Salary <= 0 OR Salary IS NULL
UNION ALL
SELECT 'Raw - null ratings', COUNT(*) FROM hr_raw WHERE Performance_Rating IS NULL
UNION ALL
SELECT 'Cleaned - null ratings', COUNT(*) FROM hr_cleaned WHERE Performance_Rating = 'Unknown'
UNION ALL
SELECT 'Raw - age errors', COUNT(*) FROM hr_raw WHERE Age < (Experience_Years + 18)
UNION ALL
SELECT 'Cleaned - age errors', COUNT(*) FROM hr_cleaned WHERE Age < (Experience_Years + 18);
SELECT COUNT(*) FROM hr_cleaned;

UPDATE hr_cleaned
SET Age = CAST(Experience_Years + 22 AS INT)
WHERE Age < (Experience_Years + 18);
SELECT 
  COUNT(*) FILTER (WHERE Salary <= 0 OR Salary IS NULL)    AS bad_salaries,
  COUNT(*) FILTER (WHERE Performance_Rating = 'Unknown')   AS replaced_ratings,
  COUNT(*) FILTER (WHERE Age < (Experience_Years + 18))    AS age_errors
FROM hr_cleaned;

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