-- ------------------------
-- Create Database & Use It
-- ------------------------
-- CREATE DATABASE user_behavior;
USE user_behavior;

-- ------------------------
-- Create Table: users
-- ------------------------
-- CREATE TABLE users (
--   id VARCHAR(10),
--   current_age VARCHAR(10),
--   retirement_age VARCHAR(10),
--   birth_year VARCHAR(10),
--   birth_month VARCHAR(10),
--   gender VARCHAR(50),
--   address VARCHAR(255),
--   latitude VARCHAR(20),
--   longitude VARCHAR(20),
--   per_capita_income VARCHAR(50),
--   yearly_income VARCHAR(50),
--   total_debt VARCHAR(50),
--   credit_score VARCHAR(10),
--   num_credit_cards VARCHAR(10)
-- );

-- ------------------------
-- Load Data: users
-- ------------------------
-- LOAD DATA LOCAL INFILE 'C:/Users/giova/Documents/Machine Learning Projects/mandiri sekuritas/users_data.csv'
-- INTO TABLE users
-- FIELDS TERMINATED BY ',' 
-- ENCLOSED BY '"'
-- LINES TERMINATED BY '\n'
-- IGNORE 1 ROWS;

-- ------------------------
-- Create Table: transactions
-- ------------------------
-- CREATE TABLE transactions (
--   id VARCHAR(10),
--   date VARCHAR(20),
--   client_id VARCHAR(10),
--   card_id VARCHAR(10),
--   amount VARCHAR(50),
--   use_chip VARCHAR(10),
--   merchant_id VARCHAR(50),
--   merchant_city VARCHAR(100),
--   merchant_state VARCHAR(50),
--   zip VARCHAR(20),
--   mcc VARCHAR(20),
--   errors VARCHAR(255)
-- );

-- ------------------------
-- Load Data: transactions
-- ------------------------
-- LOAD DATA LOCAL INFILE 'C:/Users/giova/Documents/Machine Learning Projects/mandiri sekuritas/transactions_data.csv'
-- INTO TABLE transactions
-- FIELDS TERMINATED BY ',' 
-- ENCLOSED BY '"'
-- LINES TERMINATED BY '\n'
-- IGNORE 1 ROWS;

-- ------------------------
-- Create Table: transactions
-- ------------------------
-- CREATE TABLE cards (
--   id VARCHAR(10),
--   client_id VARCHAR(10),
--   card_brand VARCHAR(50),
--   card_type VARCHAR(50),
--   card_number VARCHAR(50),
--   expires VARCHAR(20),
--   cvv VARCHAR(10),
--   has_chip VARCHAR(10),
--   num_cards_issued VARCHAR(10),
--   credit_limit VARCHAR(50),
--   acct_open_date VARCHAR(20),
--   year_pin_last_changed VARCHAR(10),
--   card_on_dark_web VARCHAR(10)
-- );
-- ------------------------
-- Load Data: cards
-- ------------------------
-- LOAD DATA LOCAL INFILE 'C:/Users/giova/Documents/Machine Learning Projects/mandiri sekuritas/cards_data.csv'
-- INTO TABLE cards
-- FIELDS TERMINATED BY ',' 
-- ENCLOSED BY '"'
-- LINES TERMINATED BY '\n'
-- IGNORE 1 ROWS;

-- ------------------------
-- Count Total Data / Table
-- ------------------------
-- SELECT count(*) from users;
-- SELECT count(*) from transactions;
-- SELECT count(*) from cards;

-- ------------------------
-- Find the First and Last Transaction of Registered Users
-- ------------------------
SELECT
  MIN(t.date) AS first_transaction_date,
  MAX(t.date) AS last_transaction_date
FROM transactions t
JOIN users u ON t.client_id = u.id;

-- ------------------------
-- Create New Table: transaction_analysis
-- ------------------------
CREATE TABLE transaction_analysis (
  -- Column from users
  id INT,
  gender VARCHAR(10),
  current_age INT,
  retirement_age INT,
  birth_period VARCHAR(7), -- Format MM-YYYY
  latitude DOUBLE,
  longitude DOUBLE,
  yearly_income DECIMAL(15,2),  -- Sudah bersih dari tanda $
  total_debt DECIMAL(15,2),     -- Sudah bersih dari tanda $
  credit_score INT,
  num_credit_cards INT,

  -- Columns of card_agg
  total_cards INT,
  max_credit_limit DECIMAL(15,2),
  darkweb_card_count INT,
  credit_card_count INT,
  debit_card_count INT,

  -- Transaction column per year
  trans_year INT,
  total_transactions INT,
  total_amount DECIMAL(15,2)
);

