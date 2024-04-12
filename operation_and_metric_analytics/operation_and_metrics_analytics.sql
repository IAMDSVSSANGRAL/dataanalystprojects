create database Project3;
show databases;
use Project3;



-- Case Study 1: Job Data Analysis:
select * from job_data;
describe job_data;
-- 1) Jobs Reviewed Over Time:
-- Objective: Calculate the number of jobs reviewed per hour for each day in November 2020.
-- Your Task: Write an SQL query to calculate the number of jobs reviewed per hour for each day in November 2020. 
with cte as (SELECT
    DATE_FORMAT(STR_TO_DATE(ds, '%m/%d/%y'), '%y-%m-%d') AS date,
   (SUM(time_spent) / 3600) AS hour,  -- Convert seconds to hours and round
    COUNT(DISTINCT job_id) AS jobs_reviewed
FROM
    job_data
group by date)

select * from cte
WHERE date LIKE '20-11-%';

-- 2)Throughput Analysis:
-- Objective: Calculate the 7-day rolling average of throughput (number of events per second).
-- Your Task: Write an SQL query to calculate the 7-day rolling average of throughput. 
-- Additionally, explain whether you prefer using the daily metric or the 7-day rolling average for throughput, and why.
select * from job_data;

SELECT
    ds,
    COUNT(event) / SUM(time_spent) AS throughput,
    AVG(COUNT(*)) OVER (ORDER BY ds ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) AS seven_day_rolling_avg_throughput
FROM
    job_data
GROUP BY
    ds
ORDER BY
    ds;

-- 3 Language Share Analysis:
-- Objective: Calculate the percentage share of each language in the last 30 days.
-- Your Task: Write an SQL query to calculate the percentage share of each language over the last 30 days.
WITH cte AS (
    SELECT
        DATE_FORMAT(STR_TO_DATE(ds, '%m/%d/%y'), '%y-%m-%d') AS date,
        language
    FROM
        job_data)
SELECT
    language,
    (COUNT(language) * 100.0) / SUM(COUNT(language)) OVER () AS percentage_share
FROM
    cte
WHERE
    date >= '20-11-01' AND date <= '20-11-30'
GROUP BY
    language;


-- 4 ) Duplicate Rows Detection:
-- Objective: Identify duplicate rows in the data.
-- Your Task: Write an SQL query to display duplicate rows from the job_data table.   

SELECT *
FROM job_data
WHERE (job_id, actor_id, event, language, time_spent, org, ds) 
IN (
    SELECT job_id, actor_id, event, language, time_spent, org, ds
    FROM job_data
    GROUP BY job_id, actor_id, event, language, time_spent, org, ds
    HAVING COUNT(*) > 1);


-- Case Study 2: Investigating Metric Spike: 

SELECT * FROM users;
select count(*) from users;
describe users;

select * from events;
select count(*) from events;
describe events;

select * from email_events;
select  count(*) from email_events;
describe email_events;



-- 1)Weekly User Engagement:
-- Objective: Measure the activeness of users on a weekly basis.
-- Your Task: Write an SQL query to calculate the weekly user engagement.

SELECT
    WEEK(STR_TO_DATE(e.occurred_at, '%d-%m-%Y %H:%i')) AS week_number,
    COUNT(distinct(u.user_id)) AS engagement_count
FROM
    users u
JOIN
    events e ON u.user_id = e.user_id
GROUP BY
	week_number
ORDER BY
    week_number;
    
-- Another solution on the taking user_id in consideration 
-- SELECT
--     u.user_id,
--     WEEK(STR_TO_DATE(e.occurred_at, '%d-%m-%Y %H:%i')) AS week_number,
--     COUNT(*) AS engagement_count
-- FROM
--     users u
-- JOIN
--     events e ON u.user_id = e.user_id
-- GROUP BY
--     u.user_id, week_number
-- ORDER BY
--     week_number;
    
    
-- 2) User Growth Analysis:
-- Objective: Analyze the growth of users over time for a product.
-- Your Task: Write an SQL query to calculate the user growth for the product.

Select * from users;
with cte as (SELECT
    YEAR(STR_TO_DATE(created_at, '%d-%m-%Y %H:%i')) AS year,
    WEEK(STR_TO_DATE(created_at, '%d-%m-%Y %H:%i')) AS week,
    count(distinct user_id) user_count
FROM
    users
group by year,week
order by year, week)

select *,sum(user_count) over(order by year,week) cummulative_user from cte;

-- 3)Weekly Retention Analysis:
-- Objective: Analyze the retention of users on a weekly basis after signing up for a product.
-- Your Task: Write an SQL query to calculate the weekly retention of users based on their sign-up cohort.

WITH user_cohorts AS (
    SELECT
        u.user_id,
        DATE_FORMAT(STR_TO_DATE(u.created_at, '%d-%m-%Y %H:%i'), '%Y-%m') AS cohort_month,
        WEEK(STR_TO_DATE(e.occurred_at, '%d-%m-%Y %H:%i')) AS week
    FROM
        users u
    JOIN
        events e ON u.user_id = e.user_id
    WHERE
        WEEK(STR_TO_DATE(e.occurred_at, '%d-%m-%Y %H:%i')) >= WEEK(STR_TO_DATE(u.created_at, '%d-%m-%Y %H:%i'))
)
SELECT
    cohort_month,
    week,
    COUNT(DISTINCT user_id) AS active_users_retended
FROM
    user_cohorts
GROUP BY
    cohort_month, week
ORDER BY
    cohort_month, week;
    
    
-- 4) Weekly Engagement Per Device:
-- Objective: Measure the activeness of users on a weekly basis per device.
-- Your Task: Write an SQL query to calculate the weekly engagement per device.

SELECT
    WEEK(STR_TO_DATE(e.occurred_at, '%d-%m-%Y %H:%i')) AS week,
    e.device,
    COUNT(*) AS engagement_count
FROM
    events e
GROUP BY
    week, e.device
ORDER BY
    week, e.device;
    

-- 5) Email Engagement Analysis:
-- Objective: Analyze how users are engaging with the email service.
-- Your Task: Write an SQL query to calculate the email engagement metrics.

select distinct(action) from email_events;
SELECT
    user_type,
    COUNT(*) AS total_emails,
    COUNT(DISTINCT user_id) AS unique_users,
    COUNT(CASE WHEN action = 'email_open' THEN 1 END) AS email_opens,
    COUNT(CASE WHEN action = 'email_clickthrough' THEN 1 END) AS email_clicks,
    COUNT(CASE WHEN action = 'sent_weekly_digest' THEN 1 END) AS weekly_digests,
    COUNT(CASE WHEN action = 'sent_reengagement_email' THEN 1 END) AS reengagement_emails
FROM
    email_events
GROUP BY
    user_type
ORDER BY
    user_type;





