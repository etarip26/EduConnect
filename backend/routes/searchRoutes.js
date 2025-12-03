// routes/searchRoutes.js
const express = require("express");
const router = express.Router();

const {
  searchTeachers,
  searchStudents
} = require("../controllers/searchController");

const { protect, requireVerifiedEmail } = require("../middleware/authMiddleware");

/* --------------------------------------------------
   STUDENT → SEARCH TEACHERS
   GET /api/search/teachers
-------------------------------------------------- */
router.get(
  "/teachers",
  protect,
  requireVerifiedEmail,
  searchTeachers
);

/* --------------------------------------------------
   TEACHER → SEARCH STUDENTS (tuition posts)
   GET /api/search/students
-------------------------------------------------- */
router.get(
  "/students",
  protect,
  requireVerifiedEmail,
  searchStudents
);

module.exports = router;