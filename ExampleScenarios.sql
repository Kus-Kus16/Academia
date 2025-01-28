--Gosc chce wyświetlić przyszłe szkolenia

select * from VW_All_FutureLectures

--Gosc chce się zarejestrować

execute PR_Add_Student
    @Name = 'Jan',
    @Surname = 'Kowalski',
    @Email = 'JanKowalski@gmail.com',
    @Phone = '+48123456789',
    @Address = 'ul. Kowalskiego 1, 00-001 Warsaw',
    @City = 'Warsaw',
    @Country = 'Poland',
    @BirthDate = '1990-01-01'

-------------------------------------------------------
-------------------------------------------------------

-- Student chce kupić szkolenie

declare @CurrentStudentID int
set @CurrentStudentID = 1

execute PR_Create_Cart
    @StudentId = @CurrentStudentID

execute PR_Add_To_Cart
    @StudentID = @CurrentStudentID,
    @LectureID = 355

declare @LastOrderID int
set @LastOrderID = (select max(OrderID) from Orders)

execute PR_Place_Order
    @OrderID = @LastOrderID

-- Student 1 chce zobaczyć swój harmonogram
declare @CurrentStudentID int
set @CurrentStudentID = 1

select * from FN_ScheduleForStudent(@CurrentStudentID)

-- Student 1 chce zobaczyć czy kolidują mu jakieś zajęcia
declare @CurrentStudentID int
set @CurrentStudentID = 1

select * from VW_Students_Bilocations
    where StudentID = @CurrentStudentID

-------------------------------------------------------
-------------------------------------------------------

-- Nauczyciel chce zobaczyć swoje zajęcia
declare @CurrentTeacher int
set @CurrentTeacher = 9

select * from FN_scheduleForTeacher (@CurrentTeacher)

-- Nauczyciel chce zobaczyć całkowitą obecność na jego zajęciach na studiach
declare @CurrentTeacher int
set @CurrentTeacher = 9

select * from VW_OnlineClasses_Attendance_Summary
         where TeacherID = @CurrentTeacher

select * from VW_StationaryClasses_Attendance_Summary
    where TeacherID = @CurrentTeacher

-- Nauczyciel chce zobaczyć całkowitą obecność na jego zajęciach na kursach
declare @CurrentTeacher int
set @CurrentTeacher = 9

select * from VW_OnlineCourseModules_Attendance_Summary
         where TeacherID = @CurrentTeacher

select * from VW_StationaryCourseModules_Attendance_Summary
    where TeacherID = @CurrentTeacher

--Nauczyciel wstawia obecność

declare @CurrentTeacher int
set @CurrentTeacher = 9

declare @CurrentAttendableID int
set @CurrentAttendableID = 2151

select ST.StudentID, ST.Name, ST.Surname, A.AttendableID, A.StartDate
from Attendable A
    join StationaryClasses SC on A.AttendableID = SC.AttendableID
    join Classes C on SC.ClassID = C.ClassID and C.TeacherID = @CurrentTeacher
    join Studies S on C.StudiesID = S.StudiesID
    join Lectures L on S.LectureID = L.LectureID
    join Enrollments E on L.LectureID = E.LectureID
    join Orders O on E.OrderID = O.OrderID
    join Students ST on O.StudentID = ST.StudentID
where A.AttendableID = @CurrentAttendableID

declare @AttendanceList AttendanceListTable;
insert into @AttendanceList (StudentID, Attendance)
values
    (4, 1),
    (197, 0),
    (265, 1),
    (292, 1),
    (374, 0),
    (483, 1),
    (533, 1),
    (621, 1);

select * from @AttendanceList

execute PR_Set_Attendances
        @AttendableID = 2151,
        @AttendanceList = @AttendanceList

-------------------------------------------------------
-------------------------------------------------------

--Dyrektor chce zobaczyć raport finansowy
select * from VW_FinancialReports

--Dyrektor chce zobaczyć przyszłe wydarzenia
select * from VW_All_FutureLectures

--Dyrektor chce zobaczyć ilość studentów zapisanych na przyszłe wydarzenia
select * from VW_All_FutureParticipants

--Dyrektor chce zobaczyć sumaryczną obecność na zajęciach
select * from VW_All_Attendance_Summary

-------------------------------------------------------
-------------------------------------------------------


--Pracownik Sekretariatu chce dodać nową klasę
execute PR_Create_Class
    @StudiesID = 'YTJUe',
    @TeacherID = 9,
    @Name = 'Klasa testowa',
    @Description = 'Klasa testowa'

--Pracownik Sekretariatu chce zmienić limit miejsc na studiach
update Studies
    set CapacityLimit = 110
    where StudiesID = 'YTJUe'

--Pracownik Sekretariatu chce zmienić nazwę klasy
update Classes
    set Name = 'Klasa testowa 2'
    where ClassID = (select max(ClassID) from Classes)

