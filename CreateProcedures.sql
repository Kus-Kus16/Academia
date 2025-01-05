-- Stworzenie koszyka -M-
create procedure PR_Create_Cart
@StudentID int,
@OrderID int output
as
begin
set nocount on;

if not exists (select 1 from Students S where S.StudentID = @StudentID)
    begin
    raiserror('Student with given ID does not exist', 16, 0);
    return;
    end

insert into Orders (StudentID, Status)
    values (@StudentID, 'Cart');
set @OrderID = scope_identity();
print 'Cart created successfuly';

end
go;

-- Dodanie szkolenia do koszyka -M-
create procedure PR_Add_To_Cart
@StudentID int,
@LectureID int
as
begin
declare @AdvancePrice money;
declare @TotalPrice money;
declare @OrderID int;
set nocount on;

if not exists (select 1 from Lectures L where L.LectureID = @LectureID)
    begin
    raiserror('Lecture with given ID does not exist', 16, 0);
    return;
    end

(select @AdvancePrice = L.AdvancePrice, @TotalPrice = L.TotalPrice from Lectures L where L.LectureID = @LectureID);

set @OrderID = (select O.OrderID from Orders O where O.StudentID = @StudentID and O.Status = 'Cart');
if @OrderID is null
    begin
    exec PR_Create_Cart
        @StudentID = @StudentID,
        @OrderID = @OrderID output;
    end

insert into Enrollments (OrderID, LectureID, AdvancePrice, TotalPrice, Status)
    values (@OrderID, @LectureID, @AdvancePrice, @TotalPrice, 'AwaitingPayment');
print 'Lecture added to cart successfuly';

end
go;

-- Dodanie obecności na zajęciach dla studentów -M-
create type AttendanceListTable as table (
    StudentID int,
    Attendance bit
)
go;

create procedure PR_Set_Attendances
@AttendableID int,
@AttendanceList AttendanceListTable readonly
as
begin
set nocount on;

if not exists (select 1 from Attendable A where A.AttendableID = @AttendableID)
    begin
    raiserror('Attendable with given ID does not exist', 16, 0);
    return;
    end

insert into Attendances (AttendableID, StudentID, Attendance)
    select @AttendableID, StudentID, Attendance from @AttendanceList;
print 'Attendances saved successfuly';

end
go;

-- Stworzenie nowego lecture -M-
create procedure PR_Create_Lecture 
@TranslatorID int = NULL,
@LectureName nvarchar(100),
@Description nvarchar(MAX),
@AdvancePrice money = NULL,
@TotalPrice money,
@Date datetime,
@Language nvarchar(10) = 'pl',
@Available bit = 0,
@LectureID int output
as
begin
set nocount on;

if @TranslatorID is not null and not exists (select 1 from Translators T where T.TranslatorID = @TranslatorID)
    begin
    raiserror('Translator with given ID does not exist', 16, 0);
    return;
    end

if @TranslatorID is not null and not exists (select 1 from Translators T where T.TranslatorID = @TranslatorID and T.Language = @Language)
    begin
    raiserror('Translator with given ID cannot translate from given language', 16, 1);
    return;
    end

if @TranslatorID is null and @Language <> 'pl'
    begin
    print 'Inserting lecture without polish translation';
    end   

if @Date < getdate()
    begin
    raiserror('Given date is from the past', 16, 3);
    return;
    end

insert into Lectures (TranslatorID, LectureName, Description, AdvancePrice, TotalPrice, Date, Language, Available)
    values(@TranslatorID, @LectureName, @Description, @AdvancePrice, @TotalPrice, @Date, @Language, @Available);
set @LectureID = scope_identity();
print 'Lecture added successfuly';

end
go;

-- Dodanie do Attendable -M-
create procedure PR_Create_Attendable
@StartDate datetime,
@EndDate datetime,
@AttendableID int output
as
begin
set nocount on;

if @EndDate < @StartDate
    begin
    raiserror('Given dates are mismatched', 16, 0);
    return;
    end

insert into Attendable (StartDate, EndDate)
    values(@StartDate, @EndDate);

set @AttendableID = scope_identity();
print 'Attendable added successfuly';

end
go;

-- Dodanie nauczyciela -Ł-
create procedure PR_Add_Teacher
@Name nvarchar(50),
@Surname nvarchar(50),
@Email nvarchar(100),
@Phone nvarchar(30),
@Address nvarchar(255),
@City nvarchar(50),
@Country nvarchar(69),
@BirthDate date,
@HireDate date
@TitleOfCourtesy nvarchar(20)
as
begin
set nocount on;

