const TuitionPost = require("../models/TuitionPost");
const TuitionApplication = require("../models/TuitionApplication");
const Match = require("../models/Match");

/* --------------------------------------------------
   CREATE TUITION POST (Student)
   Only students with approved profiles can create posts
-------------------------------------------------- */
exports.createPost = async (req, res) => {
  try {
    // Check if student profile is approved
    if (!req.user.isProfileApproved) {
      return res.status(403).json({
        message: "Profile not approved",
        details: "Admin approval required to post tuitions"
      });
    }

    const {
      title,
      details,
      description,
      classLevel,
      subjects,
      salaryMin,
      salaryMax,
      salaryRange,
      location,
      areaName,
      schedulePreferences
    } = req.body;

    if (!title || !classLevel) {
      return res.status(400).json({ message: "Missing fields" });
    }

    // Handle location format: Flutter sends {lat, lng, city, area}
    let locationData = undefined;
    if (location) {
      // Handle two possible formats:
      // 1. Direct coordinates: {lat, lng, city, area}
      if (location.lat !== undefined && location.lng !== undefined) {
        locationData = {
          type: "Point",
          coordinates: [Number(location.lng), Number(location.lat)],
          city: location.city || areaName || "",
          area: location.area || areaName || ""
        };
      }
      // 2. GeoJSON format: {type: "Point", coordinates: [lng, lat]}
      else if (location.type === "Point" && location.coordinates && Array.isArray(location.coordinates)) {
        locationData = {
          type: "Point",
          coordinates: [Number(location.coordinates[0]), Number(location.coordinates[1])],
          city: location.city || areaName || "",
          area: location.area || areaName || ""
        };
      }
    }

    // Handle salary range format
    let finalSalaryMin = salaryMin || salaryRange?.min || 0;
    let finalSalaryMax = salaryMax || salaryRange?.max || 0;

    const post = await TuitionPost.create({
      studentId: req.user._id,
      title,
      details: details || description || "",
      classLevel,
      subjects: Array.isArray(subjects) ? subjects : [],
      salaryMin: Number(finalSalaryMin),
      salaryMax: Number(finalSalaryMax),
      location: locationData,
      status: "pending_admin_review"
    });

    res.status(201).json({ post });
  } catch (err) {
    console.error("createPost error:", err);
    res.status(500).json({ message: "Server error" });
  }
};

/* --------------------------------------------------
   GET APPROVED TUITION POSTS (Public)
   Only shows approved posts
-------------------------------------------------- */
exports.getAllPosts = async (req, res) => {
  try {
    const posts = await TuitionPost.find({
      isClosed: false,
      status: "approved"
    })
      .sort({ createdAt: -1 });

    res.json({ posts });
  } catch (err) {
    console.error("getAllPosts error:", err);
    res.status(500).json({ message: "Server error" });
  }
};

/* --------------------------------------------------
   PUBLIC — GET NEARBY TUITION POSTS (Server-side geospatial)
   GET /api/tuition-posts/nearby?lat=<lat>&lng=<lng>&radiusKm=<km>&classLevel=...&subjects=...
   Supports combined location + content filters.
   Uses MongoDB 2dsphere index and `$nearSphere` for efficient queries.
   
   Query params:
   - lat, lng: center point (required)
   - radiusKm: search radius in km (default 10, max 50)
   - withDistance: if true, include dist.calculated and distance_km
   - classLevel: filter by class level
   - subjects: filter by subjects (comma-separated)
   - city: filter by city in location.city
   - page, limit: pagination (default 1, 50)
-------------------------------------------------- */
exports.getNearbyPosts = async (req, res) => {
  try {
    const lat = parseFloat(req.query.lat);
    const lng = parseFloat(req.query.lng);
    let radiusKm = req.query.radiusKm ? parseFloat(req.query.radiusKm) : 10;
    const withDistance = req.query.withDistance === 'true' || req.query.withDistance === '1';
    const page = Math.max(parseInt(req.query.page || '1', 10), 1);
    const perPage = Math.min(Math.max(parseInt(req.query.limit || req.query.perPage || '50', 10), 1), 200);
    const maxRadiusKmAllowed = 50; // protect the DB from very large scans

    // basic validation
    if (isNaN(lat) || isNaN(lng))
      return res.status(400).json({ message: "lat and lng query params are required and must be numbers" });
    if (lat < -90 || lat > 90 || lng < -180 || lng > 180)
      return res.status(400).json({ message: "lat/lng out of range" });

    if (isNaN(radiusKm) || radiusKm <= 0) radiusKm = 10;
    if (radiusKm > maxRadiusKmAllowed) radiusKm = maxRadiusKmAllowed;

    const radiusMeters = radiusKm * 1000;
    const skip = (page - 1) * perPage;

    // Build query filter combining location and content filters
    const query = { isClosed: false };

    // Optional content filters
    if (req.query.classLevel) {
      query.classLevel = req.query.classLevel;
    }
    if (req.query.subjects) {
      const subjectsArray = req.query.subjects.split(',').map(s => s.trim()).filter(s => s);
      if (subjectsArray.length > 0) {
        query.subjects = { $in: subjectsArray };
      }
    }
    if (req.query.city) {
      query["location.city"] = { $regex: req.query.city, $options: 'i' };
    }

    if (withDistance) {
      // Use aggregation $geoNear to include calculated distance (in meters) and add a km field
      const pipeline = [
        {
          $geoNear: {
            near: { type: "Point", coordinates: [lng, lat] },
            distanceField: "dist.calculated",
            maxDistance: radiusMeters,
            spherical: true,
            query
          }
        },
        { $skip: skip },
        { $limit: perPage },
        // add a convenient distance_km field for clients
        {
          $addFields: {
            distance_km: { $divide: ["$dist.calculated", 1000] }
          }
        }
      ];

      const results = await TuitionPost.aggregate(pipeline);
      return res.json({ posts: results, page, perPage });
    }

    // Fallback query using $nearSphere with pagination
    const posts = await TuitionPost.find({
      location: {
        $nearSphere: {
          $geometry: { type: "Point", coordinates: [lng, lat] },
          $maxDistance: radiusMeters
        }
      },
      isClosed: false,
      status: "approved",
      ...query
    })
      .skip(skip)
      .limit(perPage)
      .lean();

    // For the non-aggregation path we don't have distance in the result; client can compute.
    res.json({ posts, page, perPage });
  } catch (err) {
    console.error("getNearbyPosts error:", err);
    res.status(500).json({ message: "Server error" });
  }
};

