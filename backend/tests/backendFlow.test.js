require("dotenv").config();
const mongoose = require("mongoose");
const bcrypt = require("bcryptjs");
const request = require("supertest");

const User = require("../models/User");

jest.setTimeout(60000); // 60 seconds for the whole suite

const BASE_URL = process.env.TEST_BASE_URL || "http://localhost:5000";
const api = request(BASE_URL);

const runId = Date.now();

const studentEmail = `student_${runId}@test.com`;
const teacherEmail = `teacher_${runId}@test.com`;
const adminEmail = `admin_${runId}@test.com`;
const password = "Pass123!";

let studentToken;
let studentId;
let teacherToken;
let teacherId;
let adminToken;
let adminId;

let tuitionPostId;
let applicationId;
let matchId;
let demoId;
let chatRoomId;

beforeAll(async () => {
  // Connect directly to MongoDB for admin user creation
  if (!process.env.MONGO_URI) {
    throw new Error("MONGO_URI is not set in .env");
  }
  await mongoose.connect(process.env.MONGO_URI);

  // Create admin directly in DB (so we can test all admin endpoints)
  let admin = await User.findOne({ email: adminEmail.toLowerCase() });
  if (!admin) {
    const salt = await bcrypt.genSalt(10);
    const passwordHash = await bcrypt.hash(password, salt);
    admin = await User.create({
      email: adminEmail.toLowerCase(),
      passwordHash,
      role: "admin"
    });
  }
  adminId = admin._id.toString();
});

afterAll(async () => {
  await mongoose.connection.close();
});