-- ------------------------
-- Create New Table: card_agg
-- ------------------------
CREATE TABLE card_agg AS
SELECT
  client_id,
  COUNT(*) AS total_cards,
  MAX(CAST(REPLACE(REPLACE(credit_limit, '$', ''), ',', '') AS DECIMAL(12,2))) AS max_credit_limit,
  SUM(card_on_dark_web = 'Yes') AS darkweb_card_count,
  SUM(card_type = 'Credit') AS credit_card_count,
  SUM(card_type = 'Debit') AS debit_card_count
FROM cards
GROUP BY client_id;

-- ------------------------
-- Create Temp Table: trans_agg_[YEAR]
-- ------------------------
-- 2010
CREATE TEMPORARY TABLE trans_agg_2010 AS
SELECT
  client_id,
  COUNT(*) AS total_transactions_2010,
  SUM(CAST(REPLACE(REPLACE(amount, '$', ''), ',', '') AS DECIMAL(15,2))) AS total_amount_2010
FROM transactions
WHERE YEAR(date) = 2010
GROUP BY client_id;

INSERT INTO transaction_analysis (
  id, gender, current_age, retirement_age, birth_period,
  latitude, longitude, yearly_income,
  total_debt, credit_score, num_credit_cards,
  total_cards, max_credit_limit, darkweb_card_count, credit_card_count, debit_card_count,
  trans_year, total_transactions, total_amount
)
SELECT 
  u.id,
  u.gender,
  u.current_age,
  u.retirement_age,
  CONCAT(LPAD(u.birth_month, 2, '0'), '-', u.birth_year) AS birth_period,
  u.latitude,
  u.longitude,
  CAST(REPLACE(REPLACE(u.yearly_income, '$', ''), ',', '') AS DECIMAL(15,2)) AS yearly_income,
  CAST(REPLACE(REPLACE(u.total_debt, '$', ''), ',', '') AS DECIMAL(15,2)) AS total_debt,
  u.credit_score,
  u.num_credit_cards,
  c.total_cards,
  c.max_credit_limit,
  c.darkweb_card_count,
  c.credit_card_count,
  c.debit_card_count,
  2010,
  t.total_transactions_2010,
  t.total_amount_2010
FROM users u
LEFT JOIN card_agg c ON u.id = c.client_id
LEFT JOIN trans_agg_2010 t ON u.id = t.client_id;

DROP TEMPORARY TABLE IF EXISTS trans_agg_2010;

-- 2011
CREATE TEMPORARY TABLE trans_agg_2011 AS
SELECT
  client_id,
  COUNT(*) AS total_transactions_2011,
  SUM(CAST(REPLACE(REPLACE(amount, '$', ''), ',', '') AS DECIMAL(15,2))) AS total_amount_2011
FROM transactions
WHERE YEAR(date) = 2011
GROUP BY client_id;

INSERT INTO transaction_analysis (
  id, gender, current_age, retirement_age, birth_period,
  latitude, longitude, yearly_income,
  total_debt, credit_score, num_credit_cards,
  total_cards, max_credit_limit, darkweb_card_count, credit_card_count, debit_card_count,
  trans_year, total_transactions, total_amount
)
SELECT 
  u.id,
  u.gender,
  u.current_age,
  u.retirement_age,
  CONCAT(LPAD(u.birth_month, 2, '0'), '-', u.birth_year),
  u.latitude,
  u.longitude,
  CAST(REPLACE(REPLACE(u.yearly_income, '$', ''), ',', '') AS DECIMAL(15,2)),
  CAST(REPLACE(REPLACE(u.total_debt, '$', ''), ',', '') AS DECIMAL(15,2)),
  u.credit_score,
  u.num_credit_cards,
  c.total_cards,
  c.max_credit_limit,
  c.darkweb_card_count,
  c.credit_card_count,
  c.debit_card_count,
  2011,
  t.total_transactions_2011,
  t.total_amount_2011
