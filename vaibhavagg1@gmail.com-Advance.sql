--SQL Advance Case Study

--1. List all the states in which we have customers who have bought cellphones
--from 2005 till today.

--Q1--BEGIN 

select
distinct state
from dim_location as t1
inner join fact_transactions as t2
on t1.idlocation = t2.idlocation
where quantity > 0 and DATE > '2004-12-31'

--Q1--END


--2. What state in the US is buying
--the most 'Samsung' cell phones?

--Q2--BEGIN

select top 1 state
from dim_location as t1
inner join fact_transactions as t2
on t1.idlocation = t2.idlocation

inner join dim_model as t3
on t2.idmodel = t3.idmodel

inner join dim_manufacturer as t4
on t3.idmanufacturer = t4.idmanufacturer

where country = 'US' and manufacturer_name = 'samsung'
group by state
order by max(quantity) desc

--Q2--END


--3. Show the number of transactions for each model per zip code per state.

--Q3--BEGIN 

select
IdModel,
count(idModel) as countIdModel,
state,
zipcode
from fact_transactions as t1
left join dim_location as t2
on t1.IdLocation =t2.IdLocation
group by IdModel, state, ZipCode
     
	
--Q3--END



--4. Show the cheapest cellphone(Output should contain the price also).

--Q4--BEGIN

select
top 1 IdModel,
max(TotalPrice) as CheapestCellphone
from fact_transactions
group by IdModel
order by max(totalPrice)     -- by default in ascending order


--Q4--END



--5. Find out the average price for each model in the top5 manufacturers in
--terms of sales quantity and order by average price.

--Q5--BEGIN  

select
IdManufacturer,
t1.Idmodel,
avg(TotalPrice) as Avg_Price
from fact_transactions as t1
left join Dim_model as t2
on t1.IdModel = t2.IdModel
where IdManufacturer in (select
                        top 5 IdManufacturer
                        from Fact_Transactions as tA
						inner join Dim_Model as tB
						on tA.IdModel = tB.Idmodel
						group by IdManufacturer
						order by sum(quantity) desc)
group by t1.IdModel, IdMAnufacturer
order by avg(TotalPrice) desc


--Q5--END


--6. List the names of the customers and the average amount spent in 2009,
-- where the average is higher than 500.

--Q6--BEGIN

select
Customer_Name,
avg(TotalPrice) as AvgAmountSpent
from Dim_Customer as t1
Left join Fact_Transactions as t2
on t1.IdCustomer = t2.IdCustomer

inner join Dim_Date as t3
on t2.Date = t3.Date
where year = 2009
group by Customer_Name
having avg(totalPrice) > 500

--Q6--END


--7. List if there is any model that was in the top 5 in terms of quantity,
-- simultaneously in 2008, 2009 and 2010.
	
--Q7--BEGIN 

SELECT TA.IDMODEL
FROM
(select
top 5 Sum(quantity) as Top_5_Quantity,
IdModel
from Fact_Transactions as t1
inner join Dim_Date as t2
on t1.Date = t2.Date
where year = ('2008')
group by IdModel
order by sum(quantity) desc) AS TA
INNER JOIN 
(select
top 5 Sum(quantity) as Top_5_Quantity,
IdModel
from Fact_Transactions as t1
inner join Dim_Date as t2
on t1.Date = t2.Date
where  year = ('2009')
group by IdModel
order by sum(quantity) desc) AS TB
ON TA.IDMODEL = TB.IDMODEL

INNER JOIN

(select
top 5 Sum(quantity) as Top_5_Quantity,
IdModel
from Fact_Transactions as t1
inner join Dim_Date as t2
on t1.Date = t2.Date
where year = ('2010')
group by IdModel
order by sum(quantity) desc) AS TC
ON TB.IDMODEL = TC.IDMODEL


--Q7--END	



--8. Show the manufacturer with the 2nd top sales in the year of 2009 and the
-- manufacturer with the 2nd top sales in the year of 2010.

--Q8--BEGIN 
select *
from

(select
sum(convert(float, TotalPrice)) as Top_2_Sales,
Manufacturer_name,
t1.DATE
from Fact_Transactions as t1
left join Dim_model as t2
on t1.IdModel = t2.IdModel
inner Join Dim_Date as t3
on t1.Date = t3.Date
inner join DIM_MANUFACTURER as t4
on t2.IDManufacturer = t4.IDManufacturer
where year = '2009'
group by Manufacturer_name, t1.date
order by sum(convert(float,totalPrice)) desc
offset 1 row
fetch next 1 row only) As TA

union 

select *
from
(select 
sum(convert(float,TotalPrice)) as Top_2_Sales,
Manufacturer_name,
t1.DATE
from Fact_Transactions as t1
left join Dim_model as t2
on t1.IdModel = t2.IdModel
inner Join Dim_Date as t3
on t1.Date = t3.Date
inner join DIM_MANUFACTURER as t4
on t2.IDManufacturer = t4.IDManufacturer
where year = '2010'
group by Manufacturer_Name, t1.date
order by sum(convert(float,totalprice)) desc
offset 1 row
fetch next 1 row only) as tB


--Q8--END




--9. Show the manufacturers that sold cellphones in 2010 but did not in 2009.

--Q9--BEGIN

select 
Distinct Manufacturer_Name
from Dim_Model as t1
inner join Fact_Transactions as t2
on t1.IdModel = t2.IdModel

inner join Dim_date as t3
on t2.Date = t3.Date

INNER JOIN DIM_MANUFACTURER AS T4
ON T1.IDManufacturer = T4.IDManufacturer  
where quantity > 0 and year = '2010'
     and t1.IDManufacturer not in (select
				IDManufacturer
				from DIM_MODEL as tA
				inner join FACT_TRANSACTIONS as tB
				on tA.idmodel = tB.IDModel
				where  DATEPART(year, convert(date, date, 105))= 2009)
				
	  	
--Q9--END


--10. Find top 100 customers and their average spend, average quantity by each
-- year. Also find the percentage of change in their spend.

--Q10--BEGIN 
	
select tA.Customer_Name, tA.Avg_Total_Price, tA.avg_Quantity,tA.year, ((tA.Avg_Total_Price - tB.Avg_Total_Price)/tb.Avg_Total_Price)*100 as '%changeFromPreviousYear'
from

(select 
customer_name,
avg(convert(float,TotalPrice)) as Avg_Total_Price,
avg(convert(float,quantity)) as avg_Quantity,
year
from Fact_Transactions as t1
inner join Dim_Date as t2
on t1.date = t2.Date
inner join DIM_CUSTOMER as t3
on t1.IDCustomer = t3.IDCustomer
where t3.IDCustomer in (select top 100 IDCustomer
					from FACT_TRANSACTIONS
					group by idcustomer
					order by sum(convert(float, totalprice)) desc)

group by Customer_Name, year) as tA

left join (select 
customer_name,
avg(convert(float,TotalPrice)) as Avg_Total_Price,
avg(convert(float,quantity)) as avg_Quantity,
year
from Fact_Transactions as t1
inner join Dim_Date as t2
on t1.date = t2.Date
inner join DIM_CUSTOMER as t3
on t1.IDCustomer = t3.IDCustomer
where t3.IDCustomer in (select top 100 IDCustomer
					from FACT_TRANSACTIONS
					group by idcustomer
					order by sum(convert(float, totalprice)) desc)

group by Customer_Name, year) as tB
on tA.customer_name = tB.customer_name
and tA.year -1 = tB.year


--Q10--END
	