-- Listy obecności na szkoleniach -M-
create view VW_All_Attendance as
select D.AttendableID, D.StartDate, D.EndDate, S.StudentID, S.Name, S.Surname, A.Attendance, A.CompensationAttendableID
from Attendances A inner join Students S on S.StudentID = A.StudentID
    inner join Attendable D on D.AttendableID = A.AttendableID;
go

create view VW_Internships_Attendance as
select 'Internship' Type, I.InternshipID, I.StudiesID, I.Address, I.Name InternshipName, I.Description, A.*
from VW_All_Attendance A inner join Internships I on I.AttendableID = A.AttendableID;
go

create view VW_StationaryClasses_Attendance as
select 'StationaryClass' Type, C.StationaryClassID, C.ClassID, C.StudySessionID, C.Classroom, S.TeacherID, S.Name ClassName, S.Description, A.*
from VW_All_Attendance A inner join StationaryClasses C on C.AttendableID = A.AttendableID
    inner join Classes S on S.ClassID = C.ClassID;
go

create view VW_OnlineClasses_Attendance as
select 'OnlineClass' Type, C.OnlineClassID, C.ClassID, C.StudySessionID, C.IsLive, S.TeacherID, S.Name ClassName, S.Description, A.*
from VW_All_Attendance A inner join OnlineClasses C on C.AttendableID = A.AttendableID
    inner join Classes S on S.ClassID = C.ClassID;
go

create view VW_StationaryCourseModules_Attendance as
select 'StationaryCourseModule' Type, M.StationaryCourseID, M.Classroom, C.CourseModuleID, C.CourseID, C.TeacherID, C.Name CourseName, C.Description, A.*
from VW_All_Attendance A inner join StationaryCourseModules M on M.AttendableID = A.AttendableID
    inner join CourseModules C on C.CourseModuleID = M.CourseModuleID;
go

create view VW_OnlineCourseModules_Attendance as
select 'OnlineCourseModule' Type, M.OnlineCourseID, M.IsLive, C.CourseModuleID, C.CourseID, C.TeacherID, C.Name CourseName, C.Description, A.*
from VW_All_Attendance A inner join OnlineCourseModules M on M.AttendableID = A.AttendableID
    inner join CourseModules C on C.CourseModuleID = M.CourseModuleID;
go

-- Raport dotyczący frekwencji na zakończonych już wydarzeniach. -K-
create view VW_All_Attendance_Summary as
select A.AttendableID, A.StartDate, A.EndDate, count(A.StudentID) TotalStudents, sum(case when A.Attendance = 1 then 1 else 0 end) as PresentStudents,
    round( cast(sum(case when A.Attendance = 1 then 1 else 0 end) as float) / count(A.StudentID) * 100, 2 ) as AttendanceRate
from VW_All_Attendance A 
where A.EndDate < getdate()
group by A.AttendableID, A.StartDate, A.EndDate
go

create view VW_OnlineCourseModules_Attendance_Summary as
select A.attendableid, totalstudents, presentstudents, attendancerate, OCM.OnlineCourseID, CM.CourseModuleID, CourseID, Link, IsLive, TeacherID, Name, Description
    from VW_All_Attendance_Summary A
             inner join OnlineCourseModules OCM on A.attendableid = OCM.AttendableID
             inner join dbo.CourseModules CM on OCM.CourseModuleID = CM.CourseModuleID;
go

create view VW_StationaryCourseModules_Attendance_Summary as
select A.attendableid, totalstudents, presentstudents, attendancerate, SCM.StationaryCourseID, CourseID, CM.CourseModuleID, Classroom, SeatLimit,  TeacherID, CourseID, Name, Description
from VW_All_Attendance_Summary A
             inner join StationaryCourseModules SCM on A.attendableid = SCM.AttendableID
inner join dbo.CourseModules CM on SCM.CourseModuleID = CM.CourseModuleID
go

create view VW_OnlineClasses_Attendance_Summary as
select A.attendableid, totalstudents, presentstudents, attendancerate, OC.OnlineClassID, OC.ClassID, StudySessionID, Link, IsLive, StudiesID, TeacherID, Name, Description
    from VW_All_Attendance_Summary A
             inner join OnlineClasses OC on A.attendableid = OC.AttendableID
             inner join Classes C on OC.ClassID = C.ClassID
go

create view VW_StationaryClasses_Attendance_Summary as
select A.attendableid, totalstudents, presentstudents, attendancerate, SC.StationaryClassID, SC.ClassID, StudySessionID, Classroom, SeatLimit, StudiesID, TeacherID, Name, Description
    from VW_All_Attendance_Summary A
             inner join StationaryClasses SC on A.attendableid = SC.AttendableID
             inner join dbo.Classes C on C.ClassID = SC.ClassID
go

