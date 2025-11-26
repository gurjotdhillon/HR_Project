-- Testing the code after importing the data
SELECT *
FROM departments

SELECT *
FROM employee_projects

SELECT *
FROM employees

SELECT *
FROM performance_reviews

SELECT *
FROM projects

-- Show each employee’s name, department, and current salary
SELECT d.dept_name dept
	,e.first_name || ' ' || e.last_name AS employee
	,e.salary
FROM employees e
JOIN departments d ON e.dept_id = d.dept_id

-- List employees who worked on more than 3 projects.
SELECT p.emp_id
	,e.first_name || ' ' || e.last_name AS employee
FROM employee_projects p
JOIN employees e ON p.emp_id = e.emp_id
GROUP BY 1
	,2
HAVING count(*) > 3
ORDER BY Count(*) DESC

-- Find the average salary per department
SELECT d.dept_name department
	,ROUND(AVG(e.salary) / 1000, 2) AS avg_salary_thousands
FROM departments d
JOIN employees e ON e.dept_id = d.dept_id
GROUP BY 1

-- Total project hours worked per employee, then rank by hours within department
SELECT dept_name
	,emp_id
	,dept_rank
FROM (
	SELECT ep.emp_id
		,d.dept_name
		,SUM(ep.hours_worked)
		,RANK() OVER (
			PARTITION BY d.dept_name ORDER BY SUM(ep.hours_worked)
			) AS dept_rank
	FROM employee_projects ep
	JOIN employees e ON ep.emp_id = e.emp_id
	JOIN departments d ON e.dept_id = d.dept_id
	GROUP BY 1
		,2
	ORDER BY 3 DESC
	) t1
ORDER BY 1
	,3


-- Average rating per department
WITH t1 AS (
		SELECT d.dept_name department
			,e.first_name || ' ' || e.last_name AS employee
			,p.rating
		FROM departments d
		JOIN employees e ON d.dept_id = e.dept_id
		JOIN performance_reviews p ON e.emp_id = p.emp_id
		)

SELECT department
	,ROUND(AVG(rating)::NUMERIC, 3) AS avg_rating
FROM t1
GROUP BY 1


-- Employees whose salary is above the department average
WITH t1 AS (
		SELECT d.dept_id
			,d.dept_name dept
			,ROUND(AVG(e.salary), 2) AS avg_dept_salary
		FROM employees e
		JOIN departments d ON d.dept_id = e.dept_id
		GROUP BY 1
			,2
		)

SELECT e.first_name || ' ' || e.last_name AS emp
	,salary
	,t1.dept
FROM employees e
JOIN t1 ON e.dept_id = t1.dept_id
WHERE e.salary > t1.avg_dept_salary
ORDER BY 2 DESC


-- Employees who worked on projects that ended before their hire date
SELECT e.emp_id
	,e.first_name
	,e.hire_date
	,p.project_name
	,p.end_date
FROM employees e
JOIN employee_projects ep ON e.emp_id = ep.emp_id
JOIN projects p ON ep.project_id = p.project_id
WHERE p.end_date < e.hire_date;

-- Top 5 highest bonus earners in 2022
SELECT e.emp_id
	,e.first_name || ' ' || e.last_name
	,pr.bonus
FROM employees e
JOIN performance_reviews pr ON e.emp_id = pr.emp_id
WHERE review_year = 2022
ORDER BY 3 DESC Limit 5

-- Percentile rank of salaries within each department
SELECT e.emp_id
	,e.first_name
	,e.last_name
	,d.dept_name
	,e.salary
	,PERCENT_RANK() OVER (
		PARTITION BY e.dept_id ORDER BY e.salary
		) AS salary_percentile
FROM employees e
JOIN departments d ON e.dept_id = d.dept_id;

-- Top 3 employees by average rating per department
WITH t1
AS (
	SELECT e.first_name || ' ' || e.last_name AS emp
		,d.dept_name AS dept
		,AVG(pr.rating) AS avg_rating
		,RANK() OVER (
			PARTITION BY d.dept_name ORDER BY AVG(pr.rating) DESC
			) AS dept_ranking
	FROM departments d
	JOIN employees e ON d.dept_id = e.dept_id
	JOIN performance_reviews pr ON e.emp_id = pr.emp_id
	GROUP BY 1
		,2
	ORDER BY 2
		,3 DESC
	)
SELECT dept
	,emp
FROM t1
WHERE dept_ranking < 4
ORDER BY 1


-- Departments where average project hours per employee is less than 600 hours
WITH t1 AS (
		SELECT d.dept_name dept
			,e.emp_id emp
			,SUM(ep.hours_worked) tot_hours
		FROM departments d
		JOIN employees e ON e.dept_id = d.dept_id
		JOIN employee_projects ep ON e.emp_id = ep.emp_id
		GROUP BY 1
			,2
		ORDER BY 1
		)

