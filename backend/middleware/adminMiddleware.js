const jwt = require("jsonwebtoken");
const logger = require("../config/logger");

/**
 * Middleware to verify admin role
 * Checks if user has admin role in their JWT token
 */
const requireAdmin = async (req, res, next) => {
  try {
    const token = req.header("Authorization")?.replace("Bearer ", "");

    if (!token) {
      return res.status(401).json({ message: "No token provided" });
    }

    const decoded = jwt.verify(token, process.env.JWT_SECRET);

    // Check if user has admin role
    if (decoded.role !== "admin") {
      logger.warn(`Unauthorized admin access attempt by user: ${decoded.id}`);
      return res.status(403).json({
        message: "Access denied. Admin privileges required.",
        code: "ADMIN_REQUIRED"
      });
    }

    // Attach user info to request
    req.user = decoded;
    next();
  } catch (error) {
    logger.error("Admin middleware error:", error.message);
    return res.status(401).json({ message: "Invalid or expired token" });
  }
};

module.exports = { requireAdmin };