if exists 1 (select 1 from Teachers T where T.Email = @Email)
    begin
    raiserror('Teacher with given email already exists', 16, 0);
    return;
    end

if exists 1 (select 1 from Teachers T where T.Phone = @Phone)
    begin
    raiserror('Teacher with given phone number already exists', 16, 0);
    return;
    end

if @BirthDate > getdate()
    begin
    raiserror('Birth date cannot be in the future', 16, 0);
    return;
    end

if @BirthDate > @HireDate
    begin
    raiserror('Hire date cannot be before birth date', 16, 0);
    return;
    end

if @HireDate > getdate()
    begin
    raiserror('Hire date cannot be in the future', 16, 0);
    return;
    end

insert into Teachers (Name, Surname, Email, Phone, Address, City, Country, BirthDate, HireDate, TitleOfCourtesy)
    values(@Name, @Surname, @Email, @Phone, @Address, @City, @Country, @BirthDate, @HireDate, @TitleOfCourtesy);


print 'Teacher added successfully';
end
go;


-- Dodanie tłumacza -Ł-
create procedure PR_Add_Translator
@Name nvarchar(50),
@Surname nvarchar(50),
@Email nvarchar(100),
@Phone nvarchar(30),
@Address nvarchar(255),
@City nvarchar(50),
@Country nvarchar(69),
@BirthDate date,
@HireDate date,
@Language nvarchar(10)
as
begin
set nocount on;

if exists 1 (select 1 from Translators T where T.Email = @Email)
    begin
    raiserror('Translator with given email already exists', 16, 0);
    return;
    end

if exists 1 (select 1 from Translators T where T.Phone = @Phone)
    begin
    raiserror('Translator with given phone number already exists', 16, 0);
    return;
    end

if @BirthDate > getdate()
    begin
    raiserror('Birth date cannot be in the future', 16, 0);
    return;
    end

if @BirthDate > @HireDate
    begin
    raiserror('Hire date cannot be before birth date', 16, 0);
    return;
    end

if @HireDate > getdate()
    begin
    raiserror('Hire date cannot be in the future', 16, 0);
    return;
    end

insert into Translators (Name, Surname, Email, Phone, Address, City, Country, BirthDate, HireDate, Language)
    values(@Name, @Surname, @Email, @Phone, @Address, @City, @Country, @BirthDate, @HireDate, @Language);

print 'Translator added successfully';
end
go;

-- Dodanie studenta -Ł-
create procedure PR_Add_Student
@Name nvarchar(50),
@Surname nvarchar(50),
@Email nvarchar(100),
@Phone nvarchar(30),
@Address nvarchar(255),
@City nvarchar(50),
@Country nvarchar(69),
@BirthDate date
as
begin
set nocount on;

if exists 1 (select 1 from Students S where S.Email = @Email)
    begin
    raiserror('Student with given email already exists', 16, 0);
    return;
    end

if exists 1 (select 1 from Students S where S.Phone = @Phone)
    begin
    raiserror('Student with given phone number already exists', 16, 0);
    return;
    end

if @BirthDate > getdate()
    begin
    raiserror('Birth date cannot be in the future', 16, 0);
    return;
    end

insert into Students (Name, Surname, Email, Phone, Address, City, Country, BirthDate)
    values(@Name, @Surname, @Email, @Phone, @Address, @City, @Country, @BirthDate);

print 'Student added successfuly';
end
go;

--Zmiana statusów płatności -Ł-
create trigger TR_PaymentStatusChange
on Orders
after update
as
begin
set nocount on;

if exists (select 1 from inserted where Status = 'Paid')
    begin
    update Enrollments
        set Status = 'InProgress'
        where OrderID in (select OrderID from inserted where Status = 'Paid');
    end

end
go;

--dodanie StudySessionPayment po opłaceniu całości zamównienia -Ł-
create trigger TR_AddStudySessionPayment
on Enrollments 
after update
as
begin
set nocount on;

with StudiesEnrollmentsUpdated (EnrollmentID, Status) as (
    select E.EnrollmentID, E.Status
    from Studies as S 
    join Lectures as L on L.LectureID = S.LectureID
    join inserted as I on I.EnrollmentID = L.EnrollmentID
), StudySessionToBeInserted (EnrollmentID, StudySessionID, Price, DueDate, PaidDate) as (
    select  E.EnrollmentID, 
            SS.StudySessionID, 
            SS.Price, 
            DATEADD(day, -3, SS.DueDate), 
            NULL 
        from StudySessions as SS
        join Studies as S on S.StudiesID = SS.StudiesID
        join Lectures as L on L.LectureID = S.LectureID
        join Enrollments as E on E.LectureID = L.LectureID
    where E.EnrollmentID in (select EnrollmentID from StudiesEnrollmentsUpdated where Status = 'InProgress');
)

