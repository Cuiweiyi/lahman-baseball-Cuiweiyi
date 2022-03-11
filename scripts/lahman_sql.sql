SELECT *
FROM teams
-- 1. What range of years for baseball games played does the provided database cover?
-- SELECT MIN(yearid) AS first_year, MAX(yearid) AS last_year_on_range
-- FROM batting
-- GROUP BY yearid
-- ORDER BY first_year, last_year_on_range DESC;
SELECT yearid
FROM batting
ORDER BY yearid;
--Answer: 1871 through 2016. 146 years

-- 2. Find the name and height of the shortest player in the database. How many games did he play in? What is the name of the team for which he played?
SELECT namefirst, namelast, height, t.name, COUNT(t.g) AS num_games
FROM people AS p
LEFT JOIN appearances AS a
ON p.playerid = a.playerid
LEFT JOIN teams AS t
ON a.teamid = t.teamid
GROUP BY namefirst, namelast, height, t.name
ORDER BY height;
--Answer: Eddie Gaedel was 43' and played for the St.Louis Browns in 52 games. 

-- 3. Find all players in the database who played at Vanderbilt University. Create a list showing each player’s first and last names as well as the total salary they earned in the major leagues. Sort this list in descending order by the total salary earned. Which Vanderbilt player earned the most money in the majors?
SELECT DISTINCT(CONCAT(p.namefirst, ' ', p.namelast)) AS fullname, SUM(sa.salary)
FROM people AS p
INNER JOIN salaries AS sa
ON p.playerid = sa.playerid
INNER JOIN collegeplaying
ON p.playerid = collegeplaying.playerid
INNER JOIN schools AS s
ON collegeplaying.schoolid = s.schoolid
WHERE s.schoolname LIKE 'Vanderbilt%'
GROUP BY fullname
ORDER BY SUM(sa.salary) DESC;
--Answer: David Price made the most, with nearly a quarter billion dollars

-- 4. Using the fielding table, group players into three groups based on their position: label players with position OF as "Outfield", those with position "SS", "1B", "2B", and "3B" as "Infield", and those with position "P" or "C" as "Battery". Determine the number of putouts made by each of these three groups in 2016.
SELECT yearid, 
CASE WHEN pos = 'SS' OR pos = '1B' OR pos = '2B' OR pos = '3B' THEN 'Infield'
WHEN pos = 'P' OR pos = 'C' THEN 'Battery'
ELSE 'Outfield'
END AS positions,
SUM(po) AS putout
FROM fielding
WHERE yearid = 2016
GROUP BY  positions, yearid
ORDER BY putout;

/*Answer:   "Outfield"	29560
			"Battery"	41424
			"Infield"	58934*/
'select *
FROM teams'
-- 5.Find the average number of strikeouts per game by decade since 1920. Round the numbers you report to 2 decimal places. Do the same for home runs per game. Do you see any trends?
-- ORIGINAL CODE THAT WOULD NOT WORK. 我就笨蛋的很
--WITH Strikes AS
-- (SELECT CONCAT(LEFT(CAST(yearid AS text), 3), '0s')AS decade,
--  ROUND(AVG(hr)/SUM(g), 2) AS Strike_out, ROUND(AVG(HR)/SUM(g), 2) as Homers, 
--  SUM(hr) AS num_hr,
--  SUM(g) AS games
-- FROM teams
-- WHERE yearid >= 1920
-- GROUP BY decade),

-- Home AS
-- (SELECT CONCAT(LEFT(CAST(yearid AS text), 3), '0s')AS decade,
--  ROUND(AVG(HR)/SUM(g), 2) as Homers, SUM(hr) AS num_hr, SUM(g) AS games
-- FROM teams
-- WHERE yearid >= 1920
-- GROUP BY decade
-- ORDER BY decade)

-- SELECT decade, strike_out
-- FROM strikes
-- UNION
-- SELECT CAST(homers AS numeric), CAST(num_hr AS numeric)
-- FROM home
-- GROUP BY decade, num_hr, homers
-- ORDER BY decade

SELECT 
	ROUND(AVG(so),2) AS 我笨死了,
	ROUND(AVG(hr),2) AS 加油,
	/*CASE WHEN yearid BETWEEN 1920 AND 1929 THEN '1920s'
		 WHEN yearid BETWEEN 1930 AND 1939 THEN '1930s'
		 WHEN yearid BETWEEN 1940 AND 1949 THEN '1940s'
		 WHEN yearid BETWEEN 1950 AND 1959 THEN '1950s'
		 WHEN yearid BETWEEN 1960 AND 1969 THEN '1960s'
		 WHEN yearid BETWEEN 1970 AND 1979 THEN '1970s'
		 WHEN yearid BETWEEN 1980 AND 1989 THEN '1980s'
		 WHEN yearid BETWEEN 1990 AND 1999 THEN '1990s'
		 WHEN yearid BETWEEN 2000 AND 2009 THEN '2000s'
		 WHEN yearid BETWEEN 2010 AND 2019 THEN '2010s' 
		 END AS decade*/
 CONCAT(LEFT(CAST(yearid AS text), 3), '0s') AS decade
