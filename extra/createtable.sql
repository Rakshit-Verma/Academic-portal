CREATE TABLE public.batch
(
    year integer NOT NULL,
    advisor_id character varying(10) COLLATE pg_catalog."default" NOT NULL,
    department_name character varying(20) COLLATE pg_catalog."default" NOT NULL,
    CONSTRAINT batch_pkey PRIMARY KEY (year, department_name),
    CONSTRAINT batch_advisor_id_fkey FOREIGN KEY (advisor_id)
        REFERENCES public.faculty (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT batch_department_name_fkey FOREIGN KEY (department_name)
        REFERENCES public.department (name) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
)
-- Table: public.batches_allowed

-- DROP TABLE public.batches_allowed;

CREATE TABLE public.batches_allowed
(
    course_offered_id character varying(10) COLLATE pg_catalog."default" NOT NULL,
    year_course integer NOT NULL,
    semester_course character varying(10) COLLATE pg_catalog."default" NOT NULL,
    batch_year integer NOT NULL,
    batch_dept character varying(20) COLLATE pg_catalog."default" NOT NULL,
    CONSTRAINT batches_allowed_pkey PRIMARY KEY (course_offered_id, year_course, semester_course, batch_year, batch_dept),
    CONSTRAINT batches_allowed_batch_dept_fkey FOREIGN KEY (batch_dept, batch_year)
        REFERENCES public.batch (department_name, year) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT batches_allowed_course_offered_id_fkey FOREIGN KEY (semester_course, course_offered_id, year_course)
        REFERENCES public.offered_courses (semester, course_id, year) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
)
WITH (
    OIDS = FALSE
)
TABLESPACE pg_default;

ALTER TABLE public.batches_allowed
    OWNER to postgres;
-- Table: public.course_registrations

-- DROP TABLE public.course_registrations;

CREATE TABLE public.course_registrations
(
    student_entry_no character varying(10) COLLATE pg_catalog."default" NOT NULL,
    course_offered_id character varying(10) COLLATE pg_catalog."default" NOT NULL,
    year_course integer NOT NULL,
    semester_course character varying(10) COLLATE pg_catalog."default" NOT NULL,
    grade integer NOT NULL,
    credits numeric(4,3),
    CONSTRAINT course_registrations_pkey PRIMARY KEY (student_entry_no, course_offered_id, year_course, semester_course),
    CONSTRAINT course_registrations_course_offered_id_fkey FOREIGN KEY (semester_course, course_offered_id, year_course)
        REFERENCES public.offered_courses (semester, course_id, year) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
)
WITH (
    OIDS = FALSE
)
TABLESPACE pg_default;

ALTER TABLE public.course_registrations
    OWNER to postgres;

-- DROP TABLE public.courses;

CREATE TABLE public.courses
(
    id character varying(10) COLLATE pg_catalog."default" NOT NULL,
    name character varying(50) COLLATE pg_catalog."default" NOT NULL,
    l integer NOT NULL,
    t integer NOT NULL,
    p integer NOT NULL,
    CONSTRAINT courses_pkey PRIMARY KEY (id)
)
WITH (
    OIDS = FALSE
)
TABLESPACE pg_default;

ALTER TABLE public.courses
    OWNER to postgres;
-- Table: public.department

-- DROP TABLE public.department;

CREATE TABLE public.department
(
    name character varying(20) COLLATE pg_catalog."default" NOT NULL,
    CONSTRAINT department_pkey PRIMARY KEY (name)
)
WITH (
    OIDS = FALSE
)
TABLESPACE pg_default;

ALTER TABLE public.department
    OWNER to postgres;
[11:28 PM, 11/19/2019] K Rohit: -- Table: public.faculty

-- DROP TABLE public.faculty;

CREATE TABLE public.faculty
(
    id character varying(10) COLLATE pg_catalog."default" NOT NULL,
    name character varying(50) COLLATE pg_catalog."default" NOT NULL,
    department_name character varying(20) COLLATE pg_catalog."default",
    CONSTRAINT faculty_pkey PRIMARY KEY (id),
    CONSTRAINT faculty_department_name_fkey FOREIGN KEY (department_name)
        REFERENCES public.department (name) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
)
WITH (
    OIDS = FALSE
)
TABLESPACE pg_default;

ALTER TABLE public.faculty
    OWNER to postgres;
-- Table: public.offered_courses

-- DROP TABLE public.offered_courses;

CREATE TABLE public.offered_courses
(
    course_id character varying(10) COLLATE pg_catalog."default" NOT NULL,
    year integer NOT NULL,
    semester character varying(10) COLLATE pg_catalog."default" NOT NULL,
    cgpa_required real,
    course_instructor_id character varying(10) COLLATE pg_catalog."default",
    time_slot_id character(10) COLLATE pg_catalog."default" NOT NULL,
    CONSTRAINT offered_courses_pkey PRIMARY KEY (course_id, year, semester),
    CONSTRAINT offered_courses_course_id_fkey FOREIGN KEY (course_id)
        REFERENCES public.courses (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT offered_courses_course_instructor_id_fkey FOREIGN KEY (course_instructor_id)
        REFERENCES public.faculty (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
)
WITH (
    OIDS = FALSE
)
TABLESPACE pg_default;

ALTER TABLE public.offered_courses
    OWNER to postgres;
-- Table: public.prerequisite

-- DROP TABLE public.prerequisite;

CREATE TABLE public.prerequisite
(
    original_course_id character varying(10) COLLATE pg_catalog."default" NOT NULL,
    prerequisite_course_id character varying(10) COLLATE pg_catalog."default" NOT NULL,
    CONSTRAINT prerequisite_pkey PRIMARY KEY (original_course_id, prerequisite_course_id)
)
WITH (
    OIDS = FALSE
)
TABLESPACE pg_default;

ALTER TABLE public.prerequisite
    OWNER to postgres;
-- Table: public.semesters

-- DROP TABLE public.semesters;

CREATE TABLE public.semesters
(
    year integer NOT NULL,
    semester character varying(10) COLLATE pg_catalog."default" NOT NULL,
    status smallint,
    sem_id integer NOT NULL DEFAULT nextval('semesters_sem_id_seq'::regclass),
    CONSTRAINT semesters_pkey PRIMARY KEY (sem_id)
)
WITH (
    OIDS = FALSE
)
TABLESPACE pg_default;

ALTER TABLE public.semesters
    OWNER to postgres;
-- Table: public.students

-- DROP TABLE public.students;

CREATE TABLE public.students
(
    entry_no character varying(10) COLLATE pg_catalog."default" NOT NULL,
    name character varying(50) COLLATE pg_catalog."default" NOT NULL,
    batch_year integer NOT NULL,
    dept_name character varying(20) COLLATE pg_catalog."default" NOT NULL,
    CONSTRAINT students_pkey PRIMARY KEY (entry_no),
    CONSTRAINT students_batch_year_fkey FOREIGN KEY (batch_year, dept_name)
        REFERENCES public.batch (year, department_name) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
)
WITH (
    OIDS = FALSE
)
TABLESPACE pg_default;

ALTER TABLE public.students
    OWNER to postgres;