select * from coviddeaths
order by location, date

select * from covidvaccinations
order by 3,4

select location, date, total_cases, new_cases, total_deaths, population
from coviddeaths 
order by location, date

--examining by location
--looking at total cases vs total death

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
from coviddeaths 
order by location, date

--looking at total cases vs population. percentage of affceted population
select location, date, total_cases, population, (total_deaths/population)*100 as percentage_population
from coviddeaths 
order by location, date

--countries with the hightest infection rate compared to population
select location, population, max(total_cases) as highest_infection_count_by_country, max(total_cases/population)*100 as percentage_popu_infect
from coviddeaths where continent is not null group by location, population
order by percentage_popu_infect  desc

--countries with the hightest death count per population
select location, max(total_deaths) as total_death_count
from coviddeaths where continent is not null group by location
order by  total_death_count desc

--futher investigation internationally
select location, max(total_deaths) as total_death_count_int
from coviddeaths  where continent is null group by location
order by  total_death_count_int desc

select continent, max(total_deaths) as total_death_count_int
from coviddeaths   group by continent
order by  total_death_count_int desc
-- redo all query by contient above later and recorrect the as names properly


--breaking global numbers
select  date,  total_deaths, total_cases,(total_deaths/total_cases)*100 as totaldeath_percentage
from coviddeaths where continent is not null group by date,  total_deaths,total_cases
order by   date

--
select  date,  sum (new_cases)as total_cases, sum (new_deaths)as total_deaths,  sum (new_deaths)/ sum (new_cases)*100 as death_perctage
from coviddeaths where continent is not null group by date
order by   1,2

-- world total death percentage 
select   sum (new_cases)as total_cases, sum (new_deaths)as total_deaths,  sum (new_deaths)/ sum (new_cases)*100 as death_perctage
from coviddeaths where continent is not null 
order by   1,2

--looking at total population vs vaccination
select * from coviddeaths  dea
join covidvaccinations  vac
on dea.location = vac.location
and dea.date = vac.date

select dea.continent, dea.location, dea.date, dea. population, vac. new_vaccinations
from coviddeaths  dea
join covidvaccinations  vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3

--
select dea.continent, dea.location, dea.date, dea. population, vac. new_vaccinations
, sum(vac.new_vaccinations) over (partition by dea.location order by  dea. location, dea. date ) as rolling people vaccinnated

from coviddeaths  dea
join covidvaccinations  vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3


--use cte


with popvsVas (continent, location, date, population, new_vaccination, rolling_people_vaccinated)
as
(
select dea.continent, dea.location, dea.date, dea. population, vac. new_vaccinations
, sum(vac.new_vaccinations) over (partition by dea.location order by  dea. location, dea. date ) as rolling_people_vaccinated

from coviddeaths  dea
join covidvaccinations  vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3
)

select *, (rolling_people_vaccinated/population)*100
from popvsVas

--temp table

create table percent_population_vaccinated
( 
continent text,
location text,
Date  Date,
population numeric,
new_vaccination numeric,
rolling_people_vaccinated numeric
)

insert into  percent_population_vaccinated (continent, location, Date, population,new_vaccination,rolling_people_vaccinated)values
(
select 'dea.continent', 'dea.location', 'dea.date', 'dea. population', 'vac. new_vaccinations'
, sum(vac.new_vaccinations) over (partition by dea.location order by  dea. location, dea. date ) as rolling_people_vaccinated

from coviddeaths  dea
join covidvaccinations  vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3
)

select *, (rolling_people_vaccinated/population)*100
from percent_population_vaccinated
--not correct

--creating view to store data for vis later

create view percentpopulationvaccinated as 
select dea.continent, dea.location, dea.date, dea. population, vac. new_vaccinations
, sum(vac.new_vaccinations) over (partition by dea.location order by  dea. location, dea. date ) as rolling_people_vaccinated

from coviddeaths  dea
join covidvaccinations  vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3

