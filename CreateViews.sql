-- Listy obecności na szkoleniach
create view VW_All_Attendance as
select D.AttendableID, D.StartDate, D.EndDate, S.Name, S.Surname, A.Attendance
from Attendances A inner join Students S on S.StudentID = A.StudentID
    inner join Attendable D on D.AttendableID = A.AttendableID;
go

create view VW_Internships_Attendance as
select I.InternshipID, 'Internship' Type, A.StartDate, A.Name, A.Surname, A.Attendance
from VW_All_Attendance A inner join Internships I on I.AttendableID = A.AttendableID;
go

create view VW_StationaryClasses_Attendance as
select C.StationaryClassID, 'StationaryClass' Type, A.StartDate, A.Name, A.Surname, A.Attendance
from VW_All_Attendance A inner join StationaryClasses C on C.AttendableID = A.AttendableID;
go

create view VW_OnlineClasses_Attendance as
select C.OnlineClassID, 'OnlineClass' Type, A.StartDate, A.Name, A.Surname, A.Attendance
from VW_All_Attendance A inner join OnlineClasses C on C.AttendableID = A.AttendableID;
go

create view VW_StationaryCourseModules_Attendance as
select M.StationaryCourseID, 'StationaryCourseModule' Type, A.StartDate, A.Name, A.Surname, A.Attendance
from VW_All_Attendance A inner join StationaryCourseModules M on M.AttendableID = A.AttendableID;
go

create view VW_OnlineCourseModules_Attendance as
select M.OnlineCourseID, 'OnlineCourseModule' Type, A.StartDate, A.Name, A.Surname, A.Attendance
from VW_All_Attendance A inner join OnlineCourseModules M on M.AttendableID = A.AttendableID;
go

create view VW_Total_Attendance as
    (select * from VW_Internships_Attendance)
    union all
    (select * from VW_StationaryClasses_Attendance)
    union all
    (select * from VW_OnlineClasses_Attendance)
    union all
    (select * from VW_StationaryCourseModules_Attendance)
    union all
    (select * from VW_OnlineCourseModules_Attendance);
go

-- Liczba osób zapisanych na przyszłe wydarzenia
create view VW_All_FutureParticipants as
select L.LectureID, L.Date, count(E.EnrollmentID) TotalFutureParticipants
from Lectures L inner join Enrollments E on E.LectureID = L.LectureID
    and E.Status = 'InProgress' and L.Date > getdate()
group by L.LectureID, L.Date;
go

create view VW_CourseModules_FutureParticipants as
select C.CourseID, M.CourseModuleID, A.TotalFutureParticipants, case when O.CourseModuleID is not null then 'Online' else 'Stationary' end Type
from VW_All_FutureParticipants A inner join Courses C on C.LectureID = A.LectureID
    inner join CourseModules M on M.CourseID = C.CourseID
    left outer join OnlineCourseModules O on O.CourseModuleID = M.CourseModuleID
    left outer join StationaryCourseModules S on S.CourseModuleID = M.CourseModuleID;
go

create view VW_Webinars_FutureParticipants as
select W.WebinarID, A.TotalFutureParticipants, 'Online' Type
from VW_All_FutureParticipants A inner join Webinars W on W.LectureID = A.LectureID;
go

create view VW_Classes_FutureParticipants as
select D.StudiesID, C.ClassID, A.TotalFutureParticipants, case when O.OnlineClassID is not null then 'Online' else 'Stationary' end Type
from VW_All_FutureParticipants A inner join Studies D on D.LectureID = A.LectureID
    inner join Classes C on C.StudiesID = D.StudiesID
    left outer join OnlineClasses O on O.ClassID = C.ClassID
    left outer join StationaryClasses S on S.ClassID = C.ClassID;
go

create view VW_Internships_FutureParticipants as
select D.StudiesID, I.InternshipID, A.TotalFutureParticipants, 'Stationary' Type
from VW_All_FutureParticipants A inner join Studies D on D.LectureID = A.LectureID
    inner join Internships I on I.StudiesID = D.StudiesID;
go

-- Raport bilokacji - osoby zapisane na zajęcia kolidujące czasowo
create view VW_All_FutureEnrollments as
select S.StudentID, S.Name, S.Surname, L.LectureID
from Enrollments E inner join Lectures L on L.LectureID = E.LectureID
    and E.Status = 'InProgress' and L.Date > getdate()
    inner join Orders O on O.OrderID = E.OrderID
    inner join Students S on S.StudentID = O.OrderID;
go

