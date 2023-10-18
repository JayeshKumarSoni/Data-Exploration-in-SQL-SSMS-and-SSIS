/*
Covid 19 Data Exploration 

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/

Select * From PortfolioProject..CovidDeaths
Where continent is not null 
order by 3,4

-- changing data tyle of total_cases and total deaths from nvarchar to float

alter table [CovidDeaths]
alter column [total_cases] Float

-- looking at Total_Cases vs Total_Deaths

select location, date, total_deaths, total_cases, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths where location = 'United Kingdom' order by 1,2

-- Looking at Total Cases vs Population
-- shows what percentage of population has got covid 

select location, date, total_cases, population,(total_cases/population)*100 as covidPercentage
from PortfolioProject..CovidDeaths where location = 'United Kingdom' order by 1,2

-- Looking at countries with highest infection rate compared to population

select location,population, Max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as Percentpopulationinfected
from PortfolioProject..CovidDeaths group by location,population order by Percentpopulationinfected desc

-- Countries with Highest Death Count per population 

select location,population, Max(total_deaths) as TotalDeathCount ,max((total_deaths/population))*100 as PercentpopulationDied
from PortfolioProject..CovidDeaths where continent is not null group by location,population order by TotalDeathCount desc

-- Let's breakdown by CONTINENTS 

select location , Max(total_deaths) as TotalDeathCount ,max((total_deaths/population))*100 as PercentpopulationDied
from PortfolioProject..CovidDeaths where continent is null group by location order by TotalDeathCount desc

-- GLOBAL NUMBERS

select date, sum(total_deaths) as GlobalDeaths, sum(total_cases) as GlobasCases, (sum(total_deaths)/sum(total_cases))*100 as GlobalDeathPercentage
from PortfolioProject..CovidDeaths where continent is not null group by date order by date asc

-- Looking at Total_Vacination vs Total_Population Globally

alter table [CovidVaccinations]
alter column [new_vaccinations] bigint



select d.continent, d.location, d.date, d.population, v.new_vaccinations, 
sum(convert(bigint, v.new_vaccinations)) over(partition by d.location order by d.location,d.date) as TotalVaccinations
from PortfolioProject..CovidDeaths d
join PortfolioProject..CovidVaccinations v
on d.location = v.location and d.date = v.date
where d.continent is not null and v.new_vaccinations is not null order by d.location, d.date 

-- Using CTE to perform Calculation on Partition By in previous query

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
