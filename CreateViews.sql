-- Listy obecności na szkoleniach -M-
create view VW_All_Attendance as
select D.AttendableID, D.StartDate, D.EndDate, S.StudentID, S.Name, S.Surname, A.Attendance, A.CompensationAttendableID
from Attendances A inner join Students S on S.StudentID = A.StudentID
    inner join Attendable D on D.AttendableID = A.AttendableID;
go

create view VW_Internships_Attendance as
select 'Internship' Type, I.InternshipID, I.StudiesID, I.Address, I.Name, I.Description, A.*
from VW_All_Attendance A inner join Internships I on I.AttendableID = A.AttendableID;
go

create view VW_StationaryClasses_Attendance as
select 'StationaryClass' Type, C.StationaryClassID, C.ClassID, C.StudySessionID, C.Classroom, S.TeacherID, S.Name, S.Description, A.*
from VW_All_Attendance A inner join StationaryClasses C on C.AttendableID = A.AttendableID
    inner join Classes S on S.ClassID = C.ClassID;
go

create view VW_OnlineClasses_Attendance as
select 'OnlineClass' Type, C.OnlineClassID, C.ClassID, C.StudySessionID, C.IsLive, S.TeacherID, S.Name, S.Description, A.*
from VW_All_Attendance A inner join OnlineClasses C on C.AttendableID = A.AttendableID
    inner join Classes S on S.ClassID = C.ClassID;
go

create view VW_StationaryCourseModules_Attendance as
select 'StationaryCourseModule' Type, M.StationaryCourseID, M.Classroom, C.*, A.*
from VW_All_Attendance A inner join StationaryCourseModules M on M.AttendableID = A.AttendableID
    inner join CourseModules C on C.CourseModuleID = M.CourseModuleID;
go

create view VW_OnlineCourseModules_Attendance as
select M.OnlineCourseID, 'OnlineCourseModule' Type, M.OnlineCourseID, M.IsLive, C.*, A.*
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
select A.attendableid, totalstudents, presentstudents, attendancerate, OCM.OnlineCourseID, CourseModuleID, Link, IsLive
from VW_All_Attendance_Summary A
             inner join OnlineCourseModules OCM on A.attendableid = OCM.AttendableID;
go

create view VW_StationaryCourseModules_Attendance_Summary as
select A.attendableid, totalstudents, presentstudents, attendancerate, SCM.StationaryCourseID, CourseModuleID, Classroom, SeatLimit
from VW_All_Attendance_Summary A
             inner join StationaryCourseModules SCM on A.attendableid = SCM.AttendableID;
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
select L.LectureID, L.LectureName, L.Description, L.Language, L.Date, count(E.EnrollmentID) TotalFutureParticipants
from Lectures L inner join Enrollments E on E.LectureID = L.LectureID
    and E.Status = 'InProgress' and L.Date > getdate()
group by L.LectureID, L.LectureName, L.Description, L.Language, L.Date;
go

create view VW_CourseModules_FutureParticipants as
select C.CourseID, M.CourseModuleID, M.Name, M.Description, M.TeacherID, 
    case when O.CourseModuleID is not null then 'Online' else 'Stationary' end Type, A.*
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
select D.StudiesID, C.ClassID, C.Name, C.Description, C.TeacherID, S.Classroom, O.IsLive,
    case when O.OnlineClassID is not null then 'Online' else 'Stationary' end Type, A.*
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
        select L.*, A.StartDate, A.EndDate, I.InternshipID, 'Internship' Type
        from Attendable A inner join Internships I on I.AttendableID = A.AttendableID
            inner join Studies S on S.StudiesID = I.StudiesID
            inner join VW_All_FutureEnrollments L on L.LectureID = S.LectureID
    union all
        select L.*, A.StartDate, A.EndDate, Sc.StationaryClassID, 'StationaryClass' Type
        from Attendable A inner join StationaryClasses Sc on Sc.AttendableID = A.AttendableID
            inner join Classes C on C.ClassID = Sc.ClassID
            inner join Studies S on S.StudiesID = C.StudiesID
            inner join VW_All_FutureEnrollments L on L.LectureID = S.LectureID
    union all
        select L.*, A.StartDate, A.EndDate, O.OnlineClassID, 'OnlineClass' Type
        from Attendable A inner join OnlineClasses O on O.AttendableID = A.AttendableID
            inner join Classes C on C.ClassID = O.ClassID
            inner join Studies S on S.StudiesID = C.StudiesID
            inner join VW_All_FutureEnrollments L on L.LectureID = S.LectureID
    union all
        select L.*, A.StartDate, A.EndDate, O.OnlineCourseID, 'OnlineCourseModule' Type
        from Attendable A inner join OnlineCourseModules O on O.AttendableID = A.AttendableID
            inner join CourseModules M on M.CourseModuleID = O.CourseModuleID
            inner join Courses C on C.CourseID = M.CourseID
            inner join VW_All_FutureEnrollments L on L.LectureID = C.LectureID
    union all
        select L.*, A.StartDate, A.EndDate, S.StationaryCourseID, 'StationaryCourseModule' Type
        from Attendable A inner join StationaryCourseModules S on S.AttendableID = A.AttendableID
            inner join CourseModules M on M.CourseModuleID = S.CourseModuleID
            inner join Courses C on C.CourseID = M.CourseID
            inner join VW_All_FutureEnrollments L on L.LectureID = C.LectureID
)

select distinct *
from students_allAttendable A inner join students_allAttendable B
    on A.StudentID = B.StudentID and B.StartDate < A.EndDate;
go

-- Zestawienie przychodów dla każdego szkolenia -K-
create view VW_FinancialReports as
select
    l.LectureID,
    COALESCE(CAST(w.WebinarID AS NVARCHAR), CAST(c.CourseID AS NVARCHAR), CAST(s.StudiesID AS NVARCHAR)) AS EventID,
    case
        when w.WebinarID is not null then 'Webinar'
        when c.CourseID is not null then 'Course'
        when s.StudiesID is not null then 'Study'
    end as EventType,
    count(e.EnrollmentID) as TotalEnrollments,
    sum(e.TotalPrice) as TotalRevenue
from Lectures l
left join Webinars w on l.LectureID = w.LectureID
left join Courses c on l.LectureID = c.LectureID
left join Studies s on l.LectureID = s.LectureID
inner join Enrollments e on l.LectureID = e.LectureID and e.status in ('Completed', 'InProgress')
group by l.LectureID, w.WebinarID, c.CourseID, s.StudiesID;
go

-- Lista dłużników -K-
create view VW_All_Loaners as
select s.StudentID, s.Name, s.Surname, sum(TotalPrice) as TotalLoan
from Students s
inner join Orders O on s.StudentID = O.StudentID
inner join PostponedPayments P on O.OrderID = P.OrderID
inner join Enrollments E on O.OrderID = E.OrderID
group by s.StudentID, s.Name, s.Surname
go