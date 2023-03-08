
--alter table CovidDeath alter column total_cases float


select *
from [Project Portfolio]..CovidDeath
where continent is not null
ORDER BY 3,4

-- Diving into the Data of Interest 
SELECT location,date,total_cases,new_cases,total_deaths,population
FROM [Project Portfolio]..CovidDeath
WHERE LOCATION LIKE 'NIGERIA' and continent is not null
ORDER BY 1,2



-- Looking at total cases vs total deaths recorded in Nigeria
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as 'Death_percentage'
FROM [Project Portfolio]..CovidDeath
Where location like '%Nigeria%' and continent is not null
ORDER BY 1,2


-- total cases vs Population
-- percentage of people who are infected with covid

SELECT location, date, population, total_cases, (total_cases/population)*100 
FROM [Project Portfolio]..CovidDeath
Where location like '%State%'  and continent is not null
ORDER BY 1,2


-- Countries with highest infection rate compared to the poulation


SELECT top 10 location, population, Max(total_cases) as HighestInfectionCount, Max(total_cases/population)*100 as percentage_infected
FROM [Project Portfolio]..CovidDeath
Where location like '%State%' and continent is not null 
Group by location, population
ORDER BY 4 Desc

-- countries wit the highest death count per population

SELECT location, Max(total_deaths) as DeathCount
FROM [Project Portfolio]..CovidDeath
--Where location like '%State%'
where continent is not null
Group by location
ORDER BY 2 Desc


-- continent with the highest death count

SELECT continent, Max(total_deaths) as DeathCount
FROM [Project Portfolio]..CovidDeath
--Where location like '%State%'
where continent is not null
Group by continent
ORDER BY 2 Desc


--Global numbers 


SELECT date,SUM(new_cases) as Total_cases,sum(new_deaths) as Total_deaths, sum(cast(new_deaths as float))/sum(cast(new_cases as float)) *100 as DeathPercentage
FROM [Project Portfolio]..CovidDeath
--Where location like '%State%'
where continent is not null
Group by date
ORDER BY 4 desc


-- Exploring Covid Vacination 

SELECT *
FROM [Project Portfolio]..CovidDeath dea
JOIN [Project Portfolio]..CovidVaccination vac
	ON dea.location = vac.location and 
		dea.date = vac.date


-- looking at the total population vs vacination

SELECT dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations,
SUM(vac.new_vaccinations) over (partition by dea.location order by dea.location,dea.date) as cummulated_vaccination
--(rolling_vaccination)/dea.population *100
FROM [Project Portfolio]..CovidDeath dea
JOIN [Project Portfolio]..CovidVaccination vac
	ON dea.location = vac.location and 
		dea.date = vac.date
where dea.continent is not null
order by 2,3


--using cte

with cte_covidVaccination(Continent, location, Date, Population, new_vaccinations, rolling_vaccination)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations,
SUM(vac.new_vaccinations) over (partition by dea.location order by dea.location,dea.date) as cummulated_vaccination
FROM [Project Portfolio]..CovidDeath dea
JOIN [Project Portfolio]..CovidVaccination vac
	ON dea.location = vac.location and 
		dea.date = vac.date
where dea.continent is not null

)
select *,(rolling_vaccination)/convert(float,population) *100
from cte_covidVaccination



-- using tempt table to further query table to extract percent of the population vaccinated


drop table if exists #PercentPopulationVacinated
create table  #PercentPopulationVacinated
(continents varchar(255),
Location varchar(255),
Date datetime,
population numeric,
New_vaccinations numeric,
Commulative_Vaccination numeric
)

insert into #PercentPopulationVacinated
SELECT dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations,
SUM(vac.new_vaccinations) over (partition by dea.location order by dea.location,dea.date) as cummulated_vaccination
FROM [Project Portfolio]..CovidDeath dea
JOIN [Project Portfolio]..CovidVaccination vac
	ON dea.location = vac.location and 
		dea.date = vac.date
where dea.continent is not null

select *, Commulative_Vaccination/population *100 PercentPopulationVacinated
from #PercentPopulationVacinated
order by PercentPopulationVacinated

--view for later visulization 

Create view PercentPopulationVacinated as
SELECT dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations,
SUM(vac.new_vaccinations) over (partition by dea.location order by dea.location,dea.date) as cummulated_vaccination
FROM [Project Portfolio]..CovidDeath dea
JOIN [Project Portfolio]..CovidVaccination vac
	ON dea.location = vac.location and 
		dea.date = vac.date
where dea.continent is not null









