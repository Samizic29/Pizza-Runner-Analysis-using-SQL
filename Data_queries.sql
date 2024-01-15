/*
Pizza Runner business analysis
Skills used: Basic Aggregations, Windows Function, Sub-query, Common Table Expression (CTE), Joins,
String Transformations, Dealing with null values, Regular Expressions etc. was used to solve the business questions.
*/

 -- Data Cleaning

/* Customer order table clean */
-- Replace 'null' and empty values 0 for exclusions column
UPDATE customer_orders
SET exclusions = 0
WHERE exclusions = 'null' OR exclusions = '';

-- Replace 'null' and empty values 0 for extras column
UPDATE customer_orders
SET extras = 0
WHERE extras = 'null' OR extras = '';

-- Create a new table 'customer_orders_new'
CREATE TABLE customer_orders_new (
  "order_id" INTEGER,
  "customer_id" INTEGER,
  "pizza_id" INTEGER,
  "exclusions" INTEGER,
  "extras" INTEGER,
  "order_time" TIMESTAMP
);

/* Insert data from the old table into the new table with type conversion and values split in exclusions and extras column */
INSERT INTO customer_orders_new
  ("order_id", "customer_id", "pizza_id", "exclusions", "extras", "order_time")
SELECT
	order_id,
    customer_id,
    pizza_id,
    UNNEST(STRING_TO_ARRAY(exclusions, ','))::INTEGER AS exclusions,
    UNNEST(STRING_TO_ARRAY(extras, ','))::INTEGER AS extras,
	order_time
FROM customer_orders;

-- Replace NULL with 0 in exclusions and extras columns
UPDATE customer_orders_new
SET exclusions = 0
WHERE exclusions IS NULL;

UPDATE customer_orders_new
SET extras = 0
WHERE extras IS NULL;

-- Drop the old table
DROP TABLE customer_orders;

--  Rename the new table to the original table name
ALTER TABLE customer_orders_new RENAME TO customer_orders;
  
/* Runner orders table clean */
-- Create a new table 'runner_orders_new'
 CREATE TABLE runner_orders_new (
  "order_id" INTEGER,
  "runner_id" INTEGER,
  "pickup_time" TIMESTAMP,
  "distance" DECIMAL,
  "duration" INTERVAL,
  "cancellation" TEXT
);

-- Insert data from the old table into the new table with type conversions
INSERT INTO runner_orders_new ("order_id", "runner_id", "pickup_time", "distance", "duration", "cancellation")
SELECT
    "order_id",
  "runner_id",
  NULLIF("pickup_time", 'null')::TIMESTAMP AS "pickup_time",
  NULLIF(REGEXP_REPLACE("distance", '[^0-9.]', '', 'g'), '')::DECIMAL AS "distance",
  CASE WHEN duration = 'null' THEN NULL ELSE CAST("duration" AS INTERVAL) END AS "duration",
  CASE WHEN cancellation = 'null' OR cancellation = '' THEN NULL ELSE CAST(cancellation AS TEXT) END AS "cancellation"
FROM runner_orders;

-- Replace NULL with 'No' values
UPDATE runner_orders_new
SET cancellation = 'No'
WHERE cancellation IS NULL;

-- Drop the old table
DROP TABLE runner_orders;

--  Rename the new table to the original table name
ALTER TABLE runner_orders_new RENAME TO runner_orders;

/* Pizza Recipes table clean */
-- Create a new table
CREATE TABLE pizza_recipes_new (
   "pizza_id" INTEGER,
  "toppings" INTEGER
);

/* Insert data from the old table into the new table with type conversion and values split in toppings column. */
INSERT INTO pizza_recipes_new
  ("pizza_id", "toppings")
SELECT
	pizza_id,
    UNNEST(STRING_TO_ARRAY(toppings, ','))::INTEGER AS toppings
FROM pizza_recipes;

-- Drop the old table
DROP TABLE pizza_recipes;

--  Rename the new table to the original table name
ALTER TABLE pizza_recipes_new RENAME TO pizza_recipes;

-- Tables:
-- Runner table
SELECT * FROM pizza_runner.runner
-- Customer orders table
SELECT * FROM pizza_runner.customer_orders
-- Runner orders table
SELECT * FROM pizza_runner.runner_orders
-- Pizza names table
SELECT * FROM pizza_runner.pizza_names
-- Pizza recipes table
SELECT * FROM pizza_runner.pizza_recipes
-- Pizza toppings table
SELECT * FROM pizza_runner.pizza_toppings

