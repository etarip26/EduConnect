// controllers/adminController.js
const User = require("../models/User");
const StudentProfile = require("../models/StudentProfile");
const TeacherProfile = require("../models/TeacherProfile");
const TuitionPost = require("../models/TuitionPost");
const TuitionApplication = require("../models/TuitionApplication");
const DemoSession = require("../models/DemoSession");
const Notification = require("../models/Notification");
const bcrypt = require("bcrypt");
const logger = require("../config/logger");

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

// --------------------------------------------------
// ENHANCED USER MANAGEMENT METHODS
// --------------------------------------------------

/**
 * List all users with filtering and pagination
 */
const listUsers = async (req, res) => {
  try {
    const { role, status, page = 1, limit = 20, search } = req.query;
    const skip = (page - 1) * limit;

    let filter = {};
    if (role) filter.role = role;
    if (status === "suspended") filter.isSuspended = true;
    if (status === "active") filter.isSuspended = false;
    if (search) {
      filter.$or = [
        { name: { $regex: search, $options: "i" } },
        { email: { $regex: search, $options: "i" } }
      ];
    }

    const users = await User.find(filter)
      .select("-password")
      .skip(skip)
      .limit(parseInt(limit))
      .sort({ createdAt: -1 });

    const total = await User.countDocuments(filter);

    res.status(200).json({
      success: true,
      data: users,
      pagination: {
        total,
        page: parseInt(page),
        limit: parseInt(limit),
        pages: Math.ceil(total / limit)
      }
    });
  } catch (error) {
    logger.error("Error fetching users:", error.message);
    res.status(500).json({ success: false, message: "Failed to fetch users" });
  }
};

/**
 * Get user details by ID
 */
const getUserDetails = async (req, res) => {
  try {
    const { userId } = req.params;
    const user = await User.findById(userId).select("-password");
    if (!user) {
      return res
        .status(404)
        .json({ success: false, message: "User not found" });
    }
    res.status(200).json({ success: true, data: user });
  } catch (error) {
    logger.error("Error fetching user details:", error.message);
    res
      .status(500)
      .json({ success: false, message: "Failed to fetch user details" });
  }
};

/**
 * Create new admin account
 */
const createAdmin = async (req, res) => {
  try {
    const { name, email, phone, tempPassword } = req.body;

    if (!email || !tempPassword) {
      return res
        .status(400)
        .json({
          success: false,
          message: "Email and temporary password required"
        });
    }

    const existingUser = await User.findOne({ email });
    if (existingUser) {
      return res
        .status(409)
        .json({ success: false, message: "User with this email already exists" });
    }

    const hashedPassword = await bcrypt.hash(tempPassword, 10);
    const newAdmin = new User({
      name: name || email.split("@")[0],
      email: email.toLowerCase(),
      phone: phone || "",
      password: hashedPassword,
      role: "admin",
      isEmailVerified: true
    });

    await newAdmin.save();
    logger.info(`New admin created: ${email} by admin: ${req.user.email}`);

    res.status(201).json({
      success: true,
      message: "Admin account created successfully",
      data: {
        id: newAdmin._id,
        name: newAdmin.name,
        email: newAdmin.email,
        role: newAdmin.role
      }
    });
  } catch (error) {
    logger.error("Error creating admin:", error.message);
    res
      .status(500)
      .json({ success: false, message: "Failed to create admin account" });
  }
};

/**
 * Update user role
 */
const updateUserRole = async (req, res) => {
  try {
    const { userId } = req.params;
    const { role } = req.body;

    if (!["student", "teacher", "admin"].includes(role)) {
      return res
        .status(400)
        .json({ success: false, message: "Invalid role provided" });
    }

    const user = await User.findByIdAndUpdate(userId, { role }, { new: true });
    if (!user) {
      return res
        .status(404)
        .json({ success: false, message: "User not found" });
    }

    logger.info(
      `User role updated: ${user.email} → ${role} by admin: ${req.user.email}`
    );

    res.status(200).json({
      success: true,
      message: "User role updated",
      data: user
    });
  } catch (error) {
    logger.error("Error updating user role:", error.message);
    res
      .status(500)
      .json({ success: false, message: "Failed to update user role" });
  }
};

