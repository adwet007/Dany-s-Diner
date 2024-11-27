-- Create a new schema
CREATE SCHEMA dannys_diner;
USE dannys_diner;

-- Create the sales table
CREATE TABLE sales (
  customer_id CHAR(1),
  order_date DATE,
  product_id INT
);

-- Insert data into the sales table
INSERT INTO sales (customer_id, order_date, product_id)
VALUES
  ('A', '2021-01-01', 1),
  ('A', '2021-01-01', 2),
  ('A', '2021-01-07', 2),
  ('A', '2021-01-10', 3),
  ('A', '2021-01-11', 3),
  ('A', '2021-01-11', 3),
  ('B', '2021-01-01', 2),
  ('B', '2021-01-02', 2),
  ('B', '2021-01-04', 1),
  ('B', '2021-01-11', 1),
  ('B', '2021-01-16', 3),
  ('B', '2021-02-01', 3),
  ('C', '2021-01-01', 3),
  ('C', '2021-01-01', 3),
  ('C', '2021-01-07', 3);

-- Create the menu table
CREATE TABLE menu (
  product_id INT,
  product_name VARCHAR(5),
  price INT
);

-- Insert data into the menu table
INSERT INTO menu (product_id, product_name, price)
VALUES
  (1, 'sushi', 10),
  (2, 'curry', 15),
  (3, 'ramen', 12);

-- Create the members table
CREATE TABLE members (
  customer_id CHAR(1),
  join_date DATE
);

-- Insert data into the members table
INSERT INTO members (customer_id, join_date)
VALUES
  ('A', '2021-01-07'),
  ('B', '2021-01-09');
-- What is the total amount each customer spent at the restaurant?
select customer_id,sum(price) as total_amount 
from sales 
join menu on sales.product_id=menu.product_id  
group by customer_id
order by customer_id;
-- How many days has each customer visited the restaurant?
Select customer_id,count(distinct(order_date)) as days_customer_visited 
from sales group by customer_id;
-- What was the first item from the menu purchased by each customer?
select customer_id,product_name 
from menu 
join sales on sales.product_id=menu.product_id
where sales.order_date = (select min(order_date) from sales where customer_id=sales.customer_id)
order by sales.customer_id,sales.order_date;
-- What is the most purchased item on the menu and how many times was it purchased by all customers?
select count(sales.product_id) as most_purchased,product_name 
from sales join menu on sales.product_id=menu.product_id
group by product_name
order by most_purchased desc;
-- Which item was the most popular for each customer?
WITH PurchaseCounts AS (
    SELECT 
        s.customer_id,
        s.product_id,
        COUNT(s.product_id) AS purchase_count
    FROM 
        sales s
    GROUP BY 
        s.customer_id, s.product_id
),
MaxCounts AS (
    SELECT 
        customer_id,
        MAX(purchase_count) AS max_count
    FROM 
        PurchaseCounts
    GROUP BY 
        customer_id
)
SELECT 
    pc.customer_id,
    m.product_name AS most_popular_item,
    pc.purchase_count
FROM 
    PurchaseCounts pc
JOIN 
    MaxCounts mc ON pc.customer_id = mc.customer_id AND pc.purchase_count = mc.max_count
JOIN 
    menu m ON pc.product_id = m.product_id
ORDER BY 
    pc.customer_id;
-- Which item was purchased first by the customer after they became a member?
select distinct(sales.customer_id),menu.product_name
from sales join members on members.customer_id=sales.customer_id
join menu on menu.product_id=sales.product_id
where join_date<order_date
order by sales.customer_id;
-- Which item was purchased just before the customer became a member?
select distinct(sales.customer_id),menu.product_name
from sales
join menu on menu.product_id=sales.product_id
join members on members.customer_id=sales.customer_id
where sales.order_date < members.join_date
order by sales.customer_id;
-- What is the total items and amount spent for each member before they became a member?
select sales.customer_id,count(menu.product_id) as total_items,sum(menu.price)as amount_spent
from menu
join sales on menu.product_id=sales.product_id
join members on members.customer_id=sales.customer_id
where sales.order_date < members.join_date
group by sales.customer_id
order by sales.customer_id;
select price from menu;
--  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
select sales.customer_id,
sum(case
when menu.product_name='sushi' then menu.price*2
else menu.price
end) *10 as points_earned
from
menu join sales on sales.product_id=menu.product_id
group by sales.customer_id
order by sales.customer_id;
select join_date from members;
select order_date from sales;
-- In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?
select sales.customer_id,
sum(case
when menu.product_name='sushi' or sales.order_date between members.join_date and members.join_date + interval 6 day then menu.price*20
else menu.price*10
end) as points
from sales
join members on members.customer_id=sales.customer_id
join menu on menu.product_id=sales.product_id
where sales.customer_id in ('A','B') and sales.order_date between '2021-01-01' and '2021-01-31'
group by sales.customer_id;
