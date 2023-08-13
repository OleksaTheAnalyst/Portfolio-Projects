/*
Covid 19 Data Exploration 

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/

select * 
from SQLProjects..CovidDeaths 
order by 3,4 

  --Select data that we are going to be using 

  SELECT location, date, total_cases, new_cases, total_deaths, population 
  FROM SQLProjects..CovidDeaths 
  order by 1,2 
  
--Looking at Total cases vs Total deaths 
-- Shows likelihood of dying if you contract covid in your country 
  
  SELECT location, date, total_cases, total_deaths, round((total_deaths/total_cases)*100,2) as DeathPercentage 
  FROM SQLProjects..CovidDeaths 
  where location like 'germ%' 
  order by 1,2 

  -- Looking at Total cases vs Population 
  -- Shows what percentage population got Covid 

SELECT location, date,population, total_cases, round((total_cases/population)*100,2) as CasesPercentage 
FROM SQLProjects..CovidDeaths 
where location like 'germ%' 
order by 1,2 

--Looking at Countries with Highest Infection Rate compared to Population 
 
 Select Location, Population, MAX(total_cases) as HighestInfectionCount,  round(Max((total_cases/population))*100,2) as PercentPopulationInfected 
From SQLProjects..CovidDeaths 
where continent is not null

--Where location like 'germ%' 

Group by Location, Population 
order by PercentPopulationInfected desc 
  
-- Countries with Highest Death Count per Population 
 
Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount 
From SQLProjects..CovidDeaths 
where continent is not null

--Where location like 'germ%' 

Group by Location 
order by TotalDeathCount desc 

-- BREAKING THINGS DOWN BY CONTINENT

-- Showing contintents with the highest death count per population
Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount 
From SQLProjects..CovidDeaths 
where continent is not null
--Where location like 'germ%' 
Group by continent 
order by TotalDeathCount desc 

-- GLOBAL NUMBERS

SELECT date, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage 
FROM SQLProjects..CovidDeaths 
where continent is not null
--where location like 'germ%' 
group by date
order by 1,2 

-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

select de.continent, de.location, de.date, de.population, va.new_vaccinations,
sum(cast(va.new_vaccinations as int)) over (partition by de.location order by de.location, de.date) as RollingPeopleVaccinated
from SQLProjects..CovidDeaths de
join SQLProjects..CovidVaccinations va
on de.location = va.location 
and de.date = va.date
where de.continent is not null
order by 2,3

-- Using CTE to perform Calculation on Partition By in previous query

with PopVsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as (
select de.continent, de.location, de.date, de.population, va.new_vaccinations,
sum(cast(va.new_vaccinations as int)) over (partition by de.location order by de.location, de.date) as RollingPeopleVaccinated
from SQLProjects..CovidDeaths de
join SQLProjects..CovidVaccinations va
on de.location = va.location 
and de.date = va.date
where de.continent is not null
)
Select *, (RollingPeopleVaccinated/Population)*100 as Percentage
from PopVsVac

-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated

Create table #PercentPopulationVaccinated
(
Continent nvarchar (255),
Location nvarchar (255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
select de.continent, de.location, de.date, de.population, va.new_vaccinations,
sum(cast(va.new_vaccinations as int)) over (partition by de.location order by de.location, de.date) as RollingPeopleVaccinated
from SQLProjects..CovidDeaths de
join SQLProjects..CovidVaccinations va
on de.location = va.location 
and de.date = va.date
where de.continent is not null

Select *, (RollingPeopleVaccinated/Population)*100 as Percentage
from #PercentPopulationVaccinated

-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated1 as
select de.continent, de.location, de.date, de.population, va.new_vaccinations,
sum(cast(va.new_vaccinations as int)) over (partition by de.location order by de.location, de.date) as RollingPeopleVaccinated
from SQLProjects..CovidDeaths de
join SQLProjects..CovidVaccinations va
on de.location = va.location 
and de.date = va.date
where de.continent is not null

select *
from PercentPopulationVaccinated1
