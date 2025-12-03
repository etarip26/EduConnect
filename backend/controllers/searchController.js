// controllers/searchController.js
const TeacherProfile = require("../models/TeacherProfile");
const StudentProfile = require("../models/StudentProfile");
const TuitionPost = require("../models/TuitionPost");

/* --------------------------------------------------
   STUDENT → SEARCH TEACHERS
-------------------------------------------------- */
const searchTeachers = async (req, res) => {
  try {
    const {
      subject,
      classLevel,
      minSalary,
      maxSalary,
      university,
      department,
      jobTitle,
      minRating,
      maxRating,
      maxDistance,
      lat,
      lng
    } = req.query;

    let query = {};

    // Subject filter
    if (subject) query.subjects = subject;

    // Class level filter
    if (classLevel) query.classLevels = classLevel;

    // Salary expectation filter
    if (minSalary || maxSalary) {
      query.$and = [];

      if (minSalary) {
        query.$and.push({ expectedSalaryMin: { $gte: Number(minSalary) } });
      }

      if (maxSalary) {
        query.$and.push({ expectedSalaryMax: { $lte: Number(maxSalary) } });
      }
    }

    // University filter
    if (university) query.university = university;

    // Department filter
    if (department) query.department = department;

    // Job title filter
    if (jobTitle) query.jobTitle = jobTitle;

    // Rating filter (minRating & maxRating)
    if (minRating) {
      query.ratingAverage = { ...query.ratingAverage, $gte: Number(minRating) };
    }

    if (maxRating) {
      query.ratingAverage = { ...query.ratingAverage, $lte: Number(maxRating) };
    }

    let teachers = [];

    // Distance filter only if coordinates provided
    if (maxDistance && lat && lng) {
      teachers = await TeacherProfile.find({
        ...query,
        location: {
          $near: {
            $geometry: {
              type: "Point",
              coordinates: [Number(lng), Number(lat)]
            },
            $maxDistance: Number(maxDistance) * 1000 // km → meters
          }
        }
      });
    } else {
      teachers = await TeacherProfile.find(query);
    }

    res.json({ teachers });
  } catch (err) {
    console.error("searchTeachers error:", err);
    res.status(500).json({ message: "Server error" });
  }
};

/* --------------------------------------------------
   TEACHER → SEARCH STUDENTS (based on tuition posts)
-------------------------------------------------- */
const searchStudents = async (req, res) => {
  try {
    const {
      subject,
      classLevel,
      minSalary,
      maxSalary,
      mode,
      maxDistance,
      lat,
      lng
    } = req.query;

    let query = { status: "approved" }; // Only approved tuition posts

    if (subject) query.subject = subject;
    if (classLevel) query.classLevel = classLevel;
    if (mode) query.mode = mode;

    // Salary filter
    if (minSalary || maxSalary) {
      query.$and = [];

      if (minSalary) {
        query.$and.push({ salaryMin: { $gte: Number(minSalary) } });
      }

      if (maxSalary) {
        query.$and.push({ salaryMax: { $lte: Number(maxSalary) } });
      }
    }

    let tuitions = [];

    if (maxDistance && lat && lng) {
      tuitions = await TuitionPost.find({
        ...query,
        location: {
          $near: {
            $geometry: {
              type: "Point",
              coordinates: [Number(lng), Number(lat)]
            },
            $maxDistance: Number(maxDistance) * 1000
          }
        }
      });
    } else {
      tuitions = await TuitionPost.find(query);
    }

    res.json({ tuitions });
  } catch (err) {
    console.error("searchStudents error:", err);
    res.status(500).json({ message: "Server error" });
  }
};

module.exports = {
  searchTeachers,
  searchStudents
};
