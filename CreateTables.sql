-- tables
CREATE TABLE Students (
    StudentID int  NOT NULL IDENTITY(1,1),
    Name nvarchar(50)  NOT NULL,
    Surname nvarchar(50)  NOT NULL,
    Email nvarchar(100)  NOT NULL,
    Phone nvarchar(30)  NOT NULL,
    Address nvarchar(255)  NOT NULL,
    City nvarchar(50)  NOT NULL,
    Country nvarchar(69)  NOT NULL,
    BirthDate date  NOT NULL,

    CONSTRAINT Students_pk PRIMARY KEY (StudentID),

    CONSTRAINT UQ_Students_Email UNIQUE (Email),
    CONSTRAINT UQ_Students_Phone UNIQUE (Phone),
    CONSTRAINT CHK_Students_BirthDate CHECK (BirthDate < GETDATE() AND BirthDate > '1900-01-01')
);

CREATE TABLE Translators (
    TranslatorID int  NOT NULL IDENTITY(1,1),
    Name nvarchar(50)  NOT NULL,
    Surname nvarchar(50)  NOT NULL,
    Email nvarchar(100)  NOT NULL,
    Phone nvarchar(30)  NOT NULL,
    Address nvarchar(255)  NOT NULL,
    City nvarchar(50)  NOT NULL,
    Country nvarchar(69)  NOT NULL,
    BirthDate date  NOT NULL,
    HireDate date  NOT NULL,
    Language nvarchar(10)  NOT NULL,

    CONSTRAINT Translators_pk PRIMARY KEY (TranslatorID),

    CONSTRAINT UQ_Translators_Email UNIQUE (Email),
    CONSTRAINT UQ_Translators_Phone UNIQUE (Phone),
    CONSTRAINT CHK_Translators_BirthDate CHECK (BirthDate < GETDATE() AND BirthDate > '1900-01-01'),
    CONSTRAINT CHK_Translators_HireDate CHECK (HireDate < GETDATE())
);

CREATE TABLE Teachers (
    TeacherID int  NOT NULL IDENTITY(1,1),
    Name nvarchar(50)  NOT NULL,
    Surname nvarchar(50)  NOT NULL,
    Email nvarchar(100)  NOT NULL,
    Phone nvarchar(30)  NOT NULL,
    Address nvarchar(255)  NOT NULL,
    City nvarchar(50)  NOT NULL,
    Country nvarchar(69)  NOT NULL,
    BirthDate date  NOT NULL,
    HireDate date  NOT NULL,
    TitleOfCourtesy nvarchar(20)  NOT NULL,

    CONSTRAINT Teachers_pk PRIMARY KEY (TeacherID),

    CONSTRAINT UQ_Teachers_Email UNIQUE (Email),
    CONSTRAINT UQ_Teachers_Phone UNIQUE (Phone),
    CONSTRAINT CHK_Teachers_BirthDate CHECK (BirthDate < GETDATE() AND BirthDate > '1900-01-01'),
    CONSTRAINT CHK_Teachers_HireDate CHECK (HireDate < GETDATE() AND HireDate > BirthDate)
);

CREATE TABLE Orders (
    OrderID int  NOT NULL IDENTITY(1,1),
    StudentID int  NOT NULL,
    OrderDate datetime  NULL DEFAULT NULL,
    AdvancePaidDate datetime  NULL DEFAULT NULL,
    TotalPaidDate datetime  NULL DEFAULT NULL,
    Status nvarchar(15)  NOT NULL,

    CONSTRAINT Orders_pk PRIMARY KEY (OrderID),
    CONSTRAINT Orders_Students FOREIGN KEY (StudentID) REFERENCES Students (StudentID),

    CONSTRAINT CHK_Orders_Status CHECK (Status IN ('Pending', 'Completed', 'Failed', 'Canceled', 'Cart'))
);

CREATE TABLE PostponedPayments (
    OrderID int  NOT NULL,
    DueDate datetime  NOT NULL,
    PaidDate datetime  NULL DEFAULT NULL,

    CONSTRAINT PostponedPayments_pk PRIMARY KEY (OrderID),
    CONSTRAINT PostponedPayments_Orders FOREIGN KEY (OrderID) REFERENCES Orders (OrderID),

    CONSTRAINT CHK_PostponedPayments_DueDate CHECK (DueDate > GETDATE())
);

