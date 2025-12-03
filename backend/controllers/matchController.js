const Match = require("../models/Match");
const TuitionPost = require("../models/TuitionPost");

// GET /api/matches/my
// teacher → matches where teacherId = me
// student → matches where studentId = me
const getMyMatches = async (req, res) => {
  try {
    const filter =
      req.user.role === "teacher"
        ? { teacherId: req.user._id }
        : { studentId: req.user._id };

    const matches = await Match.find(filter)
      .populate("tuitionId")
      .populate("teacherId", "name email")
      .populate("studentId", "name email")
      .sort({ createdAt: -1 });

    res.json({ matches });
  } catch (err) {
    console.error("getMyMatches error:", err);
    res.status(500).json({ message: "Server error" });
  }
};

module.exports = {
  getMyMatches
};
