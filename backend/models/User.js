const mongoose = require("mongoose");

const UserSchema = new mongoose.Schema(
  {
    name: { type: String, default: "" },

    email: {
      type: String,
      required: true,
      unique: true,
      lowercase: true
    },

    phone: { type: String, default: "" },

    password: { type: String, required: true },

    role: {
      type: String,
      enum: ["student", "teacher", "admin"],
      required: true
    },

    // Email verification
    isEmailVerified: { type: Boolean, default: false },
    emailOtpCode: { type: String, default: null },
    emailOtpExpiresAt: { type: Date, default: null },

    // Admin-level safety
    isSuspended: { type: Boolean, default: false }
  },
  { timestamps: true }
);

module.exports = mongoose.model("User", UserSchema);