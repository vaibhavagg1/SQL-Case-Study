-- CASE STUDY RETAIL DATA ANALYSIS

--Data Preparation and understanding


--Q.1
-- no. of row in each table using count function

select 'CUSTOMER' , count(*) from customer -- in customer table = 5,647 rows
UNION
select 'PROD_CAT_INFO', count(*) from prod_cat_info -- in prod_cat_info table = 23 rows
UNION
select 'TRANSACTIONS', count(*) from Transactions -- in transactions table = 23053 rows


--Q.2 
--total no. of transactions that has a return using count functiom

select 
Count(transaction_id) count_transactions
from Transactions
where qty < 0                          -- 2,177 transactions


--Q.3
--converting date into valid date format using convert

select 
convert(date, dob, 105) as DOBdate_new,
convert(date, tran_date, 105) as Tran_newDate
from Customer, Transactions


--Q.4 
-- time range of transaction using Datediff and convert along with min and max

select
DATEDIFF(day,Min(convert(date, tran_date, 105)), Max(convert(date, tran_date, 105))) as day_diff,
DATEDIFF(Month,Min(convert(date, tran_date, 105)), max(convert(date, tran_date, 105))) as month_diff,
DATEDIFF(year, min(convert(date, tran_date, 105)), max(convert(date, tran_date, 105))) as year_diff

from Transactions



--Q.5
--using where clause

select prod_cat
from prod_cat_info
where prod_subcat = 'DIY'  -- product = Books


-------

--Data Analysis

--Q.1
--using count, groupby and order by

select store_type,
count(store_type) as frequency
from Transactions
group by store_type
order by frequency desc  --most frequently used channel is e-shop = 9311 times


--Q.2
-- using count and group by

select
gender,
count(gender) as count_gender
from customer
group by Gender  -- Female customer = 2753 and Male customer = 2892

--Q.3
-- using count, group by and order by in desc.

select
city_code,
Count(city_code) as Count_cityCode
from customer
group by city_Code
order by Count(city_code) desc -- Maximum no. of customer are from city_code = 3,i.e, 595 customers.

--Q.4
-- using count, group by, having clause

select 
prod_cat,
count(prod_subcat) as Count_Subcat
from prod_cat_info
group by Prod_cat
having prod_cat = 'books'  -- 6 sub-categories under product books.

--Q.5
--using max and group by clause

select
prod_cat_code,
MAX(qty) as Max_qty
from Transactions
group by prod_cat_code -- The maximum quantity of product ever ordered is 5 product

--Q.6
-- net total revenue for books and electronic using sum, convert, inner join and where

select
sum(convert(float, total_amt)) as total_revenue
from prod_cat_info as t1
inner join Transactions as t2
on t1.prod_cat_code = t2.prod_cat_code
where prod_cat in ('Electronics', 'Books')       ---	net total rev for books and electronics = 130548482.415	

		
--Q.7 
-- using count, where, in, subquery

select count(*) as Count_cust
from customer
where customer_id in (select
					cust_id
					from Transactions
					where qty > -1
					group by cust_id
					having count(transaction_id) > 10)     --   6 Customers



--Q.8 
--using sum, convert, inner join, where, and clause.

select
sum(convert(float, total_amt)) as Combined_revenue
from Transactions as t1
inner join prod_cat_info as t2
on t1.prod_cat_code = t2.prod_cat_code
where	prod_cat in ('Electronics', 'Clothing')
		and
		store_type = 'flagship store'			-- Combined revenue earned is = 14658949.89

--Q.9
-- using sum, convert, inner join, where, and, group by clause

select
prod_subcat,
sum(convert(float, total_amt)) as Total_revenue
from prod_cat_info as t1
inner join Transactions as t2
on t1.prod_cat_code = t2.prod_cat_code

inner join Customer as t3
on t3.customer_Id = t2.cust_id
where gender = 'M'
   and prod_cat = 'Electronics'
group by prod_subcat				



--Q.10 
--using top, convert, sum, inner join, group by, order by desc, case.

select
top 5 prod_subcat,
(abs(sum( case
	when convert(float, qty) < 0 then convert(float, qty)
	else 0
	end)) * 100)/sum(abs(convert(float, qty))) as return_percentage ,
(sum( case
	when convert(float, qty) > 0 then convert(float, qty)
	else 0
	end) * 100)/sum(abs(convert(float, qty))) as sales_percentage

from Transactions as t1
inner join prod_cat_info as t2
on t1.prod_cat_code = t2.prod_cat_code
group by prod_subcat
order by sum(convert(float, total_amt)) desc		


--Q.11
--

select
sum(convert(float, total_amt)) as net_total_revenue
from Transactions as t1
inner join customer as t2
on t1.cust_id = t2.customer_Id
where DATEDIFF(year, convert(date, dob, 105), 
  (select
  dateadd(DAY, -30,max(convert(date, tran_date, 105)))
  from transactions))
between 25 and 35


--Q.12 
--using top, inner join, where, convert, dateadd, group by, and, order by

select
top 1 prod_cat
from prod_cat_info as t1
inner join Transactions as t2
on t1.prod_cat_code = t2.prod_cat_code
where qty < 0
      and
	  convert(date, tran_date, 105) >= (select
					DATEadd(month, -3 , max(convert(date,tran_date, 105)))
					from transactions)
group by prod_cat
order by sum(convert(float,Qty))											-- category = Books



--Q.13 
-- using top, group by, order by, sum, convert

select
top 1 store_type
from Transactions
group by Store_type
order by sum(convert(float, total_amt)) desc, sum(convert(float, qty)) desc			-- store type = e-Shop



--Q14 
--using inner join, group by, having with sub-query, avg, convert

select
prod_cat
from prod_cat_info as t1
inner join transactions as t2
on t1.prod_cat_code = t2.prod_cat_code
group by prod_cat
having (select
avg(convert(float, total_amt))
from Transactions) < avg(convert(float, total_amt))


--Q15 
--using avg, sum, convert, inner join, where with subquery, group by , order by

select
prod_cat,
avg(convert(float, total_amt)) as avg_total_amt,
sum(convert(float, total_amt)) as sum_total_amt
from prod_cat_info as t1
inner join Transactions as t2
on t1.prod_cat_code = t2.prod_cat_code 
where t1.prod_cat_code in  (select top 5 prod_cat_code
					from Transactions
					group by prod_cat_code
					order by sum(convert(float, qty)) desc)
group by prod_cat




