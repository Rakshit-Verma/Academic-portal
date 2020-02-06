const express = require('express');
const router = express.Router();
const pg = require('pg');
// const strcmp = require('strcmp')

const pool = new pg.Pool({
  user: "postgres",
  host: "localhost",
  database: "portal",
  password: "1234",
  port: 5432
});

pool.connect();

router.get('/', async (req, res) => {
  res.render('welcome')
});
router.get('/student', async (req, res) => {
  res.render('student')
});
router.get('/faculty', async (req, res) => {
  res.render('faculty')
});
router.get('/gradeentry', async (req, res) => {
  res.render('gradeentry');
});

router.get('/viewticket', async (req, res) => {

  var faculty_advisor = req.session.facultyadvisorid;
  user = await pool.query("select * from ticket where advisor_id=$1", [faculty_advisor]);
  res.render('viewticket', { datas: user.rows });

});

router.get('/viewticket2', async (req, res) => {

  q = req.query;
  console.log(q.course_id);
  console.log(q.student_id);
  if (q.status == 0) {
    offeredcourse = await pool.query("select * from offered_courses where course_id=$1", [q.course_id]);
    var course_year = offeredcourse.rows[0].year;
    var course_semester = offeredcourse.rows[0].semester;

    credits = await pool.query("call get_total_credits($1,$2)", [q.course_id, 0]);
    course_credits = credits.rows[0].credits;

    await pool.query("update ticket set status=$1 where student_id=$2 and course_offered_id=$3", [1, q.student_id, q.course_id]);
    await pool.query("insert into course_registrations(student_entry_no ,course_offered_id ,year_course ,semester_course,grade,credits) values ($1,$2,$3,$4,$5,$6)", [q.student_id, q.course_id, course_year, course_semester, 0, course_credits]);

    var faculty_advisor = req.session.facultyadvisorid;
    user = await pool.query("select * from ticket where advisor_id=$1", [faculty_advisor]);
    res.render('viewticket', { datas: user.rows });

  }
  else {
    return res.status(400).send('ticket already approved');

  }
});




router.post('/gradeentry', async (req, res) => {
  var student_id = req.body.studentid;
  var course_id = req.body.courseid;
  var grade = parseInt(req.body.grade, 10);
  // console.log('1111111');
  // console.log('1111112');
  user = await pool.query("select * from offered_courses where course_id=$1 and course_instructor_id=$2", [course_id, req.session.facultyid]);
  // var year = user.rows[0].year;
  // var semester = user.rows[0].semester;
  var credits;
  credits1 = await pool.query("call get_total_credits($1,$2)", [course_id, credits]);
  credits = credits1.rows[0].credits;
  console.log('1111113');
  await pool.query("update course_registrations set grade = $1 where student_entry_no = $2 and course_offered_id = $3", [grade, student_id, course_id])
  return res.status(400).send("success")
  //console.log(credits);
  //var s = "insert into transcript_" + student_id + "(course_id,course_year,course_sem,grade,credits) values($1,$2,$3,$4,$5)";
  //await pool.query(s,[course_id,year,semester,grade,credits]);

});
router.get('/myofferedcourses', async (req, res) => {
  console.log('ttttttttttttttt');
  user = await pool.query("select * from offered_courses where course_instructor_id=$1", [req.session.facultyid]);
  console.log(user);
  res.render('myofferedcourses', { datas: user.rows });
});



router.post('/', async (req, res) => {
  var password = req.body.password;
  if (req.body.type == "student") {
    user = await pool.query("select * from students where entry_no = $1", [req.body.entrynumber]);
    if (user.rowCount != 0) {
      if (password == "1234") {
        req.session.entrynumber = req.body.entrynumber;
        req.session.type = req.body.type;
        res.render('student');
      }
      else {
        return res.status(400).send('Incorrect password');
      }
    }
    else {
      return res.status(400).send('user not in database');
    }
  }
  else if (req.body.type == "faculty") {
    console.log('1111111');
    user = await pool.query("select * from faculty where id = $1", [req.body.entrynumber])
    if (user.rowCount != 0) {

      if (password == "1234") {
        req.session.facultyid = req.body.entrynumber;
        req.session.type = req.body.type;
        res.render('faculty');
      }
      else {
        return res.status(400).send('incorrect password');
      }
    }
    else {
      return res.status(400).send('no faculty with this id');
    }
  }
  else {
    user = await pool.query("select * from batch where advisor_id = $1", [req.body.entrynumber])
    if (user.rowCount != 0) {

      if (password == "1234") {
        req.session.facultyadvisorid = req.body.entrynumber;
        req.session.type = req.body.type;
        res.render('facultyadvisor');
      }
      else {
        return res.status(400).send('incorrect password');
      }
    }
    else {
      return res.status(400).send('no faculty with this id');
    }

  }
});

