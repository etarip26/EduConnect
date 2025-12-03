// routes/reviewRoutes.js
const express = require("express");
const router = express.Router();

const {
  createReview,
  getTeacherReviews
} = require("../controllers/reviewController");

const { protect } = require("../middleware/authMiddleware");

// Student leaves review for teacher
router.post("/teacher/:teacherId", protect, createReview);

// Public or auth: list reviews for a teacher
router.get("/teacher/:teacherId", getTeacherReviews);

module.exports = router;
