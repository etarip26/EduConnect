const TeacherProfile = require("../models/TeacherProfile");
const StudentProfile = require("../models/StudentProfile");

// Only allow verified teachers (admins bypass)
const requireVerifiedTeacher = async (req, res, next) => {
  try {
    if (req.user.role === "admin") return next();

    if (req.user.role !== "teacher") {
      return res.status(403).json({ message: "Teacher role required" });
    }

    const profile = await TeacherProfile.findOne({ userId: req.user._id });
    if (!profile || !profile.isVerified) {
      return res
        .status(403)
        .json({ message: "Teacher account is not verified by admin" });
    }

    next();
  } catch (err) {
    console.error("requireVerifiedTeacher error:", err);
    res.status(500).json({ message: "Server error" });
  }
};

// Only allow verified students (admins bypass)
const requireVerifiedStudent = async (req, res, next) => {
  try {
    if (req.user.role === "admin") return next();

    if (req.user.role !== "student") {
      return res.status(403).json({ message: "Student role required" });
    }

    const profile = await StudentProfile.findOne({ userId: req.user._id });
    if (!profile || !profile.isVerified) {
      return res
        .status(403)
        .json({ message: "Student account is not verified by admin" });
    }

    next();
  } catch (err) {
    console.error("requireVerifiedStudent error:", err);
    res.status(500).json({ message: "Server error" });
  }
};

module.exports = {
  requireVerifiedTeacher,
  requireVerifiedStudent
};