CREATE TABLE Lectures (
    LectureID int  NOT NULL IDENTITY(1,1),
    TranslatorID int  NULL DEFAULT NULL,
    LectureName nvarchar(100)  NOT NULL,
    Description nvarchar(MAX)  NOT NULL,
    AdvancePrice money NULL DEFAULT NULL,
    TotalPrice money  NOT NULL,
    Date datetime  NOT NULL,
    Language nvarchar(10)  NOT NULL DEFAULT 'pl',
    Available bit NOT NULL DEFAULT 0,

    CONSTRAINT LectureID PRIMARY KEY (LectureID),
    CONSTRAINT Lectures_Translators FOREIGN KEY (TranslatorID) REFERENCES Translators (TranslatorID),

    CONSTRAINT CHK_Lectures_TotalPrice CHECK (TotalPrice >= 0),
    CONSTRAINT CHK_Lectures_AdvancePrice CHECK (AdvancePrice is NULL OR AdvancePrice >= 0),
    CONSTRAINT CHK_Lectures_Date CHECK (Date >= GETDATE())
);

CREATE TABLE Attendable (
    AttendableID int  NOT NULL IDENTITY(1,1),
    StartDate datetime  NOT NULL,
    EndDate datetime  NOT NULL,

    CONSTRAINT Attendable_pk PRIMARY KEY (AttendableID),

    CONSTRAINT CHK_Attendable_Date CHECK (StartDate < EndDate)
);

CREATE TABLE Enrollments (
    EnrollmentID int  NOT NULL IDENTITY(1,1),
    OrderID int  NOT NULL,
    LectureID int  NOT NULL,
    AdvancePrice money  NULL DEFAULT NULL,
    TotalPrice money  NOT NULL,
    Status nvarchar(20)  NOT NULL,

    CONSTRAINT Enrollments_pk PRIMARY KEY (EnrollmentID),
    CONSTRAINT Enrollments_Lectures FOREIGN KEY (LectureID) REFERENCES Lectures (LectureID),
    CONSTRAINT Enrollments_Orders FOREIGN KEY (OrderID) REFERENCES Orders (OrderID),

    CONSTRAINT CHK_Enrollments_Status CHECK (Status IN ('Completed', 'Failed', 'InProgress', 'Resigned', 'AwaitingPayment', 'NotPaidOnTime'))
);

CREATE TABLE StudySessionPayments (
    PaymentID int  NOT NULL IDENTITY(1,1),
    EnrollmentID int  NOT NULL,
    StudySessionID int  NOT NULL,  
    Price money  NOT NULL,
    DueDate date  NOT NULL,
    PaidDate date  NULL DEFAULT NULL,

    CONSTRAINT StudySessionPayments_pk PRIMARY KEY (PaymentID),
    CONSTRAINT StudySessionPayments_Enrollments FOREIGN KEY (EnrollmentID) REFERENCES Enrollments (EnrollmentID),
    CONSTRAINT StudySessionPayments_StudySession FOREIGN KEY (StudySessionID) REFERENCES StudySessions (StudySessionID),

    CONSTRAINT CHK_StudySessionPayments_DueDate CHECK (DueDate > GETDATE())
);

CREATE TABLE Attendances (
    AttendableID int  NOT NULL,
    StudentID int  NOT NULL,
    Attendance bit  NOT NULL DEFAULT 1,
    CompensationNote nvarchar(MAX)  NULL DEFAULT NULL,
    CompensationAttendableID int  NULL DEFAULT NULL,

    CONSTRAINT Attendances_pk PRIMARY KEY (AttendableID,StudentID),
    CONSTRAINT Attendances_Attendable FOREIGN KEY (AttendableID) REFERENCES Attendable (AttendableID),
    CONSTRAINT Attendances_Students FOREIGN KEY (StudentID) REFERENCES Students (StudentID),
    CONSTRAINT Attendances_AttendableCompensation FOREIGN KEY (CompensationAttendableID) REFERENCES Attendable (AttendableID)
);

