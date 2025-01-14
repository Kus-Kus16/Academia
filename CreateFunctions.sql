--K
--Harmonogram kierunku studiów
CREATE FUNCTION GetScheduleForStudies(studiesID NCHAR(5))
RETURNS TABLE (
    MeetingID INT,
    MeetingType NVARCHAR(50),
    ClassName NVARCHAR(255),
    TeacherName NVARCHAR(255),
    StartDate DATETIME,
    EndDate DATETIME,
    Location NVARCHAR(255),
    Link NVARCHAR(255)
)
BEGIN
    RETURN (
        SELECT
            sc.StationaryClassID AS MeetingID,
            'Stationary' AS MeetingType,
            c.Name AS ClassName,
            CONCAT(t.Name, ' ', t.Surname) AS TeacherName,
            a.StartDate,
            a.EndDate,
            sc.Classroom AS Location,
            NULL AS Link
        FROM StationaryClasses sc
        INNER JOIN Classes c ON sc.ClassID = c.ClassID
        INNER JOIN Attendable a ON sc.AttendableID = a.AttendableID
        INNER JOIN Teachers t ON c.TeacherID = t.TeacherID
        WHERE c.StudiesID = studiesID

        UNION ALL

        SELECT
            oc.OnlineClassID AS MeetingID,
            'Online' AS MeetingType,
            c.Name AS ClassName,
            CONCAT(t.Name, ' ', t.Surname) AS TeacherName,
            a.StartDate,
            a.EndDate,
            NULL AS Location,
            oc.Link AS Link
        FROM OnlineClasses oc
        INNER JOIN Classes c ON oc.ClassID = c.ClassID
        INNER JOIN Attendable a ON oc.AttendableID = a.AttendableID
        INNER JOIN Teachers t ON c.TeacherID = t.TeacherID
        WHERE c.StudiesID = studiesID
        ORDER BY StartDate
    );
END;

--Harmonogram kursu
CREATE FUNCTION GetScheduleForCourse(courseID INT)
RETURNS TABLE (
    MeetingID INT,
    MeetingType NVARCHAR(50),
    ModuleName NVARCHAR(255),
    TeacherName NVARCHAR(255),
    StartDate DATETIME,
    EndDate DATETIME,
    Location NVARCHAR(255),
    Link NVARCHAR(255)
)
BEGIN
    RETURN (
        SELECT
            scm.StationaryCourseID AS MeetingID,
            'Stationary' AS MeetingType,
            cm.Name AS ModuleName,
            CONCAT(t.Name, ' ', t.Surname) AS TeacherName,
            a.StartDate,
            a.EndDate,
            scm.Classroom AS Location,
            NULL AS Link
        FROM StationaryCourseModules scm
        INNER JOIN CourseModules cm ON scm.CourseModuleID = cm.CourseModuleID
        INNER JOIN Attendable a ON scm.AttendableID = a.AttendableID
        INNER JOIN Teachers t ON cm.TeacherID = t.TeacherID
        WHERE cm.CourseID = courseID

        UNION ALL

        SELECT
            ocm.OnlineCourseID AS MeetingID,
            'Online' AS MeetingType,
            cm.Name AS ModuleName,
            CONCAT(t.Name, ' ', t.Surname) AS TeacherName,
            a.StartDate,
            a.EndDate,
            NULL AS Location,
            ocm.Link AS Link
        FROM OnlineCourseModules ocm
        INNER JOIN CourseModules cm ON ocm.CourseModuleID = cm.CourseModuleID
        INNER JOIN Attendable a ON ocm.AttendableID = a.AttendableID
        INNER JOIN Teachers t ON cm.TeacherID = t.TeacherID
        WHERE cm.CourseID = courseID
        ORDER BY StartDate
    );
END;