create view VW_Students_Bilocations as
with students_allAttendable as (
        select L.StudentID, L.Name, L.Surname, A.StartDate, A.EndDate
        from Attendable A inner join Internships I on I.AttendableID = A.AttendableID
            inner join Studies S on S.StudiesID = I.StudiesID
            inner join VW_All_FutureEnrollments L on L.LectureID = S.LectureID
    union all
        select L.StudentID, L.Name, L.Surname, A.StartDate, A.EndDate
        from Attendable A inner join StationaryClasses Sc on Sc.AttendableID = A.AttendableID
            inner join Classes C on C.ClassID = Sc.ClassID
            inner join Studies S on S.StudiesID = C.StudiesID
            inner join VW_All_FutureEnrollments L on L.LectureID = S.LectureID
    union all
        select L.StudentID, L.Name, L.Surname, A.StartDate, A.EndDate
        from Attendable A inner join OnlineClasses O on O.AttendableID = A.AttendableID
            inner join Classes C on C.ClassID = O.ClassID
            inner join Studies S on S.StudiesID = C.StudiesID
            inner join VW_All_FutureEnrollments L on L.LectureID = S.LectureID
    union all
        select L.StudentID, L.Name, L.Surname, A.StartDate, A.EndDate
        from Attendable A inner join OnlineCourseModules O on O.AttendableID = A.AttendableID
            inner join CourseModules M on M.CourseModuleID = O.CourseModuleID
            inner join Courses C on C.CourseID = M.CourseID
            inner join VW_All_FutureEnrollments L on L.LectureID = C.LectureID
    union all
        select L.StudentID, L.Name, L.Surname, A.StartDate, A.EndDate
        from Attendable A inner join StationaryCourseModules S on S.AttendableID = A.AttendableID
            inner join CourseModules M on M.CourseModuleID = S.CourseModuleID
            inner join Courses C on C.CourseID = M.CourseID
            inner join VW_All_FutureEnrollments L on L.LectureID = C.LectureID
)

select distinct A.StudentID, A.Name, A.Surname
from students_allAttendable A inner join students_allAttendable B
    on A.StudentID = B.StudentID and B.StartDate < A.EndDate;
go

--Lista dłużników
create view VW_All_Loaners as
select distinct s.StudentID, s.Name, s.Surname
from Students s inner join Orders O on s.StudentID = O.StudentID
inner join Loans L on O.OrderID = L.OrderID;
go

--Zestawienie przychodów dla każdego webinaru/kursu/studium.
create view VW_FinancialReports as
select
    l.LectureID,
    coalesce(w.WebinarID, c.CourseID, s.StudiesID) as EventID,
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

--Raport dotyczący frekwencji na zakończonych już wydarzeniach.
create view VW_Attendance_Summary as
select a.attendableid, count(*) as totalstudents, sum(case when at.attendance = 1 then 1 else 0 end) as presentstudents,
round(cast(sum(case when at.attendance = 1 then 1 else 0 end) as float) / count(*) * 100, 2) as attendancerate
from attendable a inner join attendances at on a.attendableid = at.attendableid
where a.enddate < getdate()
group by a.attendableid;
go

create view VW_Attendance_CourseModules as
select A.attendableid, totalstudents, presentstudents, attendancerate
from VW_Attendance_Summary A
left outer join OnlineCourseModules OCM on A.attendableid = OCM.AttendableID
left outer join StationaryCourseModules SCM on OCM.AttendableID = SCM.AttendableID;
go

create view VW_Attendance_Classes as
select A.attendableid, totalstudents, presentstudents, attendancerate
from VW_Attendance_Summary A
left outer join OnlineClasses OC on A.attendableid = OC.AttendableID
left outer join StationaryClasses SC on A.attendableid = SC.AttendableID;
go

create view VW_Attendance_Internships as
select A.attendableid, totalstudents, presentstudents, attendancerate
from VW_Attendance_Summary A
inner join Internships I on A.attendableid = I.AttendableID;
go


--Lista przyszłych wydarzeń
create view VW_All_FutureLectures as
select L.LectureID, L.Date
from Lectures L inner join Enrollments E on E.LectureID = L.LectureID
    and E.Status = 'InProgress' and L.Date > getdate();
go

create view VW_Future_CourseModules as
select C.CourseID, M.CourseModuleID, A.Date, case when O.CourseModuleID is not null then 'Online' else 'Stationary' end Type
from VW_All_FutureLectures A inner join Courses C on C.LectureID = A.LectureID
    inner join CourseModules M on M.CourseID = C.CourseID
    left outer join OnlineCourseModules O on O.CourseModuleID = M.CourseModuleID
    left outer join StationaryCourseModules S on S.CourseModuleID = M.CourseModuleID;
go

create view VW_Future_Webinars as
select W.WebinarID, A.Date, 'Online' Type
from VW_All_FutureLectures A inner join Webinars W on W.LectureID = A.LectureID;
go

create view VW_Future_Classes as
select D.StudiesID, C.ClassID, A.Date, case when O.OnlineClassID is not null then 'Online' else 'Stationary' end Type
from VW_All_FutureLectures A inner join Studies D on D.LectureID = A.LectureID
    inner join Classes C on C.StudiesID = D.StudiesID
    left outer join OnlineClasses O on O.ClassID = C.ClassID
    left outer join StationaryClasses S on S.ClassID = C.ClassID;
go

create view VW_Future_Internships as
select D.StudiesID, I.InternshipID, A.Date, 'Stationary' Type
from VW_All_FutureLectures A inner join Studies D on D.LectureID = A.LectureID
    inner join Internships I on I.StudiesID = D.StudiesID;
go