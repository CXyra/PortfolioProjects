SELECT *
FROM dbo.CovidDeaths
ORDER BY 3, 4;

SELECT * 
FROM dbo.CovidVaccinations
Order BY 3, 4;

-- Select data needed

SELECT 
	location,
	date,
	total_cases,
	new_cases,
	total_deaths,
	population
FROM dbo.CovidDeaths
ORDER BY 1, 2;


-- Total cases vs Total Deaths
SELECT 
	location,
	date,
	total_cases,
	total_deaths,
	(total_deaths/total_cases)* 100 AS DeathPercentage
FROM dbo.CovidDeaths
WHERE location like '%states%'
ORDER BY 1, 2;


-- Total cases vs. Population

SELECT 
	location,
	date,
	total_cases,
	population,
	(total_cases/population)* 100 AS PercentPopulationInfected,
FROM dbo.CovidDeaths
WHERE location like '%states%'
ORDER BY 1, 2;

-- Countries with highest infection rate compared to Population
SELECT 
	location,
	MAX(total_cases) AS HighestInfectionCount,
	population,
	MAX((total_cases/population))* 100 AS PercentPopulationInfected
FROM dbo.CovidDeaths
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC;

--Countries with Highest Death Count per Population

SELECT 
	location,
	MAX(CAST(total_deaths as int)) AS TotalDeathCount
FROM dbo.CovidDeaths
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount DESC;


-- continents with the highest death count

SELECT 
	continent,
	MAX(CAST(total_deaths as int)) AS TotalDeathCount
FROM dbo.CovidDeaths
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount DESC;


-- Global Numbers


SELECT 
	SUM(new_cases) AS totalCases,
	SUM(CAST(new_deaths as int)) AS TotalDeaths,
	SUM(CAST(new_deaths as int))/SUM(new_cases)*100 AS DeathPercentage
FROM dbo.CovidDeaths
WHERE continent is not null
ORDER BY 1, 2;

-- Total Population vs. Vaccinations

SELECT 
	dea.continent,
	dea.location,
	dea.date,
	dea.population,
	vac.new_vaccinations,
	SUM(CAST(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated,
	--(RollingPeopleVaccinated/population)*100
FROM dbo.CovidDeaths dea
Join dbo.CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 1,2,3;


--Use CTE

WITH PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS
(
SELECT 
	dea.continent,
	dea.location,
	dea.date,
	dea.population,
	vac.new_vaccinations,
	SUM(CAST(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
	--(RollingPeopleVaccinated/population)*100
FROM dbo.CovidDeaths dea
Join dbo.CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 1,2,3
)
SELECT *, (RollingPeopleVaccinated/population)*100
FROM PopvsVac



-- Create view  to store data for later visualizations

CREATE VIEW PopvsVac AS 
SELECT 
	dea.continent,
	dea.location,
	dea.date,
	dea.population,
	vac.new_vaccinations,
	SUM(CAST(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
	--(RollingPeopleVaccinated/population)*100
FROM dbo.CovidDeaths dea
Join dbo.CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 1,2,3