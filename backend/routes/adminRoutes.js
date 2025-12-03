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
  updateDemoStatus
} = require("../controllers/adminController");

const { protect, requireRole } = require("../middleware/authMiddleware");

// ADMIN ONLY
router.use(protect, requireRole(["admin"]));

router.get("/stats", getAdminStats);
router.get("/users", getAllUsers);
router.patch("/users/:userId/suspend", toggleSuspendUser);

router.patch("/teachers/:teacherId/approve", approveTeacherProfile);

router.patch("/tuition/:tuitionId/approve", approveTuition);

router.patch("/applications/:appId/approve", approveApplication);

router.get("/demos", getAllDemoSessions);
router.patch("/demos/:sessionId", updateDemoStatus);

module.exports = router;
