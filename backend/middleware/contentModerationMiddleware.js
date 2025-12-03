// middleware/contentModerationMiddleware.js

/**
 * Simple message moderation placeholder.
 * Blocks profanity / bad content. You can expand later.
 */
const bannedWords = ["fuck", "shit", "bitch", "asshole"];

const chatModeration = (req, res, next) => {
  try {
    const { message } = req.body;

    if (!message) return next();

    const text = message.toLowerCase();

    const violated = bannedWords.find(w => text.includes(w));

    if (violated) {
      return res.status(400).json({
        message: `Message blocked due to inappropriate content: "${violated}"`
      });
    }

    next();
  } catch (err) {
    console.error("chatModeration error:", err);
    return res.status(500).json({ message: "Server error" });
  }
};

module.exports = { chatModeration };
