
/*


	AdventureWorks2019 Data Exploration Project using SQL

	About Project:
	In this project I will perform multiple queries to explore Data in ADV2019 Data Base in order to show different SQL skills

	About ADV2019 Data Base: 

	The AdventureWork2019 database is sample database of fictional Bicycle manufacturer Company - 'Adventure Works Cycles' , that was originally published by Microsoft
	AdventureWorks database supports standard online transaction processing scenarios for a fictitious bicycle manufacturer.
	Scenarios include Manufacturing, Sales, Purchasing, Product Management, Contact Management, and Human Resources.

	Link to DataBase: https://github.com/Microsoft/sql-server-samples/releases/download/adventureworks/AdventureWorks2019.bak

	Skills used:  Table Joining
		      CTE(Common table expressions)
		      Pivoting
		      Group Functions
		      Scalar Functions
		      Window Functions
		      Data type casting
				 
*/


use AdventureWorks2019

-----------------------------------------------------------------
-- Data Exploration
-----------------------------------------------------------------


-------- Displaying information about products that was never ordered 

-- Skills used: Joining Tables

select 
  pp.ProductID, 
  pp.Name, 
  pp.Color, 
  pp.ListPrice, 
  pp.Size 
from 
  production.Product pp 
  left join sales.SalesOrderDetail sso on pp.ProductID = sso.productId 
where 
  sso.ProductID is null

go


-----------------------------------------------------------------


-------- Displaying information about customers that didnt make any order 

-- Skills used: Joining Tables, Scalar Functions

update sales.customer set personid=customerid     
where customerid <=290

update sales.customer set personid=customerid+1700     
where customerid >= 300 and customerid<=350

update sales.customer set personid=customerid+1700     
where customerid >= 352 and customerid<=701

go

select 
  c.CustomerID, 
  ISNULL(pp.LastName, 'Unknown') LastName, 
  ISNULL(pp.FirstName, 'Unknown') FirstName 
from 
  sales.Customer c 
  left join Person.Person pp on pp.BusinessEntityID = c.PersonID 
where 
  c.CustomerID not in(
    select 
      customerID 
    from 
      Sales.SalesOrderHeader
  ) 
order by 
  c.CustomerID

go
-----------------------------------------------------------------



-------- Getting Top 10 customers with biggest number of orders

-- Skills used:Group Functions,Joining Tables

select 
  top 10 soh.CustomerID, 
  pp.FirstName, 
  pp.LastName, 
  count(SalesOrderID) as CountOfOrders 
from 
  Sales.SalesOrderHeader soh 
  join Sales.Customer c on c.CustomerID = soh.CustomerID 
  join Person.Person pp on pp.BusinessEntityID = c.PersonID 
group by 
  soh.CustomerID, 
  pp.FirstName, 
  pp.LastName 
order by 
  4 desc
  
go
-----------------------------------------------------------------


-------- Displaying information about employees and their positions in addition  it will be displayed number of eployees that holds the same position

-- Skills used: Window Functions, Joining Tables

select 
  pp.FirstName, 
  pp.LastName, 
  he.JobTitle, 
  he.HireDate, 
  count(pp.BusinessEntityID) over(partition by he.JobTitle) CountOfTitle 
from 
  HumanResources.Employee he 
  join Person.Person pp on pp.BusinessEntityID = he.BusinessEntityID

go

-----------------------------------------------------------------


-------- Getting last order date and penultimate order date for each customer 

-- Skills used: CTE(Common Table Expressions), Window Functions, Table Joining

with LP as (
  select 
    soh.SalesOrderID, 
    soh.CustomerID, 
    pp.LastName, 
    pp.FirstName, 
    lead(soh.OrderDate, 0) over (
      partition by soh.customerID 
      order by 
        soh.OrderDate desc
    ) LastOrder, 
    lead(soh.OrderDate, 1) over (
      partition by soh.customerID 
      order by 
        soh.OrderDate desc
    ) PreviousOrder, 
    Rank() over (
      partition by soh.customerID 
      order by 
        soh.OrderDate desc
    ) RN 
  from 
    Sales.SalesOrderHeader soh 
    join Sales.Customer c on soh.CustomerID = c.CustomerID 
    join Person.Person pp on pp.BusinessEntityID = c.PersonID
) 
select 
  LP.SalesOrderID, 
  lp.CustomerID, 
  lp.LastName, 
  lp.FirstName, 
  lp.LastOrder, 
  lp.PreviousOrder 
from 
  LP 
where 
  LP.RN = 1


go

-----------------------------------------------------------------


-------- Getting the most expensive order for each year and dislpaying to whom this order belongs

-- Skills used: CTE(Common Table Expressions), Group Functions, Window Functions,Scalar Functions, Table Joining

with CTE_Top1 as (
  select 
    YEAR(soh.OrderDate) 'Year', 
    soh.SalesOrderID, 
    pp.LastName, 
    pp.FirstName, 
    sum(
      sod.UnitPrice * sod.OrderQty *(1 - Sod.UnitPriceDiscount)
    ) Total, 
    Row_Number() over(
      partition by YEAR(soh.OrderDate) 
      order by 
        sum(
          sod.UnitPrice * sod.OrderQty *(1 - Sod.UnitPriceDiscount)
        ) desc
    ) RN 
  from 
    Sales.SalesOrderDetail sod 
    join Sales.SalesOrderHeader soh on sod.SalesOrderID = soh.SalesOrderID 
    join Sales.Customer c on c.CustomerID = soh.CustomerID 
    join Person.Person pp on pp.BusinessEntityID = c.PersonID 
  group by 
    YEAR(soh.OrderDate), 
    soh.SalesOrderID, 
    pp.LastName, 
    pp.FirstName
) 
select 
  Year, 
  SalesOrderID, 
  LastName, 
  FirstName, 
  Total 
