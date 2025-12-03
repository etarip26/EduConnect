// controllers/notificationController.js
const Notification = require("../models/Notification");
const User = require("../models/User");

// GET /api/notifications/my
const getMyNotifications = async (req, res) => {
  try {
    const notifications = await Notification.find({ userId: req.user._id })
      .sort({ createdAt: -1 });

    return res.status(200).json({ notifications });
  } catch (error) {
    console.error("getMyNotifications error:", error);
    return res.status(500).json({ message: "Server error" });
  }
};

// POST /api/notifications/admin
// body: { userId, title, message }
const adminCreateNotification = async (req, res) => {
  try {
    const { userId, title, message } = req.body;

    if (!userId || !title || !message) {
      return res.status(400).json({ message: "Missing required fields" });
    }

    // Ensure the user exists
    const userExists = await User.findById(userId);
    if (!userExists) {
      return res.status(404).json({ message: "User not found" });
    }

    const notification = await Notification.create({
      userId,
      title,
      message
    });

    return res.status(201).json({ notification });
  } catch (error) {
    console.error("adminCreateNotification error:", error);
    return res.status(500).json({ message: "Server error" });
  }
};

module.exports = {
  getMyNotifications,
  adminCreateNotification
};