-- PROCEDURE: public.can_take(character varying, character varying, integer)

-- DROP PROCEDURE public.can_take(character varying, character varying, integer);

CREATE OR REPLACE PROCEDURE public.can_take(
	student_id character varying,
	c_id character varying,
	INOUT result integer)

AS $$
DECLARE 
y integer;
s varchar(10);
o1 integer;
o2 integer;
o3 integer;
o4 integer;
o6 integer;
o7 integer;
s1 varchar;
s2 varchar;
s3 varchar;
s4 varchar;
s5 varchar;
s6 varchar;
s7 varchar;
s8 varchar;
result1 int;
course_credits DEC(4,2);
credit_limit DEC(4,2);
credit_taken DEC(4,2);
tot DEC(4,2);
cg DEC(4,2);
req_cg DEC(4,2);
BEGIN
SELECT year into y from semesters where status=1;
SELECT semester into s from semesters where status=1;

o1=0;
s1 = 'call compute_slot_clash($1,$2,$3,$4,$5)';
execute s1 using student_id,c_id,y,s,o1 into o1;

o2=0;
s2 = 'call compute_prerequisite($1,$2,$3)';
execute s2 using student_id,c_id,o2 into o2;

course_credits=0;
s3 = 'call get_total_credits($1,$2)';
execute s3 using c_id,course_credits into course_credits;

credit_limit=0;
s4 = 'call credit_limit($1,$2)';
execute s4 using student_id,credit_limit into credit_limit;

credit_taken=0;
s5 = 'call credits_taken($1,$2)';
execute s5 using student_id,credit_taken into credit_taken;


tot=credit_taken+course_credits;

if tot<=credit_limit THEN
    o3=1;
else
    o3=0;
end if;

cg=0;
s6 = 'call compute_cgpa($1,$2)';
execute s6 using student_id,cg into cg;

Select cgpa_required into req_cg from offered_courses where course_id=c_id and year=y and semester=s;


if req_cg<=cg THEN
    o4=1;
else
    o4=0;
end if;



o6=0;
s7 = 'call allowed_batch_check($1,$2,$3,$4,$5)';
execute s7 using student_id,c_id,y,s,o6 into o6;

result:=o6;

o7=0;
s8 = 'call has_passed($1,$2,$3)';
execute s8 using student_id,c_id,o7 into o7;

if ((o1=1) and (o2=1) and (o3=0) and (o4=1) and (o6=1) and (o7=1)) THEN
    result=2;
elsif((o1=1) and (o2=1) and (o3=1) and (o4=1) and (o6=1) and (o7=1)) THEN
    result=1;
else
    result=0;
end if;

END 
$$
LANGUAGE 'plpgsql'
-- PROCEDURE: public.allowed_batch_check(character varying, character varying, integer, character varying, integer)

-- DROP PROCEDURE public.allowed_batch_check(character varying, character varying, integer, character varying, integer);

CREATE OR REPLACE PROCEDURE public.allowed_batch_check(
	student_id character varying,
	course_id character varying,
	y integer,
	sem character varying,
	INOUT flag integer)

AS $$
DECLARE

curr_batch int;
curr_dept varchar(10);
counter int;

BEGIN
SELECT batch_year into curr_batch from students where student_id=entry_no;
SELECT dept_name into curr_dept from students where student_id=entry_no;
SELECT COUNT(*) into counter from batches_allowed where sem=semester_course and curr_batch=batch_year and course_id=course_offered_id and y=year_course and curr_dept=batch_dept;

if(counter!=0) THEN
flag=0;
else
flag=1;
end if;
END
$$
LANGUAGE 'plpgsql'

-- PROCEDURE: public.compute_prerequisite(character varying, character varying, integer)

-- DROP PROCEDURE public.compute_prerequisite(character varying, character varying, integer);

CREATE OR REPLACE PROCEDURE public.compute_prerequisite(
	student_id character varying,
	c_id character varying,
	INOUT flag integer)

AS $$
DECLARE

preq_computed int;
preq_total int;

BEGIN

select count(*) into preq_total from prerequisite where original_course_id = c_id;
select count(*) into preq_computed from prerequisite as pc, course_registrations where pc.prerequisite_course_id = course_offered_id and pc.original_course_id =c_id and student_entry_no=student_id and grade>=4;

if(preq_total!=preq_computed) THEN
flag=0;
else
flag=1;
end if;
END
$$
LANGUAGE 'plpgsql'

-- PROCEDURE: public.credit_limit(character varying, numeric)

-- DROP PROCEDURE public.credit_limit(character varying, numeric);

CREATE OR REPLACE PROCEDURE public.credit_limit(
	student_id character varying,
	INOUT credit_lim numeric)

