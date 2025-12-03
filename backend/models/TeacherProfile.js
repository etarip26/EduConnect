// models/TeacherProfile.js
const mongoose = require("mongoose");

const TeacherProfileSchema = new mongoose.Schema(
  {
    userId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
      required: true,
      unique: true
    },

    university: { type: String, default: "" },
    department: { type: String, default: "" },
    subjects: { type: [String], default: [] },
    classLevels: { type: [String], default: [] },

    jobTitle: { type: String, default: "" }, // Lecturer / Tutor / etc.

    // Salary expectation range
    expectedSalaryMin: { type: Number, default: 0 },
    expectedSalaryMax: { type: Number, default: 0 },

    location: {
      type: {
        type: String,
        enum: ["Point"],
        default: "Point"
      },
      coordinates: {
        type: [Number], // [lng, lat]
        default: [0, 0]
      },
      city: { type: String, default: "" },
      area: { type: String, default: "" }
    },

    availability: {
      days: { type: [String], default: [] },
      timeRange: { type: String, default: "" }
    },

    about: { type: String, default: "" },

    // NID (National ID) verification
    nidCardImageUrl: {
      type: String,
      default: null
    },
    isNidVerified: {
      type: Boolean,
      default: false
    },

    isVerified: {
      type: Boolean,
      default: false
    },

    // ⭐ Rating fields
    ratingAverage: {
      type: Number,
      default: 0
    },
    ratingCount: {
      type: Number,
      default: 0
    }
  },
  { timestamps: true }
);

// 2dsphere index for geo queries
TeacherProfileSchema.index({ location: "2dsphere" });

module.exports = mongoose.model("TeacherProfile", TeacherProfileSchema);
