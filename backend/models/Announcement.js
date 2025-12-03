const mongoose = require("mongoose");

const AnnouncementSchema = new mongoose.Schema(
  {
    title: {
      type: String,
      required: true
    },
    description: {
      type: String,
      required: true
    },
    type: {
      type: String,
      enum: ["notice", "alert", "info", "success"],
      default: "info"
    },
    priority: {
      type: String,
      enum: ["low", "medium", "high"],
      default: "medium"
    },
    imageUrl: {
      type: String,
      default: null
    },
    actionUrl: {
      type: String,
      default: null
    },
    displayStartDate: {
      type: Date,
      default: Date.now
    },
    displayEndDate: {
      type: Date,
      default: null
    },
    isActive: {
      type: Boolean,
      default: true
    },
    createdBy: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
      required: true
    }
  },
  { timestamps: true }
);

module.exports = mongoose.model("Announcement", AnnouncementSchema);
