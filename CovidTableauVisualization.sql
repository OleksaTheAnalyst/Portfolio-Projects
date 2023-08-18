/*

Queries used for Tableau Project

*/



-- 1. 

WITH NEWCASES AS (
SELECT date, new_deaths, CASE WHEN CAST(new_cases AS FLOAT) = 0 THEN NULL ELSE new_cases END AS new_cases1
FROM SQLProjects..CovidDeaths2 
WHERE continent is not null
--GROUP BY date
)
SELECT SUM(CAST(new_cases1 AS FLOAT)) AS total_cases, SUM(CAST(new_deaths AS FLOAT)) AS total_deaths, 
SUM(CAST(new_deaths AS FLOAT))/SUM(CAST (new_cases1 AS FLOAT))*100 AS DeathPercentage 
FROM NEWCASES
--GROUP BY date
ORDER BY 1,2


-- 2. 

-- We take these out as they are not inluded in the above queries and want to stay consistent
-- European Union is part of Europe

SELECT location, SUM(cast(new_deaths as FLOAT)) AS TotalDeathCount
FROM SQLProjects..CovidDeaths2
WHERE continent is null 
AND location not in ('World', 'European Union', 'International')
GROUP BY location
ORDER BY TotalDeathCount DESC


-- 3.

SELECT Location, Population, MAX(CAST(total_cases AS float)) AS HighestInfectionCount,  MAX((CAST(total_cases AS float)/population))*100 AS PercentPopulationInfected
FROM SQLProjects..CovidDeaths2
GROUP BY Location, Population
ORDER BY PercentPopulationInfected DESC


-- 4.


SELECT Location,date, Population, MAX(CAST(total_cases AS float)) AS HighestInfectionCount,  MAX((CAST(total_cases AS float)/population))*100 AS PercentPopulationInfected
FROM SQLProjects..CovidDeaths2
GROUP BY Location, Population, date
ORDER BY PercentPopulationInfected DESC
