--Zmiana statusów płatności -Ł-
create trigger TR_PaymentStatusChange
on Orders
after update
as
begin
    set nocount on;

    if exists (select 1 from inserted where Status = 'Completed' or AdvancePaidDate is not null)
        begin
            update Enrollments
                set Status = 'InProgress'
                where OrderID in (select OrderID from inserted where Status = 'Completed');
        end
end
go

--dodanie StudySessionPayment po opłaceniu całości zamównienia -Ł-
create trigger TR_AddStudySessionPayment
on Enrollments
after update
as
begin
    set nocount on;

    if exists(select 1 from inserted where Status = 'InProgress')
        begin
            with StudiesEnrollmentsUpdated as (
                select I.EnrollmentID, I.Status
                from inserted as I
                         join Enrollments as E on I.EnrollmentID = E.EnrollmentID
                         join Lectures as L on E.LectureID = L.LectureID
                         join Studies as S on L.LectureID = S.LectureID
            ), StudySessionToBeInserted as (
                select E.EnrollmentID, SS.StudySessionID, SS.Price, DATEADD(day, -3, SS.StartDate) as DueDate, NULL as PaidDate
                from StudySessions as SS
                         join Studies as S on SS.StudiesID = S.StudiesID
                         join Lectures as L on S.LectureID = L.LectureID
                         join Enrollments as E on L.LectureID = E.LectureID
                where E.EnrollmentID in (select EnrollmentID from StudiesEnrollmentsUpdated where Status = 'InProgress')
            )

            insert into StudySessionPayments (EnrollmentID, StudySessionID, Price, DueDate, PaidDate)
            select EnrollmentID, StudySessionID, Price, DueDate, PaidDate from StudySessionToBeInserted;
        end
end
go