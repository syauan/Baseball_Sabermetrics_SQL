-- Before running drop any existing views
DROP VIEW IF EXISTS q0;
DROP VIEW IF EXISTS q1i;
DROP VIEW IF EXISTS q1ii;
DROP VIEW IF EXISTS q1iii;
DROP VIEW IF EXISTS q1iv;
DROP VIEW IF EXISTS q2i;
DROP VIEW IF EXISTS q2ii;
DROP VIEW IF EXISTS q2iii;
DROP VIEW IF EXISTS q3i;
DROP VIEW IF EXISTS q3ii;
DROP VIEW IF EXISTS q3iii;
DROP VIEW IF EXISTS q4i;
DROP VIEW IF EXISTS q4ii;
DROP VIEW IF EXISTS q4iii;
DROP VIEW IF EXISTS q4iv;
DROP VIEW IF EXISTS q4v;

-- Question 0
CREATE VIEW q0(era)
AS
  SELECT MAX(era)
  FROM pitching
;

-- Question 1i
CREATE VIEW q1i(namefirst, namelast, birthyear)
AS
  SELECT namefirst, namelast, birthyear
  FROM people
  WHERE weight > 300
;

-- Question 1ii
CREATE VIEW q1ii(namefirst, namelast, birthyear)
AS
  SELECT namefirst, namelast, birthyear
  FROM people
  WHERE namefirst LIKE "% %"
  ORDER BY namefirst, namelast
;

-- Question 1iii
CREATE VIEW q1iii(birthyear, avgheight, count)
AS
  SELECT birthyear, AVG(height), COUNT(*)
  FROM people
  GROUP BY birthyear
  ORDER BY birthyear
;

-- Question 1iv
CREATE VIEW q1iv(birthyear, avgheight, count)
AS
  SELECT birthyear, AVG(height), COUNT(*)
  FROM people
  GROUP BY birthyear
  HAVING AVG(height) > 70
  ORDER BY birthyear
;

-- Question 2i
CREATE VIEW q2i(namefirst, namelast, playerid, yearid)
AS
  SELECT p.namefirst, p.namelast, p.playerid, h.yearid
  FROM people p INNER JOIN HallofFame h ON p.playerID = h.playerID
  WHERE inducted == "Y"
  ORDER BY h.yearid DESC, p.playerid
;

-- Question 2ii
CREATE VIEW q2ii(namefirst, namelast, playerid, schoolid, yearid)
AS
  SELECT qc.namefirst, qc.namelast, qc.playerid, s.schoolid, qc.yearid
  FROM schools s INNER JOIN
    (SELECT q.namefirst, q.namelast, q.playerid, q.yearid, c.schoolid
     FROM q2i q INNER JOIN collegeplaying c ON q.playerid = c.playerid)
  AS qc ON s.schoolid = qc.schoolid
  WHERE s.schoolstate == "CA"
  ORDER BY yearid DESC, s.schoolid, qc.playerid
;

-- Question 2iii
CREATE VIEW q2iii(playerid, namefirst, namelast, schoolid)
AS
  SELECT q.playerid, q.namefirst, q.namelast, cs.schoolid
  FROM q2i q LEFT JOIN
    (SELECT c.playerid, s.schoolid
     FROM schools s INNER JOIN collegeplaying c ON s.schoolid = c.schoolid) AS cs
  ON q.playerid = cs.playerid
  ORDER BY q.playerid DESC, cs.schoolid
;

-- Question 3i
CREATE VIEW q3i(playerid, namefirst, namelast, yearid, slg)
AS
  SELECT p.playerid, p.namefirst, p.namelast, b.yearid,
         (((b.H - b.H2B - b.H3B - b.HR) + (2 * b.H2B) +
         (3 * b.H3B) + (4 * b.HR)) / CAST(b.AB AS float)) as slg
  FROM people p INNER JOIN batting b ON p.playerid = b.playerid
  WHERE b.AB > 50
  ORDER BY slg DESC, b.yearid, p.playerid
  LIMIT 10
;

-- Question 3ii
CREATE VIEW q3ii(playerid, namefirst, namelast, lslg)
AS
  SELECT p.playerid, p.namefirst, p.namelast,
         (((b.h1 - b.h2 - b.h3 - b.h4) + (2 * b.h2) +
         (3 * b.h3) + (4 * b.h4)) / CAST(b.ab1 AS float)) as lslg
  FROM people p INNER JOIN
    (SELECT playerid, SUM(H) as h1, SUM(H2B) as h2,
            SUM(H3B) as h3, SUM(HR) as h4, SUM(AB) as ab1
    FROM batting
    GROUP BY playerid) as b ON p.playerid = b.playerid
  WHERE ab1 > 50
  ORDER BY lslg DESC, p.playerid
  LIMIT 10
;

-- Question 3iii
CREATE VIEW q3iii(namefirst, namelast, lslg)
AS
  SELECT p.namefirst, p.namelast,
           (((b.h1 - b.h2 - b.h3 - b.h4) + (2 * b.h2) +
           (3 * b.h3) + (4 * b.h4)) / CAST(b.ab1 AS float)) as lslg
    FROM people p INNER JOIN
      (SELECT playerid, SUM(H) as h1, SUM(H2B) as h2,
              SUM(H3B) as h3, SUM(HR) as h4, SUM(AB) as ab1
      FROM batting
      GROUP BY playerid) as b ON p.playerid = b.playerid
    WHERE ab1 > 50 AND lslg > (SELECT (((b.h1 - b.h2 - b.h3 - b.h4) + (2 * b.h2) +
                                      (3 * b.h3) + (4 * b.h4)) / CAST(b.ab1 AS float)) as lslg
                               FROM people p INNER JOIN
                                 (SELECT playerid, SUM(H) as h1, SUM(H2B) as h2,
                                         SUM(H3B) as h3, SUM(HR) as h4, SUM(AB) as ab1
                                 FROM batting
                                 GROUP BY playerid) as b ON p.playerid = b.playerid
                               WHERE p.playerid == "mayswi01"
                               )
;

-- Question 4i
CREATE VIEW q4i(yearid, min, max, avg)
AS
  SELECT yearid, min(salary), max(salary), avg(salary)
  FROM salaries
  GROUP BY yearid
  ORDER BY yearid
;

-- Question 4ii
CREATE VIEW q4ii(binid, low, high, count)
AS
    SELECT 1,
;

-- Question 4iii
CREATE VIEW q4iii(yearid, mindiff, maxdiff, avgdiff)
AS
  select q.yearid, q.min - s.min, q.max - s.max, q.avg - s.avg
  from
      q4i q

      inner join

      (SELECT yearid as yr, min(salary) as min, max(salary) as max, avg(salary) as avg
       FROM salaries
       GROUP BY yearid
       ORDER BY yearid) as s on q.yearid = s.yr + 1
  where q.yearid != (select min(yearid) from q4i)
;

--q.yearid, q.min - s.min, q.max - s.min, q.avg - s.avg

-- Question 4iv
CREATE VIEW q4iv(playerid, namefirst, namelast, salary, yearid)
AS
  select s.playerid, p.namefirst, p.namelast, max(salary), s.yearid
  from people p inner join salaries s on p.playerid = s.playerid
  where s.yearid == 2000 or s.yearid == 2001
  group by s.yearid
;

-- Question 4v
CREATE VIEW q4v(team, diffAvg) AS
  select a.teamid, max(salary) - min(salary)
  from allstarfull a inner join salaries s on a.playerid = s.playerid
  where a.yearid == 2016 and s.yearid == 2016
  group by a.teamid
;