if exists(select 1 from StudiesEnrollmentsUpdated where Status = 'InProgress')
    begin
    insert into StudySessionPayments (EnrollmentID, StudySessionID, Price, DueDate, PaidDate)
        select EnrollmentID, StudySessionID, Price, DueDate, PaidDate from StudySessionToBeInserted;
    end
end
go;

--dodanie webinara -K-
create procedure PR_Create_Webinar
@TeacherID int,
@Link nvarchar(100),
@IsFree bit,
@TranslatorID int = NULL,
@LectureName nvarchar(100),
@Description nvarchar(MAX),
@AdvancePrice money = NULL,
@TotalPrice money,
@Date datetime,
@Language nvarchar(10) = 'pl',
@Available bit = 0,
@WebinarID int output
as
begin
    set nocount on;

    declare @LectureID int;

    --Wywołanie PR_Create_Lecture
    exec PR_Create_Lecture
        @TranslatorID = @TranslatorID,
        @LectureName = @LectureName,
        @Description = @Description,
        @AdvancePrice = @AdvancePrice,
        @TotalPrice = @TotalPrice,
        @Date = @Date,
        @Language = @Language,
        @Available = @Available,
        @LectureID = @LectureID output;

    if @LectureID is null
    begin
        raiserror('Failed to create lecture', 16, 0);
        return;
    end

    insert into Webinars (LectureID, TeacherID,Link,IsFree)
        values (@LectureID, @TeacherID, @Link, @IsFree);

    set @WebinarID = scope_identity();
    print 'Webinar created successfully';
end
go;

--dodanie kursu -K-
create procedure PR_Create_Course
@TranslatorID int = NULL,
@LectureName nvarchar(100),
@LectureDescription nvarchar(MAX),
@AdvancePrice money = NULL,
@TotalPrice money,
@Date datetime,
@Language nvarchar(10) = 'pl',
@Available bit = 0,
@CourseID int output
as
begin
    set nocount on;

    declare @LectureID int;

    -- Wywołanie PR_Create_Lecture
    exec PR_Create_Lecture
        @TranslatorID = @TranslatorID,
        @LectureName = @LectureName,
        @Description = @LectureDescription,
        @AdvancePrice = @AdvancePrice,
        @TotalPrice = @TotalPrice,
        @Date = @Date,
        @Language = @Language,
        @Available = @Available,
        @LectureID = @LectureID output;

    if @LectureID is null
    begin
        raiserror('Failed to create lecture', 16, 0);
        return;
    end

    insert into Courses (LectureID)
        values (@LectureID);

    set @CourseID = scope_identity();
    print 'Course created successfully';
end
go;

--dodanie modułów kursów -K-
create procedure PR_Create_CourseModule
@TeacherID int,
@CourseID int,
@Name nvarchar(100),
@Description nvarchar(100),
@CourseModuleID int output
as
begin
    set nocount on;

    if not exists (select 1 from Courses where CourseID = @CourseID)
    begin
        raiserror('Course with given ID does not exist', 16, 0);
        return;
    end

    insert into CourseModules (TeacherID,CourseID, Name, Description)
        values (@TeacherID,@CourseID, @Name, @Description);

    set @CourseModuleID = scope_identity();
    print 'Course module created successfully';
end
go;

--dodanie spotkań kursów -K-
create procedure PR_Create_StationaryCourseModule
@CourseModuleID int,
@Classroom nvarchar(10),
@SeatLimit int,
@StartDate datetime,
@EndDate datetime,
@StationaryCourseID int output
as
begin
    set nocount on;

    if not exists (select 1 from CourseModules where CourseModuleID = @CourseModuleID)
    begin
        raiserror('CourseModule with given ID does not exist', 16, 0);
        return;
    end

    -- Walidacja: sprawdzenie limitu miejsc
    if @SeatLimit <= 0
    begin
        raiserror('SeatLimit must be greater than 0', 16, 0);
        return;
    end

    declare @AttendableID int;
    exec PR_Create_Attendable
        @StartDate = @StartDate,
        @EndDate = @EndDate,
        @AttendableID = @AttendableID output;

    if @AttendableID is null
    begin
        raiserror('Failed to create Attendable', 16, 0);
        return;
    end

    insert into StationaryCourseModules (CourseModuleID, AttendableID, Classroom, SeatLimit)
    values (@CourseModuleID, @AttendableID, @Classroom, @SeatLimit);

    set @StationaryCourseID = scope_identity();
    print 'StationaryCourseModule created successfully';
