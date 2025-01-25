-- Money

-- Enrollments
CREATE INDEX idx_Enrollments_AdvancePrice ON Enrollments (AdvancePrice);
CREATE INDEX idx_Enrollments_TotalPrice ON Enrollments (TotalPrice);

-- Lectures
CREATE INDEX idx_Lectures_AdvancePrice ON Lectures (AdvancePrice);
CREATE INDEX idx_Lectures_TotalPrice ON Lectures (TotalPrice);

-- StudySessionPayments
CREATE INDEX idx_StudySessionPayments_Price ON StudySessionPayments (Price);

-- StudySessions
CREATE INDEX idx_StudySessions_Price ON StudySessions (Price);



--Date and datetime

-- Attendable
CREATE INDEX idx_Attendable_StartDate ON Attendable (StartDate);
CREATE INDEX idx_Attendable_EndDate ON Attendable (EndDate);

-- Lectures
CREATE INDEX idx_Lectures_Date ON Lectures (Date);

-- Orders
CREATE INDEX idx_Orders_OrderDate ON Orders (OrderDate);
CREATE INDEX idx_Orders_AdvancePaidDate ON Orders (AdvancePaidDate);
CREATE INDEX idx_Orders_TotalPaidDate ON Orders (TotalPaidDate);

-- PostponedPayments
CREATE INDEX idx_PostponedPayments_DueDate ON PostponedPayments (DueDate);
CREATE INDEX idx_PostponedPayments_PaidDate ON PostponedPayments (PaidDate);

-- StudySessionPayments
CREATE INDEX idx_StudySessionPayments_DueDate ON StudySessionPayments (DueDate);
CREATE INDEX idx_StudySessionPayments_PaidDate ON StudySessionPayments (PaidDate);

-- StudySessions
CREATE INDEX idx_StudySessions_StartDate ON StudySessions (StartDate);
CREATE INDEX idx_StudySessions_EndDate ON StudySessions (EndDate);

-- Teachers
CREATE INDEX idx_Teachers_BirthDate ON Teachers (BirthDate);
CREATE INDEX idx_Teachers_HireDate ON Teachers (HireDate);

-- Translators
CREATE INDEX idx_Translators_BirthDate ON Translators (BirthDate);
CREATE INDEX idx_Translators_HireDate ON Translators (HireDate);

-- Students
CREATE INDEX idx_Students_BirthDate ON Students (BirthDate);



--Foreign keys

-- Attendances
CREATE INDEX idx_Attendances_AttendableID ON Attendances (AttendableID);
CREATE INDEX idx_Attendances_StudentID ON Attendances (StudentID);
CREATE INDEX idx_Attendances_CompensationAttendableID ON Attendances (CompensationAttendableID);

-- Classes
CREATE INDEX idx_Classes_StudiesID ON Classes (StudiesID);
CREATE INDEX idx_Classes_TeacherID ON Classes (TeacherID);

-- CourseModules
CREATE INDEX idx_CourseModules_CourseID ON CourseModules (CourseID);
CREATE INDEX idx_CourseModules_TeacherID ON CourseModules (TeacherID);

-- Courses
CREATE INDEX idx_Courses_LectureID ON Courses (LectureID);

-- Enrollments
CREATE INDEX idx_Enrollments_LectureID ON Enrollments (LectureID);
CREATE INDEX idx_Enrollments_OrderID ON Enrollments (OrderID);

-- Internships
CREATE INDEX idx_Internships_AttendableID ON Internships (AttendableID);
CREATE INDEX idx_Internships_StudiesID ON Internships (StudiesID);

-- Lectures
CREATE INDEX idx_Lectures_TranslatorID ON Lectures (TranslatorID);

-- PostponedPayments
CREATE INDEX idx_PostponedPayments_OrderID ON PostponedPayments (OrderID);

-- OnlineClasses
CREATE INDEX idx_OnlineClasses_AttendableID ON OnlineClasses (AttendableID);
CREATE INDEX idx_OnlineClasses_ClassID ON OnlineClasses (ClassID);
CREATE INDEX idx_OnlineClasses_LectureID ON OnlineClasses (LectureID);
CREATE INDEX idx_OnlineClasses_StudySessionID ON OnlineClasses (StudySessionID);

-- OnlineCourseModules
CREATE INDEX idx_OnlineCourseModules_AttendableID ON OnlineCourseModules (AttendableID);
CREATE INDEX idx_OnlineCourseModules_CourseModuleID ON OnlineCourseModules (CourseModuleID);

-- Orders
CREATE INDEX idx_Orders_StudentID ON Orders (StudentID);

-- StudySessionPayments
CREATE INDEX idx_StudySessionPayments_EnrollmentID ON StudySessionPayments (EnrollmentID);

-- StationaryClasses
CREATE INDEX idx_StationaryClasses_AttendableID ON StationaryClasses (AttendableID);
CREATE INDEX idx_StationaryClasses_ClassID ON StationaryClasses (ClassID);
CREATE INDEX idx_StationaryClasses_LectureID ON StationaryClasses (LectureID);
CREATE INDEX idx_StationaryClasses_StudySessionID ON StationaryClasses (StudySessionID);

-- StationaryCourseModules
CREATE INDEX idx_StationaryCourseModules_AttendableID ON StationaryCourseModules (AttendableID);
CREATE INDEX idx_StationaryCourseModules_CourseModuleID ON StationaryCourseModules (CourseModuleID);

-- Studies
CREATE INDEX idx_Studies_LectureID ON Studies (LectureID);

-- StudySessions
CREATE INDEX idx_StudySessions_StudiesID ON StudySessions (StudiesID);

-- Webinars
CREATE INDEX idx_Webinars_LectureID ON Webinars (LectureID);
CREATE INDEX idx_Webinars_TeacherID ON Webinars (TeacherID);