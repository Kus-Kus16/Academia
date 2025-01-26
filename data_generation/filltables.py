import json
import pyodbc

server = 'dbmanage.lab.ii.agh.edu.pl'
database = 'u_mackus'
username = 'u_mackus'
password = 'NRYFuOAPnIyQ'
connection_string = f'DRIVER={{ODBC Driver 17 for SQL Server}};SERVER={server};DATABASE={database};UID={username};PWD={password}'

# Connect to the database with error handling
try:
    conn = pyodbc.connect(connection_string)
    cursor = conn.cursor()
    print("Connection successful")
except pyodbc.Error as e:
    print("Error connecting to database: ", e)
    exit(1)

# List tables in the database
try:
    cursor.execute("SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE = 'BASE TABLE'")
    tables = cursor.fetchall()
    print("Tables in the database:")
    for table in tables:
        print(table.TABLE_NAME)
except pyodbc.Error as e:
    print("Error listing tables: ", e)

# Function to load JSON data from a file
def load_json_data(filename):
    with open(filename, 'r') as file:
        return json.load(file)

# Function to insert data into a table
def insert_data(table_name, data, identity_column=None):
    if identity_column:
        cursor.execute(f"SET IDENTITY_INSERT {table_name} ON")
    for record in data:
        columns = ', '.join(record.keys())
        placeholders = ', '.join(['?' for _ in record])
        sql = f'INSERT INTO {table_name} ({columns}) VALUES ({placeholders})'
        cursor.execute(sql, tuple(record.values()))
    if identity_column:
        cursor.execute(f"SET IDENTITY_INSERT {table_name} OFF")
    conn.commit()

# Load and insert data for each table
students_data = load_json_data('generated_files/students_data.json')
insert_data('Students', students_data, identity_column='StudentID')

teachers_data = load_json_data('generated_files/teachers_data.json')
insert_data('Teachers', teachers_data, identity_column='TeacherID')

translators_data = load_json_data('generated_files/translators_data.json')
insert_data('Translators', translators_data, identity_column='TranslatorID')

orders_data = load_json_data('generated_files/payments_data.json')
insert_data('Orders', orders_data, identity_column='OrderID')

loans_data = load_json_data('generated_files/loans_data.json')
insert_data('PostponedPayments', loans_data)

lectures_data = load_json_data('generated_files/lectures_data.json')
insert_data('Lectures', lectures_data, identity_column='LectureID')

attendable_data = load_json_data('generated_files/attenables_data.json')
insert_data('Attendable', attendable_data, identity_column='AttendableID')

enrollments_data = load_json_data('generated_files/enrollments_data.json')
insert_data('Enrollments', enrollments_data, identity_column='EnrollmentID')

webinars_data = load_json_data('generated_files/webinars_data.json')
insert_data('Webinars', webinars_data, identity_column='WebinarID')

courses_data = load_json_data('generated_files/courses_data.json')
insert_data('Courses', courses_data, identity_column='CourseID')

course_modules_data = load_json_data('generated_files/course_modules_data.json')
insert_data('CourseModules', course_modules_data, identity_column='CourseModuleID')

online_course_modules_data = load_json_data('generated_files/online_course_modules_data.json')
insert_data('OnlineCourseModules', online_course_modules_data, identity_column='OnlineCourseID')

stationary_course_modules_data = load_json_data('generated_files/stationary_course_modules_data.json')
insert_data('StationaryCourseModules', stationary_course_modules_data, identity_column='StationaryCourseID')

studies_data = load_json_data('generated_files/studies_data.json')
insert_data('Studies', studies_data)

internships_data = load_json_data('generated_files/internships_data.json')
insert_data('Internships', internships_data, identity_column='InternshipID')

classes_data = load_json_data('generated_files/classes_data.json')
insert_data('Classes', classes_data, identity_column='ClassID')

studysession_data = load_json_data('generated_files/study_sessions_data.json')
insert_data('StudySessions', studysession_data, identity_column='StudySessionID')

online_classes_data = load_json_data('generated_files/online_classes_data.json')
insert_data('OnlineClasses', online_classes_data, identity_column='OnlineClassID')

stationary_classes_data = load_json_data('generated_files/stationary_classes_data.json')
insert_data('StationaryClasses', stationary_classes_data, identity_column='StationaryClassID')

study_session_payments_data = load_json_data('generated_files/study_sessions_payments_data.json')
insert_data('StudySessionPayments', study_session_payments_data, identity_column='PaymentID')

attendances_data = load_json_data('generated_files/attendances_data.json')
insert_data('Attendances', attendances_data)

# Close the database connection
cursor.close()
conn.close()