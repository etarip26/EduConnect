const Announcement = require("../models/Announcement");

/* --------------------------------------------------
   GET ACTIVE ANNOUNCEMENTS FOR NOTICE BOARD
   Fetches announcements currently active for display
-------------------------------------------------- */
const getActiveAnnouncements = async (req, res) => {
  try {
    const now = new Date();

    const announcements = await Announcement.find({
      isActive: true,
      displayStartDate: { $lte: now },
      $or: [
        { displayEndDate: null },
        { displayEndDate: { $gte: now } }
      ]
    })
      .sort({ priority: -1, displayStartDate: -1 })
      .populate("createdBy", "name email")
      .limit(10);

    return res.json({
      message: "Announcements fetched",
      announcements
    });
  } catch (err) {
    console.error("getActiveAnnouncements error:", err);
    return res.status(500).json({ message: "Server error" });
  }
};

/* --------------------------------------------------
   CREATE ANNOUNCEMENT (ADMIN ONLY)
-------------------------------------------------- */
const createAnnouncement = async (req, res) => {
  try {
    const { title, description, type, priority, imageUrl, actionUrl, displayEndDate } = req.body;

    if (!title || !description) {
      return res.status(400).json({
        message: "Title and description are required"
      });
    }

    const announcement = await Announcement.create({
      title,
      description,
      type: type || "info",
      priority: priority || "medium",
      imageUrl,
      actionUrl,
      displayEndDate,
      createdBy: req.user._id
    });

    return res.status(201).json({
      message: "Announcement created",
      announcement
    });
  } catch (err) {
    console.error("createAnnouncement error:", err);
    return res.status(500).json({ message: "Server error" });
  }
};

/* --------------------------------------------------
   UPDATE ANNOUNCEMENT (ADMIN ONLY)
-------------------------------------------------- */
const updateAnnouncement = async (req, res) => {
  try {
    const { id } = req.params;
    const { title, description, type, priority, imageUrl, actionUrl, displayEndDate, isActive } = req.body;

    const announcement = await Announcement.findByIdAndUpdate(
      id,
      {
        $set: {
          title,
          description,
          type,
          priority,
          imageUrl,
          actionUrl,
          displayEndDate,
          isActive
        }
      },
      { new: true }
    );

    if (!announcement) {
      return res.status(404).json({ message: "Announcement not found" });
    }

    return res.json({
      message: "Announcement updated",
      announcement
    });
  } catch (err) {
    console.error("updateAnnouncement error:", err);
    return res.status(500).json({ message: "Server error" });
  }
};

/* --------------------------------------------------
   DELETE ANNOUNCEMENT (ADMIN ONLY)
-------------------------------------------------- */
const deleteAnnouncement = async (req, res) => {
  try {
    const { id } = req.params;

    const announcement = await Announcement.findByIdAndDelete(id);

    if (!announcement) {
      return res.status(404).json({ message: "Announcement not found" });
    }

    return res.json({
      message: "Announcement deleted",
      announcement
    });
  } catch (err) {
    console.error("deleteAnnouncement error:", err);
    return res.status(500).json({ message: "Server error" });
  }
};

module.exports = {
  getActiveAnnouncements,
  createAnnouncement,
  updateAnnouncement,
  deleteAnnouncement
};
