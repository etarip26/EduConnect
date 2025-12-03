const express = require("express");
const router = express.Router();

const { getMyMatches } = require("../controllers/matchController");
const { protect, requireRole } = require("../middleware/authMiddleware");

// All match routes require login
router.use(protect);

// GET /api/matches/my  (teacher or student)
router.get(
  "/my",
  requireRole(["teacher", "student"]),
  getMyMatches
);

module.exports = router;
