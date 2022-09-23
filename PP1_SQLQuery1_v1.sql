USE [PortfolioProject1]
GO 

SELECT *
FROM PortfolioProject1..CovidDeaths
where continent is not NULL
order by 3,4

SELECT *
FROM PortfolioProject1..CovidVaccinations
order by 3,4

--Select data we are going to be using

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject1..CovidDeaths
order by 1,2

--Looking at total cases vs total deaths
--Shows the likelihood of dying if you contract on covid in your country
SELECT location, date, total_cases, total_deaths, population, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject1..CovidDeaths
where location like '%ukr%'
order by 1,2

--Looking at total cases vs population
--Shows what percentage of population got covid in your country
SELECT Location, date, Population, total_cases, (total_cases/Population)*100 as PercentagePopulationInfected
FROM PortfolioProject1..CovidDeaths
where location like '%ukr%'
order by 1,2

--Looking at countries with highest infection rates compared to population
SELECT Location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/Population))*100 as PercentagePopulationInfected
FROM PortfolioProject1..CovidDeaths
--where location like '%states%'
GROUP BY Location, Population
--ORDER BY 1, 2
ORDER BY PercentagePopulationInfected desc

--Showing Countries with Highest Death Count per Population


--Showing continents with the highest death count per Population
SELECT Location, MAX(cast(total_deaths as int)) as TotalDeathCount, MAX((total_cases/Population))*100 as PercentagePopulationInfected
FROM PortfolioProject1..CovidDeaths
where continent is not NULL
GROUP BY Location
ORDER BY TotalDeathCount desc


--GLOBAL NUMBERS
SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProject1..CovidDeaths
--where location like '%ukr%'
where continent is not null
--group by date
order by 1,2

-- Use CTE
with Pop_vs_Vac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
-- Looking at Total Population vs Vaccinations
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) 
OVER (PARTITION by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject1..CovidDeaths dea
Join PortfolioProject1..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
SELECT *,(RollingPeopleVaccinated/population)*100 as RollingPercentageVaccinated
FROM Pop_vs_Vac

-- Temp Table

Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent nvarchar(255), 
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)
INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) 
OVER (PARTITION by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject1..CovidDeaths dea
Join PortfolioProject1..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

SELECT *,(RollingPeopleVaccinated/population)*100 as RollingPercentageVaccinated
FROM #PercentPopulationVaccinated

-- Creating view to store data for later visualizations
Create view PercentPopulationVaccinated as 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) 
OVER (PARTITION by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject1..CovidDeaths dea
Join PortfolioProject1..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select top 10 * from PercentPopulationVaccinated
SELECT * 
FROM   INFORMATION_SCHEMA.VIEWS 
WHERE  VIEW_DEFINITION like '%PercentPopulationVaccinated%'

--LET'S BREAK THINGS DOWN BY CONTINENT 
SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount, MAX((total_cases/Population))*100 as PercentagePopulationInfected
FROM PortfolioProject1..CovidDeaths
where continent is NULL and location not like '%income%'
GROUP BY location 
ORDER BY TotalDeathCount desc
