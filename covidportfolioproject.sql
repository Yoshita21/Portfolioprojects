
/*
select * from [Portfolio].[dbo].[covid deaths] order by 3,4
select * from [Portfolio].[dbo].[covid vaccinations] order by 3,4
*/

--info that will be used
select location, date, total_cases, new_cases, total_deaths,population from 
[Portfolio].[dbo].[covid deaths]
order by 1,2

--total cases vs total deaths

select location, date, total_cases, total_deaths,(total_deaths/total_cases)*100 as percentdeaths  from 
[Portfolio].[dbo].[covid deaths]
where location like '%ndia%'
order by 1,2

--total cases vs pop
select location, date, total_cases, total_deaths,(total_deaths/total_cases)*100 as percentdeaths  from 
[Portfolio].[dbo].[covid deaths]
where location like '%ndia%'
order by 1,2

--percent of population that got covid
select location, date, total_cases,population,(total_cases/population)*100 as covidpercent from 
[Portfolio].[dbo].[covid deaths]
order by 1,2

--countries with highest cases wrt population
select location,population,max(total_cases) as highestcases , MAX((total_cases/population)*100) 
as covidpercent from 
[Portfolio].[dbo].[covid deaths]
group by population,[location]
order by covidpercent desc

--countries with highest deaths wrt population

select location,max(cast(total_deaths as int)) as highestdeaths , MAX((total_deaths/population)*100) 
as deathpercent from 
[Portfolio].[dbo].[covid deaths]
where continent is not null
group by [location]
order by deathpercent desc


-- breaking by continent
--showing continents with highest death count
select continent,max(cast(total_deaths as int)) as highestdeaths from
[Portfolio].[dbo].[covid deaths]
where continent is not null
group by [continent]
ORDER by highestdeaths DESC

--globalnumbers
select date,
sum(new_cases) as total_c,sum(cast(new_deaths as int)) as total_d
--,sum(cast(new_deaths as int))/sum(new_cases)*100 as deathpercent
from 
[Portfolio].[dbo].[covid deaths]
where continent is not null
GROUP by [date]
order by 1,2

--totalpop vs vaccination
select dea.continent,dea.[location],dea.date,dea.population,vac.new_vaccinations
,sum(cast(vac.new_vaccinations as bigint))over 
(PARTITION by dea.location order by dea.location,dea.date) as rollingpeoplevaccinated
 from [Portfolio].[dbo].[covid deaths] dea JOIN
 [Portfolio].[dbo].[covid vaccinations] vac on 
dea.[location]=vac.[location]
and dea.[date]=vac.date
where dea.continent is not null
order by 2,3

-- using CTE

with popvsvac (continent,location,date,population,new_vaccinations,rollingpeoplevaccinated)
as 
(
select dea.continent,dea.[location],dea.date,dea.population,vac.new_vaccinations
,sum(cast(vac.new_vaccinations as bigint))over 
(PARTITION by dea.location order by dea.location,dea.date) as rollingpeoplevaccinated
 from [Portfolio].[dbo].[covid deaths] dea JOIN
 [Portfolio].[dbo].[covid vaccinations] vac on 
dea.[location]=vac.[location]
and dea.[date]=vac.date
where dea.continent is not null
)
select *, (rollingpeoplevaccinated/population)*100 percentvaccinated from popvsvac

-- using temp table

create table #percentpopulationvaccinated
(continent nvarchar(255),
LOCATION nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rollingpeoplevaccinated numeric
)
insert into #percentpopulationvaccinated
select dea.continent,dea.[location],dea.date,dea.population,vac.new_vaccinations
,sum(cast(vac.new_vaccinations as bigint))over 
(PARTITION by dea.location order by dea.location,dea.date) as rollingpeoplevaccinated
 from [Portfolio].[dbo].[covid deaths] dea JOIN
 [Portfolio].[dbo].[covid vaccinations] vac on 
dea.[location]=vac.[location]
and dea.[date]=vac.date
--where dea.continent is not null

select *, (rollingpeoplevaccinated/population)*100 percentvaccinated from #percentpopulationvaccinated

-- drop if theres a mistake
drop table if exists #percentpopulationvaccinated

--creating view to store data
create view percentpopulationvaccinated as
select dea.continent,dea.[location],dea.date,dea.population,vac.new_vaccinations
,sum(cast(vac.new_vaccinations as bigint))over 
(PARTITION by dea.location order by dea.location,dea.date) as rollingpeoplevaccinated
 from [Portfolio].[dbo].[covid deaths] dea JOIN
 [Portfolio].[dbo].[covid vaccinations] vac on 
dea.[location]=vac.[location]
and dea.[date]=vac.date 
where dea.continent is not NULL

select * from percentpopulationvaccinated