CREATE TABLE Webinars (
    WebinarID int  NOT NULL IDENTITY(1,1),
    LectureID int  NOT NULL,
    TeacherID int  NOT NULL,
    Link nvarchar(MAX)  NOT NULL,
    IsFree bit  NOT NULL,

    CONSTRAINT Webinars_pk PRIMARY KEY  (WebinarID),
    CONSTRAINT Webinars_Teachers FOREIGN KEY (TeacherID) REFERENCES Teachers (TeacherID),
    CONSTRAINT Webinars_Lectures FOREIGN KEY (LectureID) REFERENCES Lectures (LectureID),
);

CREATE TABLE Courses (
    CourseID int  NOT NULL IDENTITY(1,1),
    LectureID int  NOT NULL,

    CONSTRAINT Courses_pk PRIMARY KEY (CourseID),
    CONSTRAINT Courses_Lectures FOREIGN KEY (LectureID) REFERENCES Lectures (LectureID)
);

CREATE TABLE CourseModules (
    CourseModuleID int  NOT NULL IDENTITY(1,1),
    TeacherID int  NOT NULL,
    CourseID int  NOT NULL,
    Name nvarchar(100)  NOT NULL,
    Description nvarchar(MAX)  NOT NULL,

    CONSTRAINT CourseModules_pk PRIMARY KEY (CourseModuleID),
    CONSTRAINT CourseModules_Courses FOREIGN KEY (CourseID) REFERENCES Courses (CourseID),
    CONSTRAINT CourseModules_Teachers FOREIGN KEY (TeacherID) REFERENCES Teachers (TeacherID)
);

CREATE TABLE OnlineCourseModules (
    OnlineCourseID int  NOT NULL IDENTITY(1,1),
    CourseModuleID int  NOT NULL,
    AttendableID int  NOT NULL,
    Link nvarchar(MAX)  NOT NULL,
    IsLive bit  NOT NULL,

    CONSTRAINT OnlineCourseModules_pk PRIMARY KEY  (OnlineCourseID),
    CONSTRAINT OnlineCourseModules_CourseModules FOREIGN KEY (CourseModuleID) REFERENCES CourseModules (CourseModuleID),
    CONSTRAINT OnlineCourseModules_Attendable FOREIGN KEY (AttendableID) REFERENCES Attendable (AttendableID)
);

CREATE TABLE StationaryCourseModules (
    StationaryCourseID int  NOT NULL IDENTITY(1,1),
    CourseModuleID int  NOT NULL,
    AttendableID int  NOT NULL,
    Classroom nvarchar(10)  NOT NULL,
    SeatLimit int  NOT NULL,

    CONSTRAINT StationaryCourseModules_pk PRIMARY KEY (StationaryCourseID),
    CONSTRAINT StationaryCourseModules_CourseModules FOREIGN KEY (CourseModuleID) REFERENCES CourseModules (CourseModuleID),
    CONSTRAINT StationaryCourseModules_Attendable FOREIGN KEY (AttendableID) REFERENCES Attendable (AttendableID),

    CONSTRAINT CHK_StationaryCourseModules_SeatLimit CHECK (SeatLimit > 0)
);

CREATE TABLE Studies (
    StudiesID nchar(5)  NOT NULL,
    LectureID int  NOT NULL,
    Syllabus nvarchar(MAX)  NOT NULL,
    CapacityLimit int  NOT NULL,

    CONSTRAINT Studies_pk PRIMARY KEY (StudiesID),
    CONSTRAINT Studies_Lectures FOREIGN KEY (LectureID) REFERENCES Lectures (LectureID),

    CONSTRAINT CHK_Studies_CapacityLimit CHECK (CapacityLimit > 0)
);

CREATE TABLE Internships (
    InternshipID int  NOT NULL IDENTITY(1,1),
    AttendableID int  NOT NULL,
    StudiesID nchar(5)  NOT NULL,
    Address nvarchar(255)  NOT NULL,
    Name nvarchar(100)  NOT NULL,
    Description nvarchar(MAX)  NOT NULL,

    CONSTRAINT Internships_pk PRIMARY KEY (InternshipID),
    CONSTRAINT Internships_Attendable FOREIGN KEY (AttendableID) REFERENCES Attendable (AttendableID),
    CONSTRAINT Internships_Studies FOREIGN KEY (StudiesID) REFERENCES Studies (StudiesID)
);

