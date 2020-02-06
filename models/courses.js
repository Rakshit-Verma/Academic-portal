
const pg = require('pg');

const client = new pg.Client({
    user: "postgres",
    host: "localhost",
    database: "portal",
    password: "1234",
    port: 5432
});

client.connect();
var s = "CREATE TABLE courses (id varchar(10) not null,name varchar(50) not null,l integer not null,t integer not null,p integer not null,PRIMARY KEY (id))";
client.query(s, (err, res) => {
    //console.log(err,res);
});

client.query("CREATE TABLE prerequisite (original_couse_id varchar(10),prerequisite_course_id varchar(10),PRIMARY KEY (original_couse_id, prerequisite_course_id))", (err, res) => {
    //console.log(err,res);
});

client.query("CREATE TABLE department (name varchar(20),PRIMARY KEY (name))", (err, res) => {
    //console.log(err,res);
});

client.query("CREATE TABLE faculty (id varchar(10) not null,name varchar(50) not null,department_name varchar(20) ,FOREIGN KEY (department_name) REFERENCES department(name),PRIMARY KEY (id))", (err, res) => {
    //console.log(err,res);
});

client.query("CREATE TABLE offered_courses (course_id varchar(10) not null,year integer not null,semester varchar(10) not null,cgpa_required real,course_instructor_id varchar(10),time_slot_id char(10) not null,PRIMARY KEY (course_id, year, semester),FOREIGN KEY (course_id) REFERENCES courses(id),FOREIGN KEY (course_instructor_id) REFERENCES faculty(id))", (err, res) => {
    //console.log(err,res);
});

client.query("CREATE TABLE batch (year integer,advisor_id varchar(10) not null,department_name varchar(20),FOREIGN KEY (advisor_id)  REFERENCES faculty(id),FOREIGN KEY (department_name)  REFERENCES department(name),PRIMARY KEY (year, department_name))", (err, res) => {
    //console.log(err,res);
});

client.query("CREATE TABLE batches_allowed (course_offered_id varchar(10) not null,year_course integer not null,semester_course varchar(10) not null,batch_year integer not null,batch_dept varchar(20) not null,FOREIGN KEY (course_offered_id, year_course, semester_course)  REFERENCES offered_courses(course_id, year, semester),FOREIGN KEY (batch_dept, batch_year)  REFERENCES batch(department_name, year),PRIMARY KEY (course_offered_id, year_course, semester_course, batch_year, batch_dept))", (err, res) => {
    //console.log(err,res);
});

client.query("CREATE TABLE students ( entry_no varchar(10), name varchar(50) not null,batch_year integer not null,dept_name varchar(20) not null,FOREIGN KEY (batch_year, dept_name) REFERENCES batch(year, department_name),PRIMARY KEY (entry_no))", (err, res) => {
    //console.log(err,res);
});

client.query("CREATE TABLE course_registrations (student_entry_no varchar(10),course_offered_id varchar(10) not null,year_course integer not null,semester_course varchar(10) not null,FOREIGN KEY (course_offered_id, year_course, semester_course)  REFERENCES offered_courses(course_id, year, semester),PRIMARY KEY (student_entry_no, course_offered_id, year_course, semester_course))", (err, res) => {
    //console.log(err,res);
});

client.query("CREATE TABLE ticket (ticket_id varchar(10) not null,student_id varchar(10),instructor_id varchar(10) not null,advisor_id varchar(10) not null,status smallint,current_holder varchar(10),course_offered_id varchar(10) not null,year_course integer not null,semester_course varchar(10) not null,FOREIGN KEY (course_offered_id, year_course, semester_course)  REFERENCES offered_courses(course_id, year, semester),FOREIGN KEY (student_id)  REFERENCES students(entry_no),FOREIGN KEY (advisor_id)  REFERENCES faculty(id),FOREIGN KEY (instructor_id)  REFERENCES faculty(id),PRIMARY KEY (ticket_id))", (err, res) => {
    //console.log(err,res);
});

client.query("CREATE TABLE semesters (year integer not null,semester varchar(10) not null,status smallint,sem_id SERIAL not null,PRIMARY KEY (sem_id) )", (err, res) => {
    //console.log(err,res);
});

client.query(`
create or replace procedure get_total_credits(IN course_id varchar(10),INOUT credits DEC(4,2))
AS
$$
DECLARE

ll DEC(4,2);
tt DEC(4,2);
pp DEC(4,2);
 
BEGIN

select l INTO ll from courses where course.id=course_id;
select t INTO tt from courses where course.id=course_id;
select p INTO pp from courses where course.id=course_id;

credits:=0.5*pp;
credits:=credits+ll;
credits:=credits+tt;
END
$$
language plpgsql;
`, (err, ess) => {

});