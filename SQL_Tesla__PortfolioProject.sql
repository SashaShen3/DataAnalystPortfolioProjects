/*

Tesla's Casualties Data Cleaning&Exploration Project

About DataSet:
This dataset reveals an in-depth analysis of tragic Tesla vehicle accidents that have resulted in the death of a driver, occupant, cyclist, or pedestrian.
It contains an extensive amount of information related to the fatal incidents including the date and location of each crash,
model type involved and if Autopilot was enabled at the time. 

Link to DataSet:  https://github.com/SashaShen3/DataAnalystPortfolioProjects/blob/main/Tesla%20Deaths%20-%20Deaths%20(3).csv


--------------- Skills used -------------
--	CTE(Common table expressions)		
--	RegEX(Regular expressions)			
--	Temporary Tables					
--	Windows Functions					
--	Pivoting						
--	Creating Views					    
--	Converting Data Types				
--	Declaring variables using t-sql		
--      Scalar functions					
--      DDL,DML							    


*/

use PortfolioProjects

---- Observing the Data

select * from [Tesla Deaths - Deaths (3)]

go

-------------------------------------------------------------------------------------------------------

---- Selecting the Data we will work with

-------------------------------------------------------------------------------------------------------

select  tdd.[Case] ,
tdd.Year,
tdd.Date,
tdd.Country,
tdd.State,
tdd.Description,
tdd.Deaths,
tdd.Tesla_driver,
tdd.Tesla_occupant,
tdd.Other_vehicle,
tdd.Cyclists_Peds,
tdd.TSLA_cycl_peds,
tdd.Model,
tdd.AutoPilot_claimed,
tdd.Verified_Tesla_Autopilot_Death
from [Tesla Deaths - Deaths (3)] as tdd

go




-------------------------------------------------------------------------------------------------------
---- Preparing Data for Analysis: Filling Null cells , Removing unused columns
-------------------------------------------------------------------------------------------------------


---- Filling 'State' column, If state is null set state as country name 

select distinct country, State from [Tesla Deaths - Deaths (3)] as tdd
where  state is null

UPDATE [Tesla Deaths - Deaths (3)]
SET State = ISNULL(State,Country)

select  State 
from [Tesla Deaths - Deaths (3)] 
where  state is null


go
---- Filling 'Tesla_driver', if null set as '-'

select count(*)
from [Tesla Deaths - Deaths (3)] as tdd
where  Tesla_driver is null

UPDATE [Tesla Deaths - Deaths (3)]
SET Tesla_driver = ISNULL(Tesla_driver,'-')

select count(*)
from [Tesla Deaths - Deaths (3)] as tdd
where  Tesla_driver is null


go
---- Filling ''Tesla_occupant'' column ,  if null set as '-'

select count(*)
from [Tesla Deaths - Deaths (3)] as tdd
where  Tesla_occupant is null

UPDATE [Tesla Deaths - Deaths (3)]
SET Tesla_occupant = ISNULL(Tesla_occupant,'-')

select count(*)
from [Tesla Deaths - Deaths (3)] as tdd
where  Tesla_occupant is null

go
---- Filling ''Cyclists_Peds'' column ,  if null set as '-'
select count(*)
from [Tesla Deaths - Deaths (3)] as tdd
where  Cyclists_Peds is null

UPDATE [Tesla Deaths - Deaths (3)]
SET Cyclists_Peds = ISNULL(Cyclists_Peds,'-')

select count(*)
from [Tesla Deaths - Deaths (3)] as tdd
where  Cyclists_Peds is null

go
---- Filling ''Model'' column ,  if null set as '-'
select count(*)
from [Tesla Deaths - Deaths (3)] as tdd
where  Model is null

UPDATE [Tesla Deaths - Deaths (3)]
SET Model = ISNULL(Model,'-')

select count(*)
from [Tesla Deaths - Deaths (3)] as tdd
where  Model is null

go
---- Filling ''AutoPilot_claimed'' column ,  if null set as '-'
select count(*)
from [Tesla Deaths - Deaths (3)] as tdd
where  AutoPilot_claimed is null

UPDATE [Tesla Deaths - Deaths (3)]
SET AutoPilot_claimed = ISNULL(AutoPilot_claimed,'-')


select count(*)
from [Tesla Deaths - Deaths (3)] as tdd
where  AutoPilot_claimed is null

go

---- Filling ''Verified_Tesla_Autopilot_Death'' column ,  if null set as '-'

