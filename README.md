🚀 HR Analytics Dashboard (Power BI + PostgreSQL + SQL)

An end-to-end HR Analytics solution designed to analyze workforce trends across 2M+ employee records, focusing on attrition, compensation, and performance metrics.
This project demonstrates the complete data workflow from SQL-based data processing to interactive dashboard reporting in Power BI.

📌 Objective
To analyze employee data and uncover patterns in:

Attrition behavior
Salary distribution
Performance trends

Enabling data-driven HR decision-making and workforce optimization.

🛠️ Tech Stack
PostgreSQL → Data storage, cleaning, and transformation
SQL → Data extraction, joins, aggregations, preprocessing
Power BI → Dashboard development and visualization
DAX → KPI calculations and analytical measures
Dataset → Kaggle HR Dataset (2M+ records)

🔄 Data Pipeline
Raw HR dataset imported into PostgreSQL
Data cleaning and preprocessing using SQL queries (joins, aggregations)
Processed data loaded into Power BI
DAX measures created for KPI calculations
Interactive dashboards built for analysis and reporting

📊 Dashboard Overview

🔹 Attrition Analysis
Total Employees: 2M | Attrited: 206K | Attrition Rate: 10.30%
Highest attrition in HR (11.93%), lowest in IT (9.12%)
Junior-level employees account for 61% of total attrition
Employees rated Needs Improvement show 19.64% attrition rate

🔹 Salary Analysis
Average Salary: $90.18K | Median: $80.91K
IT has highest average salary ($97K), HR lowest ($75K)
Salary strongly varies by job level:
Director: $226K
Junior: $50.76K

🔹 Performance Analysis
Excellent Performers: 299K (14.94%)
Needs Improvement: 140K
Finance shows highest performance rate (15.02%)
Performance remains consistent across On-site, Hybrid, Remote

📈 Key Insights
🔍 Attrition is heavily concentrated at the Junior level (61%)
📉 Low-performing employees leave at nearly 2× higher rate
💰 Salary is driven by job level, not performance rating
🌍 Work mode has no significant impact on employee performance

💡 Business Impact
Helps HR identify high-risk attrition segments
Enables targeted retention strategies for junior employees
Supports compensation structure evaluation
Provides insights for performance management optimization

📸Dashboard Overview
Home Page
Attrition Analysis
Salary Analysis
Performance Analysis

📁 Repository Structure
HR-Analytics-Dashboard/
│── dashboard.pbix
│── sql_queries.sql
│── screenshots/
│── README.md
👤 Author

Aditya Sahu
Aspiring Data Analyst | SQL • Power BI • Python

