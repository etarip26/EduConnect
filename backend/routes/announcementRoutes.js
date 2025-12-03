const express = require("express");
const router = express.Router();

const {
  getActiveAnnouncements,
  createAnnouncement,
  updateAnnouncement,
  deleteAnnouncement
} = require("../controllers/announcementController");

const { protect } = require("../middleware/authMiddleware");

// Public - get active announcements for notice board
router.get("/active", getActiveAnnouncements);

// Admin only - create announcement
router.post("/", protect, createAnnouncement);

// Admin only - update announcement
router.put("/:id", protect, updateAnnouncement);

// Admin only - delete announcement
router.delete("/:id", protect, deleteAnnouncement);

module.exports = router;