select count(*)
from [Tesla Deaths - Deaths (3)] as tdd
where  Verified_Tesla_Autopilot_Death is null

UPDATE [Tesla Deaths - Deaths (3)]
SET Verified_Tesla_Autopilot_Death = ISNULL(Verified_Tesla_Autopilot_Death,'-')

select count(*)
from [Tesla Deaths - Deaths (3)] as tdd
where  Verified_Tesla_Autopilot_Death is null

go


---- Filling ''TSLA_cycl_peds'' column ,  if null set as '-'

select count(*)
from [Tesla Deaths - Deaths (3)] as tdd
where  TSLA_cycl_peds is null

UPDATE [Tesla Deaths - Deaths (3)]
SET TSLA_cycl_peds = ISNULL(TSLA_cycl_peds,'-')

select count(*)
from [Tesla Deaths - Deaths (3)] as tdd
where  TSLA_cycl_peds is null

go


---- Filling ''Other_vehicle'' column ,  if null set as '-'

select count(*)
from [Tesla Deaths - Deaths (3)] as tdd
where  Other_vehicle is null

UPDATE [Tesla Deaths - Deaths (3)]
SET Other_vehicle = ISNULL(Other_vehicle,'-')

select count(*)
from [Tesla Deaths - Deaths (3)] as tdd
where  Other_vehicle is null

go
-------------------------------------------------------------------------------------------------------

---- Removing Columns that wont be used

Select *
From PortfolioProjects.dbo.[Tesla Deaths - Deaths (3)]


ALTER TABLE PortfolioProjects.dbo.[Tesla Deaths - Deaths (3)]
DROP COLUMN Source,Note,Deceased_1,Deceased_2,Deceased_3,Deceased_4

go
-------------------------------------------------------------------------------------------------------






-------------------------------------------------------------------------------------------------------

---- Data Exploration

-------------------------------------------------------------------------------------------------------
-- Model vs verified accidents vs number of casualties

-- Skills used: Scalar functions

select tdd.Model , 
count(*) as 'Number of accidents',
sum(tdd.Deaths) as 'Total Casualties'
from [Tesla Deaths - Deaths (3)] as tdd
where model != '-'
group by tdd.Model
order by 3 desc

go
----------------------------------------------------------------------
-- Total Deaths per year where Tesla was involved + summary

-- Skills used: Scalar functions, Set operators, Data type converting


select * from [Tesla Deaths - Deaths (3)]

select cast(Year as varchar(10)) as 'Year',
SUM(tdd.Deaths) as 'Deaths per year'
from [Tesla Deaths - Deaths (3)] as tdd
group by Year
union 
select 'Total:', sum(Deaths)
from [Tesla Deaths - Deaths (3)]

go

-- Pivoting previous query
-- Skills used: Pivot, Scalar functions

SELECT  'Casualties' as 'Years' , [2013],[2014],[2015],[2016],[2017],[2018],[2019],[2020],[2021],[2022]
FROM (select Year ,
tdd.Deaths
from [Tesla Deaths - Deaths (3)] as tdd) p
PIVOT(SUM(Deaths) for Year IN ([2013],[2014],[2015],[2016],[2017],[2018],[2019],[2020],[2021],[2022])) pvt

go
-------------------------------------------------------------------------------------------------------

-- Getting cumulative sum from previous query

-- Skills used: performing aggregation calculation on aggregation function using CTE ,Window functions,Scalar functions

select * from [Tesla Deaths - Deaths (3)]

go

with CTE_dpy
as
(select Year,
SUM(tdd.Deaths) as 'Deaths per year'
from [Tesla Deaths - Deaths (3)] as tdd
group by Year)
select *,
sum(dpy.[Deaths per year]) over(order by dpy.Year 
ROWS BETWEEN UNBOUNDED PRECEDING and  CURRENT ROW) as 'Cumulative sum'
from CTE_dpy as dpy

go

-------------------------------------------------------------------------------------------------------
-- Global numbers

-- Skills used: Data type casting, Scalar functions

select * from [Tesla Deaths - Deaths (3)]

select DATEDIFF(YY,MIN(tdd.date),MAX(tdd.date)) as 'Number of Years',
count(*) as 'Total acidents',
SUM(tdd.Deaths) as 'Total deaths',
round(cast(SUM(tdd.Deaths) as float)/cast(count(*) as float),2) as 'Average deaths per Accident',
round(cast(SUM(tdd.Deaths) as float)/ cast(DATEDIFF(YY,MIN(tdd.date),MAX(tdd.date)) as float), 2) as 'Average number of deaths per year'
from [Tesla Deaths - Deaths (3)] as tdd

