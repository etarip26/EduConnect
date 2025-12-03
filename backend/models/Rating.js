const mongoose = require("mongoose");

const ratingSchema = new mongoose.Schema(
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
      ref: "Match",
      required: true
    },
    stars: {
      type: Number,
      min: 1,
      max: 5,
      required: true
    },
    comment: {
      type: String
    }
  },
  { timestamps: true }
);

// Prevent duplicate rating per (student, teacher, match)
ratingSchema.index(
  { teacherId: 1, studentId: 1, matchId: 1 },
  { unique: true }
);

module.exports = mongoose.model("Rating", ratingSchema);