create view VW_Internships_Attendance_Summary as
select A.AttendableID, TotalStudents, PresentStudents, AttendanceRate, StartDate,EndDate, I.InternshipID, StudiesID, Address, Name, Description
    from VW_All_Attendance_Summary A
             inner join Internships I on A.attendableid = I.AttendableID
go

-- Lista przyszłych szkoleń -K-
create view VW_All_FutureLectures as
select distinct L.LectureID, L.LectureName ,L.Date
from Lectures L inner join Enrollments E on E.LectureID = L.LectureID
    and E.Status = 'InProgress' and L.Date > getdate();
go

create view VW_Future_CourseModules as
select C.CourseID, M.CourseModuleID, A.LectureName, A.Date, case when O.CourseModuleID is not null then 'Online' else 'Stationary' end Type
from VW_All_FutureLectures A inner join Courses C on C.LectureID = A.LectureID
    inner join CourseModules M on M.CourseID = C.CourseID
    left outer join OnlineCourseModules O on O.CourseModuleID = M.CourseModuleID
    left outer join StationaryCourseModules S on S.CourseModuleID = M.CourseModuleID;
go

create view VW_Future_Webinars as
select W.WebinarID, A.LectureName,A.LectureID, A.Date, 'Online' Type
from VW_All_FutureLectures A inner join Webinars W on W.LectureID = A.LectureID;
go

create view VW_Future_Classes as
select D.StudiesID, C.ClassID, A.LectureName, A.Date, case when O.OnlineClassID is not null then 'Online' else 'Stationary' end Type
from VW_All_FutureLectures A inner join Studies D on D.LectureID = A.LectureID
    inner join Classes C on C.StudiesID = D.StudiesID
    left outer join OnlineClasses O on O.ClassID = C.ClassID
    left outer join StationaryClasses S on S.ClassID = C.ClassID;
go

create view VW_Future_Internships as
select D.StudiesID, I.InternshipID, A.LectureName, A.Date, 'Stationary' Type
from VW_All_FutureLectures A inner join Studies D on D.LectureID = A.LectureID
    inner join Internships I on I.StudiesID = D.StudiesID;
go

-- Liczba osób zapisanych na przyszłe wydarzenia -M-
create view VW_All_FutureParticipants as
select L.LectureID, L.LectureName, L.Description LectureDescription, L.Language, L.Date, count(E.EnrollmentID) TotalFutureParticipants
from Lectures L inner join Enrollments E on E.LectureID = L.LectureID
    and E.Status = 'InProgress' and L.Date > getdate()
group by L.LectureID, L.LectureName, L.Description, L.Language, L.Date;
go

create view VW_CourseModules_FutureParticipants as
select coalesce(O.OnlineCourseID, S.StationaryCourseID) CouseModuleMeetingID, case when O.CourseModuleID is not null then 'Online' else 'Stationary' end Type,
    C.CourseID, M.CourseModuleID, M.Name, M.Description, M.TeacherID, A.*
from VW_All_FutureParticipants A inner join Courses C on C.LectureID = A.LectureID
    inner join CourseModules M on M.CourseID = C.CourseID
    left outer join OnlineCourseModules O on O.CourseModuleID = M.CourseModuleID
    left outer join StationaryCourseModules S on S.CourseModuleID = M.CourseModuleID;
go

create view VW_Webinars_FutureParticipants as
select W.WebinarID, W.TeacherID, 'Online' Type, A.*
from VW_All_FutureParticipants A inner join Webinars W on W.LectureID = A.LectureID;
go

create view VW_Classes_FutureParticipants as
select coalesce(O.OnlineClassID, S.StationaryClassID) ClassMeetingID,  case when O.OnlineClassID is not null then 'Online' else 'Stationary' end Type,
    D.StudiesID, C.ClassID, C.Name, C.Description, C.TeacherID, S.Classroom, O.IsLive, A.*
from VW_All_FutureParticipants A inner join Studies D on D.LectureID = A.LectureID
    inner join Classes C on C.StudiesID = D.StudiesID
    left outer join OnlineClasses O on O.ClassID = C.ClassID
    left outer join StationaryClasses S on S.ClassID = C.ClassID;
go

create view VW_Internships_FutureParticipants as
select D.StudiesID, I.InternshipID, I.Name, I.Description, I.Address, 'Stationary' Type, A.*
from VW_All_FutureParticipants A inner join Studies D on D.LectureID = A.LectureID
    inner join Internships I on I.StudiesID = D.StudiesID;
go

-- Raport bilokacji - osoby zapisane na zajęcia kolidujące czasowo -M-
create view VW_All_FutureEnrollments as
select S.*, L.LectureID, L.LectureName, L.Description, L.Date
from Enrollments E inner join Lectures L on L.LectureID = E.LectureID
    and E.Status = 'InProgress' and L.Date > getdate()
    inner join Orders O on O.OrderID = E.OrderID
    inner join Students S on S.StudentID = O.OrderID;
go

