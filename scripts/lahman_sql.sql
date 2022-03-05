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
GROUP BY  positions, yearid, po;

select *
FROM teams
-- 5.Find the average number of strikeouts per game by decade since 1920. Round the numbers you report to 2 decimal places. Do the same for home runs per game. Do you see any trends?
SELECT ROUND(AVG(SO), 2) AS Strike_out, yearid
FROM teams
WHERE DATE_PART('decade', yearid) >= 1920;

-- 6.Find the player who had the most success stealing bases in 2016, where success is measured as the percentage of stolen base attempts which are successful. (A stolen base attempt results either in a stolen base or being caught stealing.) Consider only players who attempted at least 20 stolen bases.

-- 7. From 1970 – 2016, what is the largest number of wins for a team that did not win the world series? What is the smallest number of wins for a team that did win the world series? Doing this will probably result in an unusually small number of wins for a world series champion – determine why this is the case. Then redo your query, excluding the problem year. How often from 1970 – 2016 was it the case that a team with the most wins also won the world series? What percentage of the time?

-- 8. Using the attendance figures from the homegames table, find the teams and parks which had the top 5 average attendance per game in 2016 (where average attendance is defined as total attendance divided by number of games). Only consider parks where there were at least 10 games played. Report the park name, team name, and average attendance. Repeat for the lowest 5 average attendance.

-- 9. Which managers have won the TSN Manager of the Year award in both the National League (NL) and the American League (AL)? Give their full name and the teams that they were managing when they won the award.

-- 10. Find all players who hit their career highest number of home runs in 2016. Consider only players who have played in the league for at least 10 years, and who hit at least one home run in 2016. Report the players' first and last names and the number of home runs they hit in 2016.