router.get('/addcourses', async (req, res) => {
  res.render('addcourses');
});

router.post('/addcourses', async (req, res) => {
  var course_id = req.body.course_id;
  //var course_name = req.body.course_name;
  // var course_year = req.body.course_year;
  //const year = parseInt(course_year, 10);

  //var course_semester = req.body.course_semester;
  var course_cgpa = req.body.course_cgpa;
  const cgpa = parseFloat(course_cgpa, 10);
  //console.log(cgpa);

  var course_instructor = req.session.facultyid;
  var course_timeslot = req.body.time_slot;
  var course_prerequisite = req.body.prerequisite;

  //var course_l = req.body.l;
  //const l = parseInt(course_l, 10);

  // var course_t = req.body.t;
  //const t = parseInt(course_l, 10);

  //var course_p = req.body.p;
  //const p = parseInt(course_p, 10);
  //console.log(p);
  //console.log(l);
  //var course_batch_year_string = req.body.batch_year;
  // const course_batch_year = parseInt(course_batch_year_string, 10);

  //var course_batch_dept = req.body.batch_dept;




  user = await pool.query("select * from courses where id=$1", [course_id]);

  if (user.rowCount != 0) {
    await pool.query("insert into offered_courses(course_id,year,semester,cgpa_required,course_instructor_id,time_slot_id) values($1,$2,$3,$4,$5,$6)", [course_id, 2017, 'fall', cgpa, course_instructor, course_timeslot]);
    await pool.query("insert into prerequisite(original_course_id,prerequisite_course_id) values($1,$2)", [course_id, course_prerequisite]);
    return res.status(400).send('added');
  }
  else {
    return res.status(400).send('cannot add');
  }
});

router.get('/courses', async (req, res) => {
  user = await pool.query("SELECT * from courses");
  //console.log(user);
  res.render('courses', { datas: user.rows });
});

router.get('/prerequisites', async (req, res) => {
  user = await pool.query("select * from prerequisite");
  res.render('prerequisites', { datas: user.rows });
});

router.get('/mycourses', async (req, res) => {

  // var s = "select * from transcript_" + req.session.entrynumber;
  user = await pool.query("select * from course_registrations where student_entry_no = $1", [req.session.entrynumber]);
  res.render('mycourses', { datas: user.rows });
});
router.get('/registrationportal', async (req, res) => {
  res.render('registrationportal');
});

router.post('/registrationportal', async (req, res) => {
  console.log('enter register')
  student_id = req.session.entrynumber;
  course_id = req.body.courseid;
  var result = 0;
  var course_credits = 0;
  var dept;
  var year;
  var semester;
  student = await pool.query("select * from students where entry_no=$1", [student_id]);
  console.log(student);

  dept = student.rows[0].dept_name;
  year = student.rows[0].batch_year;


  offeredcourse = await pool.query("select * from offered_courses where course_id=$1", [course_id]);

  credits = await pool.query("call get_total_credits($1,$2)", [course_id, 0]);
  course_credits = credits.rows[0].credits;

  cantake = await pool.query("call can_take($1,$2,$3)", [req.session.entrynumber, course_id, result]);

  var course_year = offeredcourse.rows[0].year;
  var instructor_id = offeredcourse.rows[0].course_instructor_id;
  var course_semester = offeredcourse.rows[0].semester;
  var grade = 0;

  advisor = await pool.query("select * from batch where year=$1 and department_name=$2", [year, dept]);
  var faculty_advisor = advisor.rows[0].advisor_id;
  if (cantake.rows[0].result == 1) {
    console.log('enter');
    await pool.query("insert into course_registrations(student_entry_no ,course_offered_id ,year_course ,semester_course,grade,credits) values ($1,$2,$3,$4,$5,$6)", [req.session.entrynumber, course_id, course_year, course_semester, grade, course_credits]);
    /// var s = "insert into transcript_" + student_id + "(course_id,course_year,course_sem,grade,credits) values($1,$2,$3,$4,$5)";
    //console.log(s);
    //await pool.query(s, [course_id, course_year, course_semester, 0, course_credits]);
    return res.status(400).send('success');
  }
  else {
    if (cantake.rows[0].result == 2) {
      var s = student_id + course_id;
      await pool.query("insert into ticket(ticket_id,student_id,instructor_id,advisor_id,status,current_holder,course_offered_id,year_course,semester_course) values($1,$2,$3,$4,$5,$6,$7,$8,$9)", [s, student_id, instructor_id, faculty_advisor, 0, faculty_advisor, course_id, course_year, course_semester])
      return res.status(400).send('ticket generated');
    }
    else {
      return res.status(400).send('you cannot add this course');
    }
  }

});




module.exports = router;