create view VW_Students_Bilocations as
with students_allAttendable as (
        select L.StudentID, L.Name, L.Surname, L.LectureID, L.LectureName, 
            A.StartDate, A.EndDate, I.InternshipID ID, 'Internship' Type
        from Attendable A inner join Internships I on I.AttendableID = A.AttendableID
            inner join Studies S on S.StudiesID = I.StudiesID
            inner join VW_All_FutureEnrollments L on L.LectureID = S.LectureID
    union all
        select L.StudentID, L.Name, L.Surname, L.LectureID, L.LectureName,
            A.StartDate, A.EndDate, Sc.StationaryClassID ID, 'StationaryClass' Type
        from Attendable A inner join StationaryClasses Sc on Sc.AttendableID = A.AttendableID
            inner join Classes C on C.ClassID = Sc.ClassID
            inner join Studies S on S.StudiesID = C.StudiesID
            inner join VW_All_FutureEnrollments L on L.LectureID = S.LectureID
    union all
        select L.StudentID, L.Name, L.Surname, L.LectureID, L.LectureName,
            A.StartDate, A.EndDate, O.OnlineClassID ID, 'OnlineClass' Type
        from Attendable A inner join OnlineClasses O on O.AttendableID = A.AttendableID
            inner join Classes C on C.ClassID = O.ClassID
            inner join Studies S on S.StudiesID = C.StudiesID
            inner join VW_All_FutureEnrollments L on L.LectureID = S.LectureID
    union all
        select L.StudentID, L.Name, L.Surname, L.LectureID, L.LectureName,
            A.StartDate, A.EndDate, O.OnlineCourseID ID, 'OnlineCourseModule' Type
        from Attendable A inner join OnlineCourseModules O on O.AttendableID = A.AttendableID
            inner join CourseModules M on M.CourseModuleID = O.CourseModuleID
            inner join Courses C on C.CourseID = M.CourseID
            inner join VW_All_FutureEnrollments L on L.LectureID = C.LectureID
    union all
        select L.StudentID, L.Name, L.Surname, L.LectureID, L.LectureName,
            A.StartDate, A.EndDate, S.StationaryCourseID ID, 'StationaryCourseModule' Type
        from Attendable A inner join StationaryCourseModules S on S.AttendableID = A.AttendableID
            inner join CourseModules M on M.CourseModuleID = S.CourseModuleID
            inner join Courses C on C.CourseID = M.CourseID
            inner join VW_All_FutureEnrollments L on L.LectureID = C.LectureID
)

select A.StudentID, A.Name, A.Surname, 
    A.LectureID, A.LectureName, A.ID, A.Type, A.StartDate, A.EndDate, 
    B.LectureID LectureID2, B.LectureName LectureName2, B.ID ID2, B.Type Type2,
        B.StartDate StartDate2, B.EndDate EndDate2
from students_allAttendable A inner join students_allAttendable B
    on A.StudentID = B.StudentID and B.StartDate < A.EndDate and B.EndDate > A.StartDate
    and (A.LectureID != B.LectureID or A.ID != B.ID or A.Type != B.Type)
go

-- Zestawienie przychodów dla każdego szkolenia -K-
select
    l.LectureID,
    COALESCE(CAST(w.WebinarID AS NVARCHAR), CAST(c.CourseID AS NVARCHAR), CAST(s.StudiesID AS NVARCHAR),CAST(oc.OnlineClassID AS NVARCHAR),CAST(sc.StationaryClassID AS NVARCHAR)) AS EventID,
    case
        when w.WebinarID is not null then 'Webinar'
        when c.CourseID is not null then 'Course'
        when s.StudiesID is not null then 'Study'
        when oc.OnlineClassID is not null then 'OnlineClass'
        when sc.StationaryClassID is not null then 'StationaryClass'
    end as EventType,
    count(e.EnrollmentID) as TotalEnrollments,
    sum(e.TotalPrice) as TotalRevenue
from Lectures l
left join Webinars w on l.LectureID = w.LectureID
left join Courses c on l.LectureID = c.LectureID
left join Studies s on l.LectureID = s.LectureID
left join OnlineClasses oc on l.LectureID = oc.LectureID
left join StationaryClasses sc on l.LectureID = sc.LectureID
inner join Enrollments e on l.LectureID = e.LectureID and e.status in ('Completed', 'InProgress')
group by l.LectureID, w.WebinarID, c.CourseID, s.StudiesID, oc.OnlineClassID, sc.StationaryClassID;
go

-- Lista dłużników -K-
create view VW_All_Loaners as
select s.StudentID, s.Name, s.Surname, sum(TotalPrice) as TotalLoan
from Students s
inner join Orders O on s.StudentID = O.StudentID
inner join PostponedPayments P on O.OrderID = P.OrderID
inner join Enrollments E on O.OrderID = E.OrderID
group by s.StudentID, s.Name, s.Surname;
go