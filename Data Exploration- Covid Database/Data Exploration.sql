SELECT *
FROM PortfoliioProject..CovidDeaths
order by 3,4

SELECT *
FROM PortfoliioProject..CovidVaccination
order by 3,4


SELECT Location,date,total_cases, new_cases,total_deaths,population
FROM PortfoliioProject..CovidDeaths
order by 1,2

-- Looking at total cases vs Total Deaths

SELECT Location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathRate
FROM PortfoliioProject..CovidDeaths
where location like '%india%'
order by 1,2

-- Shows whart percentage of population got COVID

SELECT Location,date,total_cases,population,(total_cases/population)*100 as InfectionRate
FROM PortfoliioProject..CovidDeaths
where location like '%india%'
order by 1,2

-- Shows whart percentage of population Died

SELECT Location,date,total_deaths,population,(total_deaths/population)*100 as DeathRate
FROM PortfoliioProject..CovidDeaths
where location like '%india%'
order by 1,2

-- Looking at the countries with highest InfectionRate compared to Population

SELECT Location,Population,MAX(total_cases) as HighestInfectionCount,Max((total_cases/population))*100 
as PercentagePopulationInfected
FROM PortfoliioProject..CovidDeaths
Group by Location, Population 
order by PercentagePopulationInfected desc

-- BREAKING THINGS DOWN BY CONTINENT

-- Showing contintents with the highest death count per population

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfoliioProject..CovidDeaths
--Where location like '%india%'
Where continent is not null 
Group by continent
order by TotalDeathCount desc



-- GLOBAL NUMBERS

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfoliioProject..CovidDeaths
--Where location like '%india%'
where continent is not null 
order by 1,2

-- Looking at the populartion got vaccinated counrty wise

Select dea.continent,dea.location,dea.date,vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as bigint)) 
OVER (partition by dea.location order by dea.location,dea.date) As RollingPeople_Vaccinated
FROM PortfoliioProject..CovidDeaths dea
JOIN PortfoliioProject..CovidVaccination vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null and vac.new_vaccinations is not null 
order by 2,3

-- with percentage people Vaccinated
Select dea.continent,dea.location,dea.population,dea.date,vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as bigint)) 
OVER (partition by dea.location order by dea.location,dea.date) As RollingPeople_Vaccinated
, (SUM(cast(vac.new_vaccinations as bigint)) 
OVER (partition by dea.location order by dea.location,dea.date) / dea.population) As Percentage_Vac
FROM PortfoliioProject..CovidDeaths dea
JOIN PortfoliioProject..CovidVaccination vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null and vac.new_vaccinations is not null 
order by 2,3


-- Using CTE

With PopvsVac (Continent, Location,Population, Date,new_vaccinations,RollingPeople_Vaccinated)
as
(
Select dea.continent,dea.location,dea.population,dea.date,vac.new_vaccinations,
SUM(CONVERT(BIGINT,vac.new_vaccinations)) 
OVER (partition by dea.location order by dea.location,dea.date) As RollingPeople_Vaccinated
FROM PortfoliioProject..CovidDeaths dea
JOIN PortfoliioProject..CovidVaccination vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null and vac.new_vaccinations is not null 
-- order by 2,3
)
Select *,(RollingPeople_Vaccinated/population)*100 As Percentage_Vac
from PopvsVac


-- Using Temp Table

DROP TABLE if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar (255),
population numeric,
Date datetime,
new_vaccinations numeric,
RollingPeople_Vaccinated numeric
)
Insert into #PercentPopulationVaccinated
Select dea.continent,dea.location,dea.population,dea.date,vac.new_vaccinations,
SUM(CONVERT(BIGINT,vac.new_vaccinations)) 
OVER (partition by dea.location order by dea.location,dea.date) As RollingPeople_Vaccinated
FROM PortfoliioProject..CovidDeaths dea
JOIN PortfoliioProject..CovidVaccination vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null and vac.new_vaccinations is not null 

Select *,(RollingPeople_Vaccinated/population)*100 As Percentage_Vac
from #PercentPopulationVaccinated