from 
  CTE_Top1 
where 
  RN = 1


go



-----------------------------------------------------------------


-------- Displaying number of orders for each month in the year in matrix table

-- Skills used: Pivoting, Scalar Functions




select 
  MM as 'Month', 
  [2011], 
  [2012], 
  [2013], 
  [2014] 
from 
  (
    select 
      YEAR(soh.OrderDate) YY, 
      Month(OrderDate) MM, 
      SalesOrderID 
    from 
      Sales.SalesOrderHeader soh
  ) x pivot (
    count(x.SalesOrderID) for YY in ([2011], [2012], [2013], [2014])
  ) as pvt1 
order by 
  MM
  
  


 go



-----------------------------------------------------------------


-------- Getting total price of all orders for each month in the year, and displaying grand total with  cumulative sum of total prices for each year

-- Skills used: CTE(Common Table Expressions), Window Functions, Table Joining , Scalar Functions, Group Functions




-----CTE1
with MoSum as (
  select 
    year(soh.OrderDate) Year, 
    MONTH(soh.OrderDate) Month, 
    round (
      SUM(soh.SubTotal), 
      2
    ) 'Sum_Price' 
  from 
    Sales.SalesOrderHeader soh 
  group by 
    year(soh.OrderDate), 
    MONTH(soh.OrderDate)
), 
-----CTE2
Mosum2 as (
  select 
    MoSum.Year, 
    cast(
      MoSum.Month as varchar(20)
    ) Month, 
    MoSum.Sum_Price, 
    sum(Sum_Price) over(
      partition by MoSum.Year 
      Order by 
        MoSum.Month
    ) 'Money', 
    Row_number() over(
      partition by MoSum.Year 
      Order by 
        MoSum.Month
    ) as RN 
  from 
    MoSum 
  union 
  select 
    year(soh.OrderDate) Year, 
    'grand_total', 
    null, 
    round(
      sum(soh.SubTotal), 
      2
    ), 
    13 as RN -- There is 12 months in year i numbered grand total of each year as number 13 so it will be always the last one in order in each group
  from 
    Sales.SalesOrderHeader soh 
  group by 
    year(soh.OrderDate)
) 
----FINAL SELECT
select 
  Mosum2.Year, 
  Mosum2.Month, 
  Mosum2.Sum_Price, 
  Mosum2.Money 
from 
  Mosum2 
order by 
  1, 
  Mosum2.RN


go

-----------------------------------------------------------------


-------- Displaying employees for each department in order of their appliance to this department from the newest to the oldest 
-------- Also we will get hire date for employee that was hired one before of each employee  and differense between their hire dates  in days

-- Skills used: Multiple table Joining, Scalar functions  and Window Functions

select 
  d.Name DepartmentName, 
  e.BusinessEntityID 'Employee`sId', 
  concat(pp.firstName, ' ', pp.LastName) 'Employee`sFullName', 
  e.HireDate, 
  DATEDIFF(
    mm, 
    e.HireDate, 
    GETDATE()
  ) Seniority, 
  lead(
    concat(pp.firstName, ' ', pp.LastName)
  ) over(
    partition by d.name 
    order by 
      DATEDIFF(
        dd, 
        e.HireDate, 
        GETDATE()
      )
  ) PreviuseEmpName, 
  lead(e.HireDate) over(
    partition by d.name 
    order by 
      DATEDIFF(
        dd, 
        e.HireDate, 
        GETDATE()
      )
  ) PreviusEmpHDate, 
  DATEDIFF(
    DD, 
    lead(e.HireDate) over(
      partition by d.name 
      order by 
        DATEDIFF(
          dd, 
          e.HireDate, 
          GETDATE()
        )
    ), 
    e.HireDate
  ) DiffDays 
from 
  HumanResources.Department d 
  join HumanResources.EmployeeDepartmentHistory edh on edh.DepartmentID = d.DepartmentID 
  join HumanResources.Employee e on edh.BusinessEntityID = e.BusinessEntityID 
  join Person.Person pp on pp.BusinessEntityID = e.BusinessEntityID 
where 
  edh.EndDate is null


go

-----------------------------------------------------------------
-------- Getting applied employees's info for each date and department  


-- Skills used: Data type converting, Scalar functions  and Aggregation functions


select 
  e.HireDate as hiredate, 
  edh.DepartmentID as departmentid, 
  STRING_AGG(
    CONCAT(
      CAST(
        pp.BusinessEntityID as varchar(20)
      ), 
      ' ', 
      pp.LastName, 
      ' ', 
      pp.FirstName
    ), 
    ' .'
  ) as a 
from 
  HumanResources.EmployeeDepartmentHistory edh 
  join HumanResources.Employee e on e.BusinessEntityID = edh.BusinessEntityID 
  join Person.Person pp on pp.BusinessEntityID = e.BusinessEntityID 
where 
  edh.EndDate is null 
group by 
  e.HireDate, 
  edh.DepartmentID 
order by 
  e.HireDate
 
go
 



 
  
  
  








