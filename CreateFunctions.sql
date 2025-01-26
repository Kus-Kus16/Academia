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
            inner join Students S on S.StudentID = O.StudentID and S.StudentID = @StudentID)
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
        inner join Enrollments E on E.OrderID = O.OrderID and E.OrderID = @OrderID
    group by E.OrderID

    return @Result;
end
go

-- Sprawdzenie frekwencji na przedmiocie -Ł-
create function FN_Check_Attendance_In_Class(@ClassID int)
returns float
as
begin
    declare @Result float = 0;

    if exists(
        select 1
        from Classes
        where ClassID = @ClassID
    )
        begin
            with ClassesHappened as (
                select SC.StationaryClassID as ClassHappenedID, SC.AttendableID, 'Stationary' as ClassType
                from Classes C
                         inner join StationaryClasses SC on C.ClassID = SC.ClassID
                where C.ClassID = @ClassID
                union
                select OC.OnlineClassID, OC.AttendableID, 'Online'
                from Classes C
                         inner join OnlineClasses OC on C.ClassID = OC.ClassID
                where C.ClassID = @ClassID
            ), AttendanceChecked as (
                select sum(convert(int, Attendance)) as attendanceRate, count(*) as totalClasses
                from ClassesHappened CH
                         inner join Attendable A on CH.AttendableID = A.AttendableID
                         inner join Attendances AT on A.AttendableID = AT.AttendableID
            )
            select @Result = (
                select attendanceRate/totalClasses
                from AttendanceChecked
            )
        end
    else
        begin
            return null;
        end

    return @Result;
end
go

-- Sprawdzenie frekwencji na kursie -Ł-
create function FN_Check_Attendance_In_Course(@CourseID int)
returns float
as
begin
    declare @Result float = 0;

    if exists(
        select 1
        from Courses
        where CourseID = @CourseID
    )
        begin
            with CoursesHappened as (
                select SCM.StationaryCourseID as CourseHappenedID, SCM.AttendableID, 'Stationary' as CourseType
                from Courses C
                         inner join CourseModules CM on C.CourseID = CM.CourseID
                         inner join StationaryCourseModules SCM on CM.CourseModuleID = SCM.CourseModuleID
                where C.CourseID = @CourseID
                union
                select OCM.OnlineCourseID, OCM.AttendableID, 'Online'
                from Courses C
                         inner join CourseModules CM on C.CourseID = CM.CourseID
                         inner join OnlineCourseModules OCM on CM.CourseModuleID = OCM.CourseModuleID
                where C.CourseID = @CourseID
            ), AttendanceChecked as (
                select sum(convert(int, Attendance)) as attendanceRate, count(*) as totalClasses
                from CoursesHappened CH
                         inner join Attendable A on CH.AttendableID = A.AttendableID
                         inner join Attendances AT on A.AttendableID = AT.AttendableID
            )
            select @Result = (
                select attendanceRate/totalClasses
                from AttendanceChecked
            )
        end
    else
        begin
            return null;
        end

    return @Result;
end
go

-- Obecność studenta na wszystkich praktykach -Ł-
create function FN_Student_Presence_On_Internships(@StudentID int)
returns bit
as
begin
    declare @Result bit = 1;

    if not exists(
        select 1
        from Internships I
            inner join Studies S on I.StudiesID = S.StudiesID
            inner join Lectures L on S.LectureID = L.LectureID
            inner join Enrollments E on L.LectureID = E.LectureID
            inner join Orders O on E.OrderID = O.OrderID
        where O.StudentID = @StudentID
    )
        begin
            return null;
        end

    if exists (
        select 1
        from Internships I
                 inner join Attendable A on I.AttendableID = A.AttendableID
                 inner join Attendances AT on A.AttendableID = AT.AttendableID
        where AT.StudentID = @StudentID and AT.Attendance = 0
    )
        begin
            set @Result = 0;
        end

    return @Result;
end
go

