# 🎓 EduConnect

A comprehensive **tuition marketplace platform** connecting students and teachers seamlessly. Built with **Flutter** (frontend) and **Node.js + Express** (backend), EduConnect enables efficient tuition discovery, matching, communication, and management.

![Flutter](https://img.shields.io/badge/Flutter-3.9+-blue?logo=flutter)
![Dart](https://img.shields.io/badge/Dart-3.0+-blue?logo=dart)
![Node.js](https://img.shields.io/badge/Node.js-18+-green?logo=node.js)
![License](https://img.shields.io/badge/License-MIT-green)

---

## ✨ Features

### 🎯 Core Functionality
- **User Authentication** — Secure login/signup with email OTP verification
- **Profile Management** — Editable profiles with profile image upload/crop, role-based fields
- **Tuition Posting** — Teachers create tuition posts; students browse and apply
- **Matching System** — Intelligent student-teacher matching based on requirements
- **Chat System** — Real-time messaging between matched users (WebSocket support)
- **Notifications** — Push notifications for applications, matches, and updates
- **Search & Filter** — Location-based and subject-based search
- **Ratings & Reviews** — User rating system with feedback
- **Top Teachers** — Recognition board for highly-rated teachers
- **Announcements** — System announcements and alerts

### 🎨 UI Features
- **Profile Avatars** — Reusable avatar widget with local image persistence and fade animations
- **Overflow Menu** — 3-dot header menu for Edit & Logout
- **Image Cropping** — Built-in image cropper for avatar and NID uploads
- **Responsive Design** — Works on desktop, web, and mobile
- **Dark Mode Support** — (Ready for implementation)

### 🔒 Security
- **JWT Authentication** — Token-based secure API access
- **Password Hashing** — bcrypt for secure password storage
- **Rate Limiting** — Middleware to prevent abuse
- **Email Verification** — OTP-based email verification
- **Admin Controls** — Admin panel for user management and suspension

---

## 🏗️ Project Structure

### Frontend (Flutter/Dart)
```
lib/
├── main.dart                          # App entry point
├── src/
│   ├── config/                        # Configuration files
│   │   └── api_paths.dart             # API endpoint constants
│   ├── core/
│   │   ├── network/
│   │   │   └── api_client.dart        # HTTP client with auth
│   │   ├── services/
│   │   │   ├── auth_service.dart      # Authentication
│   │   │   ├── profile_service.dart   # Profile management
│   │   │   ├── tuition_service.dart   # Tuition operations
│   │   │   ├── chat_service.dart      # Chat management
│   │   │   ├── profile_image_service.dart  # Local image storage
│   │   │   └── storage_service.dart   # Local preferences
│   │   ├── widgets/
│   │   │   └── app_avatar.dart        # Reusable avatar widget
│   │   ├── models/
│   │   │   └── user.dart              # User data model
│   │   └── utils/
│   │       └── snackbar_utils.dart    # UI utilities
│   └── ui/
│       ├── auth/
│       │   ├── login_page.dart
│       │   ├── register_page.dart
│       │   └── otp_page.dart
│       ├── dashboard/
│       │   ├── app_sidebar.dart
│       │   └── tab/
│       │       ├── home_tab.dart
│       │       ├── search_tab.dart
│       │       ├── chat_tab.dart
│       │       ├── tuition_tab.dart
│       │       └── profile_tab.dart
│       ├── tuition/
│       ├── chat/
│       └── search/
```

### Backend (Node.js/Express)
```
backend/
├── server.js                          # Express app setup
├── config/
│   ├── db.js                          # MongoDB connection
│   ├── logger.js                      # Logging utility
│   └── email.js                       # Email configuration
├── models/
│   ├── User.js
│   ├── StudentProfile.js
│   ├── TeacherProfile.js
│   ├── TuitionPost.js
│   ├── Match.js
│   ├── ChatRoom.js
│   ├── ChatMessage.js
│   ├── Review.js
│   ├── Rating.js
│   ├── Notification.js
│   ├── DemoSession.js
│   └── Announcement.js
├── controllers/
│   ├── authController.js
│   ├── profileController.js
│   ├── tuitionController.js
│   ├── matchController.js
│   ├── chatController.js
│   ├── reviewController.js
│   ├── searchController.js
│   ├── notificationController.js
│   ├── demoController.js
│   ├── adminController.js
│   └── announcementController.js
├── routes/
│   ├── authRoutes.js
│   ├── profileRoutes.js
│   ├── tuitionRoutes.js
│   ├── matchRoutes.js
│   ├── chatRoutes.js
│   ├── reviewRoutes.js
│   ├── searchRoutes.js
│   ├── notificationRoutes.js
│   ├── demoRoutes.js
│   ├── adminRoutes.js
│   └── announcementRoutes.js
├── middleware/
│   ├── authMiddleware.js
│   ├── errorMiddleware.js
│   ├── validationMiddleware.js
│   ├── rateLimitMiddleware.js
│   ├── parentControlMiddleware.js
│   ├── contentModerationMiddleware.js
│   └── verificationMiddleware.js
├── sockets/
│   └── chatSocket.js                 # WebSocket chat implementation
├── tests/
│   └── backendFlow.test.js
└── docs/
    └── openapi.yaml                  # API documentation
```

---

## 🚀 Getting Started

### Prerequisites
- **Flutter** 3.9+ with Dart 3.0+
- **Node.js** 18+ and npm
- **MongoDB** (local or cloud)
- **Git**

### Frontend Setup

1. **Clone repository**
   ```bash
   git clone https://github.com/yourusername/EduConnect.git
   cd EduConnect
   ```

2. **Install Flutter dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure API endpoint** (in `lib/src/config/env.dart`)
   ```dart
   class Env {
     static const String apiBase = 'http://localhost:5000/api';
   }
   ```

4. **Run the app**
   ```bash
   flutter run
   ```

### Backend Setup

1. **Navigate to backend**
   ```bash
   cd backend
   ```

2. **Install dependencies**
   ```bash
   npm install
   ```

3. **Configure environment variables** (create `.env`)
   ```env
   PORT=5000
   MONGODB_URI=mongodb://localhost:27017/educonnect
   JWT_SECRET=your_jwt_secret_key
   EMAIL_USER=your_email@gmail.com
   EMAIL_PASS=your_app_password
   NODE_ENV=development
   ```

4. **Start the server**
   ```bash
   npm start
   ```

---

## 📱 Screenshots

### Authentication
- ✅ Login with email validation and password eye-toggle
- ✅ Signup with password confirmation and role selection
- ✅ OTP verification with 10-minute countdown and auto-trigger

### Dashboard
- ✅ Home tab with greeting, announcements, top teachers
- ✅ Search tab with filters and teacher discovery
- ✅ Chat tab with real-time messaging
- ✅ Profile tab with editable info and avatar management
- ✅ 3-dot header menu for Edit/Logout

### Profile Management
- ✅ Edit name inline in header
- ✅ Upload/crop/remove profile image with smooth fade animations
- ✅ NID card image upload for teacher verification
- ✅ Profile image synced across all avatar widgets

---

## 🔌 API Endpoints

### Authentication
- `POST /api/auth/login` — User login
- `POST /api/auth/register` — User registration
- `POST /api/auth/request-otp` — Request OTP
- `POST /api/auth/verify-otp` — Verify OTP
- `GET /api/auth/me` — Get current user
- `PUT /api/auth/update-basic` — Update name & phone

### Profile
- `GET /api/profile/me` — Get user profile
- `POST /api/profile/student` — Create/update student profile
- `POST /api/profile/teacher` — Create/update teacher profile
- `GET /api/profile/top-teachers` — Get top-rated teachers

### Tuition
- `GET /api/tuition-posts` — List tuition posts
- `POST /api/tuition-posts` — Create tuition post
- `POST /api/tuition-posts/apply/:id` — Apply to tuition
- `GET /api/tuition-posts/nearby` — Find nearby tuitions

### Chat
- `GET /api/chat/rooms/my` — Get user chat rooms
- `GET /api/chat/rooms/:id/messages` — Get messages in room
- `POST /api/chat/rooms/:id/messages` — Send message

### Search
- `GET /api/search/teachers` — Search teachers
- `GET /api/search/students` — Search students

### Announcements
- `GET /api/announcements/active` — Get active announcements
- `POST /api/announcements` — Create announcement (admin)
- `PUT /api/announcements/:id` — Update announcement (admin)
- `DELETE /api/announcements/:id` — Delete announcement (admin)

See [API Documentation](backend/docs/openapi.yaml) for complete details.

---

## 🛠️ Tech Stack

### Frontend
- **Flutter** 3.9+ — Cross-platform UI framework
- **Dart** 3.0+ — Programming language
- **Provider / GetIt** — State management & DI
- **http / Dio** — HTTP client
- **image_picker** — Image selection
- **image_cropper** — Image cropping
- **flutter_map** — Map integration
- **socket.io** — Real-time communication
- **shared_preferences** — Local storage

### Backend
- **Node.js** 18+ — Runtime
- **Express** 4+ — Web framework
- **MongoDB** — Database
- **Mongoose** — ODM
- **JWT** — Authentication
- **bcrypt** — Password hashing
- **nodemailer** — Email service
- **socket.io** — WebSocket server

---

## 📝 Documentation

- [PROJECT_FEATURES_OVERVIEW.md](PROJECT_FEATURES_OVERVIEW.md) — Complete feature list and architecture
- [QUICK_REFERENCE.md](QUICK_REFERENCE.md) — Quick start guide and API examples
- [IMPLEMENTATION_SUMMARY.md](IMPLEMENTATION_SUMMARY.md) — Detailed implementation notes
- [COMPLETION_REPORT.md](COMPLETION_REPORT.md) — Feature completion and testing status

---

## 🤝 Contributing

Contributions are welcome! Please follow these steps:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/YourFeature`)
3. Commit your changes (`git commit -m 'Add YourFeature'`)
4. Push to the branch (`git push origin feature/YourFeature`)
5. Open a Pull Request

---

## 📜 License

This project is licensed under the MIT License — see [LICENSE](LICENSE) file for details.

---

## 👥 Authors

- **Development Team** — EduConnect Contributors

---

## 🐛 Reporting Issues

Found a bug or have a feature request? Please open an [Issue](https://github.com/yourusername/EduConnect/issues).

---

## 📞 Support

For questions or support, please contact us at [support@educonnect.com](mailto:support@educonnect.com).

---

## 🌟 Acknowledgments

- Flutter community for excellent documentation
- Socket.io for real-time communication
- MongoDB for flexible data storage

---

**EduConnect** — Connecting Education, One Match at a Time! 🎓
