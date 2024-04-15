SELECT * FROM CovidDeaths
WHERE continent IS NOT NULL;

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2

-- shows the likelihood of dying if you contract covid in your country 
SELECT Location, date, total_cases, total_deaths, 
(total_deaths/total_cases)*100 AS DeathPercentage
FROM CovidDeaths
WHERE Location like '%state%'
AND continent IS NOT NULL
ORDER BY 1,2


-- Total Cases vs Population
SELECT Location, date, population,total_cases, total_deaths, 
(total_deaths/population)*100 AS InfectionRate
FROM CovidDeaths
-- WHERE Location like '%state%'
WHERE continent IS NOT NULL
ORDER BY 1,2

-- Look at countries with highest infection rate compared to population
SELECT 
Location, 
population, 
MAX(total_cases) AS HighestInfectionCount, 
MAX((total_cases/population)*100) AS InfectionRate
FROM CovidDeaths
WHERE continent IS NOT NULL
-- WHERE Location like '%state%'
GROUP BY Location, population
ORDER BY InfectionRate DESC



-- showing countries with highest death count per population
SELECT 
Location, 
MAX(CAST(total_deaths AS SIGNED)) AS TotalDeathCount
FROM CovidDeaths
-- WHERE Location like '%state%'
WHERE continent IS NOT NULL
GROUP BY Location
ORDER BY TotalDeathCount DESC

-- by continent
SELECT 
Location, 
MAX(CAST(total_deaths AS SIGNED)) AS TotalDeathCount
FROM CovidDeaths
-- WHERE Location like '%state%'
WHERE continent IS NULL
GROUP BY Location
ORDER BY TotalDeathCount DESC

-- continent with highest death count per population
SELECT 
continent, 
MAX(CAST(total_deaths AS SIGNED)) AS TotalDeathCount
FROM CovidDeaths
-- WHERE Location like '%state%'
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC


-- GLOBAL Numbers
SELECT 
    date, 
    SUM(CAST(new_cases AS SIGNED)) AS TotalNewCases,
    SUM(CAST(new_deaths AS SIGNED)) AS TotalNewDeaths,
    SUM(CAST(new_deaths AS SIGNED)) / SUM(CAST(new_cases AS SIGNED)) * 100 AS DeathPercentage
FROM 
    CovidDeaths
WHERE 
    continent IS NOT NULL
GROUP BY 
    date
ORDER BY 
    1, 2

SELECT d.continent, d.location, d.date, population, v.new_vaccinations,
	SUM(CAST(v.new_vaccinations AS SIGNED)) OVER 
    (PARTITION BY d.location ORDER BY d.location, d.date) AS RollingPeopleVaccinated
FROM CovidDeaths d
JOIN CovidVaccinations v
	ON d.location = v.location
	AND d.date = v.date
WHERE d.continent IS NOT NULL
ORDER BY 2,3

With PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS 
(
SELECT d.continent, d.location, d.date, population, v.new_vaccinations,
	SUM(CAST(v.new_vaccinations AS SIGNED)) OVER 
    (PARTITION BY d.location ORDER BY d.location, d.date) AS RollingPeopleVaccinated
FROM CovidDeaths d
JOIN CovidVaccinations v
	ON d.location = v.location
	AND d.date = v.date
WHERE d.continent IS NOT NULL
-- ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/population)*100
FROM PopvsVac


DROP TABLE IF EXISTS PercentPopulationVaccinated
CREATE TEMPORARY TABLE PercentPopulationVaccinated (
Continent VARCHAR(255), Location VARCHAR(255), Date DATETIME, Population NUMERIC, 
New_vaccinations NUMERIC, RollingPeopleVaccinated NUMERIC);

INSERT INTO PercentPopulationVaccinated
SELECT d.continent, d.location, d.date, population, v.new_vaccinations,
	SUM(CAST(v.new_vaccinations AS SIGNED)) OVER 
    (PARTITION BY d.location ORDER BY d.location, d.date) AS RollingPeopleVaccinated
FROM CovidDeaths d
JOIN CovidVaccinations v
	ON d.location = v.location
	AND d.date = v.date
WHERE d.continent IS NOT NULL
-- ORDER BY 2,3
;
SELECT *, (RollingPeopleVaccinated/Population)*100 AS Vaccination_Rate
FROM PercentPopulationVaccinated;


-- Create View to store data for later visualization percentpopulationvaccinated
CREATE VIEW PercentPopulationVaccinated AS 
SELECT d.continent, d.location, d.date, population, v.new_vaccinations,
	SUM(CAST(v.new_vaccinations AS SIGNED)) OVER 
    (PARTITION BY d.location ORDER BY d.location, d.date) AS RollingPeopleVaccinated
FROM CovidDeaths d
JOIN CovidVaccinations v
	ON d.location = v.location
	AND d.date = v.date
WHERE d.continent IS NOT NULL
-- ORDER BY 2,3







