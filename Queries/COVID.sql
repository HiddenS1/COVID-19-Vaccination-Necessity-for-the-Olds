DELETE FROM deaths
WHERE date > '2022-07-01'

/* Table 1: deaths */
/* Find 5 highest death rate countries */
WITH CTE AS
(
    SELECT distinct location, DATE_FORMAT(date, '%Y-%m') AS newdate, 
    MAX(total_deaths/population)*100 as Death_Rate
    FROM deaths
    WHERE DATE_FORMAT(date, '%Y-%m')='2022-07'
    GROUP BY location, newdate
    ORDER BY Death_Rate DESC
    LIMIT 5    
)

Select distinct location, DATE_FORMAT(date, '%Y-%m') AS newdate, 
MAX(total_deaths/population)*100 as Death_Rate
FROM deaths
WHERE location in 
(
    SELECT location
    FROM CTE
)
GROUP BY location, newdate
ORDER BY newdate DESC

/* Death Rate */
Select distinct location, DATE_FORMAT(date, '%Y-%m') AS newdate, 
MAX(total_deaths/population)*100 as Death_Rate
FROM deaths
WHERE location in ('China', 'United States', 'United Kingdom', 'Japan')
GROUP BY location, newdate
ORDER BY newdate ASC

/* Infection Rate */
Select distinct location, DATE_FORMAT(date, '%Y-%m') AS newdate, 
MAX(total_cases/population)*100 as Growing_Rate
FROM deaths
WHERE location in ('China', 'United States', 'United Kingdom', 'Japan')
GROUP BY location, newdate
ORDER BY newdate ASC

/* Death Rate Among Infection */
Select distinct location, DATE_FORMAT(date, '%Y-%m') AS newdate, 
MAX(total_deaths/total_cases)*100 as Infection_Death_Rate
FROM deaths
WHERE location in ('China', 'United States', 'United Kingdom', 'Japan')
GROUP BY location, newdate
ORDER BY newdate ASC

/* Visualization 1: Current Death Count by Continent */
SELECT sum(total_deaths) as Death_Count, continent
FROM deaths
WHERE DATE_FORMAT(date, '%Y-%m-%d') = '2022-07-01'
AND continent is not null
GROUP BY continent

/* Table 2: vac */
DELETE FROM vac
WHERE date < '2020-12-01'

/* Visualization 2: Vaccination Rate */
WITH CTE2 AS
(
    SELECT distinct location, DATE_FORMAT(date, '%Y-%m') AS newdate, 
    MAX(people_vaccinated) as Vaccination_Count
    FROM vac 
    GROUP BY location, newdate
    ORDER BY newdate ASC
)

SELECT * FROM
(SELECT distinct a.*, b.population, 
round(a.Vaccination_Count*100/b.population, 2) as Vaccination_Rate
FROM CTE2 a LEFT JOIN deaths b 
ON a.location = b.location
WHERE a.newdate = '2022-07') r
WHERE Vaccination_Rate > 0

SELECT * FROM
(SELECT distinct a.*, b.population, 
round(a.Vaccination_Count*100/b.population, 2) as Vaccination_Rate
FROM CTE2 a LEFT JOIN deaths b 
ON a.location = b.location) r
WHERE Vaccination_Rate > 0


/* Table 3: age */
/* Visualization 3: Vaccination Status VS Death Rate */
DELETE FROM age
WHERE month > '2022-08-01'

SELECT distinct mmwr_week as Week_Date, 
round(SUM(crude_vax_ir), 2) as Vaccinated,
round(SUM(crude_unvax_ir), 2) as Unvaccinated
FROM age
WHERE outcome='death'
AND age_group!='all_ages'
AND vaccination_status='vaccinated'
GROUP BY mmwr_week

SELECT distinct mmwr_week as Week_Date,
round(SUM(crude_vax_ir), 2) as Vaccinated,
round(SUM(crude_unvax_ir), 2) as Unvaccinated
FROM age
WHERE outcome='death'
AND age_group in ('50-64','65-79','80+')
AND vaccination_status='vaccinated'
GROUP BY mmwr_week

/* Visualization 4: Death Proportion of the Old */
WITH CTE3 AS
(
    SELECT age_group, crude_unvax_ir+crude_vax_ir as Death_Count, mmwr_week, 
    CASE WHEN age_group in ('50-64','65-79','80+') THEN 1 ELSE 0 END AS Old
    FROM age
    WHERE outcome='death'
    AND vaccination_status='vaccinated'
    AND age_group != 'all_ages'
)

SELECT SUM(Death_Count) as Total_Death,
SUM(Death_Count*Old) as Old_Death,
SUM(Death_Count*Old)*100/SUM(Death_Count) as Proportion
FROM CTE3