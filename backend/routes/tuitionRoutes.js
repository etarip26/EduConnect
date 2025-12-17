const express = require("express");
const router = express.Router();

const {
  createPost,
  getAllPosts,
  getNearbyPosts,
  applyToPost,
  getMyApplications,
  getApplicationsForPost,
  acceptApplication,
  rejectApplication,
  closePost,
  getMyPosts,
  getApprovedTuitions,
} = require("../controllers/tuitionController");

const {
  approveTuitionPost,
  approveTuitionApplication,
} = require("../controllers/adminController");

const {
  protect,
  requireRole,
  requireVerifiedEmail,
} = require("../middleware/authMiddleware");

const { getMyMatches } = require("../controllers/matchController");

/* --------------------------------------------------
   PUBLIC — GET ALL OPEN POSTS
   GET /api/tuition/posts
-------------------------------------------------- */
router.get("/posts", getAllPosts);

/* --------------------------------------------------
   PUBLIC — GET NEARBY POSTS (server-side)
   GET /api/tuition/posts/nearby?lat=24.86&lng=67.01&radiusKm=10
 -------------------------------------------------- */
router.get("/posts/nearby", getNearbyPosts);

/* --------------------------------------------------
   STUDENT — CREATE POST
   POST /api/tuition/posts
-------------------------------------------------- */
router.post(
  "/posts",
  protect,
  requireVerifiedEmail,
  requireRole(["student"]),
  createPost
);

/* --------------------------------------------------
   STUDENT — CLOSE POST
   PUT /api/tuition/posts/close/:postId
-------------------------------------------------- */
router.put(
  "/posts/close/:postId",
  protect,
  requireRole(["student"]),
  closePost
);

/* --------------------------------------------------
   TEACHER — APPLY TO POST
   POST /api/tuition/posts/:postId/apply
-------------------------------------------------- */
router.post(
  "/posts/:postId/apply",
  protect,
  requireVerifiedEmail,
  requireRole(["teacher"]),
  applyToPost
);

/* --------------------------------------------------
   TEACHER — GET MY APPLICATIONS
   GET /api/tuition/applications/my
-------------------------------------------------- */
router.get(
  "/applications/my",
  protect,
  requireRole(["teacher"]),
  getMyApplications
);

/* --------------------------------------------------
   STUDENT — GET APPLICATIONS FOR A POST
   GET /api/tuition/posts/:postId/applications
-------------------------------------------------- */
router.get(
  "/posts/:postId/applications",
  protect,
  requireRole(["student", "admin"]),
  getApplicationsForPost
);

/* --------------------------------------------------
   STUDENT — ACCEPT APPLICATION
   POST /api/tuition/applications/accept/:appId
-------------------------------------------------- */
router.post(
  "/applications/accept/:appId",
  protect,
  requireRole(["student"]),
  acceptApplication
);

/* --------------------------------------------------
   STUDENT — REJECT APPLICATION
   POST /api/tuition/applications/reject/:appId
   Body: { reason?: string }
-------------------------------------------------- */
router.post(
  "/applications/reject/:appId",
  protect,
  requireRole(["student"]),
  rejectApplication
);

/* --------------------------------------------------
   TEACHER/STUDENT — GET MY MATCHES
   GET /api/tuition/matches/my
-------------------------------------------------- */
router.get(
  "/matches/my",
  protect,
  requireRole(["teacher", "student"]),
  getMyMatches
);

/* --------------------------------------------------
   STUDENT — GET MY POSTS
   GET /api/tuition/my-posts
-------------------------------------------------- */
router.get(
  "/my-posts",
  protect,
  requireRole(["student"]),
  getMyPosts
);

/* --------------------------------------------------
   TEACHER — GET APPROVED TUITIONS TO APPLY
   GET /api/tuition/approved
-------------------------------------------------- */
router.get(
  "/approved",
  protect,
  requireRole(["teacher"]),
  getApprovedTuitions
);

/* --------------------------------------------------
   ADMIN — APPROVE TUITION POST
   PATCH /api/tuition/admin/posts/:postId/status
-------------------------------------------------- */
router.patch(
  "/admin/posts/:postId/status",
  protect,
  requireRole(["admin"]),
  approveTuitionPost
);

/* --------------------------------------------------
   ADMIN — APPROVE APPLICATION (creates match)
   PATCH /api/tuition/admin/applications/:appId/status
   Expected response: { match: {...}, ... }
-------------------------------------------------- */
router.patch(
  "/admin/applications/:appId/status",
  protect,
  requireRole(["admin"]),
  approveTuitionApplication
);

module.exports = router;
