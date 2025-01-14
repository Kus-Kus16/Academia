-- Harmonogram kierunku studiów -K-
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
)
go

-- Harmonogram kursu -K-
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

--Harmonogram studenta -K-
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

-- Sprawdzenie czy student należy do danego Attendable -M-
create function FN_Check_StudentAttendable(@StudentID int, @AttendableID int)
returns bit
as
begin
    declare @Result bit = 0;
    declare @LectureID int = null;

    set @LectureID = (
        case 
            when exists (select 1 from StationaryCourseModules where AttendableID = @AttendableID) then (
                select top 1 C.LectureID
                from StationaryCourseModules S
                    inner join CourseModules M on M.CourseModuleID = S.CourseModuleID and S.AttendableID = @AttendableID
                    inner join Courses C on C.CourseID = M.CourseID
            )
            when exists (select 1 from OnlineCourseModules where AttendableID = @AttendableID) then (
                select top 1 C.LectureID 
                from OnlineCourseModules O
                    inner join CourseModules M on M.CourseModuleID = O.CourseModuleID and O.AttendableID = @AttendableID
                    inner join Courses C on C.CourseID = M.CourseID
            )
            when exists (select 1 from Internships where AttendableID = @AttendableID) then (
                select top 1 D.LectureID 
                from Internships I
                    inner join Studies D on D.StudiesID = I.StudiesID and I.AttendableID = @AttendableID
            )
            when exists (select 1 from StationaryClasses where AttendableID = @AttendableID) then (
                select top 1 D.LectureID 
                from StationaryClasses S
                    inner join Classes C on C.ClassID = S.ClassID and S.AttendableID = @AttendableID
                    inner join Studies D on D.StudiesID = C.StudiesID
            )
            when exists (select 1 from OnlineClasses where AttendableID = @AttendableID) then (
                select top 1 D.LectureID
                from OnlineClasses O
                    inner join Classes C on C.ClassID = O.ClassID and O.AttendableID = @AttendableID
                    inner join Studies D on D.StudiesID = C.StudiesID
            )
        end
    );

    if @LectureID is not null and exists 
        (select 1 from Enrollments E 
            inner join Orders O on O.OrderID = E.OrderID and E.Status = 'InProgress' and E.LectureID = @LectureID
            inner join Students S on S.StudentID = @StudentID)
    begin 
    set @Result = 1;
    end


    return @Result;
end
go

-- Wyliczenie pozostałych wolnych miejsc na studiach -M-
create function FN_Remaining_Studies_Limit(@StudiesID nchar(5))
returns int
as
begin
    declare @Result int = 0;
    declare @Reserved int = 0;
    declare @All int = 0;

    select @Reserved = V.TotalFutureParticipants, @All = S.CapacityLimit
    from VW_All_FutureParticipants V 
        inner join Studies S on S.LectureID = V.LectureID and S.StudiesID = @StudiesID;

    set @Result = @All - @Reserved;

    return @Result;
end
go

-- Wyliczenie pozostałych wolnych miejsc na kursach -M-
create function FN_Remaining_Course_Limit(@CourseID int)
returns int
as
begin
    declare @Result int = 0;
    declare @Reserved int = 0;
    declare @All int = 0;

    select @Reserved = V.TotalFutureParticipants, @All = C.CapacityLimit
    from VW_All_FutureParticipants V 
        inner join Courses C on C.LectureID = V.LectureID and C.CourseID = @CourseID;

    set @Result = @All - @Reserved;

    return @Result;
end
go

-- Wyliczenie pozostałych wolnych miejsc w stacjonarnej klasie -M-
create function FN_Remaining_StationaryClass_Limit(@StationaryClassID int)
returns int
as
begin
    declare @Result int = 0;
    declare @Reserved int = 0;
    declare @All int = 0;
    declare @StudiesReserved int = 0;

    select @Reserved = V.TotalFutureParticipants, @All = C.SeatLimit
    from VW_All_FutureParticipants V 
        inner join StationaryClasses C on C.LectureID = V.LectureID and C.StationaryClassID = @StationaryClassID;

    select @StudiesReserved = D.CapacityLimit
    from StationaryClasses C 
        inner join Classes S on S.ClassID = C.ClassID and C.StationaryClassID = @StationaryClassID
        inner join Studies D on D.StudiesID = S.StudiesID;

    set @Result = @All - @StudiesReserved - @Reserved

    return @Result;
end
go

-- Obliczenie wartości zamówienia -M-
create function FN_Order_Value(@OrderID int)
returns money
as
begin
    declare @Result money = 0

    select @Result = sum(E.TotalPrice)
    from Orders O 
        inner join Enrollments E on E.OrderID = O.OrderID
    group by E.OrderID

    return @Result;
end
go