--Harmonogram studenta
CREATE FUNCTION GetScheduleForStudent(@studentID INT)
RETURNS TABLE (
    LectureID INT,
    LectureType NVARCHAR(50),
    CourseName NVARCHAR(255),
    ModuleName NVARCHAR(255),
    StartDate DATETIME,
    EndDate DATETIME,
    Location NVARCHAR(255),
    Link NVARCHAR(255),
    TeacherName NVARCHAR(255)
)
BEGIN
    RETURN (
        -- Spotkania online kursu
        SELECT
            'Online Course Module' AS EventType,
            ocm.Link AS EventLink,
            a.StartDate AS EventStartDate,
            a.EndDate AS EventEndDate,
        NULL AS EventLocation
        FROM Students s
        INNER JOIN Orders o ON s.StudentID = o.StudentID
        INNER JOIN Enrollments e ON o.OrderID = e.OrderID
        INNER JOIN Courses c ON e.LectureID = c.LectureID
        INNER JOIN CourseModules cm ON c.CourseID = cm.CourseID
        INNER JOIN OnlineCourseModules ocm ON cm.CourseModuleID = ocm.CourseModuleID
        INNER JOIN Attendable a ON ocm.AttendableID = a.AttendableID
        WHERE s.StudentID = @studentID

        UNION ALL
        -- Spotkania stacjonarne kursu
        SELECT
            'Stationary Course Module' AS EventType,
            NULL AS EventLink,
            a.StartDate AS EventStartDate,
            a.EndDate AS EventEndDate,
            scm.Classroom AS EventLocation
        FROM Students s
        INNER JOIN Orders o ON s.StudentID = o.StudentID
        INNER JOIN Enrollments e ON o.OrderID = e.OrderID
        INNER JOIN Courses c ON e.LectureID = c.LectureID
        INNER JOIN CourseModules cm ON c.CourseID = cm.CourseID
        INNER JOIN StationaryCourseModules scm ON cm.CourseModuleID = scm.CourseModuleID
        INNER JOIN Attendable a ON scm.AttendableID = a.AttendableID
        WHERE s.StudentID = @StudentID

        UNION ALL
        -- Webinary
        SELECT
            'Webinar' AS EventType,
            w.Link AS EventLink,
            l.Date AS EventStartDate,
            l.Date AS EventEndDate,
            NULL AS EventLocation
        FROM Students s
        INNER JOIN Orders o ON s.StudentID = o.StudentID
        INNER JOIN Enrollments e ON o.OrderID = e.OrderID
        INNER JOIN Lectures l ON e.LectureID = l.LectureID
        INNER JOIN Webinars w ON l.LectureID = w.LectureID
        WHERE s.StudentID = @StudentID

        UNION ALL
        --Spotkania studyjne online, ale wykupione bez całych studiów
        SELECT
            'Online Class without studies' AS EventType,
            oc.Link AS EventLink,
            a.StartDate AS EventStartDate,
            a.EndDate AS EventEndDate,
            NULL AS EventLocation
        FROM Students s
        INNER JOIN Orders o ON s.StudentID = o.StudentID
        INNER JOIN Enrollments e ON o.OrderID = e.OrderID
        INNER JOIN OnlineClasses oc ON e.LectureID = oc.LectureID
        INNER JOIN Attendable a ON oc.AttendableID = a.AttendableID
        WHERE s.StudentID = @StudentID

        UNION ALL
        --Spotkania studyjne stacjonarne, ale wykupione bez całych studiów
        SELECT
            'Stationary Class without studies' AS EventType,
            NULL AS EventLink,
            a.StartDate AS EventStartDate,
            a.EndDate AS EventEndDate,
            sc.Classroom AS EventLocation
        FROM Students s
        INNER JOIN Orders o ON s.StudentID = o.StudentID
        INNER JOIN Enrollments e ON o.OrderID = e.OrderID
        INNER JOIN StationaryClasses sc ON e.LectureID = sc.LectureID
        INNER JOIN Attendable a ON sc.AttendableID = a.AttendableID
        WHERE s.StudentID = @StudentID

        UNION ALL
        --Spotkania studyjne online
        SELECT
            'Online Class Studies' AS EventType,
            oc.Link AS EventLink,
            a.StartDate AS EventStartDate,
            a.EndDate AS EventEndDate,
            NULL AS EventLocation
        FROM Students s
        INNER JOIN Orders o ON s.StudentID = o.StudentID
        INNER JOIN Enrollments e ON o.OrderID = e.OrderID
        INNER JOIN Studies st ON e.LectureID = st.LectureID
        INNER JOIN Classes c ON st.StudiesID = c.StudiesID
        INNER JOIN OnlineClasses oc ON c.ClassID = oc.ClassID
        INNER JOIN Attendable a ON oc.AttendableID = a.AttendableID
        WHERE s.StudentID = @StudentID

        UNION ALL
        --Spotkania studyjne stacjonarne
        SELECT
            'Stationary Class Studies' AS EventType,
            NULL AS EventLink,
            a.StartDate AS EventStartDate,
            a.EndDate AS EventEndDate,
            sc.Classroom AS EventLocation
        FROM Students s
        INNER JOIN Orders o ON s.StudentID = o.StudentID
        INNER JOIN Enrollments e ON o.OrderID = e.OrderID
        INNER JOIN Studies st ON e.LectureID = st.LectureID
        INNER JOIN Classes c ON st.StudiesID = c.StudiesID
        INNER JOIN StationaryClasses sc ON c.ClassID = sc.ClassID
        INNER JOIN Attendable a ON sc.AttendableID = a.AttendableID
        WHERE s.StudentID = @StudentID
    );
END;