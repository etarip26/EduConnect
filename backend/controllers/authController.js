const User = require("../models/User");
const bcrypt = require("bcryptjs");
const jwt = require("jsonwebtoken");
const { sendEmail } = require("../config/email"); // fixed path

// Generate JWT
function generateToken(user) {
  return jwt.sign(
    { id: user._id, role: user.role },
    process.env.JWT_SECRET,
    { expiresIn: "7d" }
  );
}

// Shape user for API responses (never expose password)
function serializeUser(user) {
  return {
    id: user._id,
    name: user.name || "",
    email: user.email,
    phone: user.phone || "",
    role: user.role,
    isEmailVerified: user.isEmailVerified,
    isSuspended: user.isSuspended
  };
}

/* --------------------------------------------------
   REGISTER
-------------------------------------------------- */
const register = async (req, res) => {
  try {
    const { name, email, phone, password, role } = req.body;

    if (!email || !password || !role) {
      return res.status(400).json({
        message: "Email, password and role are required"
      });
    }

    const exists = await User.findOne({ email: email.toLowerCase() });
    if (exists) {
      return res.status(400).json({ message: "Email already used" });
    }

    const salt = await bcrypt.genSalt(10);
    const hash = await bcrypt.hash(password, salt);

    const user = await User.create({
      name,
      email: email.toLowerCase(),
      phone,
      password: hash,
      role,
      isEmailVerified: false
    });

    const token = generateToken(user);

    return res.status(201).json({
      message: "Registered successfully",
      token,
      user: serializeUser(user)
    });
  } catch (err) {
    console.error("Register error:", err);
    return res.status(500).json({ message: "Server error" });
  }
};

/* --------------------------------------------------
   LOGIN
-------------------------------------------------- */
const login = async (req, res) => {
  try {
    const { email, password } = req.body;

    const user = await User.findOne({ email: email.toLowerCase() });
    if (!user) return res.status(400).json({ message: "Invalid credentials" });

    const match = await bcrypt.compare(password, user.password);
    if (!match) return res.status(400).json({ message: "Invalid credentials" });

    if (user.isSuspended) {
      return res.status(403).json({ message: "Account suspended" });
    }

    const token = generateToken(user);

    return res.json({
      message: "Logged in",
      token,
      user: serializeUser(user)
    });
  } catch (err) {
    console.error("Login error:", err);
    return res.status(500).json({ message: "Server error" });
  }
};

/* --------------------------------------------------
   GET ME
-------------------------------------------------- */
const getMe = async (req, res) => {
  try {
    const user = await User.findById(req.user._id);
    if (!user) return res.status(404).json({ message: "User not found" });

    return res.json({ user: serializeUser(user) });
  } catch (err) {
    console.error("getMe error:", err);
    return res.status(500).json({ message: "Server error" });
  }
};

/* --------------------------------------------------
   REQUEST OTP
-------------------------------------------------- */
const requestOtp = async (req, res) => {
  try {
    const user = await User.findById(req.user._id);
    if (!user) return res.status(404).json({ message: "User not found" });

    if (user.isEmailVerified) {
      return res.status(400).json({ message: "Email already verified" });
    }

    const code = Math.floor(100000 + Math.random() * 900000).toString();
    const expiresAt = new Date(Date.now() + 10 * 60 * 1000);

    user.emailOtpCode = code;
    user.emailOtpExpiresAt = expiresAt;
    await user.save();

    await sendEmail({
      to: user.email,
      subject: "EduConnect Email Verification",
      text: `Your OTP code is: ${code}\nValid for 10 minutes.`
    });

    return res.json({ message: "OTP sent to email" });
  } catch (err) {
    console.error("requestOtp error:", err);
    res.status(500).json({ message: "Server error" });
  }
};

/* --------------------------------------------------
   VERIFY OTP
-------------------------------------------------- */
const verifyOtp = async (req, res) => {
  try {
    const { code } = req.body;

    if (!code)
      return res.status(400).json({ message: "OTP code is required" });

    const user = await User.findById(req.user._id);
    if (!user) return res.status(404).json({ message: "User not found" });

    if (!user.emailOtpCode)
      return res.status(400).json({ message: "OTP not requested" });

    if (user.emailOtpExpiresAt < Date.now()) {
      return res.status(400).json({ message: "OTP expired" });
    }

    if (user.emailOtpCode !== code) {
      return res.status(400).json({ message: "Invalid OTP" });
    }

    user.isEmailVerified = true;
    user.emailOtpCode = null;
    user.emailOtpExpiresAt = null;
    await user.save();

    return res.json({
      message: "Email verified successfully",
      user: serializeUser(user)
    });
  } catch (err) {
    console.error("verifyOtp error:", err);
    res.status(500).json({ message: "Server error" });
  }
};

/* --------------------------------------------------
   UPDATE BASIC USER INFO (NAME + PHONE)
-------------------------------------------------- */
const updateBasic = async (req, res) => {
  try {
    const { name, phone } = req.body;

    const user = await User.findById(req.user._id);
    if (!user) return res.status(404).json({ message: "User not found" });

    if (name) user.name = name;
    if (phone) user.phone = phone;

    await user.save();

    return res.json({
      message: "User updated successfully",
      user: serializeUser(user)
    });
  } catch (err) {
    console.error("updateBasic error:", err);
    return res.status(500).json({ message: "Server error" });
  }
};

module.exports = {
  register,
  login,
  getMe,
  requestOtp,
  verifyOtp,
  updateBasic // <-- NEW
};
