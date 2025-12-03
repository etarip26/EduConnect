const mongoose = require("mongoose");

const demoSessionSchema = new mongoose.Schema(
  {
    matchId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Match",
      required: true
    },

    // REQUIRED BASED ON CONTROLLER
    studentId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
      required: true
    },

    teacherId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
      required: true
    },

    requestedBy: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User"
    },

    scheduledAt: {
      type: Date
    },

    status: {
      type: String,
      enum: ["requested", "pending", "approved", "rejected", "completed"],
      default: "requested"
    }
  },
  { timestamps: true }
);

module.exports = mongoose.model("DemoSession", demoSessionSchema);