SELECT dept
	,AVG(tot_hours)
FROM t1
GROUP BY 1
HAVING AVG(tot_hours) < 600


--  Employees who worked on the largest project(s) by total hours
WITH t1 AS (
		SELECT project_id
			,SUM(hours_worked) AS total_hours
		FROM employee_projects
		GROUP BY 1
		ORDER BY 2 DESC limit 1
		)

SELECT e.emp_id
	,e.first_name || ' ' || e.last_name
FROM employees e
JOIN employee_projects ep ON e.emp_id = ep.emp_id
WHERE ep.project_id = (
		SELECT project_id
		FROM t1
		)

		
-- Employees whose salary is above department average but below company median
WITH t1 AS (
		SELECT percentile_cont(0.5) within
		GROUP (
				ORDER BY salary
				) AS comp_med
		FROM employees
		)
	,t2 AS (
		SELECT dept_id
			,AVG(salary) AS avg_dept_salary
		FROM employees
		GROUP BY 1
		)

SELECT e.emp_id
	,e.salary
	,e.dept_id
FROM employees e
JOIN t2 ON e.dept_id = t2.dept_id
WHERE e.salary > t2.avg_dept_salary
	AND e.salary < (
		SELECT *
		FROM t1
		)



-- Employees working on multiple projects across different departments
SELECT ep.emp_id
	,e.first_name || ' ' || e.last_name AS emp_name
FROM employee_projects ep
JOIN projects p ON ep.project_id = p.project_id
JOIN employees e ON ep.emp_id = e.emp_id
GROUP BY ep.emp_id
	,emp_name
HAVING COUNT(DISTINCT p.dept_id) > 1;



-- Employees with above-average project-count within their department
WITH t1
AS (
	SELECT e.emp_id
		,e.dept_id
		,COUNT(*) AS total_projects
	FROM employee_projects ep
	JOIN employees e ON e.emp_id = ep.emp_id
	GROUP BY e.emp_id
		,e.dept_id
	)
	,t2
AS (
	SELECT dept_id
		,AVG(total_projects) AS avg_dept
	FROM t1
	GROUP BY dept_id
	)
SELECT t1.emp_id
FROM t1
JOIN t2 USING (dept_id)
WHERE t1.total_projects > t2.avg_dept;



-- Employees with above-average project workload within their department
WITH emp_total_hours
AS (
	SELECT e.emp_id
		,e.dept_id
		,SUM(ep.hours_worked) AS total_hours
	FROM employees e
	JOIN employee_projects ep ON e.emp_id = ep.emp_id
	GROUP BY e.emp_id
		,e.dept_id
	)
	,dept_avg_hours
AS (
	SELECT dept_id
		,AVG(total_hours) AS avg_hours
	FROM emp_total_hours
	GROUP BY dept_id
	)
SELECT e.emp_id
	,e.first_name
	,e.last_name
	,eth.total_hours
	,d.dept_name
FROM emp_total_hours eth
JOIN dept_avg_hours dah ON eth.dept_id = dah.dept_id
JOIN employees e ON e.emp_id = eth.emp_id
JOIN departments d ON e.dept_id = d.dept_id
WHERE eth.total_hours > dah.avg_hours
ORDER BY d.dept_name
	,eth.total_hours DESC;



-- Top 5 projects by average employee rating
WITH t1
AS (
	SELECT ep.project_id AS project
		,ep.emp_id
		,pr.rating employee_rating
	FROM employee_projects ep
	JOIN performance_reviews pr ON ep.emp_id = pr.emp_id
	ORDER BY 1
	)
SELECT project
	,AVG(employee_rating)
FROM t1
GROUP BY 1
ORDER BY 2 DESC Limit 5


-- Employees who worked on all projects in their department
WITH dept_projects AS (
		SELECT dept_id
			,COUNT(*) AS total_projects
		FROM projects
		GROUP BY dept_id
		)
	,employee_projects AS (
		SELECT e.emp_id
			,e.first_name || ' ' || e.last_name AS employee_name
			,e.dept_id
			,COUNT(DISTINCT p.project_id) AS emp_project_count
		FROM employees e
		JOIN employee_projects ep ON e.emp_id = ep.emp_id
		JOIN projects p ON p.project_id = ep.project_id
		WHERE p.dept_id = e.dept_id
		GROUP BY e.emp_id
			,e.first_name
			,e.last_name
			,e.dept_id
		)

SELECT ep.employee_name
	,ep.dept_id
FROM employee_projects ep
JOIN dept_projects dp ON ep.dept_id = dp.dept_id
WHERE ep.emp_project_count = dp.total_projects
ORDER BY ep.employee_name;
