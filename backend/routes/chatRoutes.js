// routes/chatRoutes.js
const express = require("express");
const router = express.Router();

const {
  createOrGetRoom,
  listMyRooms,
  getRoomMessages,
  sendMessageRest
} = require("../controllers/chatController");

const { protect } = require("../middleware/authMiddleware");
const {
  enforceParentControlForStudent
} = require("../middleware/parentControlMiddleware");

// Create or get chat room for a match
router.post(
  "/rooms",
  protect,
  enforceParentControlForStudent, // block student if parent control enabled
  createOrGetRoom
);

// List my chat rooms (student or teacher)
router.get("/rooms/my", protect, listMyRooms);

// Get messages for a room
router.get(
  "/rooms/:roomId/messages",
  protect,
  enforceParentControlForStudent,
  getRoomMessages
);

// Send message in a room (REST)
router.post(
  "/rooms/:roomId/messages",
  protect,
  enforceParentControlForStudent,
  sendMessageRest
);

module.exports = router;