-- Business Questions Solved:
-- Pizza Metrics
Q -- 1. How many pizzas were ordered?
SELECT COUNT(pizza_id) AS pizza_orders
FROM pizza_runner.customer_orders;

Q -- 2. How many unique customer orders were made?
SELECT COUNT(DISTINCT customer_id) AS unique_customer_orders
FROM pizza_runner.customer_orders

Q -- 3. How many successful orders were delivered by each runner?
SELECT runner_id runner,
	   COUNT(*) total_delivered_orders
FROM pizza_runner.runner_orders
WHERE cancellation = 'No'
GROUP BY 1;

Q -- 4. How many of each type of pizza was delivered?
SELECT p.pizza_id,
	   p.pizza_name,
       COUNT(c.pizza_id) total_delivered
FROM pizza_runner.pizza_names p
LEFT JOIN pizza_runner.customer_orders c
ON p.pizza_id = c.pizza_id
GROUP BY 1, 2;

Q -- 5. How many Vegetarian and Meatlovers were ordered by each customer?
SELECT c.customer_id,
	   p.pizza_name,
	   COUNT (c.order_id) total_order
FROM pizza_runner.customer_orders c
JOIN pizza_runner.pizza_names p
ON c.pizza_id = p.pizza_id
GROUP BY 1, 2
ORDER BY 1;

Q -- 6. What was the maximum number of pizzas delivered in a single order?
SELECT MAX(pizza_count) max_pizzas_delivered
FROM	(
	SELECT order_id,
	   	   COUNT(*) pizza_count
	FROM pizza_runner.customer_orders
	GROUP BY 1
) pizza_counts;

Q -- 7. For each customer, how many delivered pizzas had at least 1 change and how many had no changes?
SELECT customer_id,
	   COUNT(CASE WHEN exclusions <> 0 OR extras <> 0 THEN 1 END) AS pizzas_with_change,
    	   COUNT(CASE WHEN exclusions = 0 AND extras = 0 THEN 1 END) AS pizzas_with_no_change
FROM pizza_runner.customer_orders
GROUP BY 1
HAVING COUNT(CASE WHEN exclusions <> 0 OR extras <> 0 THEN 1 END) >= 1 AND COUNT(CASE WHEN exclusions = 0 AND extras = 0 THEN 1 END) = 0
ORDER BY 1;

Q -- 8. How many pizzas were delivered that had both exclusions and extras?
SELECT COUNT(order_id) AS pizzas_delivered
FROM pizza_runner.customer_orders
WHERE exclusions <> 0 AND extras <> 0

Q -- 9. What was the total volume of pizzas ordered for each hour of the day?
WITH pizza_count_hour AS (
	SELECT DATE_TRUNC('hour', order_time) order_hour,
	   	   COUNT(pizza_id) AS pizzas_ordered
	FROM pizza_runner.customer_orders
	GROUP BY 1
)
SELECT order_hour,
	   SUM(pizzas_ordered) total_pizzas_ordered
FROM pizza_count_hour
GROUP BY 1
ORDER BY 1;

Q -- 10. What was the volume of orders for each day of the week?
SELECT EXTRACT('week' FROM order_time) order_week,
	   EXTRACT('day' FROM order_time) order_day,
	   COUNT(*) total_orders
FROM pizza_runner.customer_orders
GROUP BY 1, 2
ORDER BY 1, 2;

-- Runner and Customer Experience
Q -- 1. How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)

SELECT week_start_date,
  	   COUNT(*) AS no_runners_signed_up
FROM (
    SELECT
      generate_series('2021-01-01'::DATE, '2021-01-20'::DATE, '1 week'::INTERVAL) AS week_start_date
) AS weeks
LEFT JOIN pizza_runner.runners
ON registration_date >= week_start_date AND registration_date < week_start_date + '1 week'::INTERVAL
GROUP BY 1
ORDER BY 1; 

Q-- 2. What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?

SELECT runner_id,
	   ROUND(AVG(EXTRACT('minute' FROM pickup_time))) runners_avg_pickup_time_minute
FROM pizza_runner.runner_orders
GROUP BY 1
ORDER BY 1;

/* Creating Views to store data for later visualization */
  
-- How many Vegetarian and Meatlovers were ordered by each customer?
CREATE VIEW customer_orders AS
SELECT c.customer_id,
	   p.pizza_name,
	   COUNT (c.order_id) total_order
FROM pizza_runner.customer_orders c
JOIN pizza_runner.pizza_names p
ON c.pizza_id = p.pizza_id
GROUP BY 1, 2
ORDER BY 1;
