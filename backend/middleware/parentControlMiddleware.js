// middleware/parentControlMiddleware.js
const StudentProfile = require("../models/StudentProfile");

/**
 * Block *student* actions if parentControlEnabled = true
 * Teachers / Admin are not affected by this middleware.
 */
const enforceParentControlForStudent = async (req, res, next) => {
  try {
    if (!req.user) {
      return res.status(401).json({ message: "Not authorized" });
    }

    // Only students are affected
    if (req.user.role !== "student") {
      return next();
    }

    const profile = await StudentProfile.findOne({ userId: req.user._id });

    if (profile && profile.parentControlEnabled) {
      return res.status(403).json({
        message:
          "Parent control is enabled for this account. This action is blocked."
      });
    }

    return next();
  } catch (err) {
    console.error("enforceParentControlForStudent error:", err);
    return res.status(500).json({ message: "Server error" });
  }
};

module.exports = {
  enforceParentControlForStudent
};
