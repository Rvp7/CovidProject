---Deathrates in diffrent countries
SELECT Location,date,total_cases,total_deaths,ROUND((total_deaths/total_cases)*100.00,2) AS DeathRate
FROM [dbo].[CovidDeaths]
ORDER BY 1,2

---DeathRate in the USA
SELECT Location,date,total_cases,total_deaths,ROUND((total_deaths/total_cases)*100.00,2) AS DeathRate
FROM [dbo].[CovidDeaths]
WHERE Location LIKE '%states'
ORDER BY 1,2

---Active Covid cases per population
SELECT Location,date,population,total_cases,ROUND((total_cases/population)*100.00,2) AS ActiveCasesRate
FROM [dbo].[CovidDeaths]
WHERE Location LIKE '%states'
ORDER BY 1,2

---Countries with highest infection ratio and highest deaths
SELECT Location,population,MAX(total_cases) AS TotalCases, ,MAX(ROUND((total_cases/population)*100.00,2)) AS InfectionRatio 
FROM [dbo].[CovidDeaths]
GROUP BY Location,population
ORDER BY 5 DESC

---Countries with highest deaths
SELECT Location AS Country, MAX(CAST (total_deaths as int)) AS TotalDeaths
FROM [dbo].[CovidDeaths]
WHERE continent IS NOT NULL
GROUP BY Location,population
ORDER BY 2 DESC

---Deaths by Continent
SELECT Location,Max(CAST(total_deaths AS int)) AS TotalDeaths
FROM CovidDeaths
WHERE continent IS NULL
GROUP BY location
ORDER BY TotalDeaths DESC

---Percentage vaccination per population
WITH CTE AS
(SELECT d.continent,d.location,d.date,d.population,v.new_vaccinations,
		SUM(CONVERT(bigint,v.new_vaccinations))OVER(PARTITION BY d.location ORDER BY d.location,d.date) AS Running_total
FROM CovidDeaths d JOIN CovidVaccinations v
	ON d.location=v.location AND d.date=v.date
WHERE d.continent IS NOT NULL AND v.new_vaccinations IS NOT NULL
--ORDER BY 2,3
)
SELECT *,(Running_total*100/population) AS percentVaccination
FROM CTE
---WHERE location='India'
ORDER BY 2,3


---Using Table Variable 
DECLARE @PercentVaccination TABLE
(continent nvarchar(100),
location nvarchar(100),
date date,
population int,
NewVaccination int,
Running_total numeric)
INSERT INTO @PercentVaccination
SELECT d.continent,d.location,d.date,d.population,v.new_vaccinations,
		SUM(CONVERT(bigint,v.new_vaccinations))OVER(PARTITION BY d.location ORDER BY d.location,d.date) AS Running_total
FROM CovidDeaths d JOIN CovidVaccinations v
	ON d.location=v.location AND d.date=v.date
WHERE d.continent IS NOT NULL AND v.new_vaccinations IS NOT NULL

SELECT *,(Running_total/population)*100.00 AS percentVaccination 
FROM @PercentVaccination
ORDER BY 2,3
GO


---Creating a view for later analysis and visualization
CREATE VIEW PercentVaccination AS
SELECT d.continent,d.location,d.date,d.population,v.new_vaccinations,
		SUM(CONVERT(bigint,v.new_vaccinations))OVER(PARTITION BY d.location ORDER BY d.location,d.date) AS Running_total
FROM CovidDeaths d JOIN CovidVaccinations v
	ON d.location=v.location AND d.date=v.date
WHERE d.continent IS NOT NULL AND v.new_vaccinations IS NOT NULL