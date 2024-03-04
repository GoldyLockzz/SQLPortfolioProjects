--DATA obtained from OurWorldinData (https://ourworldindata.org/covid-deaths) 

SELECT *
FROM [PortfolioProject]..CovidDeaths

--Total Cases vs deaths
Select location,date, total_cases,total_deaths,(total_deaths/total_cases)*100 as '%Death'
FROM [PortfolioProject]..CovidDeaths
where location like '%austra%'



--Total Cases vs pop
Select location,max(total_cases) as highestInfected,population,max(total_cases/population)*100 as '%PopInfected',
	max(cast(total_deaths as int))as TotalDeathCount
FROM [PortfolioProject]..CovidDeaths
	--where location like '%austra%'
WHERE continent is not null
GROUP BY location,population
	--ORDER BY '%PopInfected' DESC
ORDER BY TotalDeathCount DESC



--Per Continent
Select location,max(total_cases) as highestInfected,max(total_cases/population)*100 as '%PopInfected',
	max(cast(total_deaths as int))as TotalDeathCount
FROM [PortfolioProject]..CovidDeaths
WHERE continent is null
GROUP BY location
ORDER BY TotalDeathCount DESC



--WorldWide
SELECT
	--date,
	sum(new_cases) as total_cases,
	sum(cast(new_deaths as int)) as total_deaths,
	sum(convert(int,new_deaths))/sum(new_cases)*100 as DeathPercentage
FROM [PortfolioProject]..CovidDeaths
WHERE continent is not null
	--GROUP BY date, ORDER BY date



--JOIN, CTE, WINDOWING
	--looking at total pop vs total vacc
WITH PopVac as (
SELECT death.continent,death.location,death.date, death.population,vac.new_vaccinations,
	sum(cast(vac.new_vaccinations as int)) OVER (PARTITION BY death.location
		ORDER BY death.location, death.date) as CumSumVaccinated
FROM [PortfolioProject]..CovidDeaths AS death
LEFT JOIN [PortfolioProject]..CovidVaccinations as vac
	on death.location=vac.location
	and death.date=vac.date
WHERE death.continent is not null
	--ORDER BY 1,2,3
)
SELECT *,(CumSumVaccinated/population)*100 as PercentageVaccinated
FROM PopVac
where CumSumVaccinated is not NULL



--Temp Table INSTEAD of CTE
DROP TABLE IF EXISTS #PercentPopVaccinated
CREATE TABLE #PercentPopVaccinated
( Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations int,
CumSumVaccinated int)

INSERT INTO #PercentPopVaccinated
SELECT death.continent,death.location,death.date, death.population,vac.new_vaccinations,
	sum(cast(vac.new_vaccinations as int)) OVER (PARTITION BY death.location
		ORDER BY death.location, death.date) as CumSumVaccinated
FROM [PortfolioProject]..CovidDeaths AS death
LEFT JOIN [PortfolioProject]..CovidVaccinations as vac
	on death.location=vac.location
	and death.date=vac.date
WHERE death.continent is not null
	--ORDER BY 1,2,3

SELECT *,(CumSumVaccinated/population)*100 as PercentageVaccinated
FROM #PercentPopVaccinated
where CumSumVaccinated is not NULL



-- CREATE VIEW
-- CREATE VIEW 