end
go;

create procedure PR_Create_OnlineCourseModule
@CourseModuleID int,
@Link nvarchar(100),
@IsLive bit,
@StartDate datetime,
@EndDate datetime,
@OnlineCourseID int output
as
begin
    set nocount on;

    if not exists (select 1 from CourseModules where CourseModuleID = @CourseModuleID)
    begin
        raiserror('CourseModule with given ID does not exist', 16, 0);
        return;
    end

    if @Link is null or len(@Link) = 0
    begin
        raiserror('Link cannot be null or empty', 16, 0);
        return;
    end

    declare @AttendableID int;
    exec PR_Create_Attendable
        @StartDate = @StartDate,
        @EndDate = @EndDate,
        @AttendableID = @AttendableID output;

    if @AttendableID is null
    begin
        raiserror('Failed to create Attendable', 16, 0);
        return;
    end

    insert into OnlineCourseModules (CourseModuleID, AttendableID, Link, IsLive)
    values (@CourseModuleID, @AttendableID, @Link, @IsLive);

    set @OnlineCourseID = scope_identity();
    print 'OnlineCourseModule created successfully';
end
go;

--dodanie studiów -K-
create procedure PR_Create_Studies
@TranslatorID int = NULL,
@LectureName nvarchar(100),
@Description nvarchar(MAX),
@AdvancePrice money = NULL,
@TotalPrice money,
@Date datetime,
@Language nvarchar(10) = 'pl',
@Available bit = 0,
@Syllabus nvarchar(100),
@CapacityLimit int,
@StudyID int output
as
begin
    set nocount on;

    declare @LectureID int;

    exec PR_Create_Lecture
        @TranslatorID = @TranslatorID,
        @LectureName = @LectureName,
        @Description = @Description,
        @AdvancePrice = @AdvancePrice,
        @TotalPrice = @TotalPrice,
        @Date = @Date,
        @Language = @Language,
        @Available = @Available,
        @LectureID = @LectureID output;

    if @LectureID is null
    begin
        raiserror('Failed to create lecture', 16, 0);
        return;
    end

    insert into Studies (LectureID, Syllabus, CapacityLimit)
        values (@LectureID, @Syllabus,@CapacityLimit);

    set @StudyID = scope_identity();
    print 'Study created successfully';
end
go;

--dodanie zjazdów -K-
create procedure PR_Create_StudySession
@StudiesID int,
@StartDate date,
@EndDate date,
@Price money,
@StudySessionID int output
as
begin
    set nocount on;

    if not exists (select 1 from Studies where StudiesID = @StudiesID)
    begin
        raiserror('Studies with given ID does not exist', 16, 0);
        return;
    end

    if @EndDate <= @StartDate
    begin
        raiserror('End date must be later than start date', 16, 0);
        return;
    end

    if @EndDate < getdate()
    begin
    raiserror('Given date is from the past', 16, 3);
    return;
    end

    if @Price < 0
    begin
        raiserror('Price must be greater than or equal to 0', 16, 0);
        return;
    end

    insert into StudySessions (StudiesID, StartDate, EndDate, Price)
    values (@StudiesID, @StartDate, @EndDate, @Price);

    set @StudySessionID = scope_identity();
    print 'Study session created successfully';
end
go;

--dodanie zajęć do zjazdów -K-

--------------------------------------------------


--dodanie przedmiotów -K-
create procedure PR_Create_Class
@StudiesID nchar(5),
@TeacherID int,
@Name nvarchar(100),
@Description nvarchar(MAX),
@ClassID int output
as
begin
    set nocount on;

    if not exists (select 1 from Studies where StudiesID = @StudiesID)
    begin
        raiserror('Studies with given ID does not exist', 16, 0);
        return;
    end

    if not exists (select 1 from Teachers where TeacherID = @TeacherID)
    begin
        raiserror('Teacher with given ID does not exist', 16, 0);
        return;
    end

    insert into Classes (StudiesID, TeacherID, Name, Description)
    values (@StudiesID, @TeacherID, @Name, @Description);

    set @ClassID = scope_identity();
    print 'Class created successfully';
end
go;


