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
