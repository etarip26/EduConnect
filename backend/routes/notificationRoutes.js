// routes/notificationRoutes.js
const express = require("express");
const router = express.Router();

const {
  getMyNotifications,
  adminCreateNotification
} = require("../controllers/notificationController");

const { protect, requireRole } = require("../middleware/authMiddleware");

// GET /api/notifications/my
router.get("/my", protect, getMyNotifications);

// POST /api/notifications/admin
router.post(
  "/admin",
  protect,
  requireRole(["admin"]),
  adminCreateNotification
);

module.exports = router;