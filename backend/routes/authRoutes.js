const express = require("express");
const router = express.Router();

const {
  register,
  login,
  getMe,
  requestOtp,
  verifyOtp
} = require("../controllers/authController");

const { protect } = require("../middleware/authMiddleware");
const { updateBasic } = require("../controllers/authController");
// Public
router.post("/register", register);
router.post("/login", login);

// Authenticated (need token)
router.get("/me", protect, getMe);

router.post("/request-otp", protect, requestOtp);
router.post("/verify-otp", protect, verifyOtp);
router.put("/update-basic", protect, updateBasic);

module.exports = router;