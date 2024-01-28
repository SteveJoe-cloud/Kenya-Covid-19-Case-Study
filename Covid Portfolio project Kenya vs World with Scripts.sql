Select *
From PortfolioProject..CovidDeaths
order by 3,4

--Select *
--From PortfolioProject..CovidVaccinations
--order by 3,4

Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
order by 1,2

-- Total Cases vs Total Deaths in Kenya

--Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
--From PortfolioProject..CovidDeaths
--order by 1,2

Select Location, date, total_cases, total_deaths, (CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0))*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where location like '%Kenya%'
order by 1,2

-- Total Cases vs Population
-- What Population percentage got Covid in Kenya 
Select Location, date,population, total_cases,  (CONVERT(float, total_cases) / NULLIF(CONVERT(float, population), 0))*100 as PopulationInfectedPercentage
From PortfolioProject..CovidDeaths
Where location like '%Kenya%'
order by 1,2

-- Countries with highest infection rate compared to population
Select Location, population, MAX(total_cases) as HighestInfectionCount, max ((total_cases/population))*100 as PopulationInfectedPercentage   
From PortfolioProject..CovidDeaths
Group by location, population
order by PopulationInfectedPercentage desc

-- Countries with highest death count compared to population
Select Location, population, MAX(total_deaths) as HighestDeathCount, max ((total_deaths/population))*100 as PopulationDeathPercentage   
From PortfolioProject..CovidDeaths
Group by location, population
order by PopulationDeathPercentage desc

-- Countries with highest death count 
Select Location, MAX(Convert(Float,total_deaths)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null
Group by location 
order by TotalDeathCount desc

--Continents with highest death count
Select continent, MAX(convert(float, total_deaths)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null
Group by continent
order by TotalDeathCount desc


-- Global Numbers

Select date, SUM(new_cases)as TotalCases, SUM(convert(float, new_deaths)) as TotalDeaths, 
SUM(CONVERT(FLOAT,new_deaths))/Nullif (SUM(new_cases),0)*100 as DeathPercentage  
From PortfolioProject..CovidDeaths
Where new_deaths is not null
Group by date
order by 1,2 

--  Total Death Percentage Global
Select SUM(new_cases)as TotalCases, SUM(CAST(new_deaths as int)) as TotalDeaths, 
SUM(CAST(new_deaths as int))/ SUM(new_cases)*100 as DeathPercentage  
From PortfolioProject..CovidDeaths
Where new_deaths is not null


-- Total Population vs Vaccinations
Select*
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
On dea.location = vac.location
And dea.date =  vac.date

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
On dea.Location = vac.location
and dea.date=vac.date
where dea.continent is not null
and vac.people_vaccinated is not null
and vac.new_vaccinations is not null
Order by 2,3

-- Total Population vs Vaccinations(Rolling no)
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(int, vac.new_vaccinations)) over (Partition by dea.location Order by dea.location, dea.date)
As RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
On dea.Location = vac.location
and dea.date=vac.date
where dea.continent is not null
and vac.people_vaccinated is not null
and vac.new_vaccinations is not null
Order by 2,3

--Use CTE to create temp row for RollingPeopleVaccinated

With PopvsVac (Continent, Location, Date, Population,New_vaccinations,RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as bigint)) over (Partition by dea.location Order by dea.location, dea.date)
As RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
On dea.Location = vac.location
and dea.date=vac.date
where dea.continent is not null
and vac.new_vaccinations is not null
--Order by 2,3
)
Select*, (RollingPeopleVaccinated/Population)*100
From PopvsVac

-- Temp Table 


Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population float,
New_vaccinations float,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as bigint)) over (Partition by dea.location Order by dea.location, dea.date)
As RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
On dea.Location = vac.location
and dea.date=vac.date
--where dea.continent is not null
--and vac.new_vaccinations is not null
--Order by 2,3

Select*, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

-- Creating View to store data for visualizations

Create View PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as bigint)) over (Partition by dea.location Order by dea.location, dea.date)
As RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
On dea.Location = vac.location
and dea.date=vac.date
where dea.continent is not null
--vac.new_vaccinations is not null
--Order by 2,3

Select *
From PercentPopulationVaccinated

Create View TotalDeathsKenya as
Select Location, date,population, total_cases,  (CONVERT(float, total_cases) / NULLIF(CONVERT(float, population), 0))*100 as PopulationInfectedPercentage
From PortfolioProject..CovidDeaths
Where location like '%Kenya%'
--order by 1,2