describe("EduConnect full backend flow (with admin)", () => {
  test("Health check", async () => {
    const res = await api.get("/");
    expect(res.statusCode).toBe(200);
    expect(res.body).toHaveProperty("message");
  });

  // --- AUTH REGISTRATION ---

  test("Register student", async () => {
    const res = await api.post("/api/auth/register").send({
      email: studentEmail,
      password,
      role: "student"
    });

    expect(res.statusCode).toBe(201);
    expect(res.body).toHaveProperty("token");
    expect(res.body).toHaveProperty("user");
    studentToken = res.body.token;
    studentId = res.body.user.id;
  });

  test("Register teacher", async () => {
    const res = await api.post("/api/auth/register").send({
      email: teacherEmail,
      password,
      role: "teacher"
    });

    expect(res.statusCode).toBe(201);
    expect(res.body).toHaveProperty("token");
    expect(res.body).toHaveProperty("user");
    teacherToken = res.body.token;
    teacherId = res.body.user.id;
  });

  // --- AUTH LOGIN ---

  test("Admin login", async () => {
    const res = await api.post("/api/auth/login").send({
      email: adminEmail,
      password
    });

    expect(res.statusCode).toBe(200);
    expect(res.body).toHaveProperty("token");
    adminToken = res.body.token;
  });

  test("Student login", async () => {
    const res = await api.post("/api/auth/login").send({
      email: studentEmail,
      password
    });

    expect(res.statusCode).toBe(200);
    expect(res.body).toHaveProperty("token");
    studentToken = res.body.token;
  });

  test("Teacher login", async () => {
    const res = await api.post("/api/auth/login").send({
      email: teacherEmail,
      password
    });

    expect(res.statusCode).toBe(200);
    expect(res.body).toHaveProperty("token");
    teacherToken = res.body.token;
  });

  // --- PROFILES ---

  test("Teacher can create/update profile", async () => {
    const res = await api
      .put("/api/profile/teacher")
      .set("Authorization", `Bearer ${teacherToken}`)
      .send({
        fullName: "Test Teacher",
        university: "Test University",
        department: "CSE",
        subjects: ["Math", "Physics"],
        jobTitle: "Private Tutor",
        experienceYears: 3,
        expectedSalaryRange: { min: 5000, max: 8000, currency: "BDT" },
        location: { type: "Point", coordinates: [90.4125, 23.8103] },
        serviceAreas: ["Dhanmondi"],
        availableSlots: [
          { dayOfWeek: "Sunday", startTime: "18:00", endTime: "20:00" }
        ]
      });

    expect(res.statusCode).toBe(200);
    expect(res.body).toHaveProperty("profile");
    expect(res.body.profile.fullName).toBe("Test Teacher");
  });

  test("Student can create/update profile", async () => {
    const res = await api
      .put("/api/profile/student")
      .set("Authorization", `Bearer ${studentToken}`)
      .send({
        fullName: "Test Student",
        classLevel: "Class 8",
        location: { type: "Point", coordinates: [90.4125, 23.8103] },
        parentControlEnabled: false
      });

    expect(res.statusCode).toBe(200);
    expect(res.body).toHaveProperty("profile");
    expect(res.body.profile.fullName).toBe("Test Student");
  });

  // --- ADMIN: VERIFY PROFILES & PARENT CONTROL ---

  test("Admin can verify teacher profile", async () => {
    const res = await api
      .patch(`/api/admin/teachers/${teacherId}/verify`)
      .set("Authorization", `Bearer ${adminToken}`)
      .send();

    expect(res.statusCode).toBe(200);
    expect(res.body).toHaveProperty("profile");
    expect(res.body.profile.isVerified).toBe(true);
  });

  test("Admin can verify student profile", async () => {
    const res = await api
      .patch(`/api/admin/students/${studentId}/verify`)
      .set("Authorization", `Bearer ${adminToken}`)
      .send();

    expect(res.statusCode).toBe(200);
    expect(res.body).toHaveProperty("profile");
    expect(res.body.profile.isVerified).toBe(true);
  });

  test("Admin can enable parent control on student", async () => {
    const res = await api
      .patch(`/api/admin/students/${studentId}/parent-control`)
      .set("Authorization", `Bearer ${adminToken}`)
      .send({ enabled: true });

    expect(res.statusCode).toBe(200);
    expect(res.body).toHaveProperty("profile");
    expect(res.body.profile.parentControlEnabled).toBe(true);
  });

  // --- STUDENT: CREATE TUITION POST ---

  test("Student can create tuition post (pending admin)", async () => {
    const res = await api
      .post("/api/tuition/posts")
      .set("Authorization", `Bearer ${studentToken}`)
      .send({
        title: "Need Math tutor for Class 8",
        description: "Looking for a tutor 3 days a week in the evening.",
        classLevel: "Class 8",
        subjects: ["Math"],
        salaryRange: { min: 4000, max: 6000, currency: "BDT" },
        location: { type: "Point", coordinates: [90.4125, 23.8103] },
        areaName: "Dhanmondi",
        schedulePreferences: "Sun, Tue, Thu evening"
      });

    expect(res.statusCode).toBe(201);
    expect(res.body).toHaveProperty("post");
    expect(res.body.post.status).toBe("pending_admin_review");
    tuitionPostId = res.body.post._id;
  });

  // --- ADMIN: APPROVE TUITION POST ---

  test("Admin can approve tuition post", async () => {
    const res = await api
      .patch(`/api/tuition/admin/posts/${tuitionPostId}/status`)
      .set("Authorization", `Bearer ${adminToken}`)
      .send({ status: "approved" });

    expect(res.statusCode).toBe(200);
    expect(res.body).toHaveProperty("post");
    expect(res.body.post.status).toBe("approved");
  });

  // --- TEACHER: VIEW APPROVED TUITIONS & APPLY ---

  test("Teacher can list approved tuition posts", async () => {
    const res = await api
      .get("/api/tuition/posts")
      .set("Authorization", `Bearer ${teacherToken}`);

    expect(res.statusCode).toBe(200);
    expect(res.body).toHaveProperty("posts");
    expect(Array.isArray(res.body.posts)).toBe(true);
    // There should be at least one approved post (ours)
    const found = res.body.posts.find((p) => p._id === tuitionPostId);
    expect(found).toBeDefined();
  });

  test("Teacher can apply to approved tuition", async () => {
    const res = await api
      .post(`/api/tuition/posts/${tuitionPostId}/apply`)
      .set("Authorization", `Bearer ${teacherToken}`)
      .send({
        message: "I have good experience teaching Class 8 Math.",
        proposedSalary: { amount: 5500, currency: "BDT" }
      });

    expect(res.statusCode).toBe(201);
    expect(res.body).toHaveProperty("application");
    applicationId = res.body.application._id;
  });

  // --- ADMIN: VIEW & APPROVE APPLICATION (CREATES MATCH) ---

  test("Admin can list applications for a tuition post", async () => {
    const res = await api
      .get(`/api/tuition/posts/${tuitionPostId}/applications`)
      .set("Authorization", `Bearer ${adminToken}`);

    expect(res.statusCode).toBe(200);
    expect(res.body).toHaveProperty("applications");
    expect(res.body.applications.length).toBeGreaterThan(0);
  });

  test("Admin can approve application and create match", async () => {
    const res = await api
      .patch(`/api/tuition/admin/applications/${applicationId}/status`)
      .set("Authorization", `Bearer ${adminToken}`)
      .send({ status: "approved" });

    expect(res.statusCode).toBe(200);
    expect(res.body).toHaveProperty("match");
    expect(res.body.match.isChatAllowed).toBe(true);
    expect(res.body.match.isDemoAllowed).toBe(true);
    matchId = res.body.match._id;
  });

  // --- STUDENT/TEACHER: VIEW MATCHES ---

  test("Teacher can view matches", async () => {
    const res = await api
      .get("/api/tuition/matches/my")
      .set("Authorization", `Bearer ${teacherToken}`);

    expect(res.statusCode).toBe(200);
    expect(res.body).toHaveProperty("matches");
    const found = res.body.matches.find((m) => m._id === matchId);
    expect(found).toBeDefined();
  });

  test("Student can view matches", async () => {
    const res = await api
      .get("/api/tuition/matches/my")
      .set("Authorization", `Bearer ${studentToken}`);

    expect(res.statusCode).toBe(200);
    expect(res.body).toHaveProperty("matches");
    const found = res.body.matches.find((m) => m._id === matchId);
    expect(found).toBeDefined();
  });

  // --- DEMO SESSION FLOW ---

  test("Student can request demo session for match", async () => {
    const startTime = new Date(Date.now() + 24 * 60 * 60 * 1000); // +1 day
    const endTime = new Date(startTime.getTime() + 60 * 60 * 1000); // +1 hour

    const res = await api
      .post(`/api/demo/matches/${matchId}/request`)
      .set("Authorization", `Bearer ${studentToken}`)
      .send({
        startTime: startTime.toISOString(),
        endTime: endTime.toISOString(),
        note: "Trial class on Algebra"
      });

    expect(res.statusCode).toBe(201);
    expect(res.body).toHaveProperty("demo");
    expect(res.body.demo.status).toBe("requested");
    demoId = res.body.demo._id;
  });

  test("Admin can list requested demo sessions", async () => {
    const res = await api
      .get("/api/demo/admin/sessions?status=requested")
      .set("Authorization", `Bearer ${adminToken}`);

    expect(res.statusCode).toBe(200);
    expect(res.body).toHaveProperty("demos");
    expect(Array.isArray(res.body.demos)).toBe(true);
  });

  test("Admin can approve demo session", async () => {
    const res = await api
      .patch(`/api/demo/admin/sessions/${demoId}/status`)
      .set("Authorization", `Bearer ${adminToken}`)
      .send({ status: "approved" });

    expect(res.statusCode).toBe(200);
    expect(res.body).toHaveProperty("demo");
    expect(res.body.demo.status).toBe("approved");
  });

  // --- CHAT ROOM REST FLOW (NOT SOCKET) ---

  test("Student can create/get chat room for match", async () => {
    const res = await api
      .post("/api/chat/rooms")
      .set("Authorization", `Bearer ${studentToken}`)
      .send({ matchId });

    expect(res.statusCode).toBe(200);
    expect(res.body).toHaveProperty("room");
    chatRoomId = res.body.room._id;
  });

  test("Student can send message via REST", async () => {
    const res = await api
      .post(`/api/chat/rooms/${chatRoomId}/messages`)
      .set("Authorization", `Bearer ${studentToken}`)
      .send({ text: "Hello Teacher, looking forward to our demo!" });

    expect(res.statusCode).toBe(201);
    expect(res.body).toHaveProperty("data");
    expect(res.body.data.text).toBe(
      "Hello Teacher, looking forward to our demo!"
    );
  });

  test("Teacher can fetch chat messages", async () => {
    const res = await api
      .get(`/api/chat/rooms/${chatRoomId}/messages`)
      .set("Authorization", `Bearer ${teacherToken}`);

    expect(res.statusCode).toBe(200);
    expect(res.body).toHaveProperty("messages");
    expect(res.body.messages.length).toBeGreaterThan(0);
  });

  // --- NOTIFICATIONS & ADMIN DASHBOARD ---

  test("Admin can create notification for student", async () => {
    const res = await api
      .post("/api/notifications/admin")
      .set("Authorization", `Bearer ${adminToken}`)
      .send({
        userId: studentId,
        title: "Test Notification",
        message: "This is a test notification from admin."
      });

    expect(res.statusCode).toBe(201);
    expect(res.body).toHaveProperty("notification");
  });

  test("Student can fetch own notifications", async () => {
    const res = await api
      .get("/api/notifications/my")
      .set("Authorization", `Bearer ${studentToken}`);

    expect(res.statusCode).toBe(200);
    expect(res.body).toHaveProperty("notifications");
    expect(Array.isArray(res.body.notifications)).toBe(true);
    expect(res.body.notifications.length).toBeGreaterThan(0);
  });

  test("Admin dashboard stats work", async () => {
    const res = await api
      .get("/api/admin/dashboard/stats")
      .set("Authorization", `Bearer ${adminToken}`);

    expect(res.statusCode).toBe(200);
    expect(res.body).toHaveProperty("users");
    expect(res.body).toHaveProperty("tuitions");
    expect(res.body).toHaveProperty("applications");
    expect(res.body).toHaveProperty("matches");
    expect(res.body).toHaveProperty("demos");
  });
});
