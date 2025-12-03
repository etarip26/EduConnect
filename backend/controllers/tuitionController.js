const TuitionPost = require("../models/TuitionPost");
const TuitionApplication = require("../models/TuitionApplication");
const Match = require("../models/Match");

/* --------------------------------------------------
   CREATE TUITION POST (Student)
-------------------------------------------------- */
exports.createPost = async (req, res) => {
  try {
    const {
      title,
      details,
      classLevel,
      subjects,
      salaryMin,
      salaryMax,
      location
    } = req.body;

    if (!title || !classLevel) {
      return res.status(400).json({ message: "Missing fields" });
    }

    const post = await TuitionPost.create({
      studentId: req.user._id,
      title,
      details,
      classLevel,
      subjects,
      salaryMin,
      salaryMax,
      location: location
        ? {
            type: "Point",
            coordinates: [location.lng, location.lat],
            city: location.city || "",
            area: location.area || ""
          }
        : undefined
    });

    res.status(201).json({ post });
  } catch (err) {
    console.error("createPost error:", err);
    res.status(500).json({ message: "Server error" });
  }
};

/* --------------------------------------------------
   GET APPROVED TUITION POSTS (Public)
-------------------------------------------------- */
exports.getAllPosts = async (req, res) => {
  try {
    const posts = await TuitionPost.find({ isClosed: false })
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
-------------------------------------------------- */
exports.applyToPost = async (req, res) => {
  try {
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
      teacherId: req.user._id
    });

    res.json({ message: "Applied successfully", application: app });
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
-------------------------------------------------- */
exports.getApplicationsForPost = async (req, res) => {
  try {
    const { postId } = req.params;

    const post = await TuitionPost.findOne({
      _id: postId,
      studentId: req.user._id
    });

    if (!post)
      return res.status(403).json({ message: "Not authorized" });

    const apps = await TuitionApplication.find({ postId })
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
-------------------------------------------------- */
exports.acceptApplication = async (req, res) => {
  try {
    const { appId } = req.params;

    const app = await TuitionApplication.findById(appId);
    if (!app)
      return res.status(404).json({ message: "Application not found" });

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
   FINAL EXPORT (MUST BE LAST LINE)
-------------------------------------------------- */
module.exports = exports;
