select * from CovidDeaths$
order by 3,4

select * from CovidVaccinations$
order by 3,4

-- Main data or Main query 
select location, date , total_cases , new_cases, total_deaths, population
from CovidDeaths$
order by 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows what percentage of population got covid
select location, date ,population, total_cases , (total_deaths/total_cases)*100 as DeathPercentage 
from CovidDeaths$
where location like '%india%'
order by 1,2


--Looking at country with Highest Infection Rate compared to Population 
select location, population, max(total_cases) as HighestInfectionCount , Max((total_cases/population))*100 as PercentPopulationInfected 
from CovidDeaths$
Group by location,population 
order by 4 desc


--Looking at country with Highest Death Count compared to Population 
select location,max(cast (total_deaths AS int) ) as TotalDeathCount 
from CovidDeaths$
where continent is not null
Group by location
order by TotalDeathCount desc

--Break Down things by contnent
--showing continent with the highest death count 
select continent,max(cast (total_deaths AS int) ) as TotalDeathCount 	
from CovidDeaths$
where continent is not null
Group by continent
order by TotalDeathCount desc


-- Global Number 
select sum(New_Cases) as Total_Cases , sum(cast(new_deaths as int)) as Total_Deaths,  sum(cast (new_deaths as int)) /sum(new_cases)*100 as DeathPercentage 
from CovidDeaths$
where continent is not null
--group by date
order by 1,2

--Looking at total Population vs Vaccinations
Select dea.continent , dea.location, dea.date, dea.population,vac.new_vaccinations
, SUM( convert (int,vac.new_vaccinations)) over  (partition by dea.location order by dea.location, dea.date) as RollingCountVaccinations 

from CovidDeaths$ dea
join CovidVaccinations$ vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null  --and vac.new_vaccinations is not null 
order by 2,3

--Using CTE  (Common Table Expressions)

with PopvsVac (continent , location , date, population , new_vaccinations, RollingCountaccinations) as
(Select dea.continent , dea.location, dea.date, dea.population,vac.new_vaccinations
, SUM( convert (int,vac.new_vaccinations)) over  (partition by dea.location order by dea.location, dea.date) as RollingCountVaccinations 

from CovidDeaths$ dea
join CovidVaccinations$ vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null  --and vac.new_vaccinations is not null 
--order by 2,3
)
select * ,(RollingCountaccinations/population)*100 from PopvsVac 

--Using Create table command to add Column 
create table #PercentPopulationVaccinated(
continent nvarchar(255),
location nvarchar(255),
date datetime,
Population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric)

insert into #PercentPopulationVaccinated 
Select dea.continent , dea.location, dea.date, dea.population,vac.new_vaccinations
, SUM( convert (int,vac.new_vaccinations)) over  (partition by dea.location order by dea.location, dea.date) as RollingCountVaccinations 

from CovidDeaths$ dea
join CovidVaccinations$ vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null  --and vac.new_vaccinations is not null 
--order by 2,3

select * from #PercentPopulationVaccinated order by 2,3

--Created a View for further analysis in tableau 
create view PercentPopulationVaccinated as
Select dea.continent , dea.location, dea.date, dea.population,vac.new_vaccinations
, SUM( convert (int,vac.new_vaccinations)) over  (partition by dea.location order by dea.location, dea.date) as RollingCountVaccinations 

from CovidDeaths$ dea
join CovidVaccinations$ vac
on dea.location = vac.location
and dea.date = vac.date
--where dea.continent is not null  --and vac.new_vaccinations is not null 
--order by 2,3

select * from PercentPopulationVaccinated