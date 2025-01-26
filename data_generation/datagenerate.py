
import faker
import json
import datetime
import random

def generate_dates_before_today():
    fake = faker.Faker()
    dates = []
    for _ in range(15):
        dates.append(fake.date_between(start_date='-6y', end_date='-1d'))
    dates.sort()
    return dates

def generate_dates_after_today():
    fake = faker.Faker()
    dates = []
    for _ in range(15):
        dates.append(fake.date_between(start_date='+1d', end_date='+3y'))
    dates.sort()
    return dates

before_today = generate_dates_before_today()
after_today = generate_dates_after_today()


fake = faker.Faker()
lecture_id_tracker = 1
attendable_id_tracker = 1
amount_of_classes_in_lectures = 0
counterforfun = 0
lectures = []
attendables = []
studies_ids = []
attendances = []
studysessions = []
attendancesforstudents = {}

def generate_lectures_data(zaliczka,always_available, before_today_bool):
    global lecture_id_tracker

    available = fake.boolean()
    price = fake.random_int(min=10, max=100)*10
    date = datetime.datetime.combine(fake.random_element(elements=before_today) if before_today_bool else fake.random_element(elements=after_today),datetime.time(random.randint(8, 18), 0, 0))
    
    return{
        "LectureID": lecture_id_tracker,
        "TranslatorID": fake.random_int(min=1, max=num_translators),
        "LectureName": fake.catch_phrase(),
        "Description": fake.text(),
        "AdvancePrice": price*0.7 if zaliczka else None,
        "TotalPrice": price,
        "Date": str(date),
        "Language": fake.language_code(),
        "Available": True if always_available else date > datetime.datetime.today() + datetime.timedelta(days=3)
    }

def generate_lectures_for_classes_data(date):
    global lecture_id_tracker

    price = fake.random_int(min=5, max=10)*10
    
    return{
        "LectureID": lecture_id_tracker,
        "TranslatorID": fake.random_int(min=1, max=num_translators),
        "LectureName": fake.catch_phrase(),
        "Description": fake.text(),
        "AdvancePrice": price*0.7,
        "TotalPrice": price,
        "Date": str(date),
        "Language": fake.language_code(),
        "Available": date > datetime.datetime.today() + datetime.timedelta(days=3)
    }

def generate_attendable_data(date, is_internship):

    return {
            "AttendableID": attendable_id_tracker,
            "StartDate": str(date),
            "EndDate": str(date + datetime.timedelta(days=14) if is_internship else date + datetime.timedelta(hours=2)),
        }

def generate_students_data(num_records):
    students = []
    current_id = 1;
    for _ in range(num_records):
        students.append({
            "StudentID": current_id,
            "Name": fake.first_name(),
            "Surname": fake.last_name(),
            "Email": fake.email(),
            "Phone": fake.phone_number(),
            "Address": fake.address(),
            "City": fake.city(),
            "Country": fake.country(),
            "BirthDate": str(fake.date_of_birth(minimum_age=18, maximum_age=40))
        })
        current_id += 1

    return students

def generate_translators_data(num_records):
    translators = []
    current_id = 1;
    for _ in range(num_records):
        translators.append({
            "TranslatorID": current_id,
            "Name": fake.first_name(),
            "Surname": fake.last_name(),
            "Email": fake.email(),
            "Phone": fake.phone_number(),
            "Address": fake.address(),
            "City": fake.city(),
            "Country": fake.country(),
            "BirthDate": str(fake.date_of_birth(minimum_age=30, maximum_age=60)),
            "HireDate": str(fake.date_between(start_date='-10y', end_date='-7y')),
            "Language": fake.language_code()
        })
        current_id += 1
    return translators

def generate_teachers_data(num_records):
    teachers = []
    current_id = 1;
    for _ in range(num_records):
        teachers.append({
            "TeacherID": current_id,
            "Name": fake.first_name(),
            "Surname": fake.last_name(),
            "Email": fake.email(),
            "Phone": fake.phone_number(),
            "Address": fake.address(),
            "City": fake.city(),
            "Country": fake.country(),
            "BirthDate": str(fake.date_of_birth(minimum_age=30, maximum_age=70)),
            "TitleOfCourtesy": fake.prefix(),
            "HireDate": str(fake.date_between(start_date='-10y', end_date='-7y'))
        })
        current_id += 1
    return teachers

