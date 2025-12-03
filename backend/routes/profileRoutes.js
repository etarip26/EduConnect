// routes/profileRoutes.js
const express = require("express");
const router = express.Router();

const {
  createOrUpdateTeacherProfile,
  createOrUpdateStudentProfile,
  getMyProfile,
  getTopTeachers
} = require("../controllers/profileController");

const { protect, requireRole } = require("../middleware/authMiddleware");

/* --------------------------------------------------
   STUDENT — CREATE / UPDATE PROFILE
   Supports:
   - POST /api/profile/student
   - PUT  /api/profile/student
   - POST /api/profile/student/me   (legacy)
-------------------------------------------------- */
router.post(
  "/student",
  protect,
  requireRole(["student"]),
  createOrUpdateStudentProfile
);

router.put(
  "/student",
  protect,
  requireRole(["student"]),
  createOrUpdateStudentProfile
);

// Legacy alias (if frontend ever calls /student/me with POST)
router.post(
  "/student/me",
  protect,
  requireRole(["student"]),
  createOrUpdateStudentProfile
);

/* --------------------------------------------------
   TEACHER — CREATE / UPDATE PROFILE
   Supports:
   - POST /api/profile/teacher
   - PUT  /api/profile/teacher
   - POST /api/profile/teacher/me   (legacy)
-------------------------------------------------- */
router.post(
  "/teacher",
  protect,
  requireRole(["teacher"]),
  createOrUpdateTeacherProfile
);

router.put(
  "/teacher",
  protect,
  requireRole(["teacher"]),
  createOrUpdateTeacherProfile
);

// Legacy alias
router.post(
  "/teacher/me",
  protect,
  requireRole(["teacher"]),
  createOrUpdateTeacherProfile
);

/* --------------------------------------------------
   AUTH — GET MY PROFILE
   Supports:
   - GET /api/profile/me
   - GET /api/profile/student/me   (student only)
   - GET /api/profile/teacher/me   (teacher only)
-------------------------------------------------- */
router.get("/me", protect, getMyProfile);

router.get(
  "/student/me",
  protect,
  requireRole(["student"]),
  getMyProfile
);

router.get(
  "/teacher/me",
  protect,
  requireRole(["teacher"]),
  getMyProfile
);

// PUBLIC — GET TOP TEACHERS
router.get("/top-teachers", getTopTeachers);

module.exports = router;