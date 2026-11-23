
USE sen307_2024;

-- Task 1: Count students enrolled in each course, including courses with zero students
-- Explanation: LEFT JOIN connects Course to Enrolment and includes courses without enrolments.
-- COUNT(e.student_id) counts matching enrolment records, while GROUP BY groups results by course.
-- ORDER BY sorts courses from the highest number of students to the lowest.

SELECT
    c.course_id,
    c.course_title,
    COUNT(e.student_id) AS total_students
FROM Course c
LEFT JOIN Enrolment e
    ON c.course_id = e.course_id
GROUP BY c.course_id, c.course_title
ORDER BY total_students DESC;


-- Task 2: Find courses with more than a given number of students
-- Explanation: GROUP BY groups enrolments by course, while HAVING filters
-- grouped results to show only courses with more than the specified number of students.
-- Try changing the threshold to 3, 5 and 7.

SELECT
    c.course_id,
    c.course_title,
    COUNT(e.student_id) AS total_students
FROM Course c
INNER JOIN Enrolment e
    ON c.course_id = e.course_id
GROUP BY c.course_id, c.course_title
HAVING COUNT(e.student_id) > 3
ORDER BY total_students DESC;


-- Task 3: Calculate the average number of courses taken per student, including students with zero courses
-- Explanation: The inner query uses LEFT JOIN to include every student and COUNT(e.enrolment_id)
-- to count their courses. Students without enrolments receive a count of zero.
-- The outer query uses AVG() to calculate the average and ROUND() to display two decimal places.

SELECT ROUND(AVG(course_count), 2) AS average_courses_per_student
FROM (
    SELECT
        s.student_id,
        s.full_name,
        COUNT(e.enrolment_id) AS course_count
    FROM Student s
    LEFT JOIN Enrolment e
        ON s.student_id = e.student_id
    GROUP BY s.student_id, s.full_name
) AS per_student;


-- Task 4: Find students who are not enrolled in any course (Non-correlated subquery)
-- Explanation: The inner query retrieves student IDs from the Enrolment table.
-- The outer query uses NOT IN to find students whose IDs are not in that list.
-- The inner query runs independently of the outer query.

SELECT
    student_id,
    full_name
FROM Student
WHERE student_id NOT IN (
    SELECT student_id
    FROM Enrolment
);

-- Task 5: Find the student(s) with the highest number of enrolments in each department (Correlated subquery)
-- Explanation: The first subquery counts the enrolments for each student.
-- The second subquery finds the highest enrolment count among students
-- belonging to the same department as the current student.
-- The outer query returns students whose enrolment count equals that highest count.
-- Ties are allowed, so multiple students can appear in one department.

SELECT
    d.dept_name,
    s.full_name,
    (
        SELECT COUNT(*)
        FROM Enrolment e
        WHERE e.student_id = s.student_id
    ) AS courses
FROM Student s
JOIN Department d
    ON s.dept_id = d.dept_id
WHERE (
    SELECT COUNT(*)
    FROM Enrolment e
    WHERE e.student_id = s.student_id
) = (
    SELECT MAX(student_courses.course_count)
    FROM (
        SELECT
            s2.student_id,
            COUNT(e2.enrolment_id) AS course_count
        FROM Student s2
        LEFT JOIN Enrolment e2
            ON s2.student_id = e2.student_id
        WHERE s2.dept_id = s.dept_id
        GROUP BY s2.student_id
    ) AS student_courses
)
ORDER BY d.dept_name;