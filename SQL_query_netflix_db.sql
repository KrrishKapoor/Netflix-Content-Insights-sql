-- Netflix SQL Project

DROP TABLE IF EXISTS netflix;
CREATE TABLE netflix
(
	show_id	VARCHAR(6),
	type	VARCHAR(10),
	title	VARCHAR(150),
	director	VARCHAR(208),
	casts	VARCHAR(1000),
	country	VARCHAR(150),
	date_added	VARCHAR(50),
	release_year	INT,
	rating	VARCHAR(10),
	duration	VARCHAR(15),
	listed_in   VARCHAR(100),
	description VARCHAR(250)
);

-- Clean Data

-- Step 1: Trim whitespace from all string columns
UPDATE netflix
SET 
    type = TRIM(type),
    title = TRIM(title),
    director = TRIM(director),
    casts = TRIM(casts),
    country = TRIM(country),
    date_added = TRIM(date_added),
    rating = TRIM(rating),
    duration = TRIM(duration),
    listed_in = TRIM(listed_in),
    description = TRIM(description);

-- Step 2: Set empty `director`, `cast`, `country`, `rating` to 'Unknown'
UPDATE netflix
SET 
    director = COALESCE(director, 'Unknown'),
    casts = COALESCE(casts, 'Unknown'),
    country = COALESCE(country, 'Unknown'),
    rating = COALESCE(rating, 'Unknown');

-- Step 3: Remove clearly broken rows with NULL duration (only 3 rows)
DELETE FROM netflix
WHERE duration IS NULL;


-- Exploring the Data
SELECT * FROM netflix;

SELECT 
	COUNT(*) as total_content
FROM netflix;

SELECT
	DISTINCT type
FROM netflix;

-- 15 Business Problems & Solutions

-- 1. Count the number of Movies vs TV Shows
SELECT 
	type,
	COUNT(*) as total_content_by_type
FROM netflix
GROUP BY type;


-- 2. Find the most common rating for movies and TV shows
SELECT
	type,
	rating
FROM
(
	SELECT
		type,
		rating,
		Count(*),
		RANK() OVER(PARTITION BY type ORDER BY COUNT(*) DESC ) as Ranking
	FROM netflix
	GROUP BY 1,2
) as type_rating_ranking
WHERE
	ranking = 1;


-- 3. List all movies released in a specific year (e.g., 2020)
SELECT * FROM netflix
WHERE 
	release_year = 2020 
	AND
	type = 'Movie';


-- 4. Find the top 5 countries with the most content on Netflix
SELECT
	TRIM(UNNEST(STRING_TO_ARRAY(Country, ','))) as new_country,
	COUNT(show_id) as total_content
FROM netflix
WHERE country != 'Unknown'
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5;


-- 5. Identify the longest movie
SELECT * FROM netflix
WHERE 
	type = 'Movie'
	AND 
	duration IS NOT NULL
ORDER BY SPLIT_PART(duration, ' ', 1)::INT DESC
LIMIT 1;


-- 6. Find content added in the last 5 years
WITH latest AS (
	SELECT MAX(TO_DATE(date_added, 'Month DD, YYYY')) AS max_date
	FROM netflix
	WHERE date_added IS NOT NULL
)
SELECT * 
FROM netflix, latest
WHERE date_added IS NOT NULL
AND TO_DATE(date_added, 'Month DD, YYYY') >= (max_date - INTERVAL '5 years');


-- 7. Find all the movies/TV shows by director 'Rajiv Chilaka'!
SELECT * FROM netflix
WHERE director ILIKE '%Rajiv Chilaka%';


-- 8. List all TV shows with more than 5 seasons
SELECT * FROM netflix
WHERE 
	type ='TV Show'
	AND SPLIT_PART(duration, ' ', 1)::INT > 5;


-- 10. Count the number of content items in each genre
SELECT
	TRIM(UNNEST(STRING_TO_ARRAY(listed_in, ','))) as genre,
	COUNT(*) as Total_content
FROM netflix
GROUP BY 1
ORDER BY 2 DESC;