--dodanie zajęć do przedmiotów -K-
create procedure PR_Create_OnlineClass
@ClassID int,
@Link nvarchar(MAX),
@IsLive bit,
@StartDate datetime,
@EndDate datetime,
@LectureName nvarchar(100) = NULL,
@Description nvarchar(MAX) = NULL,
@AdvancePrice money = NULL,
@TotalPrice money = NULL,
@Date datetime = NULL,
@Language nvarchar(10) = 'pl',
@StudySessionID int = NULL,
@OnlineClassID int output
as
begin
    set nocount on;

    if not exists (select 1 from Classes where ClassID = @ClassID)
    begin
        raiserror('Class with given ID does not exist', 16, 0);
        return;
    end

    if @Link is null or len(@Link) = 0
    begin
        raiserror('Link cannot be null or empty', 16, 0);
        return;
    end

    declare @AttendableID int;
    exec PR_Create_Attendable
        @StartDate = @StartDate,
        @EndDate = @EndDate,
        @AttendableID = @AttendableID output;

    if @AttendableID is null
    begin
        raiserror('Failed to create Attendable', 16, 0);
        return;
    end

    declare @LectureID int = NULL;
    if @LectureName is not null and @Description is not null and @TotalPrice is not null and @Date is not null
    begin
        exec PR_Create_Lecture
            @LectureName = @LectureName,
            @Description = @Description,
            @AdvancePrice = @AdvancePrice,
            @TotalPrice = @TotalPrice,
            @Date = @Date,
            @Language = @Language,
            @LectureID = @LectureID output;

        if @LectureID is null
        begin
            raiserror('Failed to create Lecture', 16, 0);
            return;
        end
    end

    insert into OnlineClasses (ClassID,  LectureID, StudySessionID, AttendableID, Link, IsLive)
    values (@ClassID,  @LectureID, @StudySessionID, @AttendableID,@Link, @IsLive);

    set @OnlineClassID = scope_identity();
    print 'OnlineClass created successfully';
end
go;


create procedure PR_Create_StationaryClass
@ClassID int,
@Classroom int,
@SeatLimit int,
@StartDate datetime,
@EndDate datetime,
@LectureName nvarchar(100) = NULL,
@Description nvarchar(MAX) = NULL,
@AdvancePrice money = NULL,
@TotalPrice money = NULL,
@Date datetime = NULL,
@Language nvarchar(10) = 'pl',
@StudySessionID int = NULL,
@OnlineClassID int output
as
begin
    set nocount on;

    if not exists (select 1 from Classes where ClassID = @ClassID)
    begin
        raiserror('Class with given ID does not exist', 16, 0);
        return;
    end

    declare @AttendableID int;
    exec PR_Create_Attendable
        @StartDate = @StartDate,
        @EndDate = @EndDate,
        @AttendableID = @AttendableID output;

    if @AttendableID is null
    begin
        raiserror('Failed to create Attendable', 16, 0);
        return;
    end

    declare @LectureID int = NULL;
    if @LectureName is not null and @Description is not null and @TotalPrice is not null and @Date is not null
    begin
        exec PR_Create_Lecture
            @LectureName = @LectureName,
            @Description = @Description,
            @AdvancePrice = @AdvancePrice,
            @TotalPrice = @TotalPrice,
            @Date = @Date,
            @Language = @Language,
            @LectureID = @LectureID output;

        if @LectureID is null
        begin
            raiserror('Failed to create Lecture', 16, 0);
            return;
        end
    end

    insert into StationaryClasses (ClassID,  AttendableID,LectureID, StudySessionID, Classroom,SeatLimit)
    values (@ClassID,  @LectureID, @StudySessionID, @AttendableID,@Classroom, @SeatLimit);

    set @OnlineClassID = scope_identity();
    print 'OnlineClass created successfully';
end
go;

--dodanie praktyki -K-
create procedure PR_Create_Internship
@AttendableID int,
@StudiesID nchar(5),
@Address nvarchar(255),
@Name nvarchar(100),
@Description nvarchar(MAX),
@InternshipID int output
as
begin
    set nocount on;

    if not exists (select 1 from Attendable where AttendableID = @AttendableID)
    begin
        raiserror('Attendable with given ID does not exist', 16, 0);
        return;
    end

    if not exists (select 1 from Studies where StudiesID = @StudiesID)
    begin
        raiserror('Studies with given ID does not exist', 16, 0);
        return;
    end

    insert into Internships (AttendableID, StudiesID, Address, Name, Description)
    values (@AttendableID, @StudiesID, @Address, @Name, @Description);

    set @InternshipID = scope_identity();
    print 'Internship created successfully';
end
go;
