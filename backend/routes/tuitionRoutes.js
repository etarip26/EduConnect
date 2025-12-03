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
  closePost,
} = require("../controllers/tuitionController");

const {
  protect,
  requireRole,
  requireVerifiedEmail,
} = require("../middleware/authMiddleware");

/* --------------------------------------------------
   PUBLIC — GET ALL OPEN POSTS
-------------------------------------------------- */
router.get("/", getAllPosts);

/* --------------------------------------------------
  PUBLIC — GET NEARBY POSTS (server-side)
  Example: /api/tuition-posts/nearby?lat=24.86&lng=67.01&radiusKm=10
 -------------------------------------------------- */
router.get("/nearby", getNearbyPosts);

/* --------------------------------------------------
   STUDENT — CREATE POST
-------------------------------------------------- */
router.post(
  "/",
  protect,
  requireVerifiedEmail,
  requireRole(["student"]),
  createPost
);

/* --------------------------------------------------
   STUDENT — CLOSE POST
-------------------------------------------------- */
router.put(
  "/close/:postId",
  protect,
  requireRole(["student"]),
  closePost
);

/* --------------------------------------------------
   TEACHER — APPLY TO POST
-------------------------------------------------- */
router.post(
  "/apply/:postId",
  protect,
  requireVerifiedEmail,
  requireRole(["teacher"]),
  applyToPost
);

/* --------------------------------------------------
   TEACHER — GET MY APPLICATIONS
-------------------------------------------------- */
router.get(
  "/applications/my",
  protect,
  requireRole(["teacher"]),
  getMyApplications
);

/* --------------------------------------------------
   STUDENT — GET APPLICATIONS FOR A POST
   GET /api/tuition-posts/:postId/applications
-------------------------------------------------- */
router.get(
  "/:postId/applications",
  protect,
  requireRole(["student"]),
  getApplicationsForPost
);

/* --------------------------------------------------
   STUDENT — ACCEPT APPLICATION
   POST /api/tuition-posts/accept/:appId
-------------------------------------------------- */
router.post(
  "/accept/:appId",
  protect,
  requireRole(["student"]),
  acceptApplication
);

module.exports = router;
