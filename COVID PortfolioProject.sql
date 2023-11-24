SELECT * FROM Project1..CovidDeaths
WHERE continent is not null
--abover line solves the problem of location and continet being the same place
ORDER BY 3,4


--SELECT * FROM Project1..CovidVaccinations
--ORDER BY 3,4

SELECT Location, Date, total_cases, new_cases, total_deaths, population
FROM Project1..CovidDeaths
order by 1,2

--looking at total cases VS total deaths
--shows liklihood of dying if you contract covid in your country

SELECT Location, Date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM Project1..CovidDeaths
where location like 'india'
order by 1,2

--looking at total cases vs population
--shows what percentage of population has gotten covid

SELECT Location, Date, population, total_cases, (total_cases/population)*100 as CasePercenatge
FROM Project1..CovidDeaths
where location like 'india'
order by 1,2

--looking at countries with highest infection rate compared to population

SELECT Location, population, max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as PopulationInfectedPercent
FROM Project1..CovidDeaths
--where location like 'india'
group by location, population
order by PopulationInfectedPercent desc

--Countries with highest death count per population

SELECT Location, max(cast(total_deaths as int)) as HighestDeathCount, max(population) pop,max((total_deaths/population))*100 as PopulationDeathPercent
FROM Project1..CovidDeaths
--where location like 'india'
WHERE continent is not null
group by location
order by HighestDeathCount desc

-- breaking things down by CONTINENT with highest death count per population

SELECT continent, max(cast(total_deaths as int)) as HighestDeathCount, max(population) pop,max((total_deaths/population))*100 as PopulationDeathPercent
FROM Project1..CovidDeaths
--where location like 'india'
WHERE continent is not null
group by continent
order by HighestDeathCount desc

--GLOBAL numbers (each day total across the world) 

SELECT Date, SUM(new_cases) as cases, SUM(cast(new_deaths as int)) as deaths, SUM(cast(new_deaths as int))/SUM(new_cases) * 100 as DeathPercentage
FROM Project1..CovidDeaths
--where location like 'india'
where continent is not null
GROUP BY date
order by 1,2

--GLOBAL numbers

SELECT SUM(new_cases) as cases, SUM(cast(new_deaths as int)) as deaths, SUM(cast(new_deaths as int))/SUM(new_cases) * 100 as DeathPercentage
FROM Project1..CovidDeaths
--where location like 'india'
where continent is not null
--GROUP BY date
order by 1,2

--joining both tables

SELECT * 
FROM Project1 ..CovidDeaths dea
JOIN Project1 ..CovidVaccinations vac
    ON dea.location = vac.location
	AND dea.date = vac.date

--looking at total population vs vaccination

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as int)) OVER (partition by dea.location order by dea.date, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population) * 100
FROM Project1 ..CovidDeaths dea
JOIN Project1 ..CovidVaccinations vac
    ON dea.location = vac.location
	AND dea.date = vac.date
where dea.continent is not null
order by 2,3


--USE CTE

WITH PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as int)) OVER (partition by dea.location order by dea.date, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population) * 100
FROM Project1 ..CovidDeaths dea
JOIN Project1 ..CovidVaccinations vac
    ON dea.location = vac.location
	AND dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
SELECT *, (RollingPeopleVaccinated/population) * 100
FROM PopvsVac


--TEMP TABLE
DROP TABLE if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as int)) OVER (partition by dea.location order by dea.date, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population) * 100
FROM Project1 ..CovidDeaths dea
JOIN Project1 ..CovidVaccinations vac
    ON dea.location = vac.location
	AND dea.date = vac.date
where dea.continent is not null
--order by 2,3

SELECT *, (RollingPeopleVaccinated/population) * 100
FROM #PercentPopulationVaccinated


--Creating view to store data for later visualizations

Create View
PercentagePopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as int)) OVER (partition by dea.location order by dea.date, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population) * 100
FROM Project1 ..CovidDeaths dea
JOIN Project1 ..CovidVaccinations vac
    ON dea.location = vac.location
	AND dea.date = vac.date
where dea.continent is not null
--order by 2,3
