// controllers/notificationController.js
const Notification = require("../models/Notification");
const User = require("../models/User");

// GET /api/notifications/my
const getMyNotifications = async (req, res) => {
  try {
    const { page = 1, limit = 20 } = req.query;
    const skip = (page - 1) * limit;

    const notifications = await Notification.find({ userId: req.user._id })
      .sort({ createdAt: -1 })
      .skip(skip)
      .limit(parseInt(limit));

    const totalCount = await Notification.countDocuments({ userId: req.user._id });
    const unreadCount = await Notification.countDocuments({ 
      userId: req.user._id, 
      isRead: false 
    });

    return res.status(200).json({ 
      notifications,
      totalCount,
      unreadCount,
      page: parseInt(page),
      limit: parseInt(limit)
    });
  } catch (error) {
    console.error("getMyNotifications error:", error);
    return res.status(500).json({ message: "Server error" });
  }
};

// PATCH /api/notifications/:id/read
const markNotificationAsRead = async (req, res) => {
  try {
    const { id } = req.params;

    const notification = await Notification.findById(id);
    if (!notification) {
      return res.status(404).json({ message: "Notification not found" });
    }

    // Verify ownership
    if (notification.userId.toString() !== req.user._id.toString()) {
      return res.status(403).json({ message: "Unauthorized" });
    }

    notification.isRead = true;
    await notification.save();

    return res.status(200).json({ notification });
  } catch (error) {
    console.error("markNotificationAsRead error:", error);
    return res.status(500).json({ message: "Server error" });
  }
};

// DELETE /api/notifications/:id
const deleteNotification = async (req, res) => {
  try {
    const { id } = req.params;

    const notification = await Notification.findById(id);
    if (!notification) {
      return res.status(404).json({ message: "Notification not found" });
    }

    // Verify ownership
    if (notification.userId.toString() !== req.user._id.toString()) {
      return res.status(403).json({ message: "Unauthorized" });
    }

    await Notification.findByIdAndDelete(id);

    return res.status(200).json({ message: "Notification deleted" });
  } catch (error) {
    console.error("deleteNotification error:", error);
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
  markNotificationAsRead,
  deleteNotification,
  adminCreateNotification
};