SELECT *
	FROM PortfolioProject..CovidDeaths
	WHERE continent is not null
	order by 3,4 
--SELECT *
--	FROM PortfolioProject..CovidVaccinations
--	order by 3,4 

-- Select Data that we are going to be using

SELECT Location, date, total_cases, new_cases, total_deaths, population
	FROM PortfolioProject..CovidDeaths
	ORDER BY 1,2

-- Looking at the Total Cases vs Total Deaths
-- Shows the likelihood of dying if you contract covid in the United States
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
	FROM PortfolioProject..CovidDeaths
	WHERE location ='United States'
	ORDER BY 1,2

-- Looking at Total Cases vs Population
-- Shows what percentage of population got Covid
SELECT Location, date, population, total_cases, (total_cases/population)*100 as InfectedPercentage
	FROM PortfolioProject..CovidDeaths
	WHERE location ='United States'
	ORDER BY 1,2

-- Looking at Countries with Highest Infection Rate compared to Population
SELECT Location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as InfectedPercentage
	FROM PortfolioProject..CovidDeaths
	GROUP BY Location, Population
	ORDER BY InfectedPercentage desc

--Showing Countries with the Highest Death Count
SELECT Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
	FROM PortfolioProject..CovidDeaths
	WHERE continent is not null
	GROUP BY Location
	ORDER BY TotalDeathCount desc

--LET's BREAK THINGS DOWN BY CONTINENT

-- Showing the continents with the highest death count per population
SELECT continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
	FROM PortfolioProject..CovidDeaths
	WHERE continent is not null
	GROUP BY continent
	ORDER BY TotalDeathCount desc

--GLOBAL NUMBERS

--Global Total Cases vs Total Deaths by Date

SELECT date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as death_percentage
	FROM PortfolioProject..CovidDeaths
	WHERE continent is not null
	GROUP BY date
	ORDER BY 1,2


--Global Total Cases vs Total Deaths

SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as death_percentage
	FROM PortfolioProject..CovidDeaths
	WHERE continent is not null
	ORDER BY 1,2


--Looking at Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as rolling_people_vaccinated
FROM PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location 
	and dea.date=vac.date
WHERE dea.continent is not null
ORDER BY 2,3

--USE CTE

With PopvsVac (continent, location, date, population, new_vaccinations, rolling_people_vaccinated)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as rolling_people_vaccinated
FROM PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location 
	and dea.date=vac.date
WHERE dea.continent is not null
)
Select *, (rolling_people_vaccinated/population)*100 as percentage_vaccinated
From PopvsVac
	
--TEMP TABLE

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric, 
rolling_people_vaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as rolling_people_vaccinated
FROM PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location 
	and dea.date=vac.date
--WHERE dea.continent is not null
--ORDER BY 2,3

Select *, (rolling_people_vaccinated/population)*100 as percentage_vaccinated
From #PercentPopulationVaccinated

--Creating View to Store Data for Later Visualizations

CREATE VIEW PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as rolling_people_vaccinated
FROM PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location 
	and dea.date=vac.date
WHERE dea.continent is not null
--ORDER BY 2,3

SELECT * 
FROM PercentPopulationVaccinated