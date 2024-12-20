# Dany's-Diner
SQL 8 Week challenge case study 1

## Introduction

Danny seriously loves Japanese food so in the beginning of 2021, he decides to embark upon a risky venture and opens up a cute little restaurant that sells his 3 favourite foods: sushi, curry and ramen.

Danny’s Diner is in need of your assistance to help the restaurant stay afloat - the restaurant has captured some very basic data from their few months of operation but have no idea how to use their data to help them run the business.

## Problem Statement

Danny wants to use the data to answer a few simple questions about his customers, especially about their visiting patterns, how much money they’ve spent and also which menu items are their favourite. Having this deeper connection with his customers will help him deliver a better and more personalised experience for his loyal customers.

He plans on using these insights to help him decide whether he should expand the existing customer loyalty program - additionally he needs help to generate some basic datasets so his team can easily inspect the data without needing to use SQL.

Danny has provided you with a sample of his overall customer data due to privacy issues - but he hopes that these examples are enough for you to write fully functioning SQL queries to help him answer his questions!

Danny has shared with you 3 key datasets for this case study:

- sales

- menu

- members

## Example Datasets

All datasets exist within the dannys_diner database schema - be sure to include this reference within your SQL scripts as you start exploring the data and answering the case study questions.

### Table 1: sales
The sales table captures all customer_id level purchases with an corresponding order_date and product_id information for when and what menu items were ordered.

### Table 2: menu
The menu table maps the product_id to the actual product_name and price of each menu item.

### Table 3: members
The final members table captures the join_date when a customer_id joined the beta version of the Danny’s Diner loyalty program.

## Case Study Questions
Each of the following case study questions can be answered using a single SQL statement:

#### What is the total amount each customer spent at the restaurant?
    select customer_id,sum(price) as total_amount 
    from sales 
    join menu on sales.product_id=menu.product_id  
    group by customer_id
    order by customer_id;

![Screenshot (13)](https://github.com/user-attachments/assets/d018f45d-538b-4190-94ec-afac9cb63208)


### How many days has each customer visited the restaurant?
    Select customer_id,count(distinct(order_date)) as days_customer_visited 
    from sales group by customer_id;
![Screenshot (17)](https://github.com/user-attachments/assets/fa837ec4-5dfe-4e48-8c15-adeba094d03c)

### What was the first item from the menu purchased by each customer?
    select customer_id,product_name 
    from menu 
    join sales on sales.product_id=menu.product_id
    where sales.order_date = (select min(order_date) from sales where customer_id=sales.customer_id)
    order by sales.customer_id,sales.order_date;
![Screenshot (19)](https://github.com/user-attachments/assets/2e391c98-3e7e-466b-abda-b638e34a9392)

    
### What is the most purchased item on the menu and how many times was it purchased by all customers?
    select count(sales.product_id) as most_purchased,product_name 
    from sales join menu on sales.product_id=menu.product_id
    group by product_name
    order by most_purchased desc;
![Screenshot (20)](https://github.com/user-attachments/assets/f3385167-8f6e-44f2-a011-c674e1f06602)


    
### Which item was the most popular for each customer?
    WITH PurchaseCounts AS (
    SELECT 
        s.customer_id,
        s.product_id,
        COUNT(s.product_id) AS purchase_count
    FROM 
        sales s
    GROUP BY 
        s.customer_id, s.product_id),MaxCounts AS (
    SELECT 
        customer_id,
        MAX(purchase_count) AS max_count
    FROM 
        PurchaseCounts
    GROUP BY 
        customer_id)
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
![Screenshot (21)](https://github.com/user-attachments/assets/1b5d7d3b-8870-49d4-8e22-27cfacd80be8)

    
### Which item was purchased first by the customer after they became a member?
      select distinct(sales.customer_id),menu.product_name
      from sales join members on members.customer_id=sales.customer_id
      join menu on menu.product_id=sales.product_id
      where join_date<order_date
      order by sales.customer_id;
![Screenshot (22)](https://github.com/user-attachments/assets/6918a08b-31cb-429f-8fa5-ae4147a54d00)

### Which item was purchased just before the customer became a member?
    select distinct(sales.customer_id),menu.product_name
    from sales
    join menu on menu.product_id=sales.product_id
    join members on members.customer_id=sales.customer_id
    where sales.order_date < members.join_date
    order by sales.customer_id;
![Screenshot (23)](https://github.com/user-attachments/assets/170f9294-f23e-4d3d-8bb1-d13edd0b7edd)

    
### What is the total items and amount spent for each member before they became a member?
    select sales.customer_id,count(menu.product_id) as total_items,sum(menu.price)as amount_spent
    from menu
    join sales on menu.product_id=sales.product_id
    join members on members.customer_id=sales.customer_id
    where sales.order_date < members.join_date
    group by sales.customer_id
    order by sales.customer_id;
![Screenshot (24)](https://github.com/user-attachments/assets/e9f6bfce-3217-47b7-ba2d-f557bee5e7e4)

### If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
    select sales.customer_id,
    sum(case
    when menu.product_name='sushi' then menu.price*2
    else menu.price
    end) *10 as points_earned
    from
    menu join sales on sales.product_id=menu.product_id
    group by sales.customer_id
    order by sales.customer_id;
![Screenshot (25)](https://github.com/user-attachments/assets/3ce6d1ab-68d8-4a0a-adf4-617669a63a90)
    
### In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?
    select sales.customer_id,
    sum(case
    when menu.product_name='sushi' or sales.order_date between members.join_date and members.join_date + interval 6 day then 
    menu.price*20
    else menu.price*10
    end) as points
    from sales
    join members on members.customer_id=sales.customer_id
    join menu on menu.product_id=sales.product_id
    where sales.customer_id in ('A','B') and sales.order_date between '2021-01-01' and '2021-01-31'
    group by sales.customer_id;
![Screenshot (26)](https://github.com/user-attachments/assets/f8dda980-2dad-4ef9-b384-aeab40f44588)