FROM users u
LEFT JOIN card_agg c ON u.id = c.client_id
LEFT JOIN trans_agg_2011 t ON u.id = t.client_id;

DROP TEMPORARY TABLE IF EXISTS trans_agg_2011;

-- 2012
CREATE TEMPORARY TABLE trans_agg_2012 AS
SELECT
  client_id,
  COUNT(*) AS total_transactions_2012,
  SUM(CAST(REPLACE(REPLACE(amount, '$', ''), ',', '') AS DECIMAL(15,2))) AS total_amount_2012
FROM transactions
WHERE YEAR(date) = 2012
GROUP BY client_id;

INSERT INTO transaction_analysis (
  id, gender, current_age, retirement_age, birth_period,
  latitude, longitude, yearly_income,
  total_debt, credit_score, num_credit_cards,
  total_cards, max_credit_limit, darkweb_card_count, credit_card_count, debit_card_count,
  trans_year, total_transactions, total_amount
)
SELECT 
  u.id,
  u.gender,
  u.current_age,
  u.retirement_age,
  CONCAT(LPAD(u.birth_month, 2, '0'), '-', u.birth_year),
  u.latitude,
  u.longitude,
  CAST(REPLACE(REPLACE(u.yearly_income, '$', ''), ',', '') AS DECIMAL(15,2)),
  CAST(REPLACE(REPLACE(u.total_debt, '$', ''), ',', '') AS DECIMAL(15,2)),
  u.credit_score,
  u.num_credit_cards,
  c.total_cards,
  c.max_credit_limit,
  c.darkweb_card_count,
  c.credit_card_count,
  c.debit_card_count,
  2012,
  t.total_transactions_2012,
  t.total_amount_2012
FROM users u
LEFT JOIN card_agg c ON u.id = c.client_id
LEFT JOIN trans_agg_2012 t ON u.id = t.client_id;

DROP TEMPORARY TABLE IF EXISTS trans_agg_2012;

-- 2013
CREATE TEMPORARY TABLE trans_agg_2013 AS
SELECT
  client_id,
  COUNT(*) AS total_transactions_2013,
  SUM(CAST(REPLACE(REPLACE(amount, '$', ''), ',', '') AS DECIMAL(15,2))) AS total_amount_2013
FROM transactions
WHERE YEAR(date) = 2013
GROUP BY client_id;

INSERT INTO transaction_analysis (
  id, gender, current_age, retirement_age, birth_period,
  latitude, longitude, yearly_income,
  total_debt, credit_score, num_credit_cards,
  total_cards, max_credit_limit, darkweb_card_count, credit_card_count, debit_card_count,
  trans_year, total_transactions, total_amount
)
SELECT 
  u.id,
  u.gender,
  u.current_age,
  u.retirement_age,
  CONCAT(LPAD(u.birth_month, 2, '0'), '-', u.birth_year),
  u.latitude,
  u.longitude,
  CAST(REPLACE(REPLACE(u.yearly_income, '$', ''), ',', '') AS DECIMAL(15,2)),
  CAST(REPLACE(REPLACE(u.total_debt, '$', ''), ',', '') AS DECIMAL(15,2)),
  u.credit_score,
  u.num_credit_cards,
  c.total_cards,
  c.max_credit_limit,
  c.darkweb_card_count,
  c.credit_card_count,
  c.debit_card_count,
  2013,
  t.total_transactions_2013,
  t.total_amount_2013
FROM users u
LEFT JOIN card_agg c ON u.id = c.client_id
LEFT JOIN trans_agg_2013 t ON u.id = t.client_id;

DROP TEMPORARY TABLE IF EXISTS trans_agg_2013;

-- 2014
CREATE TEMPORARY TABLE trans_agg_2014 AS
SELECT
  client_id,
  COUNT(*) AS total_transactions_2014,
  SUM(CAST(REPLACE(REPLACE(amount, '$', ''), ',', '') AS DECIMAL(15,2))) AS total_amount_2014
FROM transactions
WHERE YEAR(date) = 2014
GROUP BY client_id;

