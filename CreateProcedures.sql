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
@Available bit = 0
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
print 'Lecture added successfuly';
end
go;

-- Dodanie do Attendable -M-
create procedure PR_Create_Attendable
@StartDate datetime,
@EndDate datetime
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
print 'Attendable added successfuly';
end
go;
