-- DATA EXPLORATION PROJECT

-- TABLE: covid_deaths
-- Exploring data by **Location**

--selecting data that we will be using
select location,date,total_cases,new_cases,total_deaths,population
from portfolio_project..covid_deaths
order by 1,2

--what % of deaths are caused by covid cases
select location,date,total_cases,total_deaths,
round((total_deaths/total_cases)*100,2) as death_percentage
from portfolio_project..covid_deaths
where location='India'
order by 1,2

-- what % of population got covid
select location,date,total_cases,population,
round((total_cases/population)*100,2) as covid_percentage
from portfolio_project..covid_deaths
where location='India'
order by 1,2

-- Countries with highest infections relative to population
select location,population,max(total_cases) as total_cases_max,
max(round((total_cases/population)*100,2)) as covid_percentage_population
from portfolio_project..covid_deaths
group by location,population
order by covid_percentage_population desc

--Countries with highest deaths relative to population
select location,max(cast(total_deaths as float)) as total_deaths_max
from portfolio_project..covid_deaths
where continent is not null -- removes rows that group income levels and continents as one
group by location,population
order by total_deaths_max desc

-- Exploring data by **Continent**

-- Total deaths by continent
select continent,max(cast(total_deaths as float)) as total_deaths_max
from portfolio_project..covid_deaths
where continent is not null -- removes rows that group income levels and continents as one
group by continent
order by total_deaths_max desc

-- Global numbers

-- Total death percentage of the whole world ordered by date
select date,sum(new_cases) as sum_of_cases,
sum(cast(new_deaths as float)) as sum_of_deaths,
sum(cast(new_deaths as float))/sum(new_cases)*100 as death_percentage
from portfolio_project..covid_deaths
where continent is not null 
group by date
order by 1,2

-- Checking total death percentage of the whole world
select sum(new_cases) as sum_of_cases,
sum(cast(new_deaths as float)) as sum_of_deaths,
sum(cast(new_deaths as float))/sum(new_cases)*100 as death_percentage
from portfolio_project..covid_deaths
where continent is not null 
order by 1,2

-- TABLE: covid_vaccinations

--Looking at total population vs new vaccination

select dea.continent,dea.location,dea.date,dea.location,dea.population,vac.new_vaccinations
from portfolio_project..covid_deaths dea
join portfolio_project..covid_vaccinations vac
on dea.location=vac.location and dea.date=vac.date
where dea.continent is not null
order by 2,3

-- Adding up new vaccinations to get total vacccinations
select dea.continent,dea.location,dea.date,dea.location,dea.population,vac.new_vaccinations,
sum(cast(vac.new_vaccinations as float)) 
over (partition by dea.location order by dea.location,dea.date) as rolling_people_vaccinated --divides rows into small parts
from portfolio_project..covid_deaths dea
join portfolio_project..covid_vaccinations vac
on dea.location=vac.location and dea.date=vac.date
where dea.continent is not null 
order by 2,3

-- Total population vs vaccination

select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(cast(vac.new_vaccinations as float)) 
over (partition by dea.location order by dea.location,dea.date) as rolling_people_vaccinated --divides rows into small parts
from portfolio_project..covid_deaths dea
join portfolio_project..covid_vaccinations vac
on dea.location=vac.location and dea.date=vac.date
where dea.continent is not null 
order by 2,3

-- Creating and using CTE with the previous query

with pop_vs_vac(continent,location,date,population,new_vaccinations,rolling_people_vaccinated)
as
(
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(cast(vac.new_vaccinations as float))	
over (partition by dea.location order by dea.location,dea.date) as rolling_people_vaccinated
from portfolio_project..covid_deaths dea
join portfolio_project..covid_vaccinations vac
on dea.location=vac.location and dea.date=vac.date
where dea.continent is not null 

)
-- Percentage of rolling population that is vaccinated 
select *, round((rolling_people_vaccinated)/(population)*100,4)
from pop_vs_vac


-- TEMP TABLE
drop table if exists #percent_population_vaccinated -- drops and recreates the temp table if any changes are made
create table #percent_population_vaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population float,
new_vaccinations float,
rolling_people_vaccinated float
)
insert into #percent_population_vaccinated

select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(cast(vac.new_vaccinations as float)) 
over (partition by dea.location order by dea.location,dea.date) as rolling_people_vaccinated --divides rows into small parts
from portfolio_project..covid_deaths dea
join portfolio_project..covid_vaccinations vac
on dea.location=vac.location and dea.date=vac.date
where dea.continent is not null

select *, round((rolling_people_vaccinated)/(population)*100,4)
from #percent_population_vaccinated


-- Creating a View to store data for vizzes
create view percent_population_vaccinated as
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(cast(vac.new_vaccinations as float)) 
over (partition by dea.location order by dea.location,dea.date) as rolling_people_vaccinated --divides rows into small parts
from portfolio_project..covid_deaths dea
join portfolio_project..covid_vaccinations vac
on dea.location=vac.location and dea.date=vac.date
where dea.continent is not null