go
-------------------------------------------------------------------------------------------------------
-- Chance that Tesla's driver will survive

-- Skill used: Subqueries, Aggregate functions, Data type casting

select * from [Tesla Deaths - Deaths (3)]

go


select count(*) as 'Drivers involved in accidents',
(select count(*) from [Tesla Deaths - Deaths (3)] where Tesla_driver = '-' ) as 'Drivers survived ',
concat(
round(cast((select count(*) from [Tesla Deaths - Deaths (3)] where Tesla_driver = '-' ) as float)/ cast(COUNT(*) as float)*100,2) , ' %' 
 ) as 'Drivers chance to survive'
from [Tesla Deaths - Deaths (3)]

go


-------------------------------------------------------------------------------------------------------
--Chanse that your tesla cathces on fire during the car accident

--Skill used: T-SQL Variable declaring, Data type casting, RegEX(Regular Expressions),Scalar functions



--select count(*) from [Tesla Deaths - Deaths (3)]
--select count(*) from [Tesla Deaths - Deaths (3)] as tdd
--where tdd.description like '%burn%' or tdd.description like '%fire%'

select * from [Tesla Deaths - Deaths (3)]

go

declare @TotalAccidents as float 
select @TotalAccidents = count(*) from [Tesla Deaths - Deaths (3)]
select count(*) as 'Fire accidents',
@TotalAccidents as 'Total accidents',
concat(Round((cast(count(*) as float)/@TotalAccidents*100),2),' %') as 'Fire chance'
from [Tesla Deaths - Deaths (3)] as tdd
where tdd.description like '%burn%' or tdd.description like '%fire%'

go
-------------------------------------------------------------------------------------------------------
-- Percentage of cases where autopilot was found guilty in people death

-- Skills used: Data type converting,Scalar Functions



select * from [Tesla Deaths - Deaths (3)]

go



select concat(round(cast((select count(*) from [Tesla Deaths - Deaths (3)] where Verified_Tesla_Autopilot_Death != '-')  as float)  /  cast(count(*) as float)*100  ,  2),   ' %')   as 'Autopilot guilt percantage'
from [Tesla Deaths - Deaths (3)] as tdd

go
-------------------------------------------------------------------------------------------------------

-- Number of deaths for each country and its percantage out of total casualties + summary

-- Skill used: CTE, Set Operators, Casting data types, Window functions, Aggregate functions

select * from [Tesla Deaths - Deaths (3)]

go



with CTE_CountryPercantage
as
(
	select Country,
	cast(sum(tdd.Deaths) over (partition by Country) as float) as 'Deaths',
	cast(sum(tdd.Deaths) over() as float) as 'Total Deaths'
	from [Tesla Deaths - Deaths (3)] as tdd
) 
select distinct Country, crpy.Deaths,
concat(round(crpy.Deaths/crpy.[Total Deaths]*100,2), '%') as 'Percentage out of total Deaths'
from CTE_CountryPercantage as crpy
union
select 'Total:', SUM(Deaths), '' from [Tesla Deaths - Deaths (3)]
order by 3 desc

go

-------------------------------------------------------------------------------------------------------



-- Using Temp Table to perform previous query

--Skill used : DDL,DML

DROP Table if exists #CountryPercantage
Create Table #CountryPercantage
(
Country nvarchar(100),
Deaths float,
Total_Deaths float,
)

go

Insert into #CountryPercantage
select  Country,
	cast(sum(tdd.Deaths) over (partition by Country) as float) as 'Deaths',
	cast(sum(tdd.Deaths) over() as float) as 'Total Deaths'
	from [Tesla Deaths - Deaths (3)] as tdd

go

select distinct Country, ctpr.Deaths,
concat(round(ctpr.Deaths/ctpr.Total_Deaths*100,2), '%') as 'Percentage out of total Deaths'
from #CountryPercantage as ctpr
union
select 'Total:', SUM(Deaths), '' from [Tesla Deaths - Deaths (3)]
order by 3 desc

go

-------------------------------------------------------------------------------------------------------



-- Creating View to store data for later visualizations

--Skill used: Views

Create View CountryPercantage as
	select Country,
	cast(sum(tdd.Deaths) over (partition by Country) as float) as 'Deaths',
	cast(sum(tdd.Deaths) over() as float) as 'Total Deaths'
	from [Tesla Deaths - Deaths (3)] as tdd

go



-------------------------------------------------------------------------------------------------------




