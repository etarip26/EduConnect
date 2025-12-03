// models/StudentProfile.js
const mongoose = require("mongoose");

const StudentProfileSchema = new mongoose.Schema(
  {
    userId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
      required: true,
      unique: true
    },

    classLevel: { type: String, default: "" },

    location: {
      type: {
        type: String,
        enum: ["Point"],
        default: "Point"
      },
      // [lng, lat]
      coordinates: {
        type: [Number],
        default: [0, 0]
      },
      city: { type: String, default: "" },
      area: { type: String, default: "" }
    },

    isVerified: {
      type: Boolean,
      default: false
    },

    // 🔴 Parent control flag (admin can toggle this)
    parentControlEnabled: {
      type: Boolean,
      default: false
    }
  },
  { timestamps: true }
);

// Geo index for location-based search
StudentProfileSchema.index({ location: "2dsphere" });

module.exports = mongoose.model("StudentProfile", StudentProfileSchema);
