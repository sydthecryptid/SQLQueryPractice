--Start with psql -d hw4
--copy and paste each command to run 

-- Problem 1
-- Find the distinct courses that ‘SYS’ track students in 'CptS' major are enrolled in. Return
-- the courseno and credits for those courses. Return results sorted based on courseno.

SELECT DISTINCT c.courseno, c.credits
FROM Student s
JOIN Enroll e ON s.sid = e.sid
JOIN Course c ON e.courseno = c.courseno
WHERE s.major = 'CptS' AND s.trackcode = 'SYS'
ORDER BY c.courseno;

--- Problem 2
-- 2. Find the sorted names, ids, majors and track codes of the students who are enrolled in
-- more than 18 credits (19 or above).

SELECT s.sName, s.sID, s.major, s.trackcode, SUM(c.credits) AS total_credits
FROM Student s
JOIN Enroll e ON s.sID = e.sID --Find which classes match student's ID
JOIN Course c ON e.courseno = c.courseno --Find which classes match course number
GROUP BY s.sID, s.sName, s.major, s.trackcode
HAVING SUM(c.credits) > 18 -- Need 19+ credits
ORDER BY s.sName;

-- Problem 3
-- Find the courses that only 'SE' track students in 'CptS' major have been enrolled in. Give
-- an answer without using the set EXCEPT operator.

SELECT DISTINCT c.courseno
FROM Student s
JOIN Enroll e ON s.sID = e.sID
JOIN Course c ON e.courseno = c.courseno
WHERE s.major = 'CptS' AND s.trackcode = 'SE'
AND c.courseno NOT IN ( --subquery find courses taken by non SE 
    SELECT DISTINCT e2.courseno
    FROM Student s2
    JOIN Enroll e2 ON s2.sID = e2.sID
    WHERE NOT (s2.major = 'CptS' AND s2.trackcode = 'SE')
)
ORDER BY c.courseno;

-- 4. Find the students who have enrolled in the courses that Diane enrolled and earned the
-- same grade Diane earned in those courses. Return the student name, sID, major as well
-- as the courseno and grade for those courses.

SELECT s.sName, s.sID, s.major, e.courseno, e.grade
FROM Student s
JOIN Enroll e ON s.SID = e.sID
WHERE (e.courseno, e.grade) IN ( --subquery, find courses diane took 
    SELECT e2.courseno, e2.grade
    FROM Student s2
    JOIN Enroll e2 ON s2.sID = e2.sID --find enrollments that match diane sid
    WHERE s2.sName = 'Diane'
) AND s.sName != 'Diane' --exclude diane 
ORDER BY s.sName, e.courseno;

-- 5. Find the students in 'CptS' major who are not enrolled in any classes. Return their names
-- and sIDs. (Note: Give a solution using OUTER JOIN)

SELECT s.sName, s.sID
FROM Student s
LEFT JOIN Enroll e ON s.sID = e.sID --allows null inclusion
WHERE s.major = 'CptS' AND e.sID IS NULL --cpts students with null enrollments
ORDER BY s.sName;
