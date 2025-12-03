// models/Review.js
const mongoose = require("mongoose");

const ReviewSchema = new mongoose.Schema(
  {
    teacherId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
      required: true
    },
    studentId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
      required: true
    },
    matchId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Match"
    },

    rating: {
      type: Number,
      min: 1,
      max: 5,
      required: true
    },

    comment: {
      type: String,
      default: ""
    }
  },
  { timestamps: true }
);

// Each student can only review a teacher once (simple rule)
ReviewSchema.index({ teacherId: 1, studentId: 1 }, { unique: true });

module.exports = mongoose.model("Review", ReviewSchema);
