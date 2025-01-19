--K
-- Harmonogram kierunku studiów
create function FN_ScheduleForStudies(@studiesID nchar(5))
returns table
as
return (
    select
        sc.StationaryClassID as MeetingID,
        'Stationary' as MeetingType,
        c.Name as ClassName,
        concat(t.Name, ' ', t.Surname) as TeacherName,
        a.StartDate,
        a.EndDate,
        sc.Classroom as Location,
        null as Link
    from StationaryClasses sc
    inner join Classes c on sc.ClassID = c.ClassID
    inner join Attendable a on sc.AttendableID = a.AttendableID
    inner join Teachers t on c.TeacherID = t.TeacherID
    where c.StudiesID = @studiesID

    union all

    select
        oc.OnlineClassID as MeetingID,
        'Online' as MeetingType,
        c.Name as ClassName,
        concat(t.Name, ' ', t.Surname) as TeacherName,
        a.StartDate,
        a.EndDate,
        null as Location,
        oc.Link as Link
    from OnlineClasses oc
    inner join Classes c on oc.ClassID = c.ClassID
    inner join Attendable a on oc.AttendableID = a.AttendableID
    inner join Teachers t on c.TeacherID = t.TeacherID
    where c.StudiesID = @studiesID

    union all

    select InternshipID as MeetingID,
           'Internship' as MeetingType,
           Name,
           null,
           A2.StartDate,
           A2.EndDate,
           Address,
           null
    from Internships
    inner join dbo.Attendable A2 on A2.AttendableID = Internships.AttendableID
    where StudiesID = @studiesID
)
go

-- Harmonogram kursu
create function FN_ScheduleForCourse(@courseID INT)
returns table
as
return (
    select
        scm.StationaryCourseID as MeetingID,
        'Stationary' as MeetingType,
        cm.Name as ModuleName,
        concat(t.Name, ' ', t.Surname) as TeacherName,
        a.StartDate,
        a.EndDate,
        scm.Classroom as Location,
        null as Link
    from StationaryCourseModules scm
    inner join CourseModules cm on scm.CourseModuleID = cm.CourseModuleID
    inner join Attendable a on scm.AttendableID = a.AttendableID
    inner join Teachers t on cm.TeacherID = t.TeacherID
    where cm.CourseID = @courseID

    union all

    select
        ocm.OnlineCourseID as MeetingID,
        'Online' as MeetingType,
        cm.Name as ModuleName,
        concat(t.Name, ' ', t.Surname) as TeacherName,
        a.StartDate,
        a.EndDate,
        null as Location,
        ocm.Link as Link
    from OnlineCourseModules ocm
    inner join CourseModules cm on ocm.CourseModuleID = cm.CourseModuleID
    inner join Attendable a on ocm.AttendableID = a.AttendableID
    inner join Teachers t on cm.TeacherID = t.TeacherID
    where cm.CourseID = @courseID
)
go

