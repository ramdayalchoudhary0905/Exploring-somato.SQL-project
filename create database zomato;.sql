create database zomato;
use zomato;
CREATE TABLE goldusers_signup
(userid integer not null,
gold_signup_date date); 

INSERT INTO goldusers_signup
  (userid,gold_signup_date) 
 VALUES (1,'2018-10-9'),
		(3,'2018-10-11');

 
drop table if exists users;
CREATE TABLE users 
(userid integer,signup_date date); 

INSERT INTO users
     (userid,signup_date) 
	 VALUES (1,'2014-02-09'),
            (2,'2014-03-15'),
			(3,'2014-09-11');

drop table if exists sales;
CREATE TABLE sales
(userid integer,created_date date,product_id integer); 

INSERT INTO sales
(userid,created_date,product_id) 
 VALUES (1,'2017-06-17',2),
(3,'2019-03-21',1),
(2,'2017-06-23',3),
(1,'2016-07-15',2),
(1,'2018-11-02',3),
(3,'2015-9-26',2),
(1,'2018-03-15',1),
(1,'2019-02-19',3),
(2,'2016-01-11',1),
(1,'2018-05-17',2),
(1,'2017-08-16',1),
(3,'2016-10-21',1),
(3,'2018-09-18',2),
(3,'2017-05-22',2),
(2,'2018-02-08',2),
(2,'2019-01-03',3);


drop table if exists product;
CREATE TABLE product 
(product_id integer,product_name text,price integer); 

INSERT INTO product(product_id,product_name,price) 
 VALUES
(1,'p1',980),
(2,'p2',870),
(3,'p3',330);


select * from sales;
select * from product;
select * from goldusers_signup;
select * from users;


-- 1.what is total amount each customer spent on zomato?

select userid, sum(price) as Total_amount_spent
from sales
inner join product
on sales.product_id=product.product_id
group by userid;


-- 2. How many days each customer visit zomato?

select userid, count(distinct created_date)	as total_no_of_visit
from sales 
group by userid;


-- 3. What is the first product purchased by custmores?

select userid,product_id, created_date,first_product
from (select userid, product_id, created_date,
     rank() over(partition by userid  order by created_date asc ) as first_product
     from sales )as first_buy
where first_product=1;

-- 4. What is the most purchased item on the menu ? 

select product_id, count(product_id) as most_purhcased
from sales
group by product_id
limit 1;

-- 5. which item was purchased first by the customer after they bacame a member?  

SELECT * 
FROM (
    SELECT c.*, 
           RANK() OVER (PARTITION BY userid ORDER BY created_date DESC) AS rnk 
    FROM (
              SELECT a.userid, a.created_date, a.product_id, b.gold_signup_date 
			  FROM sales  a 
             INNER JOIN goldusers_signup  b ON a.userid = b.userid 
              AND a.created_date >= b.gold_signup_date
    ) as c
) as d 
WHERE rnk = 1;

-- 6. which item was purchased  by the customer just before bacoming a member?
  
SELECT * 
FROM (
    SELECT c.*, 
           RANK() OVER (PARTITION BY userid ORDER BY created_date DESC) AS rnk 
    FROM (
        SELECT a.userid, a.created_date, a.product_id, b.gold_signup_date 
        FROM sales a 
        INNER JOIN goldusers_signup b ON a.userid = b.userid 
        AND a.created_date <= b.gold_signup_date
    ) c
) d 
WHERE rnk = 1;

-- 7. What is total orders and amount spent for each member before they became member ?

SELECT userid, COUNT(created_date) AS order_purchased, SUM(price) AS total_amt_spent
FROM (
    SELECT c.*, d.price 
    FROM (
        SELECT a.userid, a.created_date, a.product_id, b.gold_signup_date 
        FROM sales a 
        INNER JOIN goldusers_signup b ON a.userid = b.userid AND a.created_date <= b.gold_signup_date
    ) c 
    INNER JOIN product d ON c.product_id = d.product_id
) e
GROUP BY userid;

/* 8. If buying each product generates points for eg 5rs = 2 zomato point and each product has different purchasing points 
for eg for p1 5rs = 1 zomato point, for p2 10rs = 5 zomato point and p3 5rs = 1 zomato point, 2rs = 1 zomato point, 

 calculate points  collected by each custmores and for which product has most points have been given till now  ?*/


SELECT userid, SUM(total_points) * 2.5 AS total_money_earned
FROM (SELECT e.*, amt / points AS total_points
     FROM (SELECT d.*, CASE 
                        WHEN product_id = 1 THEN 5 
                        WHEN product_id = 2 THEN 2 
                        WHEN product_id = 3 THEN 5 
                        ELSE 0 
                    END AS points
        FROM (SELECT c.userid, c.product_id, SUM(price) AS amt
             FROM (SELECT a.*, b.price 
                   FROM sales a 
                   INNER JOIN product b ON a.product_id = b.product_id) c
            GROUP BY userid, product_id) d) e
) f
GROUP BY userid;


SELECT *
FROM (SELECT *,
	 RANK() OVER (ORDER BY total_point_earned DESC) AS rnk
     FROM (SELECT product_id,SUM(total_points) AS total_point_earned
		  FROM (SELECT e.*,amt / points AS total_points
	           FROM (SELECT d.*,
				     CASE 
                        WHEN product_id = 1 THEN 5 
                        WHEN product_id = 2 THEN 2 
                        WHEN product_id = 3 THEN 5 
                        ELSE 0 
                    END AS points
                  FROM (SELECT c.userid,c.product_id,SUM(price) AS amt
                       FROM (SELECT a.*,b.price
                            FROM sales a
                           INNER JOIN product b ON a.product_id = b.product_id) AS c
                    GROUP BY userid, product_id) AS d) AS e
) AS f
GROUP BY product_id) AS g) AS h
WHERE rnk = 1;

/* 9. In the first one year after a customer joins the gold program (including their join date) 
In first one year after a customer joins gold program (including thier join date) irrespective 
of what the customer has purchased they earn 5 zomato points for every 10 rs spent who 
earned more 1 or 3 and what was their points earnings in thier first yr?*/


SELECT c.*, d.price * 0.5 AS total_points_earned 
FROM (SELECT a.userid, a.created_date, a.product_id, b.gold_signup_date 
     FROM sales a 
     INNER JOIN goldusers_signup b 
	 ON a.userid = b.userid AND a.created_date >= b.gold_signup_date 
     AND a.created_date <= DATE_ADD(b.gold_signup_date, INTERVAL 1 YEAR)) c 
INNER JOIN product d 
ON c.product_id = d.product_id;




f










