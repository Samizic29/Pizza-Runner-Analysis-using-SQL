# Business Analysis in SQL: Pizza Runner Case Study

## Oyedele Samuel

## Introduction
This is a SQL project (case study #2) from Danny’s <a href = "https://8weeksqlchallenge.com/case-study-2/"> 8weeksqlchallenge. </a> Pizza Runner is a Pizza business that recruit ‘runners’ to deliver fresh prizza from Pizza Runner headquarters to its customers.

## Problem Statement
> Danny wants to use the data to answer a few simple questions about his customers, especially about the pizzas orders, how much money they’ve spent and also which pizza menu items are their favorite.
> The data provided requires further data cleaning in other to perform some basic calculations so he can better direct his runners and optimize Pizza Runner’s operation.

## Datasets
Six (6) tables was provided for this case study:
1.	Runners: The runners table shows the registration_date for each new runner.
   
2.	Customer_orders: Customer pizza orders are captured in the customer_orders table with 1 row for each individual pizza that is part of the order.
The pizza_id relates to the type of pizza which was ordered whilst the exclusions are the ingredient_id values which should be removed from the pizza and the extras are the ingredient_id values which need to be added to the pizza.
The exclusions and extras columns will need to be cleaned up before using them in the queries.
<i> Note that customers can order multiple pizzas in a single order with varying exclusions and extras values even if the pizza is the same type!</i>

3.	Runner orders:  The runner_order table captures the pickup_time, distance and duration of each orders assigned to a runner. However not all orders are fully completed and can be cancelled by the restaurant or the customer.
<i> Note: There are some known data issues with this table that need to be cleaned up using them in the queries.</i>

4.	Pizza names: The pizza_names table captures the pizzas available in Pizza Runner.
   
5.	Pizza recipes: Each pizza_id has a standard set of toppings which are used as part of the pizza recipe.
   
6.	Pizza toppings: This table contains all of the topping_name values with their corresponding topping_id value.

## Data Cleaning
In this section, some of the tables are cleaned before performing queries on them for better analysis.
- Customer orders table
- Runner orders table
- Pizza recipes table

## Business Questions

A. Pizza Metrics
1.	How many pizzas were ordered?
2.	How many unique customer orders were made?
3.	How many successful orders were delivered by each runner?
4.	How many of each type of pizza was delivered?
5.	How many Vegetarian and Meatlovers were ordered by each customer?
6.	What was the maximum number of pizzas delivered in a single order?
7.	For each customer, how many delivered pizzas had at least 1 change and how many had no changes?
8.	How many pizzas were delivered that had both exclusions and extras?
9.	What was the total volume of pizzas ordered for each hour of the day?
10.	What was the volume of orders for each day of the week?

B. Runner and Customer Experience
1.	How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)
2.	What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?
3.	What was the average distance travelled for each runner?

## Data Insights
- Total pizzas order - 16
- They are five unique customers' orders.
- Total delivered (successful) orders - 8.
- Runner id (1) delivered the most successful pizza orders - 4.
- Meatlovers pizza is the customer's pizzas favourite.
- Customer id (103) has the highest pizza orders - 5.
- Pizzas delivered with both exclusions and extras - 3

## Conclusion
> I was able to clean and analyze business data that gives data insights to the stakeholders and helped in business decision-making. It was a great case study to practice and advance my SQL skills.

> You can check out the full documentation: <a href="https://medium.com/@samueloyedele/business-analysis-in-sql-pizza-runner-sql-case-study-212a2b9f6850">here</a>

## Tool
PostgreSQL v13

The areas of SQL covered in this case study:
-	Basic Aggregations
-	Windows Function
-	Common Table Expression
-	Joins
-	String Transformations
-	Regular expressions
-	Dealing with null values etc. 

