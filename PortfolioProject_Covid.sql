SELECT *
FROM PortfolioProject..CovidDeaths
WHERE continent is NOT NULL
ORDER BY 3,4

--SELECT *
--FROM PortfolioProject..CovidVaccinations

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
WHERE continent is NOT NULL
ORDER BY 1,2


---- LOOKING AT THE TOTAL CASES VS THE TOTAL DEATHS.
---- This Shows the likelihood of dying if you contract Covid in your country.

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS Death_Percentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%Brazil%'
AND continent is NOT NULL
ORDER BY 1,2


---- LOOKING AT THE TOTAL CASES VS THE POPULATION.
---- This Shows what percentage of population has got Covid in your country.

SELECT location, date, population, total_cases, (total_cases/population)*100 AS Population_Infected_Percentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%Brazil%'
AND continent is NOT NULL
ORDER BY 1,2


---- LOOKING AT COUNTRIES WITH THE HIGHEST INFECTION RATE COMPARED TO POPULATION.
---- This Shows the countries with the most infection rates compared to population.

SELECT location,population, max(total_cases) AS Highest_Infection_Count, max((total_cases/population)*100) AS Population_Infected_Percentage
FROM PortfolioProject..CovidDeaths
WHERE continent is NOT NULL
-- WHERE location like '%Brazil%'
GROUP BY location, population
ORDER BY Population_Infected_Percentage DESC


---- LOOKING AT COUNTRIES WITH THE HIGHEST DEATH COUNT PER TO POPULATION.
---- This Shows the countries with the most death rates compared to population.

SELECT location, MAX(cast(total_deaths as int)) AS Total_Death_Count
FROM PortfolioProject..CovidDeaths
WHERE continent is NOT NULL
-- WHERE location like '%Brazil%'
GROUP BY location
ORDER BY Total_Death_Count DESC


-- BREAKING THINGS DOWN BY CONTINENT
-- Showing contintents with the highest death count per population

SELECT continent, MAX(cast(Total_deaths as int)) AS TotalDeathCount_Continent
FROM PortfolioProject..CovidDeaths
--Where location like '%Brazil%'
WHERE continent is not null 
GROUP BY continent
order BY TotalDeathCount_Continent DESC


--- GLOBAL NUMBERS---
SELECT date, SUM(new_cases) AS Total_Cases, SUM(CAST(new_deaths AS int)) AS Total_Deaths, SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 AS Death_Percentage
FROM PortfolioProject..CovidDeaths
WHERE continent is NOT NULL
-- WHERE location like '%Brazil%'
GROUP BY date
ORDER BY 1,2

--- Total Global Deaths ---
SELECT SUM(new_cases) AS Total_Cases, SUM(CAST(new_deaths AS int)) AS Total_Deaths, SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 AS Death_Percentage
FROM PortfolioProject..CovidDeaths
WHERE continent is NOT NULL
-- WHERE location like '%Brazil%'
--GROUP BY date
ORDER BY 1,2 


--- LOOKING AT TOTAL POPULATION VS VACCINATIONS
--- Rolling Count of People vaccinated
SELECT Dea.continent, Dea.location, Dea.date, Dea.population, Vacc.new_vaccinations
, SUM(CONVERT(int,Vacc.new_vaccinations)) OVER (Partition by Dea.Location Order by Dea.location, Dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/Dea.population)*100
FROM PortfolioProject..CovidDeaths Dea
JOIN PortfolioProject..CovidVaccinations Vacc
	ON Dea.location = Vacc.location
	AND Dea.date = Vacc.date
WHERE Dea.continent is NOT NULL
ORDER BY 2,3


-- Using CTE to perform Calculation on Partition By in previous query
With PopvsVacc (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)

AS
(
SELECT Dea.continent, Dea.location, Dea.date, Dea.population, Vacc.new_vaccinations
, SUM(CONVERT(int,Vacc.new_vaccinations)) OVER (Partition by Dea.Location Order by Dea.location, Dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/Dea.population)*100
FROM PortfolioProject..CovidDeaths Dea
JOIN PortfolioProject..CovidVaccinations Vacc
	ON Dea.location = Vacc.location
	AND Dea.date = Vacc.date
WHERE Dea.continent is NOT NULL
--ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/population)*100
FROM PopvsVacc


-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select Dea.continent, Dea.location, Dea.date, Dea.population, Vacc.new_vaccinations
, SUM(CONVERT(int,Vacc.new_vaccinations)) OVER (Partition by Dea.Location Order by Dea.location, Dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths Dea
Join PortfolioProject..CovidVaccinations Vacc
	On Dea.location = Vacc.location
	and Dea.date = Vacc.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


-- Creating View to store data for later visualizations
Create View PercentPopulationVaccinated as
Select Dea.continent, Dea.location, Dea.date, Dea.population, Vacc.new_vaccinations
, SUM(CONVERT(int,Vacc.new_vaccinations)) OVER (Partition by Dea.Location Order by Dea.location, Dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths Dea
Join PortfolioProject..CovidVaccinations Vacc
	On Dea.location = Vacc.location
	and Dea.date = Vacc.date
where Dea.continent is not null 

Select *
From PercentPopulationVaccinated