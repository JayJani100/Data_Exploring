select * 
from PortfolioProjects..CovidDeaths
where continent is not null
order by 3,4 

--select * 
--from PortfolioProjects..CovidVaccinations
--order by 3,4

-- select data that we are going to be using

select location, date , total_cases, new_cases, total_deaths, population
from PortfolioProjects..CovidDeaths
order by 1,2

-- looking at total cases vs total deaths
--shows likelihodd of dying if you contarct covid in your country
select location, date , total_cases, total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProjects..CovidDeaths
where location like '%ndia%'
order by 1,2

-- looking at the total cases vs population 
-- shows waht percentage of population got covid
select location, date , population, total_cases,  (total_cases/population)*100 as PercentPopulationInfected
from PortfolioProjects..CovidDeaths
--where location like '%ndia%'
order by 1,2


--loooking at counries with highest infection rate compared to poulation
select location, population, max(total_cases)as HighestInfectionCount,  max(total_cases/population)*100 as PercentPopulationInfected
from PortfolioProjects..CovidDeaths
--where location like '%ndia%'
group by population,location
order by PercentPopulationInfected desc

-- the countries with highest death count  per popluation
select location, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProjects..CovidDeaths
--where location like '%ndia%'
where continent is not null
group by location
order by  TotalDeathCount desc

--LETS BREAK THIS DOWN BY CONTINENT


--showing the continent with highest death count per population
select continent, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProjects..CovidDeaths
--where location like '%ndia%'
where continent is not null
group by continent
order by  TotalDeathCount desc

--breaking global numbers
select date, sum(new_cases) as TotalCases,sum(cast(new_deaths as int)) as TotalDeaths, (sum(cast(new_deaths as int))/sum(new_cases)*100) as  DeathPercentage
from PortfolioProjects..CovidDeaths
--where location like '%ndia%'
where continent is not null 
group by date
order by 1,2


--Total in the world 
select sum(new_cases) as TotalCases,sum(cast(new_deaths as int)) as TotalDeaths, (sum(cast(new_deaths as int))/sum(new_cases)*100) as  DeathPercentage
from PortfolioProjects..CovidDeaths
--where location like '%ndia%'
where continent is not null 
--group by date
order by 1,2


-- covid vaccination
select * 
from PortfolioProjects..CovidVaccinations

-- Joining them 
select * 
from PortfolioProjects..CovidDeaths as dea
Join PortfolioProjects..CovidVaccinations vac
     on dea.location= vac.location 
	 and dea.date = vac.date

-- Total Population vs Vaccination
select dea.location, dea.continent, dea.date ,dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as int )) over (partition by dea.location)  
from PortfolioProjects..CovidDeaths as dea
Join PortfolioProjects..CovidVaccinations vac
     on dea.location= vac.location 
	 and dea.date = vac.date
where dea.continent is not null
order by 1,2,3
--Ulternative
select dea.location, dea.continent, dea.date ,dea.population, vac.new_vaccinations
, sum(convert(int,vac.new_vaccinations )) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinted  
from PortfolioProjects..CovidDeaths as dea
Join PortfolioProjects..CovidVaccinations vac
     on dea.location= vac.location 
	 and dea.date = vac.date
where dea.continent is not null
order by 1,2,3

--CTE
with PopVsVac ( continent, date, location, population, new_vaccinations, RollingPeopleVaccinated)
as
(
select  dea.continent,dea.location, dea.date ,dea.population, vac.new_vaccinations
, sum(convert(int,vac.new_vaccinations )) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinted  
from PortfolioProjects..CovidDeaths as dea
Join PortfolioProjects..CovidVaccinations vac
     on dea.location= vac.location 
	 and dea.date = vac.date
where dea.continent is not null
--order by 1,2,3
)
select * ,(RollingPeopleVaccinated/population)*100
from PopVsVac


--Temp Table

Drop table if exists #PercentagePopulationVaccinated
Create Table #PercentagePopulationVaccinated
(
continent nvarchar(255),
Location nvarchar(255),
Date datetime,
population numeric,
New_vaccinated numeric,
RollingPeopleVaccinated numeric,
)



insert into #PercentagePopulationVaccinated
select  dea.continent,dea.location, dea.date ,dea.population, vac.new_vaccinations
, sum(convert(int,vac.new_vaccinations )) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinted  
from PortfolioProjects..CovidDeaths as dea
Join PortfolioProjects..CovidVaccinations vac
     on dea.location= vac.location 
	 and dea.date = vac.date
where dea.continent is not null
--order by 1,2,3

select * ,(RollingPeopleVaccinated/population)*100
from #PercentagePopulationVaccinated


-- creating view to store data for visualization 

create view PercentagePopulationVaccinated as 
select  dea.continent,dea.location, dea.date ,dea.population, vac.new_vaccinations
, sum(convert(int,vac.new_vaccinations )) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinted  
from PortfolioProjects..CovidDeaths as dea
Join PortfolioProjects..CovidVaccinations vac
     on dea.location= vac.location 
	 and dea.date = vac.date
where dea.continent is not null
--order by 1,2,3

select *
from PercentagePopulationVaccinated