/**
 * Suspend user account
 */
const suspendUser = async (req, res) => {
  try {
    const { userId } = req.params;
    const { reason } = req.body;

    const user = await User.findByIdAndUpdate(
      userId,
      { isSuspended: true },
      { new: true }
    );

    if (!user) {
      return res
        .status(404)
        .json({ success: false, message: "User not found" });
    }

    logger.warn(
      `User suspended: ${user.email} (Reason: ${reason}) by admin: ${req.user.email}`
    );

    res.status(200).json({
      success: true,
      message: "User suspended successfully",
      data: user
    });
  } catch (error) {
    logger.error("Error suspending user:", error.message);
    res
      .status(500)
      .json({ success: false, message: "Failed to suspend user" });
  }
};

/**
 * Activate suspended user
 */
const activateUser = async (req, res) => {
  try {
    const { userId } = req.params;

    const user = await User.findByIdAndUpdate(
      userId,
      { isSuspended: false },
      { new: true }
    );

    if (!user) {
      return res
        .status(404)
        .json({ success: false, message: "User not found" });
    }

    logger.info(`User activated: ${user.email} by admin: ${req.user.email}`);

    res.status(200).json({
      success: true,
      message: "User activated successfully",
      data: user
    });
  } catch (error) {
    logger.error("Error activating user:", error.message);
    res
      .status(500)
      .json({ success: false, message: "Failed to activate user" });
  }
};

/**
 * Get comprehensive dashboard statistics
 */
const getDashboardStats = async (req, res) => {
  try {
    const totalUsers = await User.countDocuments();
    const students = await User.countDocuments({ role: "student" });
    const teachers = await User.countDocuments({ role: "teacher" });
    const admins = await User.countDocuments({ role: "admin" });
    const suspendedUsers = await User.countDocuments({ isSuspended: true });
    const verifiedUsers = await User.countDocuments({ isEmailVerified: true });

    // Get tuition stats
    const activeTuitions = await TuitionPost.countDocuments({ status: "approved" });
    const pendingTuitions = await TuitionPost.countDocuments({ status: "pending" });
    const pendingDemos = await DemoSession.countDocuments({ status: "pending" });

    res.status(200).json({
      success: true,
      data: {
        users: {
          totalUsers,
          students,
          teachers,
          admins,
          suspendedUsers,
          verifiedUsers,
          activeUsers: totalUsers - suspendedUsers
        },
        tuitions: {
          activeTuitions,
          pendingTuitions
        },
        demos: {
          pendingDemos
        }
      }
    });
  } catch (error) {
    logger.error("Error fetching dashboard stats:", error.message);
    res
      .status(500)
      .json({ success: false, message: "Failed to fetch statistics" });
  }
};

/**
 * Delete user account (irreversible)
 */
const deleteUser = async (req, res) => {
  try {
    const { userId } = req.params;

    const user = await User.findById(userId);
    if (user && user.role === "admin" && user._id.toString() !== req.user.id) {
      return res
        .status(403)
        .json({ success: false, message: "Cannot delete other admin accounts" });
    }

    await User.findByIdAndDelete(userId);
    logger.warn(`User deleted: ${user?.email} by admin: ${req.user.email}`);

    res.status(200).json({
      success: true,
      message: "User deleted successfully"
    });
  } catch (error) {
    logger.error("Error deleting user:", error.message);
    res
      .status(500)
      .json({ success: false, message: "Failed to delete user" });
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
  updateDemoStatus,
  listUsers,
  getUserDetails,
  createAdmin,
  updateUserRole,
  suspendUser,
  activateUser,
  getDashboardStats,
  deleteUser
};