-- 11. How has the number of TV Shows vs. Movies changed over the years?
SELECT 
  release_year,
  COUNT(*) FILTER (WHERE type = 'Movie') AS movie_count,
  COUNT(*) FILTER (WHERE type = 'TV Show') AS tv_show_count
FROM netflix
WHERE release_year IS NOT NULL
GROUP BY release_year
ORDER BY release_year DESC;


-- 12. Top 10 Longest-running TV Shows on Netflix (by seasons)
SELECT 
  title,
  duration
FROM netflix
WHERE type = 'TV Show'
  AND duration ILIKE '%Season%'
ORDER BY SPLIT_PART(duration, ' ', 1)::INT DESC
LIMIT 10;


-- 13. How many shows or movies are made through international collaboration?
SELECT
	COUNT(*) as International_collabs
FROM netflix
WHERE country like '%,%';


-- 14. Which genres are most common in TV Shows vs. Movies?
SELECT 
  type,
  TRIM(UNNEST(STRING_TO_ARRAY(listed_in, ','))) AS genre,
  COUNT(*) AS total
FROM netflix
GROUP BY 1, 2
ORDER BY 3 DESC;


-- 15. What is the average duration of movies across different genres?
SELECT 
  TRIM(UNNEST(STRING_TO_ARRAY(listed_in, ','))) AS genre,
  ROUND(AVG(SPLIT_PART(duration, ' ', 1)::INT), 2) AS avg_duration_minutes
FROM netflix
WHERE type = 'Movie'
  AND duration ILIKE '%min%'
  AND duration IS NOT NULL
GROUP BY genre
ORDER BY avg_duration_minutes DESC;


-- 16. For each year, calculate the average number of content items released
-- in India, and return the top 5 years with the highest average.
WITH indian_content AS(
	SELECT
		TO_CHAR(TO_DATE(date_added, 'Month DD, YYYY'), 'YYYY')::INT AS year_added
	FROM netflix
	WHERE country ILIKE '%India%'
	AND date_added IS NOT NULL
),
total_count AS (
	SELECT COUNT(*) AS total_indian_content
	FROM indian_content
),
yearly_counts AS (
	SELECT
		year_added,
		COUNT(*) AS yearly_count
	FROM indian_content
	GROUP BY year_added
)
SELECT
	y.year_added,
	y.yearly_count,
	ROUND(100.0 * y.yearly_count / t.total_indian_content, 2) AS percentage_of_total
FROm
	yearly_counts y, total_count t
ORDER BY 3 DESC
LIMIT 5;


-- 17. List all movies that are documentaries
SELECT * FROM netflix
WHERE
	type = 'Movie'
	AND listed_in ILIKE '%Documentaries%';


-- 18. Which month sees the most content being added to Netflix across all years?
SELECT
	TO_CHAR(TO_DATE(date_added, 'Month DD, YYYY'), 'Month') AS month,
	COUNT(*) AS total_added
FROM netflix
WHERE date_added IS NOT NULL
GROUP BY 1
ORDER BY 2 DESC;


-- 19. Find how many movies actor 'Adam Sandler' appeared in last 10 years!
SELECT * FROM netflix
WHERE 
	casts ILIKE '%Adam Sandler%'
	AND type = 'Movie'
	AND release_year > EXTRACT(YEAR FROM CURRENT_DATE) - 10;


-- 20. Find the top 10 actors who have appeared in the highest number of movies produced in Canada.
SELECT 
	TRIM(UNNEST(STRING_TO_ARRAY(casts, ','))) AS actor,
	COUNT(*) as total_count
FROM 
	netflix
WHERE 
	type = 'Movie'
	AND country ILIKE '%Canada%'
	AND casts != 'Unknown'
GROUP BY 1
ORDER BY 2 DESC
LIMIT 10;


-- 21. Categorize the content based on the presence of the keywords 'kill' and 'violence' in 
-- the description field. Label content containing these keywords as 'Intense' and all other 
-- content as 'Light'. Count how many items fall into each category.
SELECT
	CASE
		WHEN description ILIKE '%kill%'
		OR description ILIKE '%violence%'
		OR description ILIKE '%drug%' THEN 'Intense'
		ELSE 'Light'
	END AS content_label,
	Count(*) AS total_times
FROM netflix
GROUP BY Content_label;
