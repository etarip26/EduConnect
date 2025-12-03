// controllers/chatController.js
const ChatRoom = require("../models/ChatRoom");
const ChatMessage = require("../models/ChatMessage");
const Match = require("../models/Match");

/**
 * Ensure the current user is part of this room
 */
const assertInRoom = (room, userId) => {
  const uid = userId.toString();
  if (
    room.studentId.toString() !== uid &&
    room.teacherId.toString() !== uid
  ) {
    const err = new Error("You are not part of this room");
    err.statusCode = 403;
    throw err;
  }
};

/**
 * POST /api/chat/rooms
 * body: { matchId }
 * Create or get chat room for a match (student/teacher)
 */
const createOrGetRoom = async (req, res) => {
  try {
    const { matchId } = req.body;

    if (!matchId) {
      return res.status(400).json({ message: "matchId is required" });
    }

    const match = await Match.findById(matchId);
    if (!match) {
      return res.status(404).json({ message: "Match not found" });
    }

    const uid = req.user._id.toString();
    if (
      match.studentId.toString() !== uid &&
      match.teacherId.toString() !== uid
    ) {
      return res
        .status(403)
        .json({ message: "You are not part of this match" });
    }

    let room = await ChatRoom.findOne({ matchId: match._id });

    if (!room) {
      room = await ChatRoom.create({
        matchId: match._id,
        studentId: match.studentId,
        teacherId: match.teacherId
      });
    }

    return res.status(200).json({ room });
  } catch (err) {
    console.error("createOrGetRoom error:", err);
    return res.status(500).json({ message: "Server error" });
  }
};

/**
 * GET /api/chat/rooms/my
 * List rooms where I am student or teacher
 */
const listMyRooms = async (req, res) => {
  try {
    const userId = req.user._id;

    const rooms = await ChatRoom.find({
      $or: [{ studentId: userId }, { teacherId: userId }]
    })
      .populate("matchId")
      .sort({ updatedAt: -1 });

    return res.json({ rooms });
  } catch (err) {
    console.error("listMyRooms error:", err);
    return res.status(500).json({ message: "Server error" });
  }
};

/**
 * GET /api/chat/rooms/:roomId/messages
 * Get messages for a specific room
 */
const getRoomMessages = async (req, res) => {
  try {
    const { roomId } = req.params;

    const room = await ChatRoom.findById(roomId);
    if (!room) {
      return res.status(404).json({ message: "Room not found" });
    }

    // ensure user belongs to the room
    assertInRoom(room, req.user._id);

    const messages = await ChatMessage.find({ roomId })
      .sort({ createdAt: 1 });

    return res.json({ messages });
  } catch (err) {
    console.error("getRoomMessages error:", err);
    if (err.statusCode) {
      return res.status(err.statusCode).json({ message: err.message });
    }
    return res.status(500).json({ message: "Server error" });
  }
};

/**
 * POST /api/chat/rooms/:roomId/messages
 * body: { content }
 * Send a message in a room (simple REST version)
 */
const sendMessageRest = async (req, res) => {
  try {
    const { roomId } = req.params;
    const { content } = req.body;

    if (!content || !content.trim()) {
      return res.status(400).json({ message: "content is required" });
    }

    const room = await ChatRoom.findById(roomId);
    if (!room) {
      return res.status(404).json({ message: "Room not found" });
    }

    // ensure user belongs to the room
    assertInRoom(room, req.user._id);

    const message = await ChatMessage.create({
      roomId,
      senderId: req.user._id,
      content: content.trim()
    });

    // keep room updated
    room.lastMessageAt = new Date();
    await room.save();

    return res.status(201).json({ message });
  } catch (err) {
    console.error("sendMessageRest error:", err);
    if (err.statusCode) {
      return res.status(err.statusCode).json({ message: err.message });
    }
    return res.status(500).json({ message: "Server error" });
  }
};

module.exports = {
  createOrGetRoom,
  listMyRooms,
  getRoomMessages,
  sendMessageRest
};