# EduConnect - Comprehensive Project Features & Architecture Overview

## 📋 **Project Summary**
EduConnect is a **Flutter + Node.js + MongoDB** tuition discovery platform connecting students with teachers through location-based search, real-time chat, and rating systems.

---

## 🏗️ **Architecture Overview**

### **Frontend (Flutter / Dart)**
- **State Management**: GetIt (Dependency Injection) + BLoC
- **Networking**: HTTP client + ApiClient wrapper
- **Routing**: GoRouter
- **Security**: flutter_secure_storage for JWT tokens
- **Real-time**: Socket.io for chat
- **Mapping**: flutter_map + latlong2 for OpenStreetMap integration
- **Location**: geolocator for GPS + geospatial queries

### **Backend (Node.js + Express)**
- **Database**: MongoDB + Mongoose ORM
- **Authentication**: JWT tokens (7-day expiry)
- **Email**: Node-mailer for OTP + notifications
- **Geospatial**: MongoDB $nearSphere + $geoNear for location-based search
- **API Docs**: OpenAPI 3.0 + Swagger UI (protected in production)
- **Real-time**: Socket.io for chat messages

### **Database Models**
1. **User** - Core authentication entity
   - email, password (hashed bcrypt), name, phone, role
   - Email verification (OTP-based)
   - Suspension flag for admin control

2. **TeacherProfile** - Teacher-specific details
   - University, department, subjects, classLevels, jobTitle
   - Salary expectations, availability, bio
   - **⭐ Rating fields**: ratingAverage, ratingCount
   - Location (GeoJSON Point for $nearSphere queries)
   - isVerified flag

3. **StudentProfile** - Student-specific details
   - Age, grade, subjects, learning preferences
   - Preferences for tutor type

4. **TuitionPost** - Job postings by students/teachers
   - Subjects, classLevel, description, salary
   - Location, deadline, status
   - Creator reference (userId)

5. **Match** - Match between student & teacher
   - studentId, teacherId, tuitionPostId
   - Status (pending, accepted, rejected, completed)
   - Feedback/rating after completion

6. **Review & Rating** - Student reviews for teachers
   - teacherId, studentId, rating (1-5), review text
   - Timestamp

7. **ChatRoom & ChatMessage** - Real-time messaging
   - Participants (studentId, teacherId)
   - Message list with timestamps

8. **DemoSession** - Demo class booking
   - studentId, teacherId, scheduled time, status

9. **Notification** - Push notifications
   - userId, type (match_found, review_received, etc)
   - Message, read status

---

## ✨ **Existing Implemented Features**

### **1. Authentication System** ✅
- **Login**: Email + password authentication
- **Register**: Name, email, password, role (student/teacher)
- **JWT Tokens**: 7-day expiry, stored securely
- **Serialization**: User data exposed without password

### **2. Location-Based Search** ✅
- **OSM Map Integration**: flutter_map with English locale
- **Haversine Distance**: Client-side distance calculation
- **Radius Filter**: Combined with content filters (subject, class level, city, salary)
- **Nearby Endpoint**: `/api/tuition-posts/nearby` with geospatial MongoDB queries
- **Search Filters**: Subject, class level, city, salary min/max, location radius

### **3. Tuition Posting & Browsing** ✅
- **Create Posts**: Teachers post tuition offerings
- **Browse Listings**: Students search tuitions by filters
- **Detailed View**: Full tuition information + teacher details
- **Search Functionality**: Text search + location-based filtering

### **4. Messaging System** ✅
- **Real-time Chat**: Socket.io for instant messaging
- **ChatRoom Model**: Participants and message history
- **Chat Tab UI**: Display active conversations
- **Message Persistence**: MongoDB storage

### **5. UI/UX Foundation** ✅
- **Dashboard with Tabs**: Home, Search, Chat, Tuition, Profile
- **Sidebar Navigation**: Drawer with tab shortcuts + Help, Contact, Settings, Notifications, Reviews
- **Profile Management**: View/edit user details (name, email, phone)
- **Home Tab**: Featured tuitions + quick action buttons
- **Search Tab**: Full filter controls inline with results + map display

