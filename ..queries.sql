-- CampusConnect Reporting Query Set
-- Database Engine: SQLite 3.45

-- Requirement Task 4.1a: Query using IN
-- Answers: Retrieves details of students enrolled in specific entry-year cohorts (2022 and 2023).
SELECT student_id, first_name, last_name, enrollment_year 
FROM students 
WHERE enrollment_year IN (2022, 2023);

-- Requirement Task 4.1b: Query using BETWEEN
-- Answers: Finds courses with credit hours between 3 and 4 inclusive.
SELECT course_id, course_code, course_name, credits 
FROM courses 
WHERE credits BETWEEN 3 AND 4;

-- Requirement Task 4.2: Query using IS NULL / IS NOT NULL
-- Answers: Identifies active enrollments that have not yet been assigned a final grade.
SELECT enrollment_id, student_id, course_id 
FROM enrollments 
WHERE grade IS NULL;

-- Requirement Task 4.3: Query using GROUP BY with HAVING
-- Answers: Lists courses having more than 1 student enrolled.
SELECT course_id, COUNT(student_id) AS total_enrolled 
FROM enrollments 
GROUP BY course_id 
HAVING COUNT(student_id) > 1;

-- Requirement Task 4.4a: INNER JOIN
-- Answers: List student names alongside their enrolled course names.
SELECT s.first_name, s.last_name, c.course_name 
FROM enrollments e
INNER JOIN students s ON e.student_id = s.student_id
INNER JOIN courses c ON e.course_id = c.course_id;

-- Requirement Task 4.4b: LEFT JOIN
-- Answers: Lists all students and their assigned course IDs, including students not enrolled in any course.
SELECT s.student_id, s.first_name, s.last_name, e.course_id 
FROM students s
LEFT JOIN enrollments e ON s.student_id = e.student_id;

-- Requirement Task 4.4c: FULL OUTER JOIN Substitution (Emulated via LEFT JOIN + UNION in SQLite)
-- Note: SQLite does not natively support FULL OUTER JOIN syntax. Emulated below.
-- Answers: Shows all combined student-course combinations including unassigned courses & unenrolled students.
SELECT s.student_id, s.first_name, e.course_id 
FROM students s 
LEFT JOIN enrollments e ON s.student_id = e.student_id
UNION
SELECT s.student_id, s.first_name, e.course_id 
FROM enrollments e 
LEFT JOIN students s ON e.student_id = s.student_id;

-- Requirement Task 4.5a: Scalar Subquery
-- Answers: Retrieves courses with fewer available seats than the average available seats across all courses.
SELECT course_code, course_name, available_seats 
FROM courses 
WHERE available_seats < (SELECT AVG(available_seats) FROM courses);

-- Requirement Task 4.5b: Correlated Subquery
-- Answers: Retrieves students whose GPA is higher than the average GPA of students enrolled in the same year.
SELECT s1.student_id, s1.first_name, s1.gpa, s1.enrollment_year 
FROM students s1
WHERE s1.gpa > (
    SELECT AVG(s2.gpa) 
    FROM students s2 
    WHERE s2.enrollment_year = s1.enrollment_year
);

-- Requirement Task 4.5c: Query using EXISTS
-- Answers: Lists instructors who are actively teaching at least one course.
SELECT i.instructor_id, i.first_name, i.last_name 
FROM instructors i
WHERE EXISTS (
    SELECT 1 
    FROM courses c 
    WHERE c.instructor_id = i.instructor_id
);

-- Requirement Task 4.6: Set Operation (EXCEPT)
-- Answers: Finds student IDs who have not enrolled in any courses.
SELECT student_id FROM students
EXCEPT
SELECT student_id FROM enrollments;

-- Requirement Task 4.7: Window Function (RANK)
-- Answers: Ranks students within their respective enrollment year based on GPA.
SELECT student_id, first_name, enrollment_year, gpa,
       RANK() OVER (PARTITION BY enrollment_year ORDER BY gpa DESC) as rank_in_year
FROM students;