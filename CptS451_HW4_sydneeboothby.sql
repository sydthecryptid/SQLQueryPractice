--Sydnee Boothby 11896367


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

-- 6. Find the courses given in the ‘Sloan’ building which have enrolled more students than
-- their enrollment limit. Return the courseno, enroll_limit, and the actual enrollment for
-- those courses.

SELECT c.courseNo, c.enroll_limit, COUNT(e.sID) AS num_enrolled
FROM Course c
JOIN Enroll e ON c.courseno = e.courseno
WHERE c.classroom LIKE 'Sloan%'
GROUP BY c.courseNo, c.enroll_limit --group to remove dupes
HAVING COUNT(e.sID) > c.enroll_limit --find courses that exceed limit
ORDER BY c.courseNo

-- 7. Find 'CptS' major students who enrolled in a course for which there exists a prerequisite
-- that the student got a grade lower than “2”. (For example, Alice (sid: 12583589) was
-- enrolled in CptS355 but had a grade 1.75 in prerequisite CptS223.) Return the names
-- and sIDs of those students and the courseno of the course (i.e., the course whose prereq
-- had a low grade).

SELECT s.sname, s.sid, c.courseno
FROM Student s
JOIN Enroll e ON s.sid = e.sid
JOIN Course c ON e.courseno = c.courseno
JOIN Prereq p ON c.courseno = p.courseno
JOIN Enroll e2 ON p.precourseno = e2.courseno AND s.sid = e2.sid
WHERE s.major = 'CptS' AND e2.grade < 2
ORDER BY s.sname, c.courseno;

-- 8. For each ‘CptS’ course, find the percentage of the students who failed the course.
-- Assume a passing grade is 2 or above. (Note: Assume students who didn’t earn a grade in
-- class should be excluded in average calculation. Also assume all CptS courses start with
-- the ‘CptS’ prefix).

-- SELECT c.courseno, 
--     COUNT(CASE WHEN e.grade < 2 THEN 1 END) * 100.0 / COUNT(e.sID) AS fail_percentage    
-- FROM Course c
-- JOIN Enroll e ON c.courseno = e.courseno
-- WHERE c.courseno LIKE 'CptS%'
-- GROUP BY c.courseno
-- HAVING COUNT(CASE WHEN e.grade < 2 THEN 1 END) * 100.0 / COUNT(e.sID) > 0
-- ORDER BY c.courseno;


--part 2, this matches the example results from the hw outline
SELECT c.courseno, 
    COUNT(CASE WHEN e.grade >= 2 THEN 1 END) * 100.0 / COUNT(e.sID) AS passrate
FROM Course c
JOIN Enroll e ON c.courseno = e.courseno
WHERE c.courseno LIKE 'CptS%'
GROUP BY c.courseno
HAVING COUNT(CASE WHEN e.grade >= 2 THEN 1 END) * 100.0 / COUNT(e.sID) > 0
ORDER BY c.courseno;

-- 9. (10pts) Consider the following relational algebra expression.
-- (i) explain what the expression is doing,

-- The expression is finding the number of prerequistites and returning those with 2+

-- (ii) write an equivalent SQL query.

SELECT c.courseno, COUNT(p.precourseno) AS pcount --count num prereqs per course
FROM Course c
JOIN Prereq p ON c.courseno = p.courseno
GROUP BY c.courseno
HAVING COUNT(p.precourseno) >= 2 --find courses with 2+ prereqs
ORDER BY c.courseno;