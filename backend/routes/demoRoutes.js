const express = require("express");
const router = express.Router();

const {
  requestDemo,
  getAllDemoRequests,
  updateDemoStatus
} = require("../controllers/demoController");

const DemoSession = require("../models/DemoSession");
const { protect, requireRole, requireVerifiedEmail } = require("../middleware/authMiddleware");

/* --------------------------------------------------
   STUDENT — REQUEST DEMO
-------------------------------------------------- */
router.post(
  "/request",
  protect,
  requireVerifiedEmail,
  requireRole(["student"]),
  requestDemo
);

/* --------------------------------------------------
   STUDENT/TEACHER — GET MY DEMO SESSIONS
   (Used by dashboards)
-------------------------------------------------- */
router.get(
  "/my",
  protect,
  requireRole(["student", "teacher"]),
  async (req, res) => {
    try {
      const sessions = await DemoSession.find({
        $or: [
          { studentId: req.user._id },
          { teacherId: req.user._id }
        ]
      })
        .populate("studentId", "name email")
        .populate("teacherId", "name email");

      res.json({ sessions });
    } catch (err) {
      console.error("GET /demo-sessions/my error:", err);
      res.status(500).json({ message: "Server error" });
    }
  }
);

/* --------------------------------------------------
   ADMIN — VIEW ALL DEMOS
-------------------------------------------------- */
router.get(
  "/",
  protect,
  requireRole(["admin"]),
  getAllDemoRequests
);

/* --------------------------------------------------
   ADMIN — UPDATE DEMO STATUS
-------------------------------------------------- */
router.patch(
  "/:sessionId",
  protect,
  requireRole(["admin"]),
  updateDemoStatus
);

module.exports = router;
