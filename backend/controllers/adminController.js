// controllers/adminController.js
const User = require("../models/User");
const StudentProfile = require("../models/StudentProfile");
const TeacherProfile = require("../models/TeacherProfile");
const TuitionPost = require("../models/TuitionPost");
const TuitionApplication = require("../models/TuitionApplication");
const DemoSession = require("../models/DemoSession");
const Notification = require("../models/Notification");

// --------------------------------------------------
// GET DASHBOARD STATS
// --------------------------------------------------
const getAdminStats = async (req, res) => {
  try {
    const stats = {
      totalUsers: await User.countDocuments(),
      students: await User.countDocuments({ role: "student" }),
      teachers: await User.countDocuments({ role: "teacher" }),
      activeTuitions: await TuitionPost.countDocuments({ status: "approved" }),
      pendingTuitions: await TuitionPost.countDocuments({ status: "pending" }),
      demoRequests: await DemoSession.countDocuments({ status: "pending" })
    };

    res.json({ stats });
  } catch (err) {
    console.error("getAdminStats error:", err);
    res.status(500).json({ message: "Server error" });
  }
};

// --------------------------------------------------
// GET ALL USERS
// --------------------------------------------------
const getAllUsers = async (req, res) => {
  try {
    const users = await User.find().select("-password");
    res.json({ users });
  } catch (err) {
    console.error("getAllUsers error:", err);
    res.status(500).json({ message: "Server error" });
  }
};

// --------------------------------------------------
// SUSPEND / UNSUSPEND USER
// --------------------------------------------------
const toggleSuspendUser = async (req, res) => {
  try {
    const user = await User.findById(req.params.userId);
    if (!user) return res.status(404).json({ message: "User not found" });

    user.isSuspended = !user.isSuspended;
    await user.save();

    res.json({
      message: `User ${user.isSuspended ? "suspended" : "unsuspended"}`,
      user
    });
  } catch (err) {
    console.error("toggleSuspendUser error:", err);
    res.status(500).json({ message: "Server error" });
  }
};

// --------------------------------------------------
// APPROVE / REJECT TEACHER PROFILE
// --------------------------------------------------
const approveTeacherProfile = async (req, res) => {
  try {
    const teacher = await TeacherProfile.findOne({ userId: req.params.teacherId });
    if (!teacher) return res.status(404).json({ message: "Profile not found" });

    teacher.isVerified = true;
    await teacher.save();

    res.json({ message: "Teacher profile approved", teacher });
  } catch (err) {
    console.error("approveTeacherProfile error:", err);
    res.status(500).json({ message: "Server error" });
  }
};

// --------------------------------------------------
// APPROVE / REJECT TUITION
// --------------------------------------------------
const approveTuition = async (req, res) => {
  try {
    const tuition = await TuitionPost.findById(req.params.tuitionId);
    if (!tuition) return res.status(404).json({ message: "Tuition not found" });

    tuition.status = "approved";
    await tuition.save();

    res.json({ message: "Tuition approved", tuition });
  } catch (err) {
    console.error("approveTuition error:", err);
    res.status(500).json({ message: "Server error" });
  }
};

// --------------------------------------------------
// APPROVE / REJECT APPLICATION
// --------------------------------------------------
const approveApplication = async (req, res) => {
  try {
    const application = await TuitionApplication.findById(req.params.appId);
    if (!application)
      return res.status(404).json({ message: "Application not found" });

    application.status = "approved";
    await application.save();

    res.json({ message: "Application approved", application });
  } catch (err) {
    console.error("approveApplication error:", err);
    res.status(500).json({ message: "Server error" });
  }
};

// --------------------------------------------------
// GET ALL DEMO SESSIONS
// --------------------------------------------------
const getAllDemoSessions = async (req, res) => {
  try {
    const sessions = await DemoSession.find()
      .populate("studentId", "name email")
      .populate("teacherId", "name email");

    res.json({ sessions });
  } catch (err) {
    console.error("getAllDemoSessions error:", err);
    res.status(500).json({ message: "Server error" });
  }
};

// --------------------------------------------------
// UPDATE DEMO STATUS
// --------------------------------------------------
const updateDemoStatus = async (req, res) => {
  try {
    const { status } = req.body;

    const session = await DemoSession.findByIdAndUpdate(
      req.params.sessionId,
      { status },
      { new: true }
    );

    if (!session) return res.status(404).json({ message: "Not found" });

    res.json({ message: "Status updated", session });
  } catch (err) {
    console.error("updateDemoStatus error:", err);
    res.status(500).json({ message: "Server error" });
  }
};

module.exports = {
  getAdminStats,
  getAllUsers,
  toggleSuspendUser,
  approveTeacherProfile,
  approveTuition,
  approveApplication,
  getAllDemoSessions,
  updateDemoStatus
};
