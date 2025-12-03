// controllers/reviewController.js
const Review = require("../models/Review");
const TeacherProfile = require("../models/TeacherProfile");
const Match = require("../models/Match");

/**
 * Helper: recompute teacher ratingAverage & ratingCount
 */
const recomputeTeacherRating = async (teacherUserId) => {
  const agg = await Review.aggregate([
    { $match: { teacherId: teacherUserId } },
    {
      $group: {
        _id: "$teacherId",
        avgRating: { $avg: "$rating" },
        count: { $sum: 1 }
      }
    }
  ]);

  const info = agg[0];
  const ratingAverage = info ? info.avgRating : 0;
  const ratingCount = info ? info.count : 0;

  await TeacherProfile.findOneAndUpdate(
    { userId: teacherUserId },
    { ratingAverage, ratingCount },
    { new: true }
  );
};

/**
 * POST /api/reviews/teacher/:teacherId
 * body: { rating, comment, matchId? }
 * Student leaves review for teacher.
 */
const createReview = async (req, res) => {
  try {
    const { rating, comment, matchId } = req.body;
    const teacherId = req.params.teacherId;
    const studentId = req.user._id;

    if (req.user.role !== "student") {
      return res.status(403).json({ message: "Only students can review" });
    }

    if (!rating || rating < 1 || rating > 5) {
      return res.status(400).json({ message: "Rating must be 1–5" });
    }

    // OPTIONAL: if you want to enforce match-based review
    if (matchId) {
      const match = await Match.findById(matchId);
      if (!match) {
        return res.status(404).json({ message: "Match not found" });
      }

      const sId = studentId.toString();
      if (match.studentId.toString() !== sId) {
        return res.status(403).json({
          message: "You are not allowed to review this teacher for this match"
        });
      }
    }

    // Create or update review (in case unique constraint already exists)
    const review = await Review.findOneAndUpdate(
      { teacherId, studentId },
      {
        teacherId,
        studentId,
        matchId: matchId || null,
        rating,
        comment: comment || ""
      },
      { new: true, upsert: true, setDefaultsOnInsert: true }
    );

    await recomputeTeacherRating(teacherId);

    res.status(201).json({ review });
  } catch (err) {
    console.error("createReview error:", err);
    if (err.code === 11000) {
      return res
        .status(400)
        .json({ message: "You have already reviewed this teacher" });
    }
    res.status(500).json({ message: "Server error" });
  }
};

/**
 * GET /api/reviews/teacher/:teacherId
 * List reviews for a teacher
 */
const getTeacherReviews = async (req, res) => {
  try {
    const teacherId = req.params.teacherId;

    const reviews = await Review.find({ teacherId })
      .populate("studentId", "name email")
      .sort({ createdAt: -1 });

    res.json({ reviews });
  } catch (err) {
    console.error("getTeacherReviews error:", err);
    res.status(500).json({ message: "Server error" });
  }
};

module.exports = {
  createReview,
  getTeacherReviews
};
