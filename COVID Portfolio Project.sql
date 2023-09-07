SELECT TOP 50 *
FROM [PortfolioProject].dbo.CovidDeaths
Order by 3,4

SELECT TOP 50 *
FROM [PortfolioProject].dbo.CovidVaccinations
Order by 3,4

Select location, date, new_cases, total_deaths
From PortfolioProject..CovidDeaths
Order By 1,2

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where location like '%Ghana%'
Order By 1,2

--Total cases vs Population
--Percentage of Population that got covid

Select location, date, total_cases, Population, (total_cases/Population)*100 as CovidPercentage
From PortfolioProject..CovidDeaths
--Where location like '%Ghana%'
Order By 1,2

--Countries with the highest Covid Infection Rate

Select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/Population))*100 as InfectionRate
From PortfolioProject..CovidDeaths
Group by location, population
Order by InfectionRate desc

--Showing countries with the highest death count per population

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
where continent is not null
Group by location
Order by TotalDeathCount desc

--TOTAL DEATH BY CONTINENT

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
where continent is not null
Group by continent
Order by TotalDeathCount desc


--Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
--From PortfolioProject..CovidDeaths
--where continent is null
--Group by location
--Order by TotalDeathCount desc


--OVERALL DEATH PERCENTAGE OF THE WORLD

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast
	(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where continent is not null
order by 1,2

--SHOWING THE CONTINENTS WITH THE HIGHEST DEATH PER POPULATION

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount,
	MAX(cast(population as int)) as TotalPopulation, (MAX(cast(total_deaths as int)) /MAX(cast(population as int)) ) as DeathPerPopulation
From PortfolioProject..CovidDeaths
where continent is not null
Group by continent
Order by DeathPerPopulation desc


--Total Population Vs Vaccinations


Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by 
dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--	and vac.new_vaccinations is not null
order by 2, 3


--USING CTEs


With PopvsVac (Continent, Location, Date, Population, New_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by 
dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--	and vac.new_vaccinations is not null
--order by 2, 3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac


--TEMP Table

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
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by 
dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--	and vac.new_vaccinations is not null
--order by 2, 3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


--CREATING VIEW TO STORE DATA FOR LATER VISUALIZATION

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by 
dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--	and vac.new_vaccinations is not null
--order by 2, 3


Select *
From PercentPopulationVaccinated
