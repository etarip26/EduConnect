// middleware/rateLimitMiddleware.js
// Temporary no-op rate limiters so Express app.use() works cleanly.
// You can later replace these with real express-rate-limit logic.

const noopLimiter = (req, res, next) => {
  return next();
};

module.exports = {
  globalLimiter: noopLimiter,
  authLimiter: noopLimiter,
  otpLimiter: noopLimiter,
  chatLimiter: noopLimiter,
  adminLimiter: noopLimiter
};
