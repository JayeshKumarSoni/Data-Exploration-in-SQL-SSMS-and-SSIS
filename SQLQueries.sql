/*
Covid 19 Data Exploration 

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/
Select * From PortfolioProject..CovidDeaths
Where continent is not null 
order by 3,4

  
Select * From PortfolioProject..CovidVaccinations
Where continent is not null 
order by 3,4

  
-- changing data tyle of total_cases and total deaths from nvarchar to float

alter table [CovidDeaths]
alter column [total_cases] Float

--estimated percentage of dying if contacted by covid
  
select location,date,total_cases,  total_deaths ,(total_deaths/total_cases)*100 as deathpercentage
from Portfolioproject..CovidDeaths
where location = 'United Kingdom'
order by 1,2
  
-- looking at Total_Cases vs Total_Deaths
-- shows what percentage of the population got COVID
  
select location, date, total_deaths, total_cases, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths where location = 'United Kingdom' order by 1,2

-- Looking at Total Cases vs Population
-- shows what percentage of population has got covid 

select location, date, total_cases, population,(total_cases/population)*100 as covidPercentage
from PortfolioProject..CovidDeaths where location = 'United Kingdom' order by 1,2

-- Looking at countries with highest infection rate compared to population

select location,population, Max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as Percentpopulationinfected
from PortfolioProject..CovidDeaths group by location,population order by Percentpopulationinfected desc

-- Countries with the Highest Death Count per population 

--the problem occurred was the total_deaths datatype was giving problems
--these problems occur and the solution was to cast the data into integer
--after that, we discovered that we wanted specific locations whereas 
--it was considering the continent as the location where the continent was null
--this kind of problem will occur when you're doing data exploration
--so we inserted a where clause where the continent is not null  

select location,population, Max(total_deaths) as TotalDeathCount ,max((total_deaths/population))*100 as PercentpopulationDied
from PortfolioProject..CovidDeaths where continent is not null group by location,population order by TotalDeathCount desc

-- Let's break by CONTINENTS 

select location , Max(total_deaths) as TotalDeathCount ,max((total_deaths/population))*100 as PercentpopulationDied
from PortfolioProject..CovidDeaths where continent is null group by location order by TotalDeathCount desc

-- GLOBAL NUMBERS
--newcases vs deaths,deathpercentage on new cases each day 

select date, sum(total_deaths) as GlobalDeaths, sum(total_cases) as GlobasCases, (sum(total_deaths)/sum(total_cases))*100 as GlobalDeathPercentage
from PortfolioProject..CovidDeaths where continent is not null group by date order by date asc

-- Looking at Total_Vacination vs Total_Population Globally

alter table [CovidVaccinations]
alter column [new_vaccinations] bigint
-- Converting required data types from nvarchar to bigint 


select d.continent, d.location, d.date, d.population, v.new_vaccinations, 
sum(convert(bigint, v.new_vaccinations)) over(partition by d.location order by d.location,d.date) as TotalVaccinations
from PortfolioProject..CovidDeaths d
join PortfolioProject..CovidVaccinations v
on d.location = v.location and d.date = v.date
where d.continent is not null and v.new_vaccinations is not null order by d.location, d.date 

----(TotalVaccinations/population)*100 it gave an error cause we cant use
--a column we just created to then use the next one so what we need
--to create a cte or temptable  
-- Using CTE to perform Calculation on Partition By in previous query
-- if the number of columns in the cte is different than the query it will give an error
  

with popvsvac (continent, location, date, population, new_vaccinations, TotalVaccinations)
as (
select d.continent, d.location, d.date, d.population, v.new_vaccinations, 
sum(convert(bigint, v.new_vaccinations)) over(partition by d.location order by d.location,d.date) as TotalVaccinations
from PortfolioProject..CovidDeaths d
join PortfolioProject..CovidVaccinations v
on d.location = v.location and d.date = v.date
where d.continent is not null and v.new_vaccinations is not null 
--order by d.location, d.date 
)
select *, (TotalVaccinations/ population)*100 from popvsvac

-- Using Temp Table to perform Calculation on Partition By in previous query

Drop table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated(
continent nvarchar(255), location nvarchar(255), date datetime, population float, new_vaccinations numeric, TotalVaccinations numeric)


Insert into #PercentPopulationVaccinated
select d.continent, d.location, d.date, d.population, v.new_vaccinations, 
sum(convert(bigint, v.new_vaccinations)) over(partition by d.location order by d.location,d.date) as TotalVaccinations
from PortfolioProject..CovidDeaths d
join PortfolioProject..CovidVaccinations v
on d.location = v.location and d.date = v.date
where d.continent is not null and v.new_vaccinations is not null 
order by d.location, d.date 

select *, (TotalVaccinations/ population)*100 from #PercentPopulationVaccinated


-- creating view to store data for latest visualizations

Create view PercentPopulationVaccinated1 as
select d.continent, d.location, d.date, d.population, v.new_vaccinations, 
sum(convert(bigint, v.new_vaccinations)) over(partition by d.location order by d.location,d.date) as TotalVaccinations
from PortfolioProject..CovidDeaths d
join PortfolioProject..CovidVaccinations v
on d.location = v.location and d.date = v.date
where d.continent is not null and v.new_vaccinations is not null 






