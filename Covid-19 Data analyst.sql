SELECT * FROM PortfolioProject..CovidDeaths
WHERE continent is not null
ORDER BY CovidDeaths.location, CovidDeaths.date

--SELECT * FROM PortfolioProject..CovidVaccinations
--ORDER BY 3,4 -- you can also use with numbers of the columns

--Select data that we are going to be using
SELECT location, date, total_cases, new_cases, total_deaths, population FROM PortfolioProject..CovidDeaths
WHERE continent is not null
ORDER BY CovidDeaths.location, CovidDeaths.date --ORDER BY 1,2

-- Looking at the total cases vs total deaths
-- Shows likelihood of dying if you contract covid in Turkey
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS Death_percentage 
FROM PortfolioProject..CovidDeaths
Where location like '%turkey%' AND continent is not null
ORDER BY CovidDeaths.location, CovidDeaths.date --ORDER BY 1,2

--Looking at Total Cases vs Population
-- Shows what percentage of population got Covid in Turkey
SELECT location, date, population, total_cases, (total_cases/population)*100 AS Infected_Percent 
FROM PortfolioProject..CovidDeaths
Where location like '%turkey%' AND continent is not null
ORDER BY CovidDeaths.location, CovidDeaths.date --ORDER BY 1,2

--Looking at Countries with Hisghest Infection Rate compared to Population
SELECT location, population, MAX(total_cases) AS Highest_Infectýon_Count, MAX((total_cases/population))*100 AS Highest_Infected_Percent 
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY location, population
ORDER BY Highest_Infected_Percent DESC

-- Showing the Countries with Highest Death Count per Population
SELECT location, MAX(cast(total_deaths as int)) AS Total_Death_Count
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY location
ORDER BY Total_Death_Count DESC

-- Showing the Countries with Highest Death Count per Population 
SELECT continent, MAX(cast(total_deaths as int)) AS Total_Death_Count
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY Total_Death_Count DESC

-- Global Numbers
SELECT date, SUM(new_cases) AS Total_cases, SUM(cast(new_deaths as int)) AS Total_Deaths, (SUM(cast(new_deaths as int))/SUM(new_cases))*100 AS Death_percentage
FROM PortfolioProject..CovidDeaths
Where continent is not null
GROUP BY date
ORDER BY CovidDeaths.date

-- Total Death Percentage across the world
SELECT SUM(new_cases) AS Total_cases, SUM(cast(new_deaths as int)) AS Total_Deaths, (SUM(cast(new_deaths as int))/SUM(new_cases))*100 AS Death_percentage
FROM PortfolioProject..CovidDeaths
Where continent is not null

-- Looking at Total Population vs Vaccinations with new and total vaccinations
With PopvsVac(Continent, Location, Date, Population, New_Vaccinations, Rolling_People_Vaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS Rolling_People_Vaccinated
FROM PortfolioProject..CovidDeaths AS dea
JOIN PortfolioProject..CovidVaccinations AS vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY dea.location, dea.date
)
SELECT *, (Rolling_People_Vaccinated/Population)*100 AS The_Percentage
FROM PopvsVac

-- TEMP TABLE
DROP TABLE IF exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
Rolling_People_Vaccinated numeric
)
Insert Into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS Rolling_People_Vaccinated
FROM PortfolioProject..CovidDeaths AS dea
JOIN PortfolioProject..CovidVaccinations AS vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY dea.location, dea.date

SELECT *, (Rolling_People_Vaccinated/Population)*100 AS The_Percentage
FROM #PercentPopulationVaccinated

-- Creating View to store data for visualizations
CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS Rolling_People_Vaccinated
FROM PortfolioProject..CovidDeaths AS dea
JOIN PortfolioProject..CovidVaccinations AS vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY dea.location, dea.date

SELECT *
FROM PercentPopulationVaccinated