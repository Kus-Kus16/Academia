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

    if not exists (select 1 from Students S where S.StudentID = @StudentID)
        begin
        raiserror('Student with given ID does not exist', 16, 0);
        return;
        end

    if exists (select 1 from Studies S where S.LectureID = @LectureID) 
        and FN_Remaining_Studies_Limit((select S.StudiesID from Studies S where S.LectureID = @LectureID)) = 0
        begin
        raiserror('No more free places at given studies', 16, 1);
        return;
        end

    if exists (select 1 from Courses C where C.LectureID = @LectureID) 
        and FN_Remaining_Course_Limit((select C.CourseID from Courses C where C.LectureID = @LectureID)) = 0
        begin
        raiserror('No more free places at given course', 16, 1);
        return;
        end

    if exists (select 1 from StationaryClasses C where C.LectureID = @LectureID) 
        and FN_Remaining_StationaryClass_Limit((select C.StationaryClassID from StationaryClasses C where C.LectureID = @LectureID)) = 0
        begin
        raiserror('No more free places at given class', 16, 1);
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
go

-- Dodanie obecności na zajęciach dla studentów -M-
create type AttendanceListTable as table (
    StudentID int,
    Attendance bit
)
go

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

    declare @StudentID int;
    declare @Attendance bit;
    declare cur cursor for
    select StudentID from @AttendanceList

    open cur  
    fetch next from cur into @StudentID, @Attendance
    
    while @@fetch_status = 0
    begin
        if not FN_Check_StudentAttendable(@StudentID, @AttendableID)
            begin
            raiserror('Student is not enrolled to given Attendable', 16, 0);
            return;
            end

        fetch next from cur into @StudentID, @Attendance
    end

    close cur
    deallocate cur

    insert into Attendances (AttendableID, StudentID, Attendance)
        select @AttendableID, StudentID, Attendance from @AttendanceList;
    print 'Attendances saved successfuly';

end
go

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
go

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
go

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
@HireDate date,
@TitleOfCourtesy nvarchar(20),
@TeacherID int output
as
begin
    set nocount on;

    if exists (select 1 from Teachers T where T.Email = @Email)
        begin
            raiserror('Teacher with given email already exists', 16, 0);
            return;
        end

    if exists (select 1 from Teachers T where T.Phone = @Phone)
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

    set @TeacherID = scope_identity();
    print 'Teacher added successfully';
end
go


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
@Language nvarchar(10),
@TranslatorID int output
as
begin
    set nocount on;

    if exists (select 1 from Translators T where T.Email = @Email)
        begin
            raiserror('Translator with given email already exists', 16, 0);
            return;
        end

    if exists (select 1 from Translators T where T.Phone = @Phone)
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

    set @TranslatorID = scope_identity();
    print 'Translator added successfully';
end
go

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
@StudentID int output
as
begin
    set nocount on;

    if exists (select 1 from Students S where S.Email = @Email)
        begin
            raiserror('Student with given email already exists', 16, 0);
            return;
        end

    if exists (select 1 from Students S where S.Phone = @Phone)
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

    set @StudentID = scope_identity();
    print 'Student added successfuly';
end
go

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
        Throw 60000, 'Failed to create lecture', 1;
    end

    insert into Webinars (LectureID, TeacherID,Link,IsFree)
        values (@LectureID, @TeacherID, @Link, @IsFree);

    set @WebinarID = scope_identity();
    print 'Webinar created successfully';
end
go

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
        throw 60001,'Failed to create lecture', 1;
    end

    insert into Courses (LectureID)
        values (@LectureID);

    set @CourseID = scope_identity();
    print 'Course created successfully';
end
go

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
        throw 60002,'Course with given ID does not exist',1;
    end

    insert into CourseModules (TeacherID,CourseID, Name, Description)
        values (@TeacherID,@CourseID, @Name, @Description);

    set @CourseModuleID = scope_identity();
    print 'Course module created successfully';
end
go

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
        throw 60003,'CourseModule with given ID does not exist', 1;
    end

    -- Walidacja: sprawdzenie limitu miejsc
    if @SeatLimit <= 0
    begin
        throw 60004,'SeatLimit must be greater than 0', 1;
    end

    declare @AttendableID int;
    exec PR_Create_Attendable
        @StartDate = @StartDate,
        @EndDate = @EndDate,
        @AttendableID = @AttendableID output;

    if @AttendableID is null
    begin
        throw 60004, 'Failed to create Attendable',1;
    end

    insert into StationaryCourseModules (CourseModuleID, AttendableID, Classroom, SeatLimit)
    values (@CourseModuleID, @AttendableID, @Classroom, @SeatLimit);

    set @StationaryCourseID = scope_identity();
    print 'StationaryCourseModule created successfully';
end
go

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
        throw 60005,'CourseModule with given ID does not exist',1;
    end

    if @Link is null or len(@Link) = 0
    begin
        throw 60006,'Link cannot be null or empty',1;
    end

    declare @AttendableID int;
    exec PR_Create_Attendable
        @StartDate = @StartDate,
        @EndDate = @EndDate,
        @AttendableID = @AttendableID output;

    if @AttendableID is null
    begin
        throw 60007,'Failed to create Attendable', 1;
    end

    insert into OnlineCourseModules (CourseModuleID, AttendableID, Link, IsLive)
    values (@CourseModuleID, @AttendableID, @Link, @IsLive);

    set @OnlineCourseID = scope_identity();
    print 'OnlineCourseModule created successfully';