def generate_webinars_data(num_records):
    global lecture_id_tracker, lectures

    current_id = 1

    webinars = []
    for _ in range(num_records//2):
        webinars.append({
            "WebinarID": current_id,
            "LectureID": lecture_id_tracker,
            "TeacherID": fake.random_int(min=1, max=num_teachers),
            "Link": fake.url(),
            "IsFree": fake.boolean()
        })
        lectures.append(generate_lectures_data(False, True, True))
        current_id += 1
        lecture_id_tracker += 1

    for _ in range(num_records//2, num_records):
        webinars.append({
            "WebinarID": current_id,
            "LectureID": lecture_id_tracker,
            "TeacherID": fake.random_int(min=1, max=num_teachers),
            "Link": fake.url(),
            "IsFree": fake.boolean()
        })
        lectures.append(generate_lectures_data(False, True, False))
        current_id += 1
        lecture_id_tracker += 1
    return webinars

def generate_courses_data(num_records):
    global lecture_id_tracker
    
    courses = []
    current_id = 1;

    for _ in range(num_records//2):
        courses.append({
            "CourseID": current_id,
            "LectureID": lecture_id_tracker
        })
        lectures.append(generate_lectures_data(True, False, True))
        current_id += 1
        lecture_id_tracker += 1
    
    for _ in range(num_records//2, num_records):
        courses.append({
            "CourseID": current_id,
            "LectureID": lecture_id_tracker
        })
        lectures.append(generate_lectures_data(True, False, False))
        current_id += 1
        lecture_id_tracker += 1

    return courses

def generate_studies_data(num_records):
    global lecture_id_tracker

    studies = []
    for _ in range(num_records//2):
        studies_ids.append(''.join(fake.random_letters(length=5)))
        studies.append({
            "StudiesID": studies_ids[-1],
            "LectureID": lecture_id_tracker,
            "Syllabus": fake.text(),
            "CapacityLimit": 100,
        })
        lectures.append(generate_lectures_data(True, False, True))
        lecture_id_tracker += 1

    for _ in range(num_records//2, num_records):
        studies_ids.append(''.join(fake.random_letters(length=5)))
        studies.append({
            "StudiesID": studies_ids[-1],
            "LectureID": lecture_id_tracker,
            "Syllabus": fake.text(),
            "CapacityLimit": 100,
        })
        lectures.append(generate_lectures_data(True, False, False))
        lecture_id_tracker += 1
    return studies

def generate_internships_data(num_records, studies_start_index):
    global attendable_id_tracker
    
    current_id = 1
    internships = []
    for _ in range(num_records):
        internships.append({
            "InternshipID": current_id,
            "AttendableID": attendable_id_tracker,
            "StudiesID": studies_ids[current_id-1],
            "Address": fake.address(),
            "Name": fake.company(),
            "Description": fake.text()
        })
        date_parameter = datetime.datetime.strptime(lectures[studies_start_index + current_id - 1].get("Date"), "%Y-%m-%d %H:%M:%S")
        attendables.append(generate_attendable_data(date_parameter + datetime.timedelta(weeks=52), True))
        current_id += 1
        attendable_id_tracker += 1
    return internships

def generate_study_sessions_data():
    global studies_ids, studysessions, lectures
    study_sessions = []
    current_id = 1
    for i in range(10):
        studysessions.append([])
        for j in range(6):
            print(i, " ", j)
            flag = True

            while flag:
                start_date = fake.date_time_between(start_date=datetime.datetime.strptime(lectures[i+60].get("Date"), "%Y-%m-%d %H:%M:%S"), end_date=datetime.datetime.strptime(lectures[i+60].get("Date"), "%Y-%m-%d %H:%M:%S") + datetime.timedelta(weeks=174))
                end_date = start_date + datetime.timedelta(days=3)
                if(studysessions[i] == []):
                    flag = False
                else:
                    for studysession in studysessions[i]:
                        if datetime.datetime.strptime(studysession.get("StartDate"), "%Y-%m-%d %H:%M:%S") < start_date < datetime.datetime.strptime(studysession.get("EndDate"), "%Y-%m-%d %H:%M:%S") + datetime.timedelta(days=7) or datetime.datetime.strptime(studysession.get("StartDate"), "%Y-%m-%d %H:%M:%S") + datetime.timedelta(days=7) <= end_date <= datetime.datetime.strptime(studysession.get("EndDate"), "%Y-%m-%d %H:%M:%S"):
                                flag = True
                        else:
                            flag = False
                
            study_session = {
                "StudySessionID": current_id,
                "StudiesID": studies_ids[i],
                "StartDate": str(start_date),
                "EndDate": str(end_date),
                "Price": fake.random_int(min=5, max=10)*10,
            }
            study_sessions.append(study_session)
            studysessions[i].append(study_session)

            current_id += 1
    return study_sessions

def generate_classes_data(num_records):
    classes = []
    current_id = 1
    for id in studies_ids:
        for _ in range(num_records):
            classes.append({
                "ClassID": current_id,
                "StudiesID": id,
                "TeacherID": fake.random_int(min=1, max=num_teachers),
                "Name": fake.catch_phrase(),
                "Description": fake.text()
            })
            current_id += 1
    return classes

def generate_online_and_stationary_classes_data(num_records, classes_table, studies_start_index):
    global attendable_id_tracker, lecture_id_tracker, amount_of_classes_in_lectures
    
    online_current_id = 1
    stationary_current_id = 1
    online_classes = []
    stationary_classes = []

    for i, class_obj in enumerate(classes_table):
        startdate = datetime.datetime.strptime(lectures[studies_start_index + studies_ids.index(class_obj.get("StudiesID"))].get("Date"), "%Y-%m-%d %H:%M:%S")       
        print(i)
        #Generacja innych zajęć
        for _ in range(num_records//2):
            class_start_date = fake.date_time_between(start_date=startdate, end_date=(startdate + datetime.timedelta(weeks=175)))

            lectureable = fake.boolean(10)
            possibleLectureId = None
            if(lectureable):
                amount_of_classes_in_lectures += 1
                possibleLectureId = lecture_id_tracker
                lectures.append(generate_lectures_for_classes_data(class_start_date))
                lecture_id_tracker += 1

            if(i%2 == 0):
                stationary_classes.append({ 
                    "StationaryClassID": stationary_current_id,
                    "ClassID": i+1,
                    "AttendableID": attendable_id_tracker,
                    "LectureID": possibleLectureId,
                    "StudySessionID": None,
                    "Classroom": fake.random_letter()+str(fake.random_int(min=10, max=50)),
                    "SeatLimit": 50
                    })
                stationary_current_id += 1
            else:
                online_classes.append({ 
                    "OnlineClassID": online_current_id,
                    "ClassID": i+1,
                    "LectureID": possibleLectureId,
                    "AttendableID": attendable_id_tracker,
                    "StudySessionID": None,
                    "Link": fake.url(),
                    "IsLive": fake.boolean()
                })
                online_current_id += 1

            attendables.append(generate_attendable_data(class_start_date, False))
            attendable_id_tracker += 1

    #Generacja zajęć do studysessions
    for i in range(10):
        print(i)
        for studysession in studysessions[i]:
            print("StationaryClassID na zjazdach: ", stationary_current_id)
            stationary_classes.append({
                "StationaryClassID": stationary_current_id,
                "ClassID": fake.random_int(min=35*i+1, max=35*i+35),
                "AttendableID": attendable_id_tracker,
                "LectureID": None,
                "StudySessionID": studysession.get("StudySessionID"),
                "Classroom": fake.random_letter()+str(fake.random_int(min=10, max=50)),
                "SeatLimit": 50
            })
            attendables.append(generate_attendable_data(datetime.datetime.strptime(studysession.get("StartDate"), "%Y-%m-%d %H:%M:%S"), False))
            attendable_id_tracker += 1
            stationary_current_id += 1
            

            online_classes.append({ 
                "OnlineClassID": online_current_id,
                "ClassID": fake.random_int(min=35*i+1, max=35*i+35),
                "LectureID": None,
                "AttendableID": attendable_id_tracker,
                "StudySessionID": studysession.get("StudySessionID"),
                "Link": fake.url(),
                "IsLive": fake.boolean()
            })
            attendables.append(generate_attendable_data(datetime.datetime.strptime(studysession.get("EndDate"), "%Y-%m-%d %H:%M:%S")-datetime.timedelta(days=2), False))
            attendable_id_tracker += 1
            online_current_id += 1

            stationary_classes.append({
                "StationaryClassID": stationary_current_id,
                "ClassID": fake.random_int(min=(35*i)+1, max=(35*i)+35),
                "AttendableID": attendable_id_tracker,
                "LectureID": None,
                "StudySessionID": studysession.get("StudySessionID"),
                "Classroom": fake.random_letter()+str(fake.random_int(min=10, max=50)),
                "SeatLimit": 50
            })
            attendables.append(generate_attendable_data(datetime.datetime.strptime(studysession.get("EndDate"), "%Y-%m-%d %H:%M:%S")-datetime.timedelta(days=1), False))
            attendable_id_tracker += 1
            stationary_current_id += 1
            

    return stationary_classes, online_classes

def generate_course_modules_data(start_index_course, num_courses,num_course_modules, num_stationary, num_online):
    global attendable_id_tracker

    course_modules = []
    online_course_modules = []
    stationary_course_modules = []

    course_modules_id = 1
    online_course_modules_id = 1
    stationary_course_modules_id = 1

    for i in range(num_courses):
        start_course_date = datetime.datetime.strptime(lectures[start_index_course + i].get("Date"), "%Y-%m-%d %H:%M:%S")
        for j in range(num_course_modules):
            start_module_date = start_course_date + datetime.timedelta(weeks=j)
            course_modules.append({
                "CourseModuleID": course_modules_id,
                "TeacherID": fake.random_int(min=1, max=num_teachers),
                "CourseID": i+1,
                "Name": fake.catch_phrase(),
                "Description": fake.text(),
            })
            if(i%3 == 0):
                for k in range(num_stationary):
                    start_single_module_date = start_module_date + datetime.timedelta(days=k)
                    stationary_course_modules.append({
                        "StationaryCourseID": stationary_course_modules_id,
                        "CourseModuleID": course_modules_id,
                        "AttendableID": attendable_id_tracker,
                        "Classroom": str(fake.random_letter())+str(fake.random_int(min=10, max=99)),
                        "SeatLimit": 60
                    })
                    stationary_course_modules_id += 1
                    attendables.append(generate_attendable_data(start_single_module_date, False))
                    attendable_id_tracker += 1
            elif(i%3 == 1):
                for k in range(num_online):
                    start_single_module_date = start_module_date + datetime.timedelta(days=k)
                    online_course_modules.append({
                        "OnlineCourseID": online_course_modules_id,
                        "CourseModuleID": course_modules_id,
                        "AttendableID": attendable_id_tracker,
                        "Link": fake.url(),
                        "IsLive": fake.boolean()
                    })
                    online_course_modules_id += 1
                    attendables.append(generate_attendable_data(start_single_module_date, False))
                    attendable_id_tracker += 1
            else:
                for k in range(num_stationary//2):
                    start_single_module_date = start_module_date + datetime.timedelta(days=k)
                    stationary_course_modules.append({
                        "StationaryCourseID": stationary_course_modules_id,
                        "CourseModuleID": course_modules_id,
                        "AttendableID": attendable_id_tracker,
                        "Classroom": str(fake.random_letter())+str(fake.random_int(min=10, max=99)),
                        "SeatLimit": 30
                    })
                    stationary_course_modules_id += 1
                    attendables.append(generate_attendable_data(start_single_module_date, False))
                    attendable_id_tracker += 1

                for k in range(num_online//2, num_online):
                    start_single_module_date = start_module_date + datetime.timedelta(days=k)
                    online_course_modules.append({
                        "OnlineCourseID": online_course_modules_id,
                        "CourseModuleID": course_modules_id,
                        "AttendableID": attendable_id_tracker,
                        "Link": fake.url(),
                        "IsLive": fake.boolean()
                    })
                    online_course_modules_id += 1
                    attendables.append(generate_attendable_data(start_single_module_date, False))
                    attendable_id_tracker += 1
            course_modules_id += 1
   
    return course_modules, online_course_modules, stationary_course_modules


def generate_orders_data(student_numbers, stat_course_meeting, online_course_meeting, internships, stationary_classes, online_classes):
    global studysessions
    orders = []
    enrollments = []
    loans = []
    studysessionpayments = []
    order_id = 1
    enrollment_id = 1
    studysessionpayment_id = 1

    studysessionspaymentstobeupdated = []

    for i in range(student_numbers-3):

        order_amount = fake.random_int(min=1, max=3)

        while order_amount > 0:
            lectures_drawn = []
            oldest_date = datetime.datetime.strptime("3000-12-12 12:12:12", "%Y-%m-%d %H:%M:%S")
            failed = fake.boolean(21)
            all_webinars = True

            for _ in range(fake.random_int(min=2, max=3)):
                lecture_id_aaaa = fake.random_int(min=0, max=len(lectures)-1)
                
                if(lecture_id_aaaa > 59): all_webinars = False

                lectures_drawn.append(lectures[lecture_id_aaaa])
                if datetime.datetime.strptime(lectures_drawn[-1].get("Date"), "%Y-%m-%d %H:%M:%S") < oldest_date:
                    oldest_date = datetime.datetime.strptime(lectures_drawn[-1].get("Date"), "%Y-%m-%d %H:%M:%S")

                if(
                    not failed and 
                    lecture_id_aaaa > 59 and 
                    datetime.datetime.strptime(lectures[lecture_id_aaaa].get("Date"), "%Y-%m-%d %H:%M:%S") < datetime.datetime.today()
                ): 
                    generate_attendance(i+1,lecture_id_aaaa, stat_course_meeting, online_course_meeting, internships, stationary_classes, online_classes)

                enrollments.append({
                    "EnrollmentID": enrollment_id,
                    "OrderID": order_id,
                    "LectureID": lectures[lecture_id_aaaa].get("LectureID"),
                    "AdvancePrice": lectures[lecture_id_aaaa].get("AdvancePrice"),
                    "TotalPrice": lectures[lecture_id_aaaa].get("TotalPrice"),
                    "Status": "InProgress" if not failed else "NotPaidOnTime"
                })

                if(60 <= lecture_id_aaaa < 70 and not failed):
                    for studysession in studysessions[lecture_id_aaaa-60]:
                        studysessionpayments.append({
                            "PaymentID": studysessionpayment_id,
                            "EnrollmentID": enrollment_id,
                            "StudySessionID": studysession.get("StudySessionID"),
                            "Price": studysession.get("Price"),
                            "DueDate": str(datetime.datetime.strptime(studysession.get("StartDate"), "%Y-%m-%d %H:%M:%S") - datetime.timedelta(days=3)),
                            "PaidDate": None
                        })
                        studysessionspaymentstobeupdated.append(studysessionpayment_id - 1)
                        studysessionpayment_id += 1
                    

                enrollment_id += 1
            
            today = datetime.datetime.combine(datetime.datetime.today(), datetime.time(fake.random_int(min=8, max=12), 0, 0))
            order_date = min(oldest_date - datetime.timedelta(days=fake.random_int(min=7, max=100)), today)
            dfgjlsdbng = min(order_date + datetime.timedelta(days=fake.random_int(min=0, max=3)),today)

            orders.append({
                "OrderID": order_id,
                "StudentID": i+1,
                "OrderDate": str(order_date),
                "AdvancePaidDate": str(dfgjlsdbng) if (not failed or not all_webinars) else None,
                "TotalPaidDate": str(dfgjlsdbng)  if not failed else None,
                "Status": "Completed" if not failed else "Failed"
            })

            counter = True
            for index in studysessionspaymentstobeupdated:
                studysessionpayments[index].update({"PaidDate": str(dfgjlsdbng)})
                        
            
            studysessionspaymentstobeupdated = []
            order_id += 1
            order_amount -= 1
           
        
    return orders, enrollments, studysessionpayments

def generate_attendance(student_id, lecture_id, stat_course_meetings, online_course_meetings, internships, stationary_classes, online_classes):
    global attendances, counterforfun

    if 60 <= lecture_id <= 89:
        course_module_ids = []

        for i in range(5*(lecture_id-59), 5*(lecture_id-59)-5,-1):
            course_module_ids.append(i)

        for stat_course_meeting in stat_course_meetings:
            
            if counterforfun == 0:
                print(stat_course_meeting)
                counterforfun += 1
            if stat_course_meeting.get("CourseModuleID") in course_module_ids:
                attendid = stat_course_meeting.get("AttendableID")
                if datetime.datetime.strptime(attendables[attendid-1].get("EndDate"), "%Y-%m-%d %H:%M:%S") < datetime.datetime.today():
                    attendance = {
                        "AttendableID": attendid,
                        "StudentID": student_id,
                        "Attendance": True,
                        "CompensationNote": None,
                        "CompensationAttendableID": None
                    }
                    
                    if student_id not in attendancesforstudents.keys():
                        attendancesforstudents.update({student_id: set()}) 
                        attendances.append(attendance)
                        attendancesforstudents[student_id].add(attendid)
                    elif attendid not in attendancesforstudents[student_id]:
                        attendances.append(attendance)
                        attendancesforstudents[student_id].add(attendid)
                

        for online_course_meeting in online_course_meetings:

            if online_course_meeting.get("CourseModuleID") in course_module_ids:
                attendid = online_course_meeting.get("AttendableID")
                if datetime.datetime.strptime(attendables[attendid-1].get("EndDate"), "%Y-%m-%d %H:%M:%S") < datetime.datetime.today():
                    attendance = {
                        "AttendableID": attendid,
                        "StudentID": student_id,
                        "Attendance": True,
                        "CompensationNote": None,
                        "CompensationAttendableID": None
                    }
                

                    if student_id not in attendancesforstudents.keys():
                        attendancesforstudents.update({student_id: set()}) 
                        attendances.append(attendance)
                        attendancesforstudents[student_id].add(attendid)
                    elif attendid not in attendancesforstudents[student_id]:
                        attendances.append(attendance)
                        attendancesforstudents[student_id].add(attendid)

    elif 90 <= lecture_id <= 99:
        print("Internship")
        class_ids = []
        for i in range(35*(lecture_id-89), 35*(lecture_id-89)-35,-1):
            class_ids.append(i)
        
        for internship in internships:
            internship_studies_id = internship.get("StudiesID")
            if internship_studies_id == studies_ids[lecture_id-90]:
                attendid =  internship.get("AttendableID")
                if datetime.datetime.strptime(attendables[attendid-1].get("EndDate"), "%Y-%m-%d %H:%M:%S") < datetime.datetime.today():
                    attendance = {
                        "AttendableID":attendid,
                        "StudentID": student_id,
                        "Attendance": True,
                        "CompensationNote": None,
                        "CompensationAttendableID": None
                    }

                    if student_id not in attendancesforstudents.keys():
                        attendancesforstudents.update({student_id: set()}) 
                        attendances.append(attendance)
                        attendancesforstudents[student_id].add(attendid)
                        
                    elif attendid not in attendancesforstudents[student_id]:
                        attendances.append(attendance)
                        attendancesforstudents[student_id].add(attendid)
                        

        for stationary_class in stationary_classes:
            if stationary_class.get("ClassID") in class_ids:
                attendid = stationary_class.get("AttendableID")
                if datetime.datetime.strptime(attendables[attendid-1].get("EndDate"), "%Y-%m-%d %H:%M:%S") < datetime.datetime.today():
                    attendance = {
                        "AttendableID": attendid,
                        "StudentID": student_id,
                        "Attendance": True,
                        "CompensationNote": None,
                        "CompensationAttendableID": None
                    }

                    if student_id not in attendancesforstudents.keys():
                        attendancesforstudents.update({student_id: set()}) 
                        attendances.append(attendance)
                        attendancesforstudents[student_id].add(attendid)
                    elif attendid not in attendancesforstudents[student_id]:
                        attendances.append(attendance)
                        attendancesforstudents[student_id].add(attendid)
        
        for online_class in online_classes:
            if online_class.get("ClassID") in class_ids:
                attendid = online_class.get("AttendableID")
                if datetime.datetime.strptime(attendables[attendid-1].get("EndDate"), "%Y-%m-%d %H:%M:%S") < datetime.datetime.today():
                    attendance = {
                        "AttendableID": attendid,
                        "StudentID": student_id,
                        "Attendance": True,
                        "CompensationNote": None,
                        "CompensationAttendableID": None
                    }

                    if student_id not in attendancesforstudents.keys():
                        attendancesforstudents.update({student_id: set()}) 
                        attendances.append(attendance)
                        attendancesforstudents[student_id].add(attendid)
                    elif attendid not in attendancesforstudents[student_id]:
                        attendances.append(attendance)
                        attendancesforstudents[student_id].add(attendid)

    elif 100 <= lecture_id:
        for stationary_class in stationary_classes: 
            if stationary_class.get("LectureID") == lecture_id:
                attendid = stationary_class.get("AttendableID")
                if datetime.datetime.strptime(attendables[attendid-1].get("EndDate"), "%Y-%m-%d %H:%M:%S") < datetime.datetime.today():
                    attendance = {
                        "AttendableID": attendid,
                        "StudentID": student_id,
                        "Attendance": True,
                        "CompensationNote": None,
                        "CompensationAttendableID": None
                    }

                    if student_id not in attendancesforstudents.keys():
                        attendancesforstudents.update({student_id: set()}) 
                        attendances.append(attendance)
                        attendancesforstudents[student_id].add(attendid)
                    elif attendid not in attendancesforstudents[student_id]:
                        attendances.append(attendance)
                        attendancesforstudents[student_id].add(attendid)
                break
        
        for online_class in online_classes:
            if online_class.get("LectureID") == lecture_id:
                attendid = online_class.get("AttendableID")
                if datetime.datetime.strptime(attendables[attendid-1].get("EndDate"), "%Y-%m-%d %H:%M:%S") < datetime.datetime.today():
                    attendance = {
                        "AttendableID": attendid,
                        "StudentID": student_id,
                        "Attendance": True,
                        "CompensationNote": None,
                        "CompensationAttendableID": None
                    }

                    if student_id not in attendancesforstudents.keys():
                        attendancesforstudents.update({student_id: set()}) 
                        attendances.append(attendance)
                        attendancesforstudents[student_id].add(attendid)
                    elif attendid not in attendancesforstudents[student_id]:
                        attendances.append(attendance)
                        attendancesforstudents[student_id].add(attendid)

                break
    

def export_to_json(data, filename):
    with open(filename, 'w') as f:
        json.dump(data, f, indent=4)

def import_from_json(filename):
    with open(filename, 'r') as f:
        return json.load(f)

if __name__ == "__main__":
    data = import_from_json('table_parameters.json')

    num_students = data.get("students_number", 100)
    num_translators = data.get("translators_number", 100)
    num_payments = data.get("payments_succeeded_number", 100)
    num_payements_failed = data.get("payments_not_succeeded_number", 100)
    num_loans = data.get("loans_number", 100)
    num_enrollments = data.get("enrollments_number", 100)
    num_teachers = data.get("lecturers_number", 100)
    num_courses = data.get("courses_number", 100)
    num_webinars = data.get("webinars_number", 100)
    num_studies = 10

    num_studies_internships = data.get("studies_internships_number", 100)
    num_studies_classes = data.get("studies_classes_number", 100)
    num_online_classes = data.get("online_classes_number", 100)
    num_stationary_classes = data.get("stationary_classes_number", 100)
    num_course_modules = data.get("course_modules_number", 100)
    num_stationary_course_modules = data.get("stationary_course_modules_number", 100)
    num_online_course_modules = data.get("online_course_modules_number", 100)
    num_attendances = data.get("attendances_number", 100)


    print("Doing students")
    students_data = generate_students_data(num_students)
    
    print("Doing teachers")
    teachers_data = generate_teachers_data(num_teachers)
    
    print("Doing translators")
    translators_data = generate_translators_data(num_translators)
    
    print("Doing webinars") 
    webinars_data = generate_webinars_data(num_webinars)
    
    print("Doing courses")
    courses_data = generate_courses_data(num_courses)
    
    print("Doing studies")
    studies_data = generate_studies_data(num_studies)
    
    print("Doing internships")
    studies_start_index = num_webinars+num_courses
    internships_data = generate_internships_data(num_studies_internships,studies_start_index)

    print(studies_ids)
    study_sessions_data = generate_study_sessions_data()
    
    print("Doing classes")
    classes_data = generate_classes_data(num_studies_classes)
    
    print("Doing stationary and online classes")
    stationary_classes_data, online_classes_data = generate_online_and_stationary_classes_data(num_stationary_classes + num_online_classes, classes_data, studies_start_index)
    
    print("Doiung course modules")
    course_modules_data, online_course_modules_data, stationary_course_modules_data = generate_course_modules_data(num_webinars, num_courses, 5, num_stationary_course_modules, num_online_course_modules)

    print("Doing payments")
    payments_data, enrollments_data, study_sessions_payments_data = generate_orders_data(num_students, stationary_course_modules_data, online_course_modules_data, internships_data, stationary_classes_data, online_classes_data)
  
    print("studnets json")
    export_to_json(students_data, 'generated_files/students_data.json')
    print("teachers json")
    export_to_json(teachers_data, 'generated_files/teachers_data.json')
    print("translators json")
    export_to_json(translators_data, 'generated_files/translators_data.json')
    print("webinars json")
    export_to_json(webinars_data, 'generated_files/webinars_data.json')
    print("courses json")
    export_to_json(courses_data, 'generated_files/courses_data.json')
    print("studies json")
    export_to_json(studies_data, 'generated_files/studies_data.json')
    print("internships json")   
    export_to_json(internships_data, 'generated_files/internships_data.json')
    print("study sessions json")
    export_to_json(study_sessions_data, 'generated_files/study_sessions_data.json')
    print("classes json")
    export_to_json(classes_data, 'generated_files/classes_data.json')
    print("stationary classes json")
    export_to_json(stationary_classes_data, 'generated_files/stationary_classes_data.json')
    print("online classes json")
    export_to_json(online_classes_data, 'generated_files/online_classes_data.json')
    print("course modules json")
    export_to_json(course_modules_data, 'generated_files/course_modules_data.json')
    print("online course modules json")
    export_to_json(online_course_modules_data, 'generated_files/online_course_modules_data.json')
    print("stationary course modules json")
    export_to_json(stationary_course_modules_data, 'generated_files/stationary_course_modules_data.json')
    print("lectures json")
    export_to_json(lectures, 'generated_files/lectures_data.json')
    print("attendables json")
    export_to_json(attendables, 'generated_files/attenables_data.json')
    print("payments json")
    export_to_json(payments_data, 'generated_files/payments_data.json')
    print("enrollments json")
    export_to_json(enrollments_data, 'generated_files/enrollments_data.json')
    print("study sessions payments json")
    export_to_json(study_sessions_payments_data, 'generated_files/study_sessions_payments_data.json')
    print("attendances json")
    export_to_json(attendances, 'generated_files/attendances_data.json')

    print(attendables[1])
    print(attendables[2])
    print(attendables[56])
    