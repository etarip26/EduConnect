// 404 handler
const notFound = (req, res, next) => {
  res.status(404);
  res.json({ message: `Not Found - ${req.originalUrl}` });
};

// General error handler
const errorHandler = (err, req, res, next) => {
  console.error("Unhandled error:", err);

  const statusCode = res.statusCode && res.statusCode !== 200 ? res.statusCode : 500;

  res.status(statusCode).json({
    message: err.message || "Server error"
  });
};

module.exports = { notFound, errorHandler };
