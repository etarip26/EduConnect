// routes/adminRoutes.js
const express = require("express");
const router = express.Router();

const {
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
} = require("../controllers/adminController");

const { protect, requireRole } = require("../middleware/authMiddleware");
const { requireAdmin } = require("../middleware/adminMiddleware");

// All routes require authentication and admin role
router.use(protect, requireRole(["admin"]));

// --------------------------------------------------
// STATS & DASHBOARD
// --------------------------------------------------
router.get("/stats", getAdminStats); // Legacy endpoint
router.get("/dashboard/stats", getDashboardStats); // New enhanced endpoint

// --------------------------------------------------
// USER MANAGEMENT
// --------------------------------------------------
router.get("/users", listUsers); // List with pagination & filtering
router.get("/users/:userId", getUserDetails); // Get user details
router.post("/users/admin/create", createAdmin); // Create new admin
router.patch("/users/:userId/role", updateUserRole); // Update user role
router.patch("/users/:userId/suspend", suspendUser); // Suspend user
router.patch("/users/:userId/activate", activateUser); // Activate user
router.delete("/users/:userId", deleteUser); // Delete user (legacy toggle endpoint)
router.patch("/users/:userId/suspend-toggle", toggleSuspendUser); // Legacy toggle

// --------------------------------------------------
// TEACHER MANAGEMENT
// --------------------------------------------------
router.patch("/teachers/:teacherId/approve", approveTeacherProfile);

// --------------------------------------------------
// TUITION MANAGEMENT
// --------------------------------------------------
router.patch("/tuition/:tuitionId/approve", approveTuition);
router.patch("/applications/:appId/approve", approveApplication);

// --------------------------------------------------
// DEMO SESSIONS
// --------------------------------------------------
router.get("/demos", getAllDemoSessions);
router.patch("/demos/:sessionId", updateDemoStatus);

module.exports = router;
