# Employee Analytics SQL Project – Report

## 1. Overview
This report summarizes insights generated from a series of advanced SQL queries applied to a multi-table employee database. The purpose is to demonstrate analytical SQL capabilities and extract meaningful trends related to employee performance, project workload, departmental efficiency, and compensation structure.

---

## 2. Key Findings

### 2.1 Salary Insights
- Several employees earn **above their department’s average salary**, indicating higher-value or more experienced staff within those units.
- By comparing salaries to the **company-wide median**, we identified employees who are paid competitively within their departments but still fall below the company benchmark—an indication of uneven pay distribution across departments.

---

## 3. Project & Workload Insights

### 3.1 Employees With the Highest Workload
- Using total project hours, we ranked employees within each department.
- Some departments showed significant workload imbalance where one employee contributed disproportionately more hours.

### 3.2 Largest Projects
- By calculating each project’s total hours, we identified the single highest-effort project.
- Employees contributing to this project can be considered key operational personnel.

### 3.3 Cross-Department Work
- A subset of employees participated in projects belonging to **multiple departments**, indicating cross-functional collaboration or shared resource constraints.

### 3.4 Employees Who Worked on All Department Projects
- A specialized query revealed employees who contributed to *every* project within their department.
- These individuals are likely critical contributors or senior staff.

---

## 4. Performance Review Insights

### 4.1 Top Performers
- Using window functions, we extracted the **top 3 employees per department** based on average performance ratings.
- Performance distribution varies widely between departments.

### 4.2 Department Rating Averages
- Some departments consistently outperform others in performance reviews.
- These variations may reflect differences in management style, team composition, or workloads.

---

## 5. Department-Level Analysis

### 5.1 Project Hours per Department
- Departments with an average per-employee project workload below 600 hours were identified.
- This suggests wide differences in staffing, project distribution, or operational demands.

### 5.2 Salary Percentile Rankings
- Percentile ranks show how individual salaries compare internally within each department.
- Useful for compensation alignment and fairness analysis.

---

## 6. Bonus & Recognition Insights

### 6.1 Top 5 Bonus Earners (2022)
- These employees likely had exceptional contributions or belonged to project-critical teams.

---

## 7. Technical Highlights

This project makes significant use of:
- **Window functions** (`RANK`, `PERCENT_RANK`, `percentile_cont`)
- **CTEs** for cleaner logical blocks
- **Aggregations & groupings**
- **Multi-table joins** with up to three or more tables
- **Subqueries** (inline + CTE based)
- **Conditional filtering** using median/average benchmarks

These techniques simulate real corporate analytics environments.

---

## 8. Conclusion

This SQL analytics project demonstrates the ability to extract complex business insights from a multi-table relational database. The queries cover compensation, project management, performance evaluation, departmental comparison, and advanced analytical logic.

Future work could include:
- Visual dashboards  
- Predictive modeling  
- Optimization metrics  
- Integration with BI tools (Power BI, Tableau, Looker)

---

## 9. Author
**Gurjot Dhillon**