INSERT INTO transaction_analysis (
  id, gender, current_age, retirement_age, birth_period,
  latitude, longitude, yearly_income,
  total_debt, credit_score, num_credit_cards,
  total_cards, max_credit_limit, darkweb_card_count, credit_card_count, debit_card_count,
  trans_year, total_transactions, total_amount
)
SELECT 
  u.id,
  u.gender,
  u.current_age,
  u.retirement_age,
  CONCAT(LPAD(u.birth_month, 2, '0'), '-', u.birth_year),
  u.latitude,
  u.longitude,
  CAST(REPLACE(REPLACE(u.yearly_income, '$', ''), ',', '') AS DECIMAL(15,2)),
  CAST(REPLACE(REPLACE(u.total_debt, '$', ''), ',', '') AS DECIMAL(15,2)),
  u.credit_score,
  u.num_credit_cards,
  c.total_cards,
  c.max_credit_limit,
  c.darkweb_card_count,
  c.credit_card_count,
  c.debit_card_count,
  2014,
  t.total_transactions_2014,
  t.total_amount_2014
FROM users u
LEFT JOIN card_agg c ON u.id = c.client_id
LEFT JOIN trans_agg_2014 t ON u.id = t.client_id;

DROP TEMPORARY TABLE IF EXISTS trans_agg_2014;

-- 2015
CREATE TEMPORARY TABLE trans_agg_2015 AS
SELECT
  client_id,
  COUNT(*) AS total_transactions_2015,
  SUM(CAST(REPLACE(REPLACE(amount, '$', ''), ',', '') AS DECIMAL(15,2))) AS total_amount_2015
FROM transactions
WHERE YEAR(date) = 2015
GROUP BY client_id;

INSERT INTO transaction_analysis (
  id, gender, current_age, retirement_age, birth_period,
  latitude, longitude, yearly_income,
  total_debt, credit_score, num_credit_cards,
  total_cards, max_credit_limit, darkweb_card_count, credit_card_count, debit_card_count,
  trans_year, total_transactions, total_amount
)
SELECT 
  u.id,
  u.gender,
  u.current_age,
  u.retirement_age,
  CONCAT(LPAD(u.birth_month, 2, '0'), '-', u.birth_year),
  u.latitude,
  u.longitude,
  CAST(REPLACE(REPLACE(u.yearly_income, '$', ''), ',', '') AS DECIMAL(15,2)),
  CAST(REPLACE(REPLACE(u.total_debt, '$', ''), ',', '') AS DECIMAL(15,2)),
  u.credit_score,
  u.num_credit_cards,
  c.total_cards,
  c.max_credit_limit,
  c.darkweb_card_count,
  c.credit_card_count,
  c.debit_card_count,
  2015,
  t.total_transactions_2015,
  t.total_amount_2015
FROM users u
LEFT JOIN card_agg c ON u.id = c.client_id
LEFT JOIN trans_agg_2015 t ON u.id = t.client_id;

DROP TEMPORARY TABLE IF EXISTS trans_agg_2015;

-- 2016
CREATE TEMPORARY TABLE trans_agg_2016 AS
SELECT
  client_id,
  COUNT(*) AS total_transactions_2016,
  SUM(CAST(REPLACE(REPLACE(amount, '$', ''), ',', '') AS DECIMAL(15,2))) AS total_amount_2016
FROM transactions
WHERE YEAR(date) = 2016
GROUP BY client_id;

INSERT INTO transaction_analysis (
  id, gender, current_age, retirement_age, birth_period,
  latitude, longitude, yearly_income,
  total_debt, credit_score, num_credit_cards,
  total_cards, max_credit_limit, darkweb_card_count, credit_card_count, debit_card_count,
  trans_year, total_transactions, total_amount
)
SELECT 
  u.id,
  u.gender,
  u.current_age,
  u.retirement_age,
  CONCAT(LPAD(u.birth_month, 2, '0'), '-', u.birth_year),
  u.latitude,
  u.longitude,
  CAST(REPLACE(REPLACE(u.yearly_income, '$', ''), ',', '') AS DECIMAL(15,2)),
  CAST(REPLACE(REPLACE(u.total_debt, '$', ''), ',', '') AS DECIMAL(15,2)),
  u.credit_score,
  u.num_credit_cards,
  c.total_cards,
  c.max_credit_limit,
  c.darkweb_card_count,
  c.credit_card_count,
  c.debit_card_count,
  2016,
  t.total_transactions_2016,
  t.total_amount_2016
