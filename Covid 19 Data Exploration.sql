
 
--Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

select *
  from [Covid Portfolio]..['Covid deaths$']
 where continent is not null 
 order by date desc


 --most cases registered location
 select location, population, MAX(total_cases) as case_count
  from [Covid Portfolio]..['Covid deaths$']
 where continent is not null
 group by location, population
 order by MAX(total_cases) desc

 --most infected country compared to population
 
select location, population, MAX(total_cases) as case_count, MAX(total_cases/population) total_case_vs_population
  from [Covid Portfolio]..['Covid deaths$']
 where continent is not null
 group by location, population
 order by total_case_vs_population desc

  -- --most cases registered continent
;with total_case_of_location as 
(
select continent,location, population, MAX(total_cases) as case_count
  from [Covid Portfolio]..['Covid deaths$']
 where continent is not null
 group by continent,location, population
)
 select continent, sum(case_count) as total_case, sum(population) as total_pop
   from total_case_of_location
  group by continent
  order by sum(case_count) desc



 --death count

  select location, max(cast(total_deaths as int)) as total_deaths
   from [Covid Portfolio]..['Covid deaths$']
  where continent is null 
  group by location
  

--death percent of world by date

select date, sum(new_cases) total_case, sum(cast(new_deaths as int)) total_deaths 
		,sum(cast(new_deaths as int))/ sum(new_cases)*100 death_percent
  from [Covid Portfolio]..['Covid deaths$']
 where continent is not null
 group by date
 order by 1
 
--death percent woldwide
select  sum(new_cases) total_case, sum(cast(new_deaths as int)) total_deaths 
		,sum(cast(new_deaths as int))/ sum(new_cases)*100 death_percent
  from [Covid Portfolio]..['Covid deaths$']
 where continent is not null
 order by 1

--total population worldwide VS vaccinations

;with temp as
( select d.continent, d.location, d.date, d.population, v.new_vaccinations,
	   SUM(CONVERT(float,v.new_vaccinations )) OVER 
	   (partition by d.location order by d.location,d.date ) Running_total_vaccinated
	   
  from [Covid Portfolio]..['Covid deaths$'] d
  join [Covid Portfolio]..['Covid vaccination$'] v
	   on d.location=v.location
	   and d.date=v.date
 where d.continent is not null 
)
select *, (Running_total_vaccinated/population)*100 vaccinated_percentage
  from temp t
 order by location,date





--create data for visualization 
drop table if exists dbo.#data_viz
create table dbo.#data_viz
(
Continent varchar(255),
Location varchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
Running_total_vaccinated numeric
)



insert into [Covid Portfolio].[dbo].[Table_1]
 select d.continent, d.location, d.date, d.population, v.new_vaccinations,
	   SUM(CONVERT(float,v.new_vaccinations )) OVER 
	   (partition by d.location order by d.location,d.date ) Running_total_vaccinated
	   
  from [Covid Portfolio]..['Covid deaths$'] d
  join [Covid Portfolio]..['Covid vaccination$'] v
	   on d.location=v.location
	   and d.date=v.date
 where d.continent is not null
  --order by location,date


 select * from [Covid Portfolio].[dbo].[Table_1]




 create view [Table_1] as
  select d.continent, d.location, d.date, d.population, v.new_vaccinations,
	   SUM(CONVERT(float,v.new_vaccinations )) OVER 
	   (partition by d.location order by d.location,d.date ) Running_total_vaccinated
	   
  from [Covid Portfolio]..['Covid deaths$'] d
  join [Covid Portfolio]..['Covid vaccination$'] v
	   on d.location=v.location
	   and d.date=v.date
 where d.continent is not null


 select * from [Covid Portfolio].[dbo].[view_1]
