-- CampusConnect Relational Database Schema & Data Initialization
-- Database Engine: SQLite 3.45

-- Enforce Foreign Key constraints in SQLite
PRAGMA foreign_keys = ON;

-- Clean up existing tables
DROP TABLE IF EXISTS enrollments;
DROP TABLE IF EXISTS courses;
DROP TABLE IF EXISTS instructors;
DROP TABLE IF EXISTS students;

-- ============================================================================
-- TASK 1: SCHEMA DESIGN (3NF)
-- ============================================================================

-- Table 1: instructors
CREATE TABLE instructors (
    instructor_id INTEGER PRIMARY KEY AUTOINCREMENT,
    first_name TEXT NOT NULL,
    last_name TEXT NOT NULL,
    email TEXT UNIQUE NOT NULL,
    department TEXT NOT NULL
);

-- Table 2: students
CREATE TABLE students (
    student_id INTEGER PRIMARY KEY AUTOINCREMENT,
    first_name TEXT NOT NULL,
    last_name TEXT NOT NULL,
    email TEXT UNIQUE NOT NULL,
    enrollment_year INTEGER NOT NULL CHECK(enrollment_year >= 2000),
    gpa REAL DEFAULT 0.0 CHECK(gpa >= 0.0 AND gpa <= 4.0)
);

-- Table 3: courses
CREATE TABLE courses (
    course_id INTEGER PRIMARY KEY AUTOINCREMENT,
    course_code TEXT UNIQUE NOT NULL,
    course_name TEXT NOT NULL,
    credits INTEGER NOT NULL CHECK(credits > 0),
    available_seats INTEGER NOT NULL CHECK(available_seats >= 0),
    instructor_id INTEGER NOT NULL,
    FOREIGN KEY (instructor_id) REFERENCES instructors(instructor_id) ON DELETE RESTRICT
);

-- Table 4: enrollments (Junction table)
CREATE TABLE enrollments (
    enrollment_id INTEGER PRIMARY KEY AUTOINCREMENT,
    student_id INTEGER NOT NULL,
    course_id INTEGER NOT NULL,
    enrollment_date TEXT DEFAULT CURRENT_DATE,
    grade TEXT CHECK(grade IN ('A', 'B', 'C', 'D', 'F', NULL)),
    FOREIGN KEY (student_id) REFERENCES students(student_id) ON DELETE CASCADE,
    FOREIGN KEY (course_id) REFERENCES courses(course_id) ON DELETE CASCADE,
    UNIQUE(student_id, course_id)
);

-- ============================================================================
-- TASK 5: INDEXING
-- ============================================================================

-- Composite index to speed up student-course lookup in queries & joins
-- Requirement: Task 5 - Composite index on two columns used together
CREATE INDEX idx_enrollments_student_course ON enrollments(student_id, course_id);

-- Single-column index to speed up grade reporting and NULL checks
-- Requirement: Task 5 - Single column index on a heavily queried/filtered attribute
CREATE INDEX idx_enrollments_grade ON enrollments(grade);

-- ============================================================================
-- TASK 3: SAMPLE DATA INSERTS
-- ============================================================================

-- Root Table 1: instructors (10 rows)
INSERT INTO instructors (first_name, last_name, email, department) VALUES
('Alan', 'Turing', 'alan.turing@campusconnect.edu', 'Computer Science'),
('Ada', 'Lovelace', 'ada.lovelace@campusconnect.edu', 'Computer Science'),
('Grace', 'Hopper', 'grace.hopper@campusconnect.edu', 'Software Engineering'),
('Edgar', 'Codd', 'edgar.codd@campusconnect.edu', 'Database Systems'),
('Donald', 'Knuth', 'donald.knuth@campusconnect.edu', 'Algorithms'),
('Barbara', 'Liskov', 'barbara.liskov@campusconnect.edu', 'Software Systems'),
('Leslie', 'Lamport', 'leslie.lamport@campusconnect.edu', 'Distributed Systems'),
('John', 'von Neumann', 'john.neumann@campusconnect.edu', 'Mathematics'),
('Claude', 'Shannon', 'claude.shannon@campusconnect.edu', 'Information Theory'),
('Tim', 'Berners-Lee', 'tim.bernerslee@campusconnect.edu', 'Web Systems');

-- Root Table 2: students (10 rows)
INSERT INTO students (first_name, last_name, email, enrollment_year, gpa) VALUES
('Alice', 'Smith', 'alice.smith@student.edu', 2023, 3.8),
('Bob', 'Jones', 'bob.jones@student.edu', 2022, 3.2),
('Charlie', 'Brown', 'charlie.brown@student.edu', 2024, 2.9),
('Diana', 'Prince', 'diana.prince@student.edu', 2023, 3.9),
('Evan', 'Wright', 'evan.wright@student.edu', 2021, 3.1),
('Fiona', 'Gallagher', 'fiona.gallagher@student.edu', 2024, 3.5),
('George', 'Clark', 'george.clark@student.edu', 2022, 2.7),
('Hannah', 'Abbott', 'hannah.abbott@student.edu', 2023, 3.6),
('Ian', 'Malcolm', 'ian.malcolm@student.edu', 2021, 3.4),
('Julia', 'Roberts', 'julia.roberts@student.edu', 2024, 3.7);

-- Child Table 1: courses (10 rows)
INSERT INTO courses (course_code, course_name, credits, available_seats, instructor_id) VALUES
('CS101', 'Intro to Computer Science', 3, 29, 1),
('CS201', 'Data Structures & Algorithms', 4, 15, 5),
('DB301', 'Relational Database Systems', 4, 10, 4),
('SE401', 'Software Engineering Principles', 3, 20, 3),
('DS501', 'Distributed Systems Design', 4, 5, 7),
('MATH101', 'Discrete Mathematics', 3, 35, 8),
('INFO201', 'Information Theory', 3, 12, 9),
('WEB301', 'Web Architectures', 3, 25, 10),
('CS302', 'Object-Oriented Design', 3, 18, 6),
('CS102', 'Advanced Python Programming', 3, 8, 2);

-- Child Table 2: enrollments (10 valid rows)
INSERT INTO enrollments (student_id, course_id, enrollment_date, grade) VALUES
(1, 1, '2026-01-15', 'A'),
(1, 3, '2026-01-16', 'A'),
(2, 2, '2026-01-15', 'B'),
(2, 3, '2026-01-16', 'C'),
(3, 1, '2026-01-17', NULL),
(4, 4, '2026-01-18', 'A'),
(5, 5, '2026-01-19', 'B'),
(6, 6, '2026-01-20', NULL),
(7, 2, '2026-01-21', 'F'),
(8, 8, '2026-01-22', 'B');

-- DEMONSTRATION OF REFERENTIAL INTEGRITY VIOLATION (Task 3 Requirement)
-- The following statement attempts to insert an enrollment for a non-existent student (ID: 999).
-- Execution will fail with a Foreign Key Constraint violation unless commented out.
-- INSERT INTO enrollments (student_id, course_id, enrollment_date, grade) VALUES (999, 1, '2026-02-01', 'A');

-- ============================================================================
-- TASK 6: TRANSACTIONS & ISOLATION
-- ============================================================================

-- Multi-statement Atomic Transaction: Enrolling Student ID 9 into Course ID 1
-- Requirement: Task 6 - Atomicity across updates in two related tables
BEGIN TRANSACTION;

UPDATE courses 
SET available_seats = available_seats - 1 
WHERE course_id = 1 AND available_seats > 0;

INSERT INTO enrollments (student_id, course_id, enrollment_date, grade) 
VALUES (9, 1, '2026-07-21', NULL);

COMMIT;