FROM users u
LEFT JOIN card_agg c ON u.id = c.client_id
LEFT JOIN trans_agg_2016 t ON u.id = t.client_id;

DROP TEMPORARY TABLE IF EXISTS trans_agg_2016;

-- 2017
CREATE TEMPORARY TABLE trans_agg_2017 AS
SELECT
  client_id,
  COUNT(*) AS total_transactions_2017,
  SUM(CAST(REPLACE(REPLACE(amount, '$', ''), ',', '') AS DECIMAL(15,2))) AS total_amount_2017
FROM transactions
WHERE YEAR(date) = 2017
GROUP BY client_id;

INSERT INTO transaction_analysis (
  id, gender, current_age, retirement_age, birth_period,
  latitude, longitude, yearly_income,
  total_debt, credit_score, num_credit_cards,
  total_cards, max_credit_limit, darkweb_card_count, credit_card_count, debit_card_count,
  trans_year, total_transactions, total_amount
)
SELECT 
  u.id,
  u.gender,
  u.current_age,
  u.retirement_age,
  CONCAT(LPAD(u.birth_month, 2, '0'), '-', u.birth_year),
  u.latitude,
  u.longitude,
  CAST(REPLACE(REPLACE(u.yearly_income, '$', ''), ',', '') AS DECIMAL(15,2)),
  CAST(REPLACE(REPLACE(u.total_debt, '$', ''), ',', '') AS DECIMAL(15,2)),
  u.credit_score,
  u.num_credit_cards,
  c.total_cards,
  c.max_credit_limit,
  c.darkweb_card_count,
  c.credit_card_count,
  c.debit_card_count,
  2017,
  t.total_transactions_2017,
  t.total_amount_2017
FROM users u
LEFT JOIN card_agg c ON u.id = c.client_id
LEFT JOIN trans_agg_2017 t ON u.id = t.client_id;

DROP TEMPORARY TABLE IF EXISTS trans_agg_2017;

-- 2018
CREATE TEMPORARY TABLE trans_agg_2018 AS
SELECT
  client_id,
  COUNT(*) AS total_transactions_2018,
  SUM(CAST(REPLACE(REPLACE(amount, '$', ''), ',', '') AS DECIMAL(15,2))) AS total_amount_2018
FROM transactions
WHERE YEAR(date) = 2018
GROUP BY client_id;

INSERT INTO transaction_analysis (
  id, gender, current_age, retirement_age, birth_period,
  latitude, longitude, yearly_income,
  total_debt, credit_score, num_credit_cards,
  total_cards, max_credit_limit, darkweb_card_count, credit_card_count, debit_card_count,
  trans_year, total_transactions, total_amount
)
SELECT 
  u.id,
  u.gender,
  u.current_age,
  u.retirement_age,
  CONCAT(LPAD(u.birth_month, 2, '0'), '-', u.birth_year),
  u.latitude,
  u.longitude,
  CAST(REPLACE(REPLACE(u.yearly_income, '$', ''), ',', '') AS DECIMAL(15,2)),
  CAST(REPLACE(REPLACE(u.total_debt, '$', ''), ',', '') AS DECIMAL(15,2)),
  u.credit_score,
  u.num_credit_cards,
  c.total_cards,
  c.max_credit_limit,
  c.darkweb_card_count,
  c.credit_card_count,
  c.debit_card_count,
  2018,
  t.total_transactions_2018,
  t.total_amount_2018
FROM users u
LEFT JOIN card_agg c ON u.id = c.client_id
LEFT JOIN trans_agg_2018 t ON u.id = t.client_id;

DROP TEMPORARY TABLE IF EXISTS trans_agg_2018;

-- 2019
CREATE TEMPORARY TABLE trans_agg_2019 AS
SELECT
  client_id,
  COUNT(*) AS total_transactions_2019,
  SUM(CAST(REPLACE(REPLACE(amount, '$', ''), ',', '') AS DECIMAL(15,2))) AS total_amount_2019