-- Sprawdzenie czy student zdaje (na ten moment) studia -Ł-
create function FN_Student_Passes_Studies(@StudentID int, @StudiesID nchar(5))
returns bit
as
begin
    declare @Result bit = 0;

    if exists(
        select 1
        from Enrollments E
            inner join Lectures L on E.LectureID = L.LectureID
            inner join Studies S on L.LectureID = S.LectureID and S.StudiesID = @StudiesID
            inner join Orders O on E.OrderID = O.OrderID
        where O.StudentID = @StudentID and (E.Status = 'Completed' or E.Status = 'InProgress') and S.StudiesID = @StudiesID
    )
        begin
            with ClassesHappened as (
                select SC.StationaryClassID as ClassHappenedID, SC.AttendableID, 'Stationary' as ClassType, SC.StudySessionID
                from Studies S
                         inner join Classes C on S.StudiesID = C.StudiesID
                         inner join StationaryClasses SC on C.ClassID = SC.ClassID
                where S.StudiesID = @StudiesID
                union
                select OC.OnlineClassID, OC.AttendableID, 'Online',OC.StudySessionID
                from Studies S
                         inner join Classes C on S.StudiesID = C.StudiesID
                         inner join OnlineClasses OC on C.ClassID = OC.ClassID
                where S.StudiesID = @StudiesID
            ), AttendanceChecked as (
                select sum(convert(int, Attendance)) as attendanceRate, count(*) as totalClasses
                from ClassesHappened CH
                        inner join Attendable A on CH.AttendableID = A.AttendableID
                        inner join Attendances AT on A.AttendableID = AT.AttendableID
                where AT.StudentID = @StudentID
            ), AttendanceSessionsChecked as (
                select sum(convert(int, Attendance)) as attendanceRate, count(*) as totalClasses
                from ClassesHappened CH
                        inner join Attendable A on CH.AttendableID = A.AttendableID
                        inner join Attendances AT on A.AttendableID = AT.AttendableID
                where AT.StudentID = @StudentID and CH.StudySessionID is not null
            )
            select @Result = case
                               when ASCH.attendanceRate / ASCH.totalClasses < 1 then 0
                               when AC.attendanceRate / AC.totalClasses >= 0.8 then 1
                               else 0
                             end
            from AttendanceChecked AC, AttendanceSessionsChecked ASCH
        end
    else
        begin
            return null;
        end

    return @Result;
end
go

-- Lista studentów na zajęciach -M-
create function FN_Students_List(@AttendableID int)
returns table
as
return (
select A.*, T.StudentID, T.Name, T.Surname, T.Email
        from Attendable A inner join Internships I on I.AttendableID = A.AttendableID and A.AttendableID = @AttendableID
            inner join Studies D on D.StudiesID = I.StudiesID
            inner join Lectures L on L.LectureID = D.LectureID
            inner join Enrollments E on E.LectureID = L.LectureID and E.Status = 'InProgress'
            inner join Orders O on O.OrderID = E.OrderID
            inner join Students T on T.StudentID = O.StudentID
    union all
        select A.*, T.StudentID, T.Name, T.Surname, T.Email
        from Attendable A inner join StationaryClasses C on C.AttendableID = A.AttendableID and A.AttendableID = @AttendableID
            inner join Classes S on S.ClassID = C.ClassID
            inner join Studies D on D.StudiesID = S.StudiesID
            inner join Lectures L on L.LectureID = D.LectureID
            inner join Enrollments E on E.LectureID = L.LectureID and E.Status = 'InProgress'
            inner join Orders O on O.OrderID = E.OrderID
            inner join Students T on T.StudentID = O.StudentID
    union all
        select A.*, T.StudentID, T.Name, T.Surname, T.Email
        from Attendable A inner join StationaryClasses C on C.AttendableID = A.AttendableID and A.AttendableID = @AttendableID
            inner join Lectures L on L.LectureID = C.LectureID
            inner join Enrollments E on E.LectureID = L.LectureID and E.Status = 'InProgress'
            inner join Orders O on O.OrderID = E.OrderID
            inner join Students T on T.StudentID = O.StudentID
    union all
        select A.*, T.StudentID, T.Name, T.Surname, T.Email
        from Attendable A inner join OnlineClasses C on C.AttendableID = A.AttendableID and A.AttendableID = @AttendableID
            inner join Classes S on S.ClassID = C.ClassID
            inner join Studies D on D.StudiesID = S.StudiesID
            inner join Lectures L on L.LectureID = D.LectureID
            inner join Enrollments E on E.LectureID = L.LectureID and E.Status = 'InProgress'
            inner join Orders O on O.OrderID = E.OrderID
            inner join Students T on T.StudentID = O.StudentID
    union all
        select A.*, T.StudentID, T.Name, T.Surname, T.Email
        from Attendable A inner join OnlineClasses C on C.AttendableID = A.AttendableID and A.AttendableID = @AttendableID
            inner join Lectures L on L.LectureID = C.LectureID
            inner join Enrollments E on E.LectureID = L.LectureID and E.Status = 'InProgress'
            inner join Orders O on O.OrderID = E.OrderID
            inner join Students T on T.StudentID = O.StudentID
    union all
        select A.*, T.StudentID, T.Name, T.Surname, T.Email
        from Attendable A inner join StationaryCourseModules C on C.AttendableID = A.AttendableID and A.AttendableID = @AttendableID
            inner join CourseModules S on S.CourseModuleID = C.CourseModuleID
            inner join Courses D on D.CourseID = S.CourseID
            inner join Lectures L on L.LectureID = D.LectureID
            inner join Enrollments E on E.LectureID = L.LectureID and E.Status = 'InProgress'
            inner join Orders O on O.OrderID = E.OrderID
            inner join Students T on T.StudentID = O.StudentID
    union all
        select A.*, T.StudentID, T.Name, T.Surname, T.Email
        from Attendable A inner join OnlineCourseModules C on C.AttendableID = A.AttendableID and A.AttendableID = @AttendableID
            inner join CourseModules S on S.CourseModuleID = C.CourseModuleID
            inner join Courses D on D.CourseID = S.CourseID
            inner join Lectures L on L.LectureID = D.LectureID
            inner join Enrollments E on E.LectureID = L.LectureID and E.Status = 'InProgress'
            inner join Orders O on O.OrderID = E.OrderID
            inner join Students T on T.StudentID = O.StudentID
)
go

