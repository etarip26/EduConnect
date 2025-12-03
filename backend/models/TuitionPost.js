const mongoose = require("mongoose");

const TuitionPostSchema = new mongoose.Schema(
  {
    studentId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
      required: true
    },

    title: { type: String, required: true },
    details: { type: String, default: "" },
    classLevel: { type: String, required: true },
    subjects: { type: [String], default: [] },

    salaryMin: { type: Number, default: 0 },
    salaryMax: { type: Number, default: 0 },

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

    isClosed: {
      type: Boolean,
      default: false
    }
  },
  { timestamps: true }
);

TuitionPostSchema.index({ location: "2dsphere" });

module.exports = mongoose.model("TuitionPost", TuitionPostSchema);