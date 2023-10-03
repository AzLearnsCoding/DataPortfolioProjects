Select *
From dbo.CovidDeaths
Where continent is not null
order by 3,4

--Select *
--From dbo.CovidVaccinations
--order by 3,4

-- Select Data we are going to use 

Select location, date, total_cases, new_cases, total_deaths, population
From dbo.CovidDeaths
Where continent is not null
order by 1,2

-- Total Cases VS total Deaths
-- Shows Likelyhood of dying if you contract covid in your country
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
From dbo.CovidDeaths
Where location like '%states%'
Where continent is not null
order by 1,2


-- Total Cases Vs Population 
--Shows what Percentage of Pop got covid

Select location, date, Population, total_cases,  (total_cases/population)*100 AS PercentPopulationInfected
From dbo.CovidDeaths
--Where location like '%states%'
Where continent is not null
order by 1,2


-- Countries with highest Infection rate compared to population 


Select location, Population, MAX(total_cases) As HighestInfectionCount,  Max((total_cases/population))*100 AS PercentPopulationInfected
From dbo.CovidDeaths
--Where location like '%states%'
Group By location, Population
order by PercentPopulationInfected desc


-- Showing Countries with Highest Death Count Per Population 

Select location, MAX(cast(Total_deaths as int)) As TotalDeathCount
From dbo.CovidDeaths
--Where location like '%states%'
Where continent is not null
Group By location
order by TotalDeathCount desc

-- Break things down by Continent 
-- Showing continents with highest death count per population 

Select continent, MAX(cast(Total_deaths as int)) As TotalDeathCount
From dbo.CovidDeaths
--Where location like '%states%'
Where continent is not null
Group By continent
order by TotalDeathCount desc

-- Global numbers 

Select date, SUM(new_cases) as total_cases, Sum(cast(new_deaths as int)) as total_deaths, Sum(cast(new_deaths as int))/SUM(New_cases)*100 AS DeathPercentage
From dbo.CovidDeaths
--Where location like '%states%'
Where continent is not null
Group By date
order by 1,2

-- Total Pop vs Vaccinations 

Select dea.continent, dea.location, dea.date, dea.population, dea.new_vaccinations
, SUM(Cast(dea.new_vaccinations as int)) OVER(Partition by dea.location order by dea.location, dea.date)  As RollingPeopleVaccinated, --(RollingPeopleVaccinated/population)*100
From CovidDeaths dea
Join CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
order by 2,3


-- USE CTE 

With PopvsVac(continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, dea.new_vaccinations
, SUM(Cast(dea.new_vaccinations as int)) OVER(Partition by dea.location order by dea.location, dea.date)  As RollingPeopleVaccinated --(RollingPeopleVaccinated/population)*100
From CovidDeaths dea
Join CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac


-- Temp Table
DROP Table If exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated 
(
continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated Numeric 
)

Insert into #PercentPopulationVaccinated 

Select dea.continent, dea.location, dea.date, dea.population, dea.new_vaccinations
, SUM(Cast(dea.new_vaccinations as int)) OVER(Partition by dea.location order by dea.location, dea.date)  As RollingPeopleVaccinated --(RollingPeopleVaccinated/population)*100
From CovidDeaths dea
Join CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


-- Creating View to store data for later Visulation 

Create View PercentPopulationVaccinated As 

Select dea.continent, dea.location, dea.date, dea.population, dea.new_vaccinations
, SUM(Cast(dea.new_vaccinations as int)) OVER(Partition by dea.location order by dea.location, dea.date)  As RollingPeopleVaccinated --(RollingPeopleVaccinated/population)*100
From CovidDeaths dea
Join CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--order by 2,3