/* --------------------------------------------------
   APPLY TO TUITION (Teacher)
   Only teachers with approved profiles can apply
-------------------------------------------------- */
exports.applyToPost = async (req, res) => {
  try {
    // Check if teacher profile is approved
    if (!req.user.isProfileApproved) {
      return res.status(403).json({
        message: "Profile not approved",
        details: "Admin approval required to apply to tuitions"
      });
    }

    const { postId } = req.params;

    const post = await TuitionPost.findById(postId);
    if (!post) return res.status(404).json({ message: "Post not found" });

    // Prevent duplicate application
    const existing = await TuitionApplication.findOne({
      postId,
      teacherId: req.user._id
    });

    if (existing)
      return res.status(400).json({ message: "Already applied" });

    const app = await TuitionApplication.create({
      postId,
      teacherId: req.user._id,
      status: "pending_admin_review"
    });

    res.status(201).json({ application: app });
  } catch (err) {
    console.error("applyToPost error:", err);
    res.status(500).json({ message: "Server error" });
  }
};

/* --------------------------------------------------
   GET MY APPLICATIONS (Teacher)
-------------------------------------------------- */
exports.getMyApplications = async (req, res) => {
  try {
    const apps = await TuitionApplication.find({
      teacherId: req.user._id
    })
      .populate("postId")
      .sort({ createdAt: -1 });

    res.json({ applications: apps });
  } catch (err) {
    console.error("getMyApplications error:", err);
    res.status(500).json({ message: "Server error" });
  }
};

/* --------------------------------------------------
   STUDENT — GET ALL APPLICATIONS FOR A TUITION POST
   GET /api/tuition-posts/:postId/applications
   Students see only admin-approved applications
   Admins see all applications for review
-------------------------------------------------- */
exports.getApplicationsForPost = async (req, res) => {
  try {
    const { postId } = req.params;

    // Allow admins to view applications for any post, or students to view their own
    let post;
    if (req.user.role === "admin") {
      post = await TuitionPost.findOne({ _id: postId });
    } else {
      post = await TuitionPost.findOne({
        _id: postId,
        studentId: req.user._id
      });
    }

    if (!post)
      return res.status(403).json({ message: "Not authorized" });

    // Students can only see admin-approved applications
    // Admins can see all applications
    const query = { postId };
    if (req.user.role !== "admin") {
      query.status = "admin_approved";
    }

    const apps = await TuitionApplication.find(query)
      .populate("teacherId", "name email")
      .sort({ createdAt: -1 });

    const result = apps.map(a => ({
      _id: a._id,
      teacherId: a.teacherId._id,
      teacherName: a.teacherId.name,
      email: a.teacherId.email,
      status: a.status,
    }));

    res.json({ applications: result });

  } catch (err) {
    console.error("getApplicationsForPost error:", err);
    res.status(500).json({ message: "Server error" });
  }
};