end
go

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
@StudyID nchar(5)
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
        throw 60008,'Failed to create lecture', 1;
    end

    insert into Studies (StudiesID,LectureID, Syllabus, CapacityLimit)
        values (@StudyID,@LectureID, @Syllabus,@CapacityLimit);

    print 'Study created successfully';
end
go

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
    end

    if @EndDate <= @StartDate
    begin
        throw 60010,'End date must be later than start date', 1;
    end

    if @EndDate < getdate()
    begin
    throw 60011,'Given date is from the past',1;
    return;
    end

    if @Price < 0
    begin
        throw 60012,'Price must be greater than or equal to 0',1;
    end

    insert into StudySessions (StudiesID, StartDate, EndDate, Price)
    values (@StudiesID, @StartDate, @EndDate, @Price);

    set @StudySessionID = scope_identity();
    print 'Study session created successfully';
end
go

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
        throw 60013,'Studies with given ID does not exist',1;
    end

    if not exists (select 1 from Teachers where TeacherID = @TeacherID)
    begin
        throw 60014,'Teacher with given ID does not exist',1;
    end

    insert into Classes (StudiesID, TeacherID, Name, Description)
    values (@StudiesID, @TeacherID, @Name, @Description);

    set @ClassID = scope_identity();
    print 'Class created successfully';
end
go

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
        throw 60015,'Class with given ID does not exist',1;
    end

    if @Link is null or len(@Link) = 0
    begin
        throw 60016,'Link cannot be null or empty', 1;
    end

    declare @AttendableID int;
    exec PR_Create_Attendable
        @StartDate = @StartDate,
        @EndDate = @EndDate,
        @AttendableID = @AttendableID output;

    if @AttendableID is null
    begin
        throw 60017,'Failed to create Attendable',1;
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
            throw 60018,'Failed to create Lecture',1;
        end
    end

    insert into OnlineClasses (ClassID,  LectureID, StudySessionID, AttendableID, Link, IsLive)
    values (@ClassID,  @LectureID, @StudySessionID, @AttendableID,@Link, @IsLive);

    set @OnlineClassID = scope_identity();
    print 'OnlineClass created successfully';
end
go

--dodanie zajęć stacjonarnych -K-
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
        throw 60019,'Class with given ID does not exist', 1;
    end

    -- Sprawdzenie, czy SeatLimit jest >= CapacityLimit w Studies
    declare @CapacityLimit int;
    select @CapacityLimit = s.CapacityLimit
    from Classes c
    inner join Studies s on c.StudiesID = s.StudiesID
    where c.ClassID = @ClassID;

    if @CapacityLimit IS NULL
    begin
        throw 60020,'CapacityLimit not found for the given ClassID in Studies',1;
    end

    if @SeatLimit < @CapacityLimit
    begin
        throw 60021,'SeatLimit must be greater than or equal to CapacityLimit', 1;
    end

    declare @AttendableID int;
    exec PR_Create_Attendable
        @StartDate = @StartDate,
        @EndDate = @EndDate,
        @AttendableID = @AttendableID output;

    if @AttendableID is null
    begin
        throw 60022,'Failed to create Attendable', 1;
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
            throw 60023,'Failed to create Lecture', 1;
        end
    end

    insert into StationaryClasses (ClassID,  AttendableID,LectureID, StudySessionID, Classroom,SeatLimit)
    values (@ClassID,  @LectureID, @StudySessionID, @AttendableID,@Classroom, @SeatLimit);

    set @OnlineClassID = scope_identity();
    print 'OnlineClass created successfully';
end
go

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
        throw 60024,'Attendable with given ID does not exist', 1;
    end

    if not exists (select 1 from Studies where StudiesID = @StudiesID)
    begin
       throw 60025,'Studies with given ID does not exist', 1;
    end

    insert into Internships (AttendableID, StudiesID, Address, Name, Description)
    values (@AttendableID, @StudiesID, @Address, @Name, @Description);

    set @InternshipID = scope_identity();
    print 'Internship created successfully';
end
go

-- złożenie zamówienia -M-
create procedure PR_Place_Order
@OrderID int
as
begin
    set nocount on;

    if not exists (select 1 from Orders O where O.OrderID = @OrderID)
        begin
        raiserror('Cart with given ID does not exist', 16, 0);
        return;
        end

    begin
        update Orders
            set OrderDate = getdate(), Status = 'Pending'
            where OrderID = @OrderID;
    end
    print 'Order placed successfuly';

end
go

-- opłacenie zaliczki zamówienia -M-
create procedure PR_AdvancePayment_Paid
@OrderID int
as
begin
    set nocount on;

    if not exists (select 1 from Orders O where O.OrderID = @OrderID)
        begin
        raiserror('Cart with given ID does not exist', 16, 0);
        return;
        end

    begin
        update Orders
            set AdvancePaidDate = getdate()
            where OrderID = @OrderID;
    end
    print 'AdvancePayment date saved successfuly';

end
go

-- opłacenie całości zamówienia -M-
create procedure PR_TotalPayment_Paid
@OrderID int
as
begin
    set nocount on;

    if not exists (select 1 from Orders O where O.OrderID = @OrderID)
        begin
        raiserror('Cart with given ID does not exist', 16, 0);
        return;
        end

    begin
        update Orders
            set TotalPaidDate = getdate(), Status = 'Completed'
            where OrderID = @OrderID;
    end
    print 'TotalPaid date saved successfuly';

end
go