FROM teams
WHERE yearid >= 1920
GROUP BY 
	decade
ORDER BY 
	decade;

-- 6.Find the player who had the most success stealing bases in 2016, where success is measured as the percentage of stolen base attempts which are successful. (A stolen base attempt results either in a stolen base or being caught stealing.) Consider only players who attempted at least 20 stolen bases.
SELECT p.namefirst,
p.namelast, 
b.yearid,
sb AS stolen_bases_nm,
cs,
ROUND((CAST(sb AS numeric) / (CAST(sb AS numeric) + CAST(cs AS numeric))), 2) AS success_perc
FROM batting AS b
LEFT JOIN people AS p
ON b.playerid = p.playerid
WHERE yearid = 2016
GROUP BY  p.namefirst, p.namelast, b.yearid, sb, cs
HAVING sb + cs >= 20
ORDER BY success_perc DESC;
--Answer: Chris Owings had a 91% success rate.


-- 7. From 1970 – 2016, what is the largest number of wins for a team that did not win the world series? What is the smallest number of wins for a team that did win the world series? Doing this will probably result in an unusually small number of wins for a world series champion – determine why this is the case. Then redo your query, excluding the problem year. How often from 1970 – 2016 was it the case that a team with the most wins also won the world series? What percentage of the time?
SELECT DISTINCT name, yearid, wswin, MAX(w) 
FROM teams
WHERE yearid >= 1970 AND wswin LIKE 'N'
group by DISTINCT name, yearid, wswin
ORDER BY MAX(w) DESC;
--Answer: Seattle Mariners had 7116 wins and did not win the world series
SELECT DISTINCT name, yearid, wswin, w 
FROM teams
WHERE yearid >= 1970 AND wswin LIKE 'Y'
ORDER BY w;
--Answer: Los Angeles Dogers went to the world series and won with only 63 years.
WITH winner AS
(SELECT MAX(w) AS win_win, yearid
FROM teams
WHERE wswin = 'Y'
GROUP BY yearid),
loser AS
(SELECT MAX(w) AS win_lose, yearid
FROM teams
WHERE wswin = 'N'
GROUP BY yearid)
SELECT 
ROUND(AVG(CASE WHEN win_win >= win_lose THEN 1 
		  ELSE 0 END)*100,1) AS win_percent
 FROM winner
 INNER JOIN loser
 ON winner.yearid = loser.yearid
 ORDER BY win_percent DESC;
--Answer: 43.6%

-- 8. Using the attendance figures from the homegames table, find the teams and parks which had the top 5 average attendance per game in 2016 (where average attendance is defined as total attendance divided by number of games). Only consider parks where there were at least 10 games played. Report the park name, team name, and average attendance. Repeat for the lowest 5 average attendance.
SELECT DISTINCT t.name, parks.park_name, AVG(h.attendance)/SUM(h.games) AS total_attendance 
FROM homegames AS h
LEFT JOIN teams AS t
ON h.team = t.teamid
LEFT JOIN parks
ON parks.park = h.park
WHERE year = 2016 AND 9<
(SELECT COUNT(park)
FROM parks)
GROUP BY t.name, parks.park_name
ORDER BY total_attendance DESC
LIMIT 5; 
/*Answer: TOP 5 WERE"St. Louis Perfectos" at "Busch Stadium III"
"Cleveland Bronchos" at "Progressive Field"
"Cleveland Blues" at "Progressive Field"
"Philadelphia Blue Jays" at "Citizens Bank Park"
"Houston Colt .45's" at "Minute Maid Park"*/

SELECT DISTINCT t.name, parks.park_name, AVG(h.attendance)/SUM(h.games) AS total_attendance 
FROM homegames AS h
LEFT JOIN teams AS t
ON h.team = t.teamid
LEFT JOIN parks
ON parks.park = h.park
WHERE year = 2016 AND 9<
(SELECT COUNT(park)
FROM parks)
GROUP BY t.name, parks.park_name
ORDER BY total_attendance
LIMIT 5; 
/* Lowest attendance was for "Chicago White Sox" at "U.S. Cellular Field"
"Philadelphia Phillies" at	"Citizens Bank Park"
"Cleveland Indians"	at "Progressive Field"
"Cincinnati Reds" at "Great American Ballpark"
"Pittsburgh Pirates" at "PNC Park"*/
select *
from awardsmanagers
-- 9. Which managers have won the TSN Manager of the Year award in both the National League (NL) and the American League (AL)? Give their full name and the teams that they were managing when they won the award.
WITH Lwinners AS (
SELECT a.yearid, CONCAT(p.namefirst, ' ', p.namelast) AS fullname, a.lgid, a.playerid, awardid
FROM awardsmanagers AS a
LEFT JOIN people AS p
	ON p.playerid = a.playerid
WHERE lgid = 'AL' AND awardid = 'TSN Manager of the Year'
GROUP BY a.yearid, fullname, a.lgid, a.playerid, awardid)