FROM transactions
WHERE YEAR(date) = 2019
GROUP BY client_id;

INSERT INTO transaction_analysis (
  id, gender, current_age, retirement_age, birth_period,
  latitude, longitude, yearly_income,
  total_debt, credit_score, num_credit_cards,
  total_cards, max_credit_limit, darkweb_card_count, credit_card_count, debit_card_count,
  trans_year, total_transactions, total_amount
)
SELECT 
  u.id,
  u.gender,
  u.current_age,
  u.retirement_age,
  CONCAT(LPAD(u.birth_month, 2, '0'), '-', u.birth_year),
  u.latitude,
  u.longitude,
  CAST(REPLACE(REPLACE(u.yearly_income, '$', ''), ',', '') AS DECIMAL(15,2)),
  CAST(REPLACE(REPLACE(u.total_debt, '$', ''), ',', '') AS DECIMAL(15,2)),
  u.credit_score,
  u.num_credit_cards,
  c.total_cards,
  c.max_credit_limit,
  c.darkweb_card_count,
  c.credit_card_count,
  c.debit_card_count,
  2019,
  t.total_transactions_2019,
  t.total_amount_2019
FROM users u
LEFT JOIN card_agg c ON u.id = c.client_id
LEFT JOIN trans_agg_2019 t ON u.id = t.client_id;

DROP TEMPORARY TABLE IF EXISTS trans_agg_2019;

-- ------------------------
-- Check new table: transaction_analysis
-- ------------------------
SELECT * FROM transaction_analysis LIMIT 10;
SELECT DISTINCT trans_year FROM transaction_analysis;

-- ------------------------
-- Additional Columns: active_user, productive_user, having_debt
-- ------------------------
ALTER TABLE transaction_analysis ADD COLUMN active_user INT;
ALTER TABLE transaction_analysis ADD COLUMN productive_user INT;
ALTER TABLE transaction_analysis ADD COLUMN having_debt INT;

SET SQL_SAFE_UPDATES = 0;

UPDATE transaction_analysis ta
JOIN (
    SELECT id
    FROM (
        SELECT id
        FROM transaction_analysis
        GROUP BY id
        HAVING COALESCE(SUM(total_transactions), 0) > 0
    ) AS filtered_ids
) active_ids ON ta.id = active_ids.id
SET ta.active_user = 1;

UPDATE transaction_analysis
SET active_user = 0
WHERE active_user IS NULL;


UPDATE transaction_analysis
SET productive_user = CASE
    WHEN current_age < 60 THEN 1
    ELSE 0
END;

UPDATE transaction_analysis
SET having_debt = CASE
    WHEN COALESCE(total_debt, 0) > 0 THEN 1
    ELSE 0
END;

-- ------------------------
-- Check new table and save it: transaction_analysis 
-- ------------------------
SELECT * FROM transaction_analysis LIMIT 10;

-- ------------------------
-- List of Users Who Never Transacted at All (2010–2019)
-- ------------------------
SELECT COUNT(*) AS total_users_without_transaction
FROM (
  SELECT id
  FROM transaction_analysis
  GROUP BY id
  HAVING COALESCE(SUM(total_transactions), 0) = 0
) AS no_tx;

-- ------------------------
-- Number of Active Users per Year
-- ------------------------
SELECT
  trans_year,
  COUNT(DISTINCT id) AS total_active_users
FROM transaction_analysis
WHERE total_transactions > 0
GROUP BY trans_year
ORDER BY trans_year;

-- ------------------------
-- Number of New Users per Year (Based on First Transaction > 0)
-- ------------------------
SELECT
  trans_year,
  COUNT(*) AS new_users
FROM (
  SELECT 
    id, 
    MIN(trans_year) AS trans_year
  FROM transaction_analysis
  WHERE total_transactions > 0
  GROUP BY id
) AS first_active_tx
GROUP BY trans_year
ORDER BY trans_year;

-- ------------------------
-- Top 5 Highest Debt-to-Income Ratios
-- ------------------------
SELECT DISTINCT 
  id, 
  total_debt, 
  yearly_income,
  ROUND(total_debt / yearly_income, 2) AS debt_to_income_ratio