### **6. API Documentation** ✅
- **OpenAPI 3.0 Spec**: `/api/docs` with Swagger UI
- **Production Protection**: Secret key required in production

### **7. Notification System** ✅ (Backend Ready)
- **Model**: Notification collection with userId, type, message, read status
- **Routes**: `/api/notifications` endpoints ready
- **Frontend**: Placeholder in sidebar (coming soon)

### **8. Rating & Reviews** ✅ (Partial)
- **Database**: TeacherProfile has ratingAverage, ratingCount
- **Review Model**: Stores student reviews + ratings (1-5 stars)
- **Frontend**: Sidebar placeholder for Reviews & Ratings (coming soon)

---

## 🆕 **NEW FEATURES TO IMPLEMENT**

### **Phase 1: UI Improvements & NoticeBoard**
1. ✅ **NoticeBoard on HomePage**
   - Display announcements, system notices, admin messages
   - Backend: Notice/Announcement model + admin endpoint
   - Frontend: Widget on home_tab.dart

2. ✅ **Top Teachers Recognition**
   - Show teachers with highest ratings
   - Backend: Query TeacherProfile sorted by ratingAverage
   - Frontend: Widget on home_tab.dart or dedicated page

3. ✅ **NID Card Image Upload**
   - Add `nidCardImageUrl` field to TeacherProfile
   - File picker + upload functionality in profile_tab.dart
   - Verification badge for verified teachers

### **Phase 2: Authentication Flow Improvements**
4. ✅ **Fixed Login Page**
   - Clean UI: Email field + Password field + Login button
   - Proper validation + error messages
   - Loading state handling

5. ✅ **Fixed Signup Page**
   - Fields: Name, Email, Password, Re-enter Password
   - Eye toggle for password visibility
   - Validation: Password match check
   - Role selection (student/teacher)
   - After signup → redirect to OTP verification

6. ✅ **Enhanced OTP Flow**
   - After registration → OTP page automatically shown
   - "Send OTP" button sends code to user email
   - 6-digit OTP input field
   - "Verify OTP" button → success → redirect to dashboard
   - 10-minute OTP expiry with countdown
   - Resend OTP option

---

## 📊 **Feature Working Principles**

### **Location-Based Search Flow**
1. User toggles "Use Current Location" in search filters
2. App requests device location (GPS)
3. User sets radius (km)
4. User sets additional filters (subject, class level, etc.)
5. **Search Tab** calls combined backend endpoint with:
   - `lat`, `lng`, `radiusKm` (location params)
   - `subject`, `classLevel`, `city`, `salaryMin`, `salaryMax` (content params)
6. Backend query merges both criteria
7. Results displayed in search tab with distance + teacher info

### **Rating & Review System**
1. After tuition session, student leaves review
2. Review includes: 1-5 star rating + text comment
3. Backend aggregates into TeacherProfile.ratingAverage + ratingCount
4. Top teachers ranked by ratingAverage
5. Ratings visible in tuition listings + profile

### **Notification System**
1. Backend triggers notifications on events (match found, review received, new tuition post)
2. Stored in Notification collection
3. Users view in Notifications section (sidebar placeholder)
4. Can mark as read

### **Chat System**
1. Student/teacher initiates chat
2. ChatRoom created with both participants
3. Messages sent via Socket.io in real-time
4. Message history persisted in MongoDB
5. Displayed in Chat Tab

---

## 🔌 **Backend API Endpoints (Key Routes)**

### **Auth Routes** (`/api/auth`)
- `POST /register` - Create new user + auto-login
- `POST /login` - Email + password authentication
- `GET /me` - Get current user (protected)
- `POST /request-otp` - Send OTP to email (protected)
- `POST /verify-otp` - Verify OTP code (protected)
- `PUT /update-basic` - Update name + phone (protected)

### **Tuition Routes** (`/api/tuition-posts`)
- `GET /` - List all tuition posts with filters
- `GET /nearby` - Geospatial nearby search with combined filters
- `GET /:id` - Get tuition details
- `POST /` - Create tuition post (protected)
- `PUT /:id` - Update tuition (protected)
- `DELETE /:id` - Delete tuition (protected)

