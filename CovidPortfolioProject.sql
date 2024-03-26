
Select *
From Covid..CovidDeath
Order by 3,4

--Select *
--From dbo.CovidVaccination
--Order by 3,4

Select location, date, total_cases, new_cases, total_deaths, population
From Covid..CovidDeath
Order by 1,2


-- Looking at Total_cases vs Total_deaths
-- Shows Likelihood of dying if you contact covid in Kazakhstan
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
From Covid..CovidDeath
Where location like '%Kazakhstan%'
and continent is not null
Order by 1,2

--Looking at total_cases vs population
-- Shows the percentage of COVID-19 case in Kazakhstan 
Select location, date, total_cases, population, (total_cases/population)*100 as Case_Percentage
From Covid..CovidDeath
Where location like '%Kazakhstan%'
Order by 1,2

-- Looking at Countries with highest Infection Rate compared to Population

Select location, population, MAX (total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
From Covid..CovidDeath
--Where location like '%Kazakhstan%'
Group by location, population
Order by PercentPopulationInfected desc


-- Showing Countris with Highest Death Count per Population 

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From Covid..CovidDeath
--Where location like '%Kazakhstan%'
Where continent is not null
Group by location
Order by TotalDeathCount desc


-- LET's Break THings down by continent

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From Covid..CovidDeath
--Where location like '%Kazakhstan%'
Where continent is null
Group by location
Order by TotalDeathCount desc


-- Showing continents with the highest death count per popilation


Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From Covid..CovidDeath
--Where location like '%Kazakhstan%'
Where continent is not null
Group by continent
Order by TotalDeathCount desc

-- GLOBAL NUMBERS

Select date, SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(new_deaths)/SUM(new_cases)*100 as death_percentage
From Covid..CovidDeath
--Where location like '%Kazakhstan%'
where new_cases <> 0
and new_deaths <> 0
group by date
Order by 1,2 


Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location) as RollingPeopleVaccinated
From Covid..CovidDeath dea
Join Covid..CovidVaccination vac
 On dea.location = vac.location
 and dea.date = vac.date
 Where dea.continent is not null
  order by 2,3


  --USE CTE
  With PopvsVac (Continent, location, date, population,new_vaccinations, RollingPeopleVaccinated)
  as 
  (
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location) as RollingPeopleVaccinated
From Covid..CovidDeath dea
Join Covid..CovidVaccination vac
 On dea.location = vac.location
 and dea.date = vac.date
 Where dea.continent is not null
 -- order by 1,2,3
  )
  Select *, (RollingPeopleVaccinated/population)*100
  From PopvsVac


  -- TEMP Table 

  Create Table #PercentPopulationVaccinated 
  (
  Continent nvarchar(255),
  Location nvarchar(255),
  Date Datetime,
  population numeric,
  New_vaccinations numeric,
  RollingPeopleVaccinated numeric
  )

  INSERT INTO #PercentPopulationVaccinated
  Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location) as RollingPeopleVaccinated
From Covid..CovidDeath dea
Join Covid..CovidVaccination vac
 On dea.location = vac.location
 and dea.date = vac.date
 Where dea.continent is not null
 -- order by 1,2,3

 Select *, (RollingPeopleVaccinated/Population)*100
 From #PercentPopulationVaccinated

 -- Creating view
 Create view PercentPopulationVaccinated as 
  Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location) as RollingPeopleVaccinated
From Covid..CovidDeath dea
Join Covid..CovidVaccination vac
 On dea.location = vac.location
 and dea.date = vac.date
 Where dea.continent is not null
 --order by 1,2,3