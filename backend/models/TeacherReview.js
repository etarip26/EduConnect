const mongoose = require("mongoose");

const teacherReviewSchema = new mongoose.Schema(
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
    rating: {
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

// One review per (student, teacher)
teacherReviewSchema.index(
  { teacherId: 1, studentId: 1 },
  { unique: true }
);

module.exports = mongoose.model("TeacherReview", teacherReviewSchema);
