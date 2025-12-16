// routes/notificationRoutes.js
const express = require("express");
const router = express.Router();

const {
  getMyNotifications,
  markNotificationAsRead,
  deleteNotification,
  adminCreateNotification
} = require("../controllers/notificationController");

const { protect, requireRole } = require("../middleware/authMiddleware");

// GET /api/notifications/my
router.get("/my", protect, getMyNotifications);

// PATCH /api/notifications/:id/read
router.patch("/:id/read", protect, markNotificationAsRead);

// DELETE /api/notifications/:id
router.delete("/:id", protect, deleteNotification);

// POST /api/notifications/admin
router.post(
  "/admin",
  protect,
  requireRole(["admin"]),
  adminCreateNotification
);

module.exports = router;