CREATE TABLE StudySessions (
    StudySessionID int  NOT NULL IDENTITY(1,1),
    StudiesID nchar(5)  NOT NULL,
    StartDate date  NOT NULL,
    EndDate date  NOT NULL,
    Price money  NOT NULL,

    CONSTRAINT StudySessions_pk PRIMARY KEY (StudySessionID),
    CONSTRAINT StudySessions_Studies FOREIGN KEY (StudiesID) REFERENCES Studies (StudiesID),

    CONSTRAINT CHK_StudySessions_Date CHECK (StartDate < EndDate),
    CONSTRAINT CHK_StudySessions_Price CHECK (Price >= 0),
);

CREATE TABLE Classes (
    ClassID int  NOT NULL IDENTITY(1,1),
    StudiesID nchar(5)  NOT NULL,
    TeacherID int  NOT NULL,
    Name nvarchar(100)  NOT NULL,
    Description nvarchar(MAX)  NOT NULL,

    CONSTRAINT Classes_pk PRIMARY KEY (ClassID),
    CONSTRAINT Classes_Teachers FOREIGN KEY (TeacherID) REFERENCES Teachers (TeacherID),
    CONSTRAINT Classes_Studies FOREIGN KEY (StudiesID) REFERENCES Studies (StudiesID)
);

CREATE TABLE OnlineClasses (
    OnlineClassID int  NOT NULL IDENTITY(1,1),
    ClassID int  NOT NULL,
    AttendableID int  NOT NULL,
    LectureID int NULL DEFAULT NULL,
    StudySessionID int NULL DEFAULT NULL,
    Link nvarchar(MAX)  NOT NULL,
    IsLive bit  NOT NULL,

    CONSTRAINT OnlineClasses_pk PRIMARY KEY (OnlineClassID),
    CONSTRAINT OnlineClasses_Classes FOREIGN KEY (ClassID) REFERENCES Classes (ClassID),
    CONSTRAINT OnlineClasses_Attendable FOREIGN KEY (AttendableID) REFERENCES Attendable (AttendableID),
    CONSTRAINT OnlineClasses_Lectures FOREIGN KEY (LectureID) REFERENCES Lectures (LectureID),
    CONSTRAINT OnlineClasses_StudySessions FOREIGN KEY (StudySessionID) REFERENCES StudySessions (StudySessionID)
);

CREATE TABLE StationaryClasses (
    StationaryClassID int  NOT NULL IDENTITY(1,1),
    ClassID int  NOT NULL,
    AttendableID int  NOT NULL,
    LectureID int NULL DEFAULT NULL,
    StudySessionID int NULL DEFAULT NULL,
    Classroom nvarchar(10)  NOT NULL,
    SeatLimit int  NOT NULL,

    CONSTRAINT StationaryClasses_pk PRIMARY KEY (StationaryClassID),
    CONSTRAINT StationaryClasses_Classes FOREIGN KEY (ClassID) REFERENCES Classes (ClassID),
    CONSTRAINT StationaryClasses_Attendable FOREIGN KEY (AttendableID) REFERENCES Attendable (AttendableID),
    CONSTRAINT StationaryClasses_Lectures FOREIGN KEY (LectureID) REFERENCES Lectures (LectureID),
    CONSTRAINT StationaryClasses_StudySessions FOREIGN KEY (StudySessionID) REFERENCES StudySessions (StudySessionID),

    CONSTRAINT CHK_StationaryClasses_SeatLimit CHECK (SeatLimit > 0)
);

-- DELETION ORDER:
DROP TABLE StationaryClasses
DROP TABLE OnlineClasses
DROP TABLE Classes
DROP TABLE StudySessions
DROP TABLE Internships
DROP TABLE Studies
DROP TABLE StationaryCourseModules
DROP TABLE OnlineCourseModules
DROP TABLE CourseModules
DROP TABLE Courses
DROP TABLE Webinars
DROP TABLE Attendances
DROP TABLE StudySessionPayments
DROP TABLE Enrollments
DROP TABLE Lectures
DROP TABLE Attendable
DROP TABLE PostponedPayments
DROP TABLE Orders
DROP TABLE Teachers
DROP TABLE Translators
DROP TABLE Students;