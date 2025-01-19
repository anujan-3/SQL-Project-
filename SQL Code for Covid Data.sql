
Select *
-- Continent is null then a entire continent has been selected
From SQLProject..CovidDeaths
Where continent is not null
order by 3,4


Select *
From SQLProject..CovidVaccinations
order by 3,4

-- Now we are going to select the data that we will be using 

Select Location,date,total_cases,new_cases,total_deaths, population
From SQLProject..CovidDeaths
order by 1,2


-- Firstly we will look at the total cases vs the total deaths
-- How many cases are in each country, and observe how many deaths they have for the no. of cases 
-- Shows the likelihood of dying if you contract covid in your country

Select Location,date,total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From SQLProject..CovidDeaths
where location like '%kingdom%'
order by 1,2

-- Lets look at Total Cases vs Population
-- Shows what percentage of population that contracted Covid

Select Location,date,total_cases,Population,(total_cases/population)*100 as PercentPopulationInfected
From SQLProject..CovidDeaths
where location like '%kingdom%'
order by 1,2


-- Lets observe the countries with the highest infection rate compared to Population
Select Location,Population,MAX((total_cases/population))*100 as PercentPopulationInfected
From SQLProject..CovidDeaths
Group by Location, Population
order by PercentPopulationInfected desc

-- This is showing the countries with Highest Death Count per Population
-- cast used to remove issue with data type when using aggregate function coverts it to integer

Select Location,MAX(cast(Total_Deaths as int)) as TotalDeathCount
From SQLProject..CovidDeaths
Where continent is not null
Group by Location
order by TotalDeathCount desc

-- Let's try and break it down by continent
-- Showing contintents with the highest death count per population
Select continent,MAX(cast(Total_Deaths as int)) as TotalDeathCount
From SQLProject..CovidDeaths
Where continent is not null
Group by continent
order by TotalDeathCount desc


-- Break down the data across the entire world - not looking at continent or specific locations
--using group by so need an aggregate func so sum of new cases equals the total cases
-- new deaths is a float so we need to convert it to a integer
-- remove date and you get death percentage across the world
Select SUM(new_cases) as total_cases,SUM(cast(new_deaths as int)) as total_deaths,(SUM(cast(new_deaths as int))/SUM(new_cases))*100 as DeathPercentage
From SQLProject..CovidDeaths
where continent is not null
--Group by date
order by 1,2


-- I want to join the two data sets with location and date #
-- Looking at Total Population vs vaccinations
-- I want to do a rolling count of new vaccinations by using windows function and partition by by location. 
-- New location so new count
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,dea.date) as RollingPeopleVaccinated
From SQLProject..CovidDeaths dea
Join SQLProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


--USE CTE
-- We want to total population vs vaccinations to determine how many people are vaccinated
With PopvsVac (Continent,Location,Date,Population,New_Vaccinations,RollingPeopleVaccinated)
as
(
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,dea.date) as RollingPeopleVaccinated
From SQLProject..CovidDeaths dea
Join SQLProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)

Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac

-- TEMP TABLE - another example of how to display data
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
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,dea.date) as RollingPeopleVaccinated
From SQLProject..CovidDeaths dea
Join SQLProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

-- Creating View to store data for perhaps visualisations
Create View PercentPopulationVaccinated as 
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,dea.date) as RollingPeopleVaccinated
From SQLProject..CovidDeaths dea
Join SQLProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select * 
From PercentPopulationVaccinated