--Harmonogram nauczyciela -K-
create function FN_ScheduleForTeacher (@TeacherID int)
returns table
as
return (
    select
        a.AttendableID,
        a.StartDate,
        a.EndDate,
        case
            when ocm.OnlineCourseID is not null then 'Online Course Module'
            when scm.StationaryCourseID is not null then 'Stationary Course Module'
            when oc.OnlineClassID is not null then 'Online Class'
            when sc.StationaryClassID is not null then 'Stationary Class'
        end as EventType,
        case
            when ocm.OnlineCourseID is not null then cm.Name
            when scm.StationaryCourseID is not null then cm.Name
            when oc.OnlineClassID is not null then c.Name
            when sc.StationaryClassID is not null then c.Name
        end as EventName,
        case
            when ocm.OnlineCourseID is not null then 'Online'
            when scm.StationaryCourseID is not null then scm.Classroom
            when oc.OnlineClassID is not null then 'Online'
            when sc.StationaryClassID is not null then sc.Classroom
        end as Location
    from
        Attendable a
    left join OnlineCourseModules ocm on ocm.AttendableID = a.AttendableID
    left join StationaryCourseModules scm on scm.AttendableID = a.AttendableID
    left join OnlineClasses oc on oc.AttendableID = a.AttendableID
    left join StationaryClasses sc on sc.AttendableID = a.AttendableID
    left join CourseModules cm on cm.CourseModuleID = ocm.CourseModuleID or cm.CourseModuleID = scm.CourseModuleID
    left join Classes c on c.ClassID = oc.ClassID or c.ClassID = sc.ClassID
    where cm.TeacherID = @TeacherID or c.TeacherID = @TeacherID

    UNION ALL

    select '-',
           L.date,
           L.date,
           'Webinar',
           L.LectureName,
           Link
    from Webinars
    inner join dbo.Lectures L on Webinars.LectureID = L.LectureID
    where TeacherID = @TeacherID
)
go

--Harmonogram translatora -K-
create function FN_ScheduleForTranslator (@TranslatorID int)
returns table
as
return (
    select
        a.AttendableID,
        a.StartDate,
        a.EndDate,
        case
            when scm.StationaryCourseID is not null then 'Stationary Course Module'
            when sc.StationaryClassID is not null then 'Stationary Class'
            when ocm.OnlineCourseID is not null then 'Online Course Module'
            when oc.OnlineClassID is not null then 'Online Class'
        end as EventType,
        case
            when scm.StationaryCourseID is not null then cm.Name
            when sc.StationaryClassID is not null and c.Name is null then L.LectureName
            when sc.StationaryClassID is not null then c.Name
            when ocm.OnlineCourseID is not null then cm.Name
            when oc.OnlineClassID is not null and c.Name is null then L.LectureName
            when oc.OnlineClassID is not null then c.Name
        end as EventName,
        case
            when scm.StationaryCourseID is not null then scm.Classroom
            when sc.StationaryClassID is not null then sc.Classroom
            when ocm.OnlineCourseID is not null then 'Online'
            when oc.OnlineClassID is not null then 'Online'
        end as Location
    from
        Attendable a
    left join StationaryCourseModules scm on scm.AttendableID = a.AttendableID
    left join CourseModules cm on cm.CourseModuleID = scm.CourseModuleID
    left join StationaryClasses sc on sc.AttendableID = a.AttendableID
    left join Classes c on c.ClassID = sc.ClassID
    left join OnlineCourseModules ocm on ocm.AttendableID = a.AttendableID
    left join OnlineClasses oc on oc.AttendableID = a.AttendableID
    left join Courses on cm.CourseID = Courses.CourseID
    left join dbo.Studies S on c.StudiesID = S.StudiesID
    left join dbo.Lectures L on Courses.LectureID = L.LectureID or
                                S.LectureID = L.LectureID or
                                sc.LectureID = L.LectureID or
                                oc.LectureID = L.LectureID
    where L.TranslatorID = @TranslatorID
);
go