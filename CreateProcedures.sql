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
@HireDate date
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
@BirthDate date,
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