wolf_fang AS(
SELECT CONCAT(p.namefirst, ' ', p.namelast) AS fullname, a.lgid, a.playerid, awardid
FROM awardsmanagers AS a
LEFT JOIN people AS p
USING (playerid)
)

SELECT COALESCE(fullname) AS full_name, lwinners.awardid, lwinners.lgid, t.name
FROM lwinners
JOIN people AS b
ON lwinners.playerid = b.playerid
JOIN managershalf
ON b.playerid = managershalf.playerid 
LEFT JOIN teams AS t
ON managershalf.teamid = t.teamid
WHERE awardid = 'TSN Manager of the Year'
GROUP BY full_name, t.name, lwinners.lgid, awardid 
ORDER BY Full_name;
--Answer: Tony LaRussa for the Chicago White Sox and Bobby Cox for the Atlanta Braves

-- with NL as (
-- select *
-- from awardsmanagers
-- where lgid = 'NL'),
-- AL as (
-- select *
-- from awardsmanagers
-- where lgid = 'AL')
-- select DISTINCT(CONCAT(p.namefirst, ' ', p.namelast)), NL.playerid,
-- NL.lgid, m.yearid,
-- AL.lgid
-- from NL
-- inner join AL
-- on NL.playerid = AL.playerid
-- left join managers as m
-- on NL.playerid = m.playerid
-- left join people as p
--  ON p.playerid =nl.playerid
-- where NL.awardid ilike '%TSN Manager%'
-- and AL.awardid ilike '%TSN Manager%'

-- 10. Find all players who hit their career highest number of home runs in 2016. Consider only players who have played in the league for at least 10 years, and who hit at least one home run in 2016. Report the players' first and last names and the number of home runs they hit in 2016.
WITH highs AS (
SELECT DISTINCT(CONCAT(p.namefirst, ' ', p.namelast)) AS fullname,  
b.hr, 
b.yearid
FROM batting AS b
JOIN people AS p
ON p.playerid = b.playerid
WHERE DATE_PART('year', CAST(debut AS DATE)) = 2006
GROUP BY ROLLUP(fullname, yearid)),

SELECT
DISTINCT(CONCAT(namefirst, ' ', namelast)) AS full_name,  
MAX(hr) AS homers, AVG(hr) AS avg_home,
yearid
FROM highs
WHERE highs.yearid = 2016 AND highs.hr > 1 AND homers > avg_home
GROUP BY fullname, yearid
ORDER BY max_homers DESC;

SELECT debut
FROM people
--CTE from PHIL
-- WITH winner AS 
-- (SELECT MAX(w) AS winnerwins,
--  yearid
--  FROM teams
--  WHERE wswin = 'y'
--  GROUP BY yearid), 
--  loser AS (SELECT MAX(w) AS loserwins,
-- yearid
-- FROM teams
-- WHERE wswin = 'N'
-- GROUP BY yearid)
-- SELECT ROUND(AVG(CASE WHEN winnerwins >= loserwins THEN 1
-- 				ELSE 0 END)*100,1) AS winpct
-- FROM winner
-- INNER JOIN loser
-- ON winner.yearid = loser.yearid


--2nd one from PHIL
-- with NL as (
-- select *
-- from awardsmanagers
-- where lgid = 'NL'),
-- AL as (
-- select *
-- from awardsmanagers
-- where lgid = 'AL')
-- select DISTINCT(CONCAT(p.namefirst, ' ', p.namelast)), NL.playerid,
-- NL.lgid,
-- AL.lgid
-- from NL
-- inner join AL
-- on NL.playerid = AL.playerid
-- left join managers as m
-- on NL.playerid = m.playerid
-- left join people as p
--  ON p.playerid =nl.playerid
-- where NL.awardid ilike '%TSN Manager%'
-- and AL.awardid ilike '%TSN Manager%'

SELECT DISTINCT(CONCAT(p.namefirst, ' ', p.namelast)) AS fullname,  
b.hr, 
b.yearid
FROM batting AS b
JOIN people AS p
ON p.playerid = b.playerid
WHERE DATE_PART('year', CAST(debut AS DATE)) = 2006
GROUP BY ROLLUP(fullname, yearid)

-- from Jasmine Drumright
-- -- -- -- -- SELECT
-- -- -- -- -- 	DISTINCT yearid,
-- -- -- -- -- 	name,
-- -- -- -- -- 	wswin,
-- -- -- -- -- 	wins,
-- -- -- -- -- 	mostwins
-- -- -- -- -- FROM(
-- -- -- -- -- 	SELECT
-- -- -- -- -- 		DISTINCT yearid,
 		name,
wswin,
 		w AS wins,
		MAX(w) OVER(PARTITION BY yearid) AS mostwins
 	FROM teams
 	WHERE yearid >= 1970
 	ORDER BY yearid DESC) AS subquery
 WHERE wswin LIKE 'Y'
AND wins = mostwins
 ORDER BY yearid DESC;
