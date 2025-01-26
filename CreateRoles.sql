
-- Grant permissions to AdministratorBazyDanych
create role AdministratorBazyDanych;

grant all privileges to AdministratorBazyDanych;

-- Grant permissions to Gosc
create role Gosc;

grant select on VW_All_FutureLectures to Gosc;
grant select on VW_Future_CourseModules to Gosc;
grant select on VW_Future_Webinars to Gosc;
grant select on VW_Future_Classes to Gosc;

grant insert on Students to Gosc;

grant execute on PR_Add_Student to Gosc;

-- Grant permissions to Student
create role Student;

grant select on VW_All_FutureLectures to Student;
grant select on VW_Future_CourseModules to Student;
grant select on VW_Future_Webinars to Student;
grant select on VW_Future_Classes to Student;

grant execute on PR_Create_Cart to Student;
grant execute on PR_Add_To_Cart to Student;
grant execute on PR_Place_Order to Student;

grant select on FN_ScheduleForStudent to Student;
grant select on FN_ScheduleForStudies to Student;
grant select on FN_ScheduleForCourse to Student;

grant select on VW_All_Attendance to Student;
grant select on VW_Internships_Attendance to Student;
grant select on VW_OnlineClasses_Attendance to Student;
grant select on VW_StationaryClasses_Attendance to Student;
grant select on VW_StationaryCourseModules_Attendance to Student;

grant select on VW_Students_Bilocations to Student;

grant execute on FN_Student_Passes_Studies to Student;
grant execute on FN_Student_Presence_On_Internships to Student;

-- Grant permissions to Nauczyciel
create role Nauczyciel;

grant select on Webinars to Nauczyciel;
grant select on CourseModules to Nauczyciel;
grant select on Classes to Nauczyciel;
grant select on OnlineClasses to Nauczyciel;
grant select on StationaryClasses to Nauczyciel;
grant select on StationaryCourseModules to Nauczyciel;
grant select on OnlineCourseModules to Nauczyciel;

grant select on FN_Students_List to Nauczyciel;

grant execute on PR_Set_Attendances to Nauczyciel;

grant select on VW_All_Attendance to Nauczyciel;
grant select on VW_OnlineClasses_Attendance to Nauczyciel;
grant select on VW_StationaryClasses_Attendance to Nauczyciel;
grant select on VW_StationaryCourseModules_Attendance to Nauczyciel;

grant select on FN_ScheduleForTeacher to Nauczyciel;
grant select on FN_ScheduleForStudies to Nauczyciel;
grant select on FN_ScheduleForCourse to Nauczyciel;

-- Grant permissions to Dyrektor
create role Dyrektor;

grant update on StudySessionPayments to Dyrektor;
grant select, insert, update, delete on PostponedPayments to Dyrektor;

grant select on VW_FinancialReports to Dyrektor;
grant select on VW_All_Loaners to Dyrektor;

grant select on VW_All_FutureLectures to Dyrektor;
grant select on VW_All_FutureEnrollments to Dyrektor;
grant select on VW_All_FutureLectures to Dyrektor;

grant select on VW_All_Attendance to Dyrektor;
grant select on VW_All_Attendance to Dyrektor;
grant select on VW_Internships_Attendance to Dyrektor;
grant select on VW_Internships_Attendance_Summary to Dyrektor;
grant select on VW_OnlineClasses_Attendance to Dyrektor;
grant select on VW_OnlineClasses_Attendance_Summary to Dyrektor;
grant select on VW_StationaryClasses_Attendance to Dyrektor;
grant select on VW_StationaryClasses_Attendance_Summary to Dyrektor;
grant select on VW_OnlineCourseModules_Attendance to Dyrektor;
grant select on VW_OnlineCourseModules_Attendance_Summary to Dyrektor;
grant select on VW_StationaryCourseModules_Attendance to Dyrektor;
grant select on VW_StationaryCourseModules_Attendance_Summary to Dyrektor;

grant select on VW_Students_Bilocations to Dyrektor;

-- Grant permissions to PracownikSekretariatu
create role PracownikSekretariatu;

grant execute on PR_Create_Lecture to PracownikSekretariatu;

grant execute on PR_Create_Studies to PracownikSekretariatu;
grant execute on PR_Create_Class to PracownikSekretariatu;
grant execute on PR_Create_OnlineClass to PracownikSekretariatu;
grant execute on PR_Create_StationaryClass to PracownikSekretariatu;
grant execute on PR_Create_StudySession to PracownikSekretariatu;

grant execute on PR_Create_Course to PracownikSekretariatu;
grant execute on PR_Create_CourseModule to PracownikSekretariatu;
grant execute on PR_Create_OnlineCourseModule to PracownikSekretariatu;
grant execute on PR_Create_StationaryCourseModule to PracownikSekretariatu;

grant execute on PR_Create_Webinar to PracownikSekretariatu;

grant execute on PR_Add_Teacher to PracownikSekretariatu;
grant execute on PR_Add_Translator to PracownikSekretariatu;

grant select, insert, update, delete on Lectures to PracownikSekretariatu;

grant select, insert, update, delete on Studies to PracownikSekretariatu;
grant select, insert, update, delete on Classes to PracownikSekretariatu;
grant select, insert, update, delete on OnlineClasses to PracownikSekretariatu;
grant select, insert, update, delete on StationaryClasses to PracownikSekretariatu;
grant select, insert, update, delete on StudySessions to PracownikSekretariatu;

grant select, insert, update, delete on Courses to PracownikSekretariatu;
grant select, insert, update, delete on CourseModules to PracownikSekretariatu;
grant select, insert, update, delete on OnlineCourseModules to PracownikSekretariatu;
grant select, insert, update, delete on StationaryCourseModules to PracownikSekretariatu;

grant select, insert, update, delete on Webinars to PracownikSekretariatu;

-- Grant permissions to Tlumacz
create role Tlumacz;

grant select on Lectures to Tlumacz;
grant select on Webinars to Tlumacz;
grant select on CourseModules to Tlumacz;
grant select on Classes to Tlumacz;
grant select on OnlineClasses to Tlumacz;
grant select on StationaryClasses to Tlumacz;
grant select on StationaryCourseModules to Tlumacz;
grant select on OnlineCourseModules to Tlumacz;

grant select on FN_ScheduleForTranslator to Tlumacz;
grant select on FN_ScheduleForStudies to Tlumacz;
grant select on FN_ScheduleForCourse to Tlumacz;


-----------------------------------------
drop role AdministratorBazyDanych;
drop role Gosc;
drop role Student;
drop role Nauczyciel;
drop role Dyrektor;
drop role PracownikSekretariatu;
drop role Tlumacz;
