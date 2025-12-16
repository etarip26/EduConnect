// controllers/adminController.js
const User = require("../models/User");
const StudentProfile = require("../models/StudentProfile");
const TeacherProfile = require("../models/TeacherProfile");
const TuitionPost = require("../models/TuitionPost");
const TuitionApplication = require("../models/TuitionApplication");
const Match = require("../models/Match");
const DemoSession = require("../models/DemoSession");
const Notification = require("../models/Notification");
const Notice = require("../models/Notice");
const TeacherNID = require("../models/TeacherNID");
const ParentControl = require("../models/ParentControl");
const bcrypt = require("bcryptjs");
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
      pendingTuitions: await TuitionPost.countDocuments({ status: { $in: ["pending", "pending_admin_review"] } }),
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

    // Create notification for student
    await Notification.create({
      userId: tuition.studentId,
      title: "Tuition Post Approved",
      message: `Your tuition post "${tuition.title}" has been approved and is now visible to teachers.`,
      type: "tuition_approved",
      relatedId: tuition._id,
      isRead: false
    });

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
// GET PENDING TUITION APPLICATIONS
// --------------------------------------------------
const getPendingApplications = async (req, res) => {
  try {
    const applications = await TuitionApplication.find({ status: "pending_admin_review" })
      .populate("postId", "title classLevel subjects salaryMin salaryMax location")
      .populate("teacherId", "name email")
      .populate({
        path: "teacherId",
        select: "name email",
        model: "User"
      })
      .sort({ createdAt: -1 });

    // Enrich with teacher profile data (CV, NID, etc.)
    const enrichedApps = await Promise.all(
      applications.map(async (app) => {
        const TeacherProfile = require("../models/TeacherProfile");
        const profile = await TeacherProfile.findOne({ userId: app.teacherId._id });
        return {
          ...app.toObject(),
          teacherProfile: profile || {}
        };
      })
    );

    res.json({ applications: enrichedApps });
  } catch (err) {
    console.error("getPendingApplications error:", err);
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
    const pendingTuitions = await TuitionPost.countDocuments({ status: { $in: ["pending", "pending_admin_review"] } });
    const pendingApplications = await TuitionApplication.countDocuments({ status: "pending_admin_review" });
    
    // Get match stats
    const activeMatches = await Match.countDocuments({ status: "active" });
    
    // Get demo stats
    const pendingDemos = await DemoSession.countDocuments({ status: "pending" });
    const approvedDemos = await DemoSession.countDocuments({ status: "approved" });

    // Return in the format the test expects
    res.status(200).json({
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
      applications: {
        pendingApplications
      },
      matches: {
        activeMatches
      },
      demos: {
        pendingDemos,
        approvedDemos
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

// --------------------------------------------------
// PROFILE APPROVAL SYSTEM
// --------------------------------------------------

/**
 * Get pending profiles for approval
 */
const getPendingProfiles = async (req, res) => {
  try {
    const role = req.query.role || "teacher"; // teacher or student

    const profiles = await User.find({
      role: role,
      isProfileApproved: false,
      isBanned: false
    }).select("-password");

    res.status(200).json({
      success: true,
      data: profiles,
      total: profiles.length
    });
  } catch (error) {
    logger.error("Error fetching pending profiles:", error.message);
    res
      .status(500)
      .json({ success: false, message: "Failed to fetch pending profiles" });
  }
};

/**
 * Approve user profile
 */
const approveUserProfile = async (req, res) => {
  try {
    const { userId } = req.params;

    const user = await User.findByIdAndUpdate(
      userId,
      {
        isProfileApproved: true,
        approvedBy: req.user.id,
        approvalDate: new Date()
      },
      { new: true }
    ).select("-password");

    if (!user) {
      return res
        .status(404)
        .json({ success: false, message: "User not found" });
    }

    logger.info(`Profile approved: ${user.email} by admin: ${req.user.email}`);

    res.status(200).json({
      success: true,
      message: "Profile approved successfully",
      data: user
    });
  } catch (error) {
    logger.error("Error approving profile:", error.message);
    res
      .status(500)
      .json({ success: false, message: "Failed to approve profile" });
  }
};

/**
 * Reject user profile
 */
const rejectUserProfile = async (req, res) => {
  try {
    const { userId } = req.params;
    const { reason } = req.body;

    const user = await User.findById(userId);
    if (!user) {
      return res
        .status(404)
        .json({ success: false, message: "User not found" });
    }

    // Keep isProfileApproved as false, store rejection reason
    user.approvalDate = new Date();
    user.approvedBy = req.user.id;
    await user.save();

    logger.info(
      `Profile rejected: ${user.email} (Reason: ${reason}) by admin: ${req.user.email}`
    );

    res.status(200).json({
      success: true,
      message: "Profile rejected",
      reason: reason
    });
  } catch (error) {
    logger.error("Error rejecting profile:", error.message);
    res
      .status(500)
      .json({ success: false, message: "Failed to reject profile" });
  }
};

// --------------------------------------------------
// TUITION POST APPROVAL SYSTEM
// --------------------------------------------------

/**
 * Get pending tuition posts
 */
const getPendingTuitionPosts = async (req, res) => {
  try {
    const posts = await TuitionPost.find({ status: { $in: ["pending", "pending_admin_review"] } })
      .populate("studentId", "name email phone")
      .sort({ createdAt: -1 });

    res.status(200).json({
      success: true,
      data: posts,
      total: posts.length
    });
  } catch (error) {
    logger.error("Error fetching pending posts:", error.message);
    res
      .status(500)
      .json({ success: false, message: "Failed to fetch pending posts" });
  }
};

/**
 * Approve tuition post
 */
const approveTuitionPost = async (req, res) => {
  try {
    const { postId } = req.params;

    const post = await TuitionPost.findByIdAndUpdate(
      postId,
      {
        status: "approved",
        isApproved: true,
        approvedBy: req.user.id,
        approvalDate: new Date()
      },
      { new: true }
    ).populate("studentId", "name email");

    if (!post) {
      return res
        .status(404)
        .json({ success: false, message: "Post not found" });
    }

    logger.info(`Tuition post approved: ${post._id} by admin: ${req.user.email}`);

    res.status(200).json({
      post
    });
  } catch (error) {
    logger.error("Error approving post:", error.message);
    res
      .status(500)
      .json({ success: false, message: "Failed to approve post" });
  }
};

/**
 * Reject tuition post
 */
const rejectTuitionPost = async (req, res) => {
  try {
    const { postId } = req.params;
    const { reason } = req.body;

    const post = await TuitionPost.findByIdAndUpdate(
      postId,
      {
        status: "rejected",
        isApproved: false,
        rejectionReason: reason
      },
      { new: true }
    ).populate("studentId", "name email");

    if (!post) {
      return res
        .status(404)
        .json({ success: false, message: "Post not found" });
    }

    logger.info(
      `Tuition post rejected: ${post._id} (Reason: ${reason}) by admin: ${req.user.email}`
    );

    res.status(200).json({
      success: true,
      message: "Tuition post rejected",
      data: post
    });
  } catch (error) {
    logger.error("Error rejecting post:", error.message);
    res
      .status(500)
      .json({ success: false, message: "Failed to reject post" });
  }
};

/**
 * Approve tuition application and create match
 * PATCH /api/tuition/admin/applications/:appId/status
 */
const approveTuitionApplication = async (req, res) => {
  try {
    const { appId } = req.params;
    const { action, notes } = req.body; // action: "approve" or "reject"

    if (!["approve", "reject"].includes(action)) {
      return res
        .status(400)
        .json({ success: false, message: "Invalid action" });
    }

    const application = await TuitionApplication.findById(appId);
    if (!application) {
      return res
        .status(404)
        .json({ success: false, message: "Application not found" });
    }

    // Update application status - admin review done
    application.status = action === "approve" ? "admin_approved" : "admin_rejected";
    application.adminReviewedBy = req.user._id;
    application.adminReviewDate = new Date();
    application.adminReviewNotes = notes || null;
    await application.save();

    // Find the post
    const post = await TuitionPost.findById(application.postId);
    if (!post) {
      return res
        .status(404)
        .json({ success: false, message: "Post not found" });
    }

    // Create notification for teacher about application decision
    if (action === "approve") {
      // Create a match
      const match = await Match.create({
        tuitionId: post._id,
        studentId: post.studentId,
        teacherId: application.teacherId,
        status: "active",
        isChatAllowed: true,
        isDemoAllowed: true
      });

      // Notify teacher of approval
      await Notification.create({
        userId: application.teacherId,
        title: "Application Approved",
        message: `Your application for "${post.title}" has been approved! You can now connect with the student.`,
        type: "application_approved",
        relatedId: application._id,
        isRead: false
      });

      logger.info(
        `Application approved and match created: ${appId} by admin: ${req.user.email}`
      );

      res.status(200).json({
        success: true,
        message: "Application approved and match created",
        match
      });
    } else {
      // Notify teacher of rejection
      const rejectionMessage = notes
        ? `Your application for "${post.title}" was not approved. ${notes}`
        : `Your application for "${post.title}" was not approved.`;

      await Notification.create({
        userId: application.teacherId,
        title: "Application Not Approved",
        message: rejectionMessage,
        type: "application_rejected",
        relatedId: application._id,
        isRead: false
      });

      logger.info(
        `Application rejected: ${appId} by admin: ${req.user.email}`
      );

      res.status(200).json({
        success: true,
        message: "Application rejected"
      });
    }
  } catch (error) {
    logger.error("Error approving application:", error.message);
    res
      .status(500)
      .json({ success: false, message: "Failed to approve application" });
  }
};

// --------------------------------------------------
// NID VERIFICATION SYSTEM
// --------------------------------------------------

/**
 * Get pending NID verifications
 */
const getPendingNIDVerifications = async (req, res) => {
  try {
    const nids = await TeacherNID.find({ verificationStatus: "pending" })
      .populate("teacherId", "name email phone")
      .sort({ createdAt: -1 });

    res.status(200).json({
      success: true,
      data: nids,
      total: nids.length
    });
  } catch (error) {
    logger.error("Error fetching pending NIDs:", error.message);
    res
      .status(500)
      .json({ success: false, message: "Failed to fetch pending NIDs" });
  }
};

/**
 * Verify teacher NID
 */
const verifyTeacherNID = async (req, res) => {
  try {
    const { nidId } = req.params;

    const nid = await TeacherNID.findByIdAndUpdate(
      nidId,
      {
        isVerified: true,
        verificationStatus: "verified",
        verifiedBy: req.user.id,
        verificationDate: new Date()
      },
      { new: true }
    ).populate("teacherId", "name email");

    if (!nid) {
      return res
        .status(404)
        .json({ success: false, message: "NID not found" });
    }

    logger.info(
      `NID verified: ${nid.nidNumber} (Teacher: ${nid.teacherId.email}) by admin: ${req.user.email}`
    );

    res.status(200).json({
      success: true,
      message: "NID verified successfully",
      data: nid
    });
  } catch (error) {
    logger.error("Error verifying NID:", error.message);
    res
      .status(500)
      .json({ success: false, message: "Failed to verify NID" });
  }
};

/**
 * Reject NID verification
 */
const rejectNIDVerification = async (req, res) => {
  try {
    const { nidId } = req.params;
    const { reason } = req.body;

    const nid = await TeacherNID.findByIdAndUpdate(
      nidId,
      {
        verificationStatus: "rejected",
        rejectionReason: reason,
        isVerified: false
      },
      { new: true }
    ).populate("teacherId", "name email");

    if (!nid) {
      return res
        .status(404)
        .json({ success: false, message: "NID not found" });
    }

    logger.warn(
      `NID rejected: ${nid.nidNumber} (Reason: ${reason}) by admin: ${req.user.email}`
    );

    res.status(200).json({
      success: true,
      message: "NID rejected",
      data: nid
    });
  } catch (error) {
    logger.error("Error rejecting NID:", error.message);
    res
      .status(500)
      .json({ success: false, message: "Failed to reject NID" });
  }
};

// --------------------------------------------------
// BAN SYSTEM
// --------------------------------------------------

/**
 * Ban user
 */
const banUser = async (req, res) => {
  try {
    const { userId } = req.params;
    const { reason } = req.body;

    const user = await User.findByIdAndUpdate(
      userId,
      {
        isBanned: true,
        banReason: reason,
        bannedDate: new Date(),
        bannedBy: req.user.id
      },
      { new: true }
    ).select("-password");

    if (!user) {
      return res
        .status(404)
        .json({ success: false, message: "User not found" });
    }

    logger.warn(`User banned: ${user.email} (Reason: ${reason}) by admin: ${req.user.email}`);

    res.status(200).json({
      success: true,
      message: "User banned successfully",
      data: user
    });
  } catch (error) {
    logger.error("Error banning user:", error.message);
    res
      .status(500)
      .json({ success: false, message: "Failed to ban user" });
  }
};

/**
 * Unban user
 */
const unbanUser = async (req, res) => {
  try {
    const { userId } = req.params;

    const user = await User.findByIdAndUpdate(
      userId,
      {
        isBanned: false,
        banReason: null,
        bannedDate: null,
        bannedBy: null
      },
      { new: true }
    ).select("-password");

    if (!user) {
      return res
        .status(404)
        .json({ success: false, message: "User not found" });
    }

    logger.info(`User unbanned: ${user.email} by admin: ${req.user.email}`);

    res.status(200).json({
      success: true,
      message: "User unbanned successfully",
      data: user
    });
  } catch (error) {
    logger.error("Error unbanning user:", error.message);
    res
      .status(500)
      .json({ success: false, message: "Failed to unban user" });
  }
};

// --------------------------------------------------
// NOTICE SYSTEM
// --------------------------------------------------

/**
 * Create notice
 */
const createNotice = async (req, res) => {
  try {
    const { title, content, priority, targetRole, expiresAt } = req.body;

    const notice = new Notice({
      title,
      content,
      priority: priority || "medium",
      targetRole: targetRole || "all",
      createdBy: req.user.id,
      expiresAt: expiresAt ? new Date(expiresAt) : null
    });

    await notice.save();

    logger.info(`Notice created: ${title} by admin: ${req.user.email}`);

    res.status(201).json({
      success: true,
      message: "Notice created successfully",
      data: notice
    });
  } catch (error) {
    logger.error("Error creating notice:", error.message);
    res
      .status(500)
      .json({ success: false, message: "Failed to create notice" });
  }
};

/**
 * Get all active notices
 */
const getNotices = async (req, res) => {
  try {
    const notices = await Notice.find({ isActive: true })
      .populate("createdBy", "name")
      .sort({ priority: -1, createdAt: -1 });

    res.status(200).json({
      success: true,
      data: notices,
      total: notices.length
    });
  } catch (error) {
    logger.error("Error fetching notices:", error.message);
    res
      .status(500)
      .json({ success: false, message: "Failed to fetch notices" });
  }
};

/**
 * Delete notice
 */
const deleteNotice = async (req, res) => {
  try {
    const { noticeId } = req.params;

    const notice = await Notice.findByIdAndUpdate(
      noticeId,
      { isActive: false },
      { new: true }
    );

    if (!notice) {
      return res
        .status(404)
        .json({ success: false, message: "Notice not found" });
    }

    logger.info(`Notice deleted: ${notice.title} by admin: ${req.user.email}`);

    res.status(200).json({
      success: true,
      message: "Notice deleted successfully"
    });
  } catch (error) {
    logger.error("Error deleting notice:", error.message);
    res
      .status(500)
      .json({ success: false, message: "Failed to delete notice" });
  }
};

// --------------------------------------------------
// PARENT CONTROL SYSTEM
// --------------------------------------------------

/**
 * Get parent controls for a parent
 */
const getParentControls = async (req, res) => {
  try {
    const { parentId } = req.params;

    const controls = await ParentControl.find({ parentId })
      .populate("childId", "name email role")
      .populate("restrictions.blockedTeachers", "name")
      .populate("restrictions.allowedTeachers", "name");

    res.status(200).json({
      success: true,
      data: controls,
      total: controls.length
    });
  } catch (error) {
    logger.error("Error fetching parent controls:", error.message);
    res
      .status(500)
      .json({ success: false, message: "Failed to fetch parent controls" });
  }
};

/**
 * Create parent-child relationship with restrictions
 */
const createParentControl = async (req, res) => {
  try {
    const { parentId, childId } = req.body;

    // Check if relationship already exists
    const existing = await ParentControl.findOne({ parentId, childId });
    if (existing) {
      return res
        .status(409)
        .json({
          success: false,
          message: "Parent-child relationship already exists"
        });
    }

    const control = new ParentControl({
      parentId,
      childId,
      verifiedBy: req.user.id,
      isVerified: true,
      verificationDate: new Date()
    });

    await control.save();

    logger.info(
      `Parent control created: ${parentId} → ${childId} by admin: ${req.user.email}`
    );

    res.status(201).json({
      success: true,
      message: "Parent-child relationship created",
      data: control
    });
  } catch (error) {
    logger.error("Error creating parent control:", error.message);
    res
      .status(500)
      .json({ success: false, message: "Failed to create parent control" });
  }
};

/**
 * Update parent restrictions
 */
const updateParentRestrictions = async (req, res) => {
  try {
    const { controlId } = req.params;
    const restrictions = req.body;

    const control = await ParentControl.findByIdAndUpdate(
      controlId,
      { restrictions },
      { new: true }
    ).populate("childId", "name email");

    if (!control) {
      return res
        .status(404)
        .json({ success: false, message: "Control not found" });
    }

    logger.info(
      `Parent restrictions updated for: ${control.childId.email} by admin: ${req.user.email}`
    );

    res.status(200).json({
      success: true,
      message: "Restrictions updated",
      data: control
    });
  } catch (error) {
    logger.error("Error updating restrictions:", error.message);
    res
      .status(500)
      .json({ success: false, message: "Failed to update restrictions" });
  }
};

module.exports = {
  getAdminStats,
  getAllUsers,
  toggleSuspendUser,
  approveTeacherProfile,
  approveTuition,
  approveApplication,
  getPendingApplications,
  getAllDemoSessions,
  updateDemoStatus,
  listUsers,
  getUserDetails,
  createAdmin,
  updateUserRole,
  suspendUser,
  activateUser,
  getDashboardStats,
  deleteUser,
  getPendingProfiles,
  approveUserProfile,
  rejectUserProfile,
  getPendingTuitionPosts,
  approveTuitionPost,
  rejectTuitionPost,
  approveTuitionApplication,
  getPendingNIDVerifications,
  verifyTeacherNID,
  rejectNIDVerification,
  banUser,
  unbanUser,
  createNotice,
  getNotices,
  deleteNotice,
  getParentControls,
  createParentControl,
  updateParentRestrictions
};