### **Profile Routes** (`/api/profile`)
- `GET /teacher/:userId` - Get teacher profile
- `PUT /teacher` - Update teacher profile (protected)
- `GET /student/:userId` - Get student profile
- `PUT /student` - Update student profile (protected)

### **Chat Routes** (`/api/chat`)
- `POST /room` - Create/get chat room
- `GET /rooms` - List user's chat rooms
- `GET /messages/:roomId` - Get chat history

### **Review Routes** (`/api/reviews`)
- `POST /` - Create review + update teacher rating
- `GET /teacher/:teacherId` - Get reviews for teacher
- `GET /top-rated` - Get top-rated teachers

### **Match Routes** (`/api/matches`)
- `POST /` - Create match
- `GET /` - List user's matches
- `PUT /:id` - Update match status

### **Notification Routes** (`/api/notifications`)
- `GET /` - Get user's notifications
- `PUT /:id` - Mark notification as read
- `DELETE /:id` - Delete notification

---

## 📱 **Frontend Screens/Tabs**

### **Dashboard Tabs**
1. **Home Tab** - Welcome, quick actions, featured tuitions
2. **Search Tab** - Filters (subject, class, city, salary, location, radius) + results with distance
3. **Chat Tab** - List of chat rooms + messages
4. **Tuition Tab** - User's tuition posts (create/manage)
5. **Profile Tab** - User profile edit, verification, settings

### **Sidebar Menu**
- Home, Search, Chat, Tuition, Profile/Admin
- Notifications (placeholder)
- Reviews & Ratings (placeholder)
- Settings (placeholder)
- Help & Support (placeholder)
- Contact (placeholder)
- Logout

### **Auth Pages**
- Login Page (email + password)
- Signup Page (name, email, password, re-password, role)
- OTP Verification Page (6-digit code, resend, countdown)

### **Dedicated Pages**
- Tuition Details Page
- Tuition Create/Edit Page
- Nearby Search Page
- My Applications Page
- Admin Dashboard (placeholder)

---

## 🛠️ **Technology Stack**

| Layer | Technology | Purpose |
|-------|-----------|---------|
| **Frontend** | Flutter 3.9+ | Cross-platform mobile app |
| **State Management** | GetIt + BLoC | Dependency injection + reactive state |
| **HTTP** | http + Dio | API communication |
| **Security** | flutter_secure_storage | JWT token persistence |
| **Real-time** | Socket.io | Chat + notifications |
| **Mapping** | flutter_map + latlong2 | Location display + distance |
| **Backend** | Node.js + Express | REST API server |
| **Database** | MongoDB + Mongoose | Data persistence + geospatial queries |
| **Auth** | JWT + bcrypt | Secure authentication |
| **Email** | Nodemailer | OTP delivery + notifications |
| **API Docs** | OpenAPI 3.0 + Swagger | Interactive API documentation |

---

## 🚀 **Deployment Readiness**

- ✅ API documentation available at `/api/docs`
- ✅ CORS enabled for cross-origin requests
- ✅ Error handling middleware in place
- ✅ JWT token validation on protected routes
- ✅ Geospatial indexes on teacher locations
- ✅ Production-ready Swagger protection
- ✅ Secure password hashing with bcrypt
- ⏳ Pending: NoticeBoard, Top Teachers, NID verification, Enhanced Auth UI

---

## 📝 **Next Implementation Steps**

1. **Add Announcement/Notice Model** (Backend)
2. **Create NoticeBoard Widget** (Frontend)
3. **Implement Top Teachers Query** (Backend)
4. **Create Top Teachers Widget** (Frontend)
5. **Add NID field to TeacherProfile** (Backend)
6. **Create NID Upload UI** (Frontend)
7. **Enhance Login Page** (Frontend)
8. **Enhance Signup Page with Eye Toggle** (Frontend)
9. **Fix OTP Flow with Email Trigger** (Backend + Frontend)
10. **Integrate Auth Pages into Main Navigation**

---

**Status**: Core features implemented. Ready for new feature implementations and auth UI polish.
**Last Updated**: December 3, 2025
