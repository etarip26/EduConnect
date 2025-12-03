// controllers/demoController.js
const DemoSession = require("../models/DemoSession");
const Match = require("../models/Match");

/* --------------------------------------------------
   STUDENT — REQUEST DEMO SESSION
-------------------------------------------------- */
const requestDemo = async (req, res) => {
  try {
    const { matchId } = req.body;

    const match = await Match.findById(matchId);
    if (!match) return res.status(404).json({ message: "Match not found" });

    if (match.studentId.toString() !== req.user._id.toString()) {
      return res.status(403).json({ message: "You are not this match's student" });
    }

    const session = await DemoSession.create({
      matchId,
      studentId: match.studentId,
      teacherId: match.teacherId,
      status: "pending"
    });

    res.status(201).json({ session });
  } catch (err) {
    console.error("requestDemo error:", err);
    res.status(500).json({ message: "Server error" });
  }
};

/* --------------------------------------------------
   ADMIN — GET ALL DEMO REQUESTS
-------------------------------------------------- */
const getAllDemoRequests = async (req, res) => {
  try {
    const demos = await DemoSession.find()
      .populate("studentId", "name email")
      .populate("teacherId", "name email");

    res.json({ demos });
  } catch (err) {
    console.error("getAllDemoRequests error:", err);
    res.status(500).json({ message: "Server error" });
  }
};

/* --------------------------------------------------
   ADMIN — APPROVE / REJECT DEMO SESSION
-------------------------------------------------- */
const updateDemoStatus = async (req, res) => {
  try {
    const { sessionId } = req.params;
    const { status } = req.body; // "approved" | "rejected"

    const allowed = ["approved", "rejected"];
    if (!allowed.includes(status)) {
      return res.status(400).json({ message: "Invalid status" });
    }

    const session = await DemoSession.findByIdAndUpdate(
      sessionId,
      { status },
      { new: true }
    );

    if (!session) return res.status(404).json({ message: "Demo session not found" });

    res.json({ session });
  } catch (err) {
    console.error("updateDemoStatus error:", err);
    res.status(500).json({ message: "Server error" });
  }
};

module.exports = {
  requestDemo,
  getAllDemoRequests,
  updateDemoStatus
};