--Harmonogram studenta
create function FN_ScheduleForStudent(@studentid int)
returns table
as
return (
        -- Spotkania online kursu
        select
            'Online Course Module' as EventType,
            ocm.Link as EventLink,
            a.StartDate as EventStartDate,
            a.EndDate as EventEndDate,
        null as EventLocation
        from Students s
        inner join Orders o on s.StudentID = o.StudentID
        inner join Enrollments e on o.OrderID = e.OrderID
        inner join Courses c on e.LectureID = c.LectureID
        inner join CourseModules cm on c.CourseID = cm.CourseID
        inner join OnlineCourseModules ocm on cm.CourseModuleID = ocm.CourseModuleID
        inner join Attendable a on ocm.AttendableID = a.AttendableID
        where s.StudentID = @studentid

        union all
        -- Spotkania stacjonarne kursu
        select
            'Stationary Course Module' as EventType,
            null as EventLink,
            a.StartDate as EventStartDate,
            a.EndDate as EventEndDate,
            scm.Classroom as EventLocation
        from Students s
        inner join Orders o on s.StudentID = o.StudentID
        inner join Enrollments e on o.OrderID = e.OrderID
        inner join Courses c on e.LectureID = c.LectureID
        inner join CourseModules cm on c.CourseID = cm.CourseID
        inner join StationaryCourseModules scm on cm.CourseModuleID = scm.CourseModuleID
        inner join Attendable a on scm.AttendableID = a.AttendableID
        where s.StudentID = @studentid

        union all
        -- Webinary
        select
            'Webinar' as EventType,
            w.Link as EventLink,
            l.Date as EventStartDate,
            l.Date as EventEndDate,
            null as EventLocation
        from Students s
        inner join Orders o on s.StudentID = o.StudentID
        inner join Enrollments e on o.OrderID = e.OrderID
        inner join Lectures l on e.LectureID = l.LectureID
        inner join Webinars w on l.LectureID = w.LectureID
        where s.StudentID = @studentid

        union all
        -- Spotkania studyjne online, ale wykupione bez całych studiów
        select
            'Online Class without studies' as EventType,
            oc.Link as EventLink,
            a.StartDate as EventStartDate,
            a.EndDate as EventEndDate,
            null as EventLocation
        from Students s
        inner join Orders o on s.StudentID = o.StudentID
        inner join Enrollments e on o.OrderID = e.OrderID
        inner join OnlineClasses oc on e.LectureID = oc.LectureID
        inner join Attendable a on oc.AttendableID = a.AttendableID
        where s.StudentID = @studentid

        union all
        -- Spotkania studyjne stacjonarne, ale wykupione bez całych studiów
        select
            'Stationary Class without studies' as EventType,
            null as EventLink,
            a.StartDate as EventStartDate,
            a.EndDate as EventEndDate,
            sc.Classroom as EventLocation
        from Students s
        inner join Orders o on s.StudentID = o.StudentID
        inner join Enrollments e on o.OrderID = e.OrderID
        inner join StationaryClasses sc on e.LectureID = sc.LectureID
        inner join Attendable a on sc.AttendableID = a.AttendableID
        where s.StudentID = @studentid

        union all
        -- Spotkania studyjne online
        select
            'Online Class Studies' as EventType,
            oc.Link as EventLink,
            a.StartDate as EventStartDate,
            a.EndDate as EventEndDate,
            null as EventLocation
        from Students s
        inner join Orders o on s.StudentID = o.StudentID
        inner join Enrollments e on o.OrderID = e.OrderID
        inner join Studies st on e.LectureID = st.LectureID
        inner join Classes c on st.StudiesID = c.StudiesID
        inner join OnlineClasses oc on c.ClassID = oc.ClassID
        inner join Attendable a on oc.AttendableID = a.AttendableID
        where s.StudentID = @studentid

        union all
        -- Spotkania studyjne stacjonarne
        select
            'Stationary Class Studies' as EventType,
            null as EventLink,
            a.StartDate as EventStartDate,
            a.EndDate as EventEndDate,
            sc.Classroom as EventLocation
        from Students s
        inner join Orders o on s.StudentID = o.StudentID
        inner join Enrollments e on o.OrderID = e.OrderID
        inner join Studies st on e.LectureID = st.LectureID
        inner join Classes c on st.StudiesID = c.StudiesID
        inner join StationaryClasses sc on c.ClassID = sc.ClassID
        inner join Attendable a on sc.AttendableID = a.AttendableID
        where s.StudentID = @studentid

        union all
        -- Staże
        select
            'Internship' as EventType,
            null as EventLink,
            a.StartDate as EventStartDate,
            a.EndDate as EventEndDate,
            i.Address as EventLocation
        from Students s
        inner join Orders o on s.StudentID = o.StudentID
        inner join Enrollments e on o.OrderID = e.OrderID
        inner join Studies st on e.LectureID = st.LectureID
        inner join Internships i on st.StudiesID = i.StudiesID
        inner join Attendable a on i.AttendableID = a.AttendableID
        where s.StudentID = @studentid
    );
go