FROM transaction_analysis
WHERE yearly_income > 0
ORDER BY debt_to_income_ratio DESC
LIMIT 5;

-- ------------------------
-- Outlier Detection – Number of Users with Total Amount in 1 Year > 100K
-- ------------------------
SELECT COUNT(DISTINCT id) AS total_outlier_users
FROM transaction_analysis
WHERE total_amount > 100000;

-- ------------------------
-- Average Credit Score by Gender
-- ------------------------
WITH per_user AS (
  SELECT 
    id,
    gender,
    AVG(credit_score) AS credit_score_per_user
  FROM transaction_analysis
  GROUP BY id, gender
)
SELECT 
  gender,
  ROUND(AVG(credit_score_per_user), 2) AS avg_credit_score
FROM per_user
GROUP BY gender;


-- ------------------------
-- Average Transaction Value and Credit Score by Age Group
-- ------------------------
WITH per_user AS (
  SELECT 
    id,
    MIN(current_age) AS current_age,
    SUM(total_amount) AS total_spending,
    SUM(total_transactions) AS total_tx,
    ROUND(SUM(total_amount) / NULLIF(SUM(total_transactions), 0), 2) AS avg_tx_per_user,
    AVG(credit_score) AS avg_credit_score
  FROM transaction_analysis
  GROUP BY id
)
SELECT
  CASE
    WHEN current_age < 30 THEN 'Under 30'
    WHEN current_age BETWEEN 30 AND 49 THEN '30–49'
    ELSE '50+'
  END AS age_group,
  ROUND(AVG(avg_tx_per_user), 2) AS avg_transaction_per_user,
  ROUND(AVG(avg_credit_score), 2) AS avg_credit_score
FROM per_user
GROUP BY age_group;

-- ------------------------
-- Distribution of Total Number of Cards per User
-- ------------------------
WITH per_user AS (
  SELECT id, MAX(total_cards) AS total_cards
  FROM transaction_analysis
  GROUP BY id
)
SELECT total_cards, COUNT(*) AS user_count
FROM per_user
GROUP BY total_cards
ORDER BY total_cards;

-- ------------------------
-- Average Number of Credit and Debit Cards per Unique User
-- ------------------------
WITH per_user AS (
  SELECT id,
         MAX(credit_card_count) AS credit_card_count,
         MAX(debit_card_count) AS debit_card_count
  FROM transaction_analysis
  GROUP BY id
)
SELECT 
  ROUND(AVG(credit_card_count), 2) AS avg_credit_cards_per_user,
  ROUND(AVG(debit_card_count), 2) AS avg_debit_cards_per_user
FROM per_user;

-- ------------------------
-- Top 5 combinations of years and credit score segments with the highest average spending per user
-- ------------------------
WITH per_user_year AS (
  SELECT 
    id,
    trans_year,
    AVG(credit_score) AS credit_score,
    SUM(total_amount) AS total_amount
  FROM transaction_analysis
  GROUP BY id, trans_year
),
per_segment_year AS (
  SELECT 
    trans_year,
    CASE 
      WHEN credit_score < 600 THEN 'Low (<600)'
      WHEN credit_score BETWEEN 600 AND 749 THEN 'Medium (600-749)'
      ELSE 'High (750+)' 
    END AS credit_score_group,
    ROUND(AVG(total_amount), 2) AS avg_annual_spending_per_user
  FROM per_user_year
  GROUP BY trans_year, credit_score_group
)
SELECT *
FROM per_segment_year
ORDER BY avg_annual_spending_per_user DESC
LIMIT 5;

-- ------------------------
-- Percentage of Users Exposed to the Darkweb Based on Unique IDs
-- ------------------------
WITH per_user AS (
  SELECT 
    id,
    MAX(darkweb_card_count) AS darkweb_card_count
  FROM transaction_analysis
  GROUP BY id
)
SELECT 
  COUNT(*) AS total_users,
  SUM(CASE WHEN darkweb_card_count > 0 THEN 1 ELSE 0 END) AS exposed_users,
  ROUND(100.0 * SUM(CASE WHEN darkweb_card_count > 0 THEN 1 ELSE 0 END) / COUNT(*), 2) AS exposed_percentage
FROM per_user;

