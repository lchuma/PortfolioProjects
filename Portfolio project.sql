select * 
from [Portfolio Project]..[Covid Deaths]
where continent is not null
order by 3, 4


--select * 
--from [Portfolio Project]..[Covid Vaccinations]
--order by 3, 4

-- Select Data that we are going to be using


select Location, date, total_cases, new_cases, total_deaths
from [Portfolio Project]..[Covid Deaths]
where continent is not null
order by 1, 2


-- Looking at Total Cases vs Total Deaths
-- shows the likelihood of dying if you contract Covid in a CERTAIN country

select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from [Portfolio Project]..[Covid Deaths]
Where location like '%states%'
order by 1, 2

---Total Cases vs Population

select Location, date, total_cases, population, (total_cases/population)*100 as MortalityPercentage
from [Portfolio Project]..[Covid Deaths]
--Where location like '%states%'
order by 1, 2

--Looking at countries with highest infection rate compared to population

select Location, population, MAX(total_cases) AS HightestInfectionCount, Max( (total_cases/population))*100 as PercentPopulationInfected
from [Portfolio Project]..[Covid Deaths]
--Where location like '%states%
group by Location, population
order by PercentPopulationInfected desc


---Showing Countries with Highest Death Count per Population
select Location, MAX(cast(total_deaths as int)) AS HightestDeathCount
from [Portfolio Project]..[Covid Deaths]
--Where location like '%states%
where continent is not null
group by Location, Population

order by HightestDeathCount desc



--Lets break things down by continent

select continent, MAX(cast(total_deaths as int)) AS HightestDeathCount
from [Portfolio Project]..[Covid Deaths]
--Where location like '%states%
where continent is not null
group by continent
order by HightestDeathCount desc 


--- Showing the continent with the highest death per population

select continent, MAX(cast(total_deaths as int)) AS HightestDeathCount
from [Portfolio Project]..[Covid Deaths]
--Where location like '%states%
where continent is not null
group by continent
order by HightestDeathCount desc 


-- Global Numbers

select  sum(new_cases) as TotalCases, Sum(cast(new_deaths as int )) as TotalDeath,   Sum(cast(new_deaths as int))/sum(new_cases)*100 AS DeathPercentage
from [Portfolio Project]..[Covid Deaths]
--Where location like '%states%'
where continent is not null
--group by date
order by 1, 2

-- Looking at Total Population vs Vaccinations

Select dea.continent, dea.location,	 dea.date, dea.population, vac.new_vaccinations,
Sum(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date) As RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
From [Portfolio Project]..[Covid Deaths] dea
Join [Portfolio Project]..[Covid Vaccinations] vac
  ON dea.location = vac.location
  and dea.date = vac.date
  where dea.continent is not null
   order by 2, 3

   --USE CTE

   With PopVsVac (Continent, Location, Date, Population,new_vaccinations, RollingPeopleVaccinated)
   as
   (
   Select dea.continent, dea.location,	 dea.date, dea.population, vac.new_vaccinations,
Sum(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date) As RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
From [Portfolio Project]..[Covid Deaths] dea
Join [Portfolio Project]..[Covid Vaccinations] vac
  ON dea.location = vac.location
  and dea.date = vac.date
  where dea.continent is not null
   --order by 2, 3
   )
   Select *, (RollingPeopleVaccinated/Population)*100
   From PopVsVac


   --TEMP Table
   Drop table if exists #PercentPopulationVaccinated
   Create Table #PercentPopulationVaccinated
   (
   Continent nvarchar (255),
   Location nvarchar (255),
   Date datetime,
   Population numeric,
   new_vaccinations numeric,
   RollingPeopleVaccinated numeric
   )




   Insert into #PercentPopulationVaccinated

   Select dea.continent, dea.location,	 dea.date, dea.population, vac.new_vaccinations,
Sum(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date) As RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
From [Portfolio Project]..[Covid Deaths] dea
Join [Portfolio Project]..[Covid Vaccinations] vac
  ON dea.location = vac.location
  and dea.date = vac.date
  --where dea.continent is not null
   --order by 2, 3

   Select *, (RollingPeopleVaccinated/Population)*100
   From #PercentPopulationVaccinated



   --Creating View to store data for visualizations

   Create View PercentPopulationVaccinatedTest as
   Select dea.continent, dea.location,	 dea.date, dea.population, vac.new_vaccinations,
Sum(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date) As RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
From [Portfolio Project]..[Covid Deaths] dea
Join [Portfolio Project]..[Covid Vaccinations] vac
  ON dea.location = vac.location
  and dea.date = vac.date
 where dea.continent is not null
   --order by 2, 3

   select *
   From PercentPopulationVaccinatedTest