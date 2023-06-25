select*
from CovidDeaths
order by 3,4

select*
from CovidVaccinations
order by 3,4

------------

select location,date,total_cases,new_cases,total_deaths,population
from CovidDeaths
order by 1,2


--total cases vs total deaths (%)

select location,date,total_deaths,total_cases, (total_deaths/total_cases)*100 as percentagedeaths
from CovidDeaths
where location='india'
order by 1,2

-------total deaths(need to consider new deaths since total deaths is adding new deaths too)
select sum(new_deaths)ast
from CovidDeaths
where location='india'

----- %caseswrtpopulation

select location,date, population, total_cases, (total_cases/population)*100 as caseswrtpopulation
from CovidDeaths
where location like '%india%'
order by 1,2,3,4



-----which are the countries with highest infection rate compared to population


select location, population, max(total_cases)highestinfection, max((total_cases/population)*100) as percentagehighestinfection
from CovidDeaths

group by location,population
order by percentagehighestinfection desc


----countries with highest deathcount per population

select location,max(total_deaths)deathcount from CovidDeaths
where continent is not null
group by location
order by 2 desc

-------deathcount wrt continent
select location ,max(total_deaths)deathcount from CovidDeaths
where continent is  null
group by location 
order by 2 desc


select continent ,max(total_deaths)deathcount from CovidDeaths
where continent is not null
group by continent 
order by 2 desc


--------   global deaths

select sum(new_deaths)globaldeathcount
from CovidDeaths

----------------------------------------------------------------------------------------------------


-------CovidVaccinations
select*
from CovidVaccinations


------joining both

select*
from CovidDeaths de

join CovidVaccinations va
on de.location=va.location and
de.date=va.date

------total population vs vaccination
select d.location,d.population,v.people_vaccinated
from CovidDeaths d
join CovidVaccinations v
on d.location=v.location
where d.location is not null
order by 1,2,3



select*
from CovidDeaths
select*
from CovidVaccinations

-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine


select d.location,d.date,d.population,v.new_vaccinations, sum(new_vaccinations)over(partition by d.location order by d.location,d.date)rolling
from CovidDeaths d
join CovidVaccinations v
on d.location=v.location
and d.date=v.date
where d.continent is not null
order by 1,2


----using cte to get %rolling


with vd (continent,location,date,population,new_vaccination,rolling)
as
(
select d.continent,d.location,d.date,d.population,v.new_vaccinations, sum(new_vaccinations)over(partition by d.location order by d.location,d.date)rolling
from CovidDeaths d
join CovidVaccinations v
on d.location=v.location
and d.date=v.date
where d.continent is not null
)
select*,(rolling/population)*100 as percentagerolling
from vd

-- Using Temp Table to perform Calculation on Partition By in previous query

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
Select d.continent, d.location, d.date, d.population, v.new_vaccinations
, SUM(v.new_vaccinations) OVER (Partition by d.Location Order by d.location, d.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From CovidDeaths d
Join CovidVaccinations v
	On d.location = v.location
	and d.date = v.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated



-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select d.continent, d.location, d.date, d.population, v.new_vaccinations
, SUM(v.new_vaccinations) OVER (Partition by d.Location Order by d.location, d.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From CovidDeaths d
Join CovidVaccinations v
	On d.location = v.location
	and d.date = v.date
where d.continent is not null 
--order by 2,3











	