/* --------------------------------------------------
   STUDENT — ACCEPT APPLICATION
   POST /api/tuition-posts/accept/:appId
   Student can only accept admin-approved applications
-------------------------------------------------- */
exports.acceptApplication = async (req, res) => {
  try {
    const { appId } = req.params;

    const app = await TuitionApplication.findById(appId);
    if (!app)
      return res.status(404).json({ message: "Application not found" });

    // Check that application is admin-approved
    if (app.status !== "admin_approved") {
      return res.status(400).json({ 
        message: "Cannot accept application",
        details: `Application is still pending admin review. Status: ${app.status}`
      });
    }

    const post = await TuitionPost.findById(app.postId);
    if (!post)
      return res.status(404).json({ message: "Post not found" });

    if (post.studentId.toString() !== req.user._id.toString())
      return res.status(403).json({ message: "Not authorized" });

    app.status = "accepted";
    await app.save();

    await TuitionApplication.updateMany(
      { postId: post._id, _id: { $ne: appId } },
      { $set: { status: "rejected" } }
    );

    post.isClosed = true;
    await post.save();

    const match = await Match.create({
      tuitionId: post._id,
      studentId: post.studentId,
      teacherId: app.teacherId,
      status: "active"
    });

    res.json({
      message: "Application accepted",
      matchId: match._id
    });

  } catch (err) {
    console.error("acceptApplication error:", err);
    res.status(500).json({ message: "Server error" });
  }
};

/* --------------------------------------------------
   STUDENT — REJECT APPLICATION
   POST /api/tuition-posts/reject/:appId
   Student can reject individual admin-approved applications
-------------------------------------------------- */
exports.rejectApplication = async (req, res) => {
  try {
    const { appId } = req.params;
    const { reason } = req.body;

    const app = await TuitionApplication.findById(appId);
    if (!app)
      return res.status(404).json({ message: "Application not found" });

    // Check that application is admin-approved
    if (app.status !== "admin_approved") {
      return res.status(400).json({ 
        message: "Cannot reject application",
        details: `Application cannot be rejected. Status: ${app.status}`
      });
    }

    const post = await TuitionPost.findById(app.postId);
    if (!post)
      return res.status(404).json({ message: "Post not found" });

    if (post.studentId.toString() !== req.user._id.toString())
      return res.status(403).json({ message: "Not authorized" });

    app.status = "student_rejected";
    app.rejectionReason = reason || null;
    await app.save();

    // Create notification for teacher
    const Notification = require("../models/Notification");
    await Notification.create({
      userId: app.teacherId,
      title: "Application Not Selected",
      message: `Your application for "${post.title}" was not selected. ${reason ? `Feedback: ${reason}` : ''}`,
      type: "application_rejected_by_student",
      relatedId: app._id,
      isRead: false
    });

    res.json({
      message: "Application rejected"
    });

  } catch (err) {
    console.error("rejectApplication error:", err);
    res.status(500).json({ message: "Server error" });
  }
};

/* --------------------------------------------------
   CLOSE A POST (Student)
-------------------------------------------------- */
exports.closePost = async (req, res) => {
  try {
    const { postId } = req.params;

    const post = await TuitionPost.findOne({
      _id: postId,
      studentId: req.user._id
    });

    if (!post)
      return res.status(403).json({ message: "Not authorized" });

    post.isClosed = true;
    await post.save();

    res.json({ message: "Post closed" });
  } catch (err) {
    console.error("closePost error:", err);
    res.status(500).json({ message: "Server error" });
  }
};

/* --------------------------------------------------
   GET MY POSTS (Student)
   GET /api/tuition/my-posts
-------------------------------------------------- */
exports.getMyPosts = async (req, res) => {
  try {
    const posts = await TuitionPost.find({ studentId: req.user._id })
      .sort({ createdAt: -1 });

    res.json({ posts });
  } catch (err) {
    console.error("getMyPosts error:", err);
    res.status(500).json({ message: "Server error" });
  }
};

/* --------------------------------------------------
   GET APPROVED TUITIONS (for Teachers to apply)
   GET /api/tuition/approved
-------------------------------------------------- */
exports.getApprovedTuitions = async (req, res) => {
  try {
    const posts = await TuitionPost.find({ 
      status: "approved",
      isClosed: false 
    })
      .populate("studentId", "name email phone")
      .sort({ createdAt: -1 });

    res.json({ posts });
  } catch (err) {
    console.error("getApprovedTuitions error:", err);
    res.status(500).json({ message: "Server error" });
  }
};

/* --------------------------------------------------
   FINAL EXPORT (MUST BE LAST LINE)
-------------------------------------------------- */
module.exports = exports;
