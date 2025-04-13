-- Netflix TV Shows and Movies Analysis Project --

-- Create table
DROP TABLE IF EXISTS netflix;
CREATE TABLE netflix
(
	show_id	VARCHAR(5),
	type    VARCHAR(10),
	title	VARCHAR(250),
	director VARCHAR(550),
	casts	VARCHAR(1050),
	country	VARCHAR(550),
	date_added	DATE,
	release_year	INT,
	rating	VARCHAR(15),
	duration	VARCHAR(15),
	listed_in	VARCHAR(250),
	description VARCHAR(550)
)

-- Data Exploration --

SELECT * FROM netflix;

SELECT 
	COUNT(*) as total_content
FROM netflix;

SELECT DISTINCT type
FROM netflix;

--

SELECT * FROM netflix
WHERE show_id IS NULL

SELECT * FROM netflix
WHERE type IS NULL

SELECT * FROM netflix
WHERE title IS NULL

SELECT * FROM netflix
WHERE director IS NULL --

SELECT * FROM netflix
WHERE casts IS NULL --

SELECT * FROM netflix
WHERE country IS NULL --

SELECT * FROM netflix
WHERE date_added IS NULL

SELECT * FROM netflix
WHERE release_year IS NULL

SELECT * FROM netflix
WHERE rating IS NULL

SELECT * FROM netflix
WHERE duration IS NULL

SELECT * FROM netflix
WHERE listed_in IS NULL

SELECT * FROM netflix
WHERE description IS NULL


-- Business Problems --

-- 1. Count the number of Movies vs TV Shows
SELECT 
	type,
	COUNT(*) as total_content
FROM netflix
GROUP BY type

-- 2. Find the most common rating for movies and TV shows
SELECT 
	type,
	rating,
	COUNT(*)
FROM netflix
GROUP BY 1, 2
ORDER BY 1, 3 DESC

--
WITH RatingCounts AS (
    SELECT 
        type,
        rating,
        COUNT(*) AS rating_count
    FROM netflix
    GROUP BY type, rating
),
RankedRatings AS (
    SELECT 
        type,
        rating,
        rating_count,
        RANK() OVER (PARTITION BY type ORDER BY rating_count DESC) AS rank
    FROM RatingCounts
)
SELECT 
    type,
    rating AS most_frequent_rating
FROM RankedRatings
WHERE rank = 1;

-- 3. List all movies released in a specific year (e.g., 2020)
SELECT * 
FROM netflix
WHERE type = 'Movie' AND release_year = 2020

--
SELECT type, release_year
FROM netflix
WHERE type = 'Movie' AND release_year = 2020

-- 4. Find the top 5 countries with the most content on Netflix
SELECT country, COUNT(show_id) as total_content
FROM netflix
GROUP BY 1

--
SELECT 
	-- convierte cada valor de la columna country en un array y después separa cada país con unnest
	UNNEST(STRING_TO_ARRAY(country, ',')) as new_country 
FROM netflix

--
SELECT 
	UNNEST(STRING_TO_ARRAY(country, ',')) as new_country, 
	COUNT(show_id) as total_content
FROM netflix
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5

--
SELECT 
	TRIM(UNNEST(STRING_TO_ARRAY(country, ','))) as new_country, 
	COUNT(show_id) as total_content
FROM netflix
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5

-- 5. Identify the longest movie
SELECT 
    title,
    duration,
    CAST(SPLIT_PART(duration, ' ', 1) AS INTEGER) AS minutes
FROM netflix
WHERE type = 'Movie'
     AND duration IS NOT NULL
ORDER BY minutes DESC
LIMIT 1;

-- 6. Find content added in the last 5 years
SELECT 
	DISTINCT EXTRACT(YEAR FROM date_added) as year
FROM netflix
ORDER BY year;

--
SELECT title, date_added
FROM netflix
WHERE
	EXTRACT(YEAR FROM date_added) IN
	(
	SELECT
		DISTINCT EXTRACT(YEAR FROM date_added)
		FROM netflix
		ORDER BY EXTRACT(YEAR FROM date_added) DESC
		LIMIT 5
	);

-- 7. Find all the movies/TV shows by director 'Rajiv Chilaka'
SELECT * FROM netflix
WHERE director ILIKE '%Rajiv Chilaka%'

-- otra forma
SELECT *
FROM
(

	SELECT 
		*,
		UNNEST(STRING_TO_ARRAY(director, ',')) as director_name
	FROM 
	netflix
)
WHERE 
	director_name = 'Rajiv Chilaka'

-- 8. List all TV shows with more than 5 seasons
SELECT 
	*,
	SPLIT_PART(duration, ' ', 1) as seasons
FROM netflix
WHERE 
	type = 'TV Show'

--
SELECT *
FROM netflix
WHERE 
	type = 'TV Show'
	AND
	SPLIT_PART(duration, ' ', 1)::INT > 5

-- 9. Count the number of content items in each genre
SELECT 
	listed_in,
	show_id,
	UNNEST(STRING_TO_ARRAY(listed_in, ',')) 
FROM netflix

--
SELECT 
	TRIM(UNNEST(STRING_TO_ARRAY(listed_in, ','))) as genre,
	COUNT(show_id) as total_content
FROM netflix
GROUP BY 1
ORDER BY total_content DESC

-- 10. Find each year and the average numbers of content release by United States on netflix. 
-- return top 5 year with highest avg content release 
SELECT 
	country,
	release_year,
	COUNT(*)
FROM netflix
WHERE country = 'United States'
GROUP BY 1, 2

--
SELECT 
	country,
	release_year,
	COUNT(show_id) as total_release,
	ROUND(
		COUNT(show_id)::numeric/(SELECT COUNT(show_id) FROM netflix WHERE country = 'United States')::numeric * 100 
		,2)as avg_release
FROM netflix
WHERE country = 'United States' 
GROUP BY country, 2
ORDER BY avg_release DESC 
LIMIT 5

-- 11. List all movies that are documentaries
SELECT * FROM netflix
WHERE 
	listed_in ILIKE '%documentaries%'

-- 12. Find how many movies actor 'Ryan Reynolds' appeared in last 10 years!
SELECT * FROM netflix
WHERE 
	casts LIKE '%Ryan Reynolds%'
	AND 
	release_year > EXTRACT(YEAR FROM CURRENT_DATE) - 10


-- 13. Find the top 10 actors who have appeared in the highest number of movies produced in United Kingdom.
SELECT 
	TRIM(UNNEST(STRING_TO_ARRAY(casts, ','))) AS actors,
	COUNT(*) AS total_content
FROM netflix
WHERE country LIKE '%United Kingdom%'
GROUP BY 1
ORDER BY 2 DESC
LIMIT 10

-- 14. Categorize the content based on the presence of the keywords 'kill' and 'violence' in 
--the description field. Label content containing these keywords as 'Bad' and all other 
--content as 'Good'. Count how many items fall into each category.
WITH new_table
AS
(
SELECT 
	*, 
	CASE 
	WHEN 
		description ILIKE '%kill%' OR
		description ILIKE '%violence%' THEN 'Bad Content'
		ELSE 'Good Content'
	END category
FROM netflix
)
SELECT
	category,
	COUNT(*) as total_content
FROM new_table
GROUP BY 1
WHERE 
	description ILIKE '%kill%'
	OR
	description ILIKE '%violence%'













	
	


























