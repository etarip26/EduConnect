const jwt = require("jsonwebtoken");
const User = require("../models/User");
const StudentProfile = require("../models/StudentProfile");

/* --------------------------------------------------
   PROTECT — Verify JWT Token
-------------------------------------------------- */
const protect = async (req, res, next) => {
  let token;

  if (req.headers.authorization?.startsWith("Bearer")) {
    token = req.headers.authorization.split(" ")[1];
  }

  if (!token) {
    return res.status(401).json({ message: "Not authorized, no token" });
  }

  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET);

    const user = await User.findById(decoded.id).select("-password");

    if (!user) {
      return res.status(401).json({ message: "User no longer exists" });
    }

    if (user.isSuspended) {
      return res.status(403).json({ message: "Account suspended" });
    }

    req.user = user;
    next();
  } catch (err) {
    console.error("protect error:", err);
    return res.status(401).json({ message: "Not authorized, invalid token" });
  }
};

/* --------------------------------------------------
   REQUIRE ROLE (admin / teacher / student)
-------------------------------------------------- */
const requireRole = (roles = []) => {
  return (req, res, next) => {
    if (!roles.includes(req.user.role)) {
      return res.status(403).json({ message: "Forbidden: wrong role" });
    }
    next();
  };
};

/* --------------------------------------------------
   REQUIRE VERIFIED EMAIL
-------------------------------------------------- */
const requireVerifiedEmail = (req, res, next) => {
  if (!req.user.isEmailVerified) {
    return res.status(403).json({ message: "Email not verified" });
  }
  next();
};

/* --------------------------------------------------
   PARENT CONTROL BLOCKER
   (Blocks student from chatting or requesting demo 
    when admin enabled parentControl)
-------------------------------------------------- */
const blockIfParentControlEnabled = async (req, res, next) => {
  try {
    if (req.user.role !== "student") return next();

    const profile = await StudentProfile.findOne({ userId: req.user._id });
    if (!profile) return next();

    if (profile.parentControlEnabled) {
      return res.status(403).json({
        message: "Parent control enabled — this action is blocked"
      });
    }

    next();
  } catch (err) {
    console.error("parentControl middleware error:", err);
    res.status(500).json({ message: "Server error" });
  }
};

module.exports = {
  protect,
  requireRole,
  requireVerifiedEmail,
  blockIfParentControlEnabled
};