AS $$
DECLARE
current_id integer;
last_sem varchar(10);
secondlast_sem varchar(10);
last_year integer;
secondlast_year integer;
last_totalcredits DEC(4,2);
secondlast_totalcredits DEC(4,2);

BEGIN

SELECT sem_id into current_id from semesters where status=1;

if current_id>=3 then

SELECT year into secondlast_year from semesters where sem_id=current_id-2;
SELECT year into last_year from semesters where sem_id=current_id-1;

SELECT semester into secondlast_sem from semesters where sem_id=current_id-2;
SELECT semester into last_sem from semesters where sem_id=current_id-1;

credit_lim=0;

select sum(credits) into secondlast_totalcredits from course_registrations where student_entry_no = student_id and grade>4 and year_course=secondlast_year and semester_course = secondlast_sem; 
select sum(credits) into last_totalcredits from course_registrations where student_entry_no = student_id and grade>4 and year_course=last_year and semester_course = sem_year; 

credit_lim=credit_lim+@secondlast_totalcredits;
credit_lim=credit_lim+@last_totalcredits;
credit_lim=credit_lim/2;
credit_lim=credit_lim*1.25;

else
credit_lim=24;
END IF;

END
$$
LANGUAGE 'plpgsql'

-- PROCEDURE: public.credits_taken(character varying, numeric)

-- DROP PROCEDURE public.credits_taken(character varying, numeric);

CREATE OR REPLACE PROCEDURE public.credits_taken(
	student_id character varying,
	INOUT total_credits_taken numeric)

AS $$
DECLARE 
    y int; 
    s varchar(10);
    total DEC(4,2);
BEGIN
SELECT semester into s from semesters where status=1;
SELECT year into y from semesters where status=1;
select sum(credits) into total from course_registrations where student_entry_no=student_id and year_course = y and semester_course=s;

if total is not null then
total_credits_taken:=total;
else
total_credits_taken=0;
end if;
END
$$
LANGUAGE 'plpgsql'

-- PROCEDURE: public.compute_cgpa(character varying, numeric)

-- DROP PROCEDURE public.compute_cgpa(character varying, numeric);

CREATE OR REPLACE PROCEDURE public.compute_cgpa(
	student_id character varying,
	INOUT cgpa numeric)

AS $$
DECLARE

total_credits DEC(10,2);
total DEC(10,2);
BEGIN

select sum(credits) into total_credits from course_registrations where student_entry_no = student_id and grade>=4;
select sum(grade*credits) into total from course_registrations where student_entry_no = student_id and grade>=4;
cgpa=round(total/total_credits,2);
END
$$
LANGUAGE 'plpgsql'

-- PROCEDURE: public.get_total_credits(character varying, numeric)

-- DROP PROCEDURE public.get_total_credits(character varying, numeric);

CREATE OR REPLACE PROCEDURE public.get_total_credits(
	course_id character varying,
	INOUT credits numeric)

AS $$
DECLARE

ll DEC(4,2);
tt DEC(4,2);
pp DEC(4,2);

BEGIN

select l INTO ll from courses where courses.id=course_id;
select t INTO tt from courses where courses.id=course_id;
select p INTO pp from courses where courses.id=course_id;

credits:=0.5*pp;
credits:=credits+ll;
credits:=credits+tt;
END
$$
LANGUAGE 'plpgsql'
-- PROCEDURE: public.has_passed(character varying, character varying, integer)

-- DROP PROCEDURE public.has_passed(character varying, character varying, integer);

CREATE OR REPLACE PROCEDURE public.has_passed(
	student_id character varying,
	course_id character varying,
	INOUT result integer)

AS $$
DECLARE

passed int;
BEGIN
select count(*) into passed from course_registrations where course_offered_id=course_id and student_entry_no=student_id and grade>=4;

if passed!=0 THEN
result=0;
else
result=1;
end if;
END
$$
LANGUAGE 'plpgsql'

-- PROCEDURE: public.compute_slot_clash(character varying, character varying, integer, character varying, integer)

-- DROP PROCEDURE public.compute_slot_clash(character varying, character varying, integer, character varying, integer);

CREATE OR REPLACE PROCEDURE public.compute_slot_clash(
	student_id character varying,
	c_id character varying,
	y integer,
	s character varying,
	INOUT result integer)

AS $$
DECLARE
total_clash int;
tsi varchar;
BEGIN
Select time_slot_id into tsi from offered_courses where c_id=course_id and y=year and s=semester;
Select count(*) into total_clash from course_registrations,offered_courses where student_entry_no=student_id and course_offered_id=course_id and year_course=year and semester_course=semester and time_slot_id=tsi and year=y and semester=s;
if total_clash=0 then
result:=1;
else
result:=0;
end if;
END
$$
LANGUAGE 'plpgsql'
