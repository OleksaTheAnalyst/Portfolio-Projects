/*
Covid 19 Data Exploration 

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/

SELECT *
FROM SQLProjects..CovidDeaths2
ORDER BY 3,4

 --Select data that we are going to be using 

SELECT location, date, total_cases, new_cases, total_deaths, population 
FROM SQLProjects..CovidDeaths2 
ORDER BY 1,2 
  
  --Looking at Total cases vs Total deaths 
-- Shows likelihood of dying if you contract covid in your country 
  
SELECT location, date, total_cases, total_deaths, (CAST(total_deaths AS FLOAT)/CAST (total_cases AS FLOAT))*100 AS DeathPercentage 
FROM SQLProjects..CovidDeaths2 
WHERE location like 'germ%' 
ORDER BY 1,2 

  -- Looking at Total cases vs Population 
  -- Shows what percentage population got Covid 

SELECT location, date,population, total_cases, ROUND((CAST (total_cases AS float)/population)*100,2) AS CasesPercentage 
FROM SQLProjects..CovidDeaths2 
WHERE location like 'germ%' 
ORDER BY 1,2 

--Looking at Countries with Highest Infection Rate compared to Population 
 
SELECT Location, Population, MAX(CAST(total_cases AS FLOAT)) as HighestInfectionCount,  ROUND(Max((CAST(total_cases AS float)/population))*100,2) AS PercentPopulationInfected 
FROM SQLProjects..CovidDeaths2 
WHERE continent IS NOT NULL
--Where location like 'germ%' 
GROUP BY Location, Population 
ORDER BY PercentPopulationInfected DESC 
  
-- Countries with Highest Death Count per Population 
 
SELECT Location, MAX(CAST(total_deaths AS FLOAT)) as TotalDeathCount 
FROM SQLProjects..CovidDeaths2 
WHERE continent is not null
GROUP BY Location 
ORDER BY TotalDeathCount DESC 

-- BREAKING THINGS DOWN BY CONTINENT

-- Showing contintents with the highest death count per population

SELECT continent, MAX(CAST(total_deaths AS FLOAT)) AS TotalDeathCount 
FROM SQLProjects..CovidDeaths2 
WHERE continent is not null
GROUP BY continent 
ORDER BY TotalDeathCount DESC 

-- GLOBAL NUMBERS
-- In the Death percentage we cannot divide by zero, so we change zero numbers into NULL using conditional clause and CTE

WITH NEWCASES AS (
SELECT date, new_deaths, CASE WHEN CAST(new_cases AS FLOAT) = 0 THEN NULL ELSE new_cases END AS new_cases1
FROM SQLProjects..CovidDeaths2 
WHERE continent is not null
--GROUP BY date
)
SELECT date, SUM(CAST(new_cases1 AS FLOAT)) AS total_cases, SUM(CAST(new_deaths AS FLOAT)) AS total_deaths, 
SUM(CAST(new_deaths AS FLOAT))/SUM(CAST (new_cases1 AS FLOAT))*100 AS DeathPercentage 
FROM NEWCASES
GROUP BY date
ORDER BY 1,2


-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

SELECT de.continent, de.location, de.date, de.population, va.new_vaccinations,
SUM(CAST(va.new_vaccinations AS int)) OVER (partition by de.location order by de.location, de.date) AS RollingPeopleVaccinated
FROM SQLProjects..CovidDeaths2 de
JOIN SQLProjects..CovidVaccinations va
ON de.location = va.location 
AND de.date = va.date
WHERE de.continent IS NOT NULL
ORDER BY 2,3

-- Using CTE to perform Calculation on Partition By in previous query

WITH PopVsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS (
SELECT de.continent, de.location, de.date, de.population, va.new_vaccinations,
SUM(CAST(va.new_vaccinations as FLOAT)) OVER (partition by de.location order by de.location, de.date) AS RollingPeopleVaccinated
FROM SQLProjects..CovidDeaths2 de
JOIN SQLProjects..CovidVaccinations va
ON de.location = va.location 
AND de.date = va.date
WHERE de.continent IS NOT NULL
)
SELECT *, (RollingPeopleVaccinated/Population)*100 AS Percentage
FROM PopVsVac

-- Using Temp Table to perform Calculation on Partition By in previous query

DROP TABLE IF EXISTS #PercentPopulationVaccinated

CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar (255),
Location nvarchar (255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT de.continent, de.location, de.date, de.population, va.new_vaccinations,
SUM(CAST(va.new_vaccinations as FLOAT)) OVER (partition by de.location order by de.location, de.date) AS RollingPeopleVaccinated
FROM SQLProjects..CovidDeaths2 de
JOIN SQLProjects..CovidVaccinations va
ON de.location = va.location 
AND de.date = va.date
WHERE de.continent IS NOT NULL

SELECT *, (RollingPeopleVaccinated/Population)*100 AS Percentage
FROM #PercentPopulationVaccinated

-- Creating View to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated AS
SELECT de.continent, de.location, de.date, de.population, va.new_vaccinations,
SUM(CAST(va.new_vaccinations as FLOAT)) OVER (partition by de.location order by de.location, de.date) AS RollingPeopleVaccinated
FROM SQLProjects..CovidDeaths2 de
JOIN SQLProjects..CovidVaccinations va
ON de.location = va.location 
AND de.date = va.date
WHERE de.continent IS NOT NULL

SELECT *
FROM PercentPopulationVaccinated
