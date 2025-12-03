const jwt = require("jsonwebtoken");
const User = require("../models/User");
const StudentProfile = require("../models/StudentProfile");
const ChatMessage = require("../models/ChatMessage");
const { moderateText } = require("../middleware/contentModerationMiddleware");

function initChatSocket(io) {
  // Authenticate every socket connection using JWT
  io.use(async (socket, next) => {
    try {
      const token =
        socket.handshake.auth?.token || socket.handshake.query?.token;

      if (!token) {
        return next(new Error("No token provided"));
      }

      const decoded = jwt.verify(token, process.env.JWT_SECRET);
      const user = await User.findById(decoded.id);

      if (!user) {
        return next(new Error("User not found"));
      }

      if (user.isSuspended) {
        return next(new Error("Account suspended"));
      }

      if (user.role === "student") {
        const profile = await StudentProfile.findOne({ userId: user._id });
        if (profile && profile.parentControlEnabled) {
          return next(new Error("Parent control enabled for this account"));
        }
      }

      socket.user = {
        _id: user._id.toString(),
        role: user.role,
        name: user.name
      };

      next();
    } catch (err) {
      console.error("Socket auth error:", err.message);
      next(new Error("Invalid token"));
    }
  });

  io.on("connection", (socket) => {
    // Client joins a chat room (roomId should match your ChatRoom/_id)
    socket.on("joinRoom", ({ roomId }) => {
      if (!roomId) return;
      socket.join(roomId);
      socket.emit("joinedRoom", { roomId });
    });

    // Typing indicator
    socket.on("typing", ({ roomId, isTyping }) => {
      if (!roomId) return;
      socket.to(roomId).emit("typing", {
        roomId,
        userId: socket.user._id,
        name: socket.user.name,
        isTyping: !!isTyping
      });
    });

    // Send message via socket
    socket.on("sendMessage", async ({ roomId, text }) => {
      try {
        if (!roomId || !text) return;

        // Basic content moderation
        if (moderateText(text)) {
          socket.emit("messageError", {
            roomId,
            message: "Message contains inappropriate language"
          });
          return;
        }

        // Save to DB
        const msg = await ChatMessage.create({
          roomId,
          senderId: socket.user._id,
          text,
          status: "delivered"
        });

        // Emit to everyone in room (including sender)
        io.to(roomId).emit("newMessage", {
          _id: msg._id,
          roomId,
          senderId: msg.senderId,
          text: msg.text,
          createdAt: msg.createdAt,
          status: msg.status
        });
      } catch (err) {
        console.error("sendMessage socket error:", err);
        socket.emit("messageError", {
          roomId,
          message: "Failed to send message"
        });
      }
    });

    // Mark messages as read
    socket.on("markRead", async ({ roomId }) => {
      try {
        if (!roomId) return;

        await ChatMessage.updateMany(
          {
            roomId,
            senderId: { $ne: socket.user._id },
            status: { $ne: "seen" }
          },
          { $set: { status: "seen" } }
        );

        io.to(roomId).emit("messagesRead", {
          roomId,
          userId: socket.user._id
        });
      } catch (err) {
        console.error("markRead socket error:", err);
      }
    });

    socket.on("disconnect", () => {
      // Optional: track presence
    });
  });
}

module.exports = initChatSocket;
