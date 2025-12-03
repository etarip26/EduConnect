# Quick Reference Guide - New Features

## 🚀 Quick Start for Testing

### **1. NoticeBoard** (Home Page)
- **Location**: Home Tab → Top Section (below greeting, above top teachers)
- **Widget**: `NoticeBoard` - Shows announcements with priority badges
- **Backend**: POST `/api/announcements` to create (admin only)
- **Data**: Title, description, type, priority, image, dates

### **2. Top Teachers** (Home Page)
- **Location**: Home Tab → Middle Section (between notice board and featured tuitions)
- **Widget**: `TopTeachers` - Shows 5 highest-rated teachers with stars
- **Endpoint**: GET `/profile/top-teachers?limit=5` (public)
- **Features**: Rank badges, rating display, subjects, university

### **3. NID Card Upload** (Profile Tab - Teachers Only)
- **Location**: Profile Tab → Teacher Profile Section → Bottom (NID Card Verification)
- **Button**: "Upload NID Image" (only in edit mode)
- **Preview**: Shows uploaded image
- **Status**: ✅ Uploaded / ❌ Not Uploaded badge
- **Saves**: Included in profile update

### **4. Enhanced Login**
- **Path**: `/login`
- **Features**: 
  - Email validation
  - Password eye toggle
  - Form validation
  - Error messages

### **5. Enhanced Signup**
- **Path**: `/register`
- **Features**:
  - Name field
  - Email validation
  - Password field with eye toggle
  - Confirm password with eye toggle
  - Password match validation
  - Role selector (Student/Teacher)

### **6. Enhanced OTP Page**
- **Path**: `/otp` (auto-triggered after signup)
- **Features**:
  - Auto-sends OTP on page load
  - 10-minute countdown (MM:SS)
  - 6-digit input field
  - Resend button (appears after countdown)
  - Resets countdown on resend
  - Back to Login button

---

## 📱 User Flows

### **Teacher Registration & Verification**
1. Click "Create Account"
2. Enter: Name, Email, Password, Confirm Password
3. Select "👨‍🏫 Teacher" role
4. Click "Create Account"
5. Auto-redirected to OTP page
6. OTP auto-sent to email
7. Enter 6-digit code
8. Click "Verify OTP"
9. Success → Dashboard

### **Profile - Add NID (Teachers)**
1. Go to Profile Tab
2. Click "Save Changes" to enter edit mode
3. Scroll to "NID Card Verification" section
4. Click "Upload NID Image"
5. Select image from gallery
6. Image preview appears
7. Click "Save Changes" to save profile
8. NID Card status updates

### **Discover Top Teachers**
1. Go to Home Tab
2. See "⭐ Top Rated Teachers" section
3. View ranked teachers (1st, 2nd, 3rd with badges)
4. See rating, subjects, university
5. Click teacher name for profile (coming soon)

### **Check System Announcements**
1. Go to Home Tab
2. See "📋 Notice Board" section
3. View active announcements
4. See priority badges (High, Medium, Low)
5. See announcement types (Notice, Alert, Info, Success)

---

## 🔌 Backend API Quick Reference

### Create Announcement (Admin)
```bash
POST /api/announcements
Authorization: Bearer <token>
{
  "title": "System Maintenance",
  "description": "Server maintenance on Dec 5",
  "type": "alert",
  "priority": "high",
  "imageUrl": "https://...",
  "displayEndDate": "2025-12-05T23:59:59Z"
}
```

### Get Active Announcements
```bash
GET /api/announcements/active
(No auth required)
```

### Get Top Teachers
```bash
GET /profile/top-teachers?limit=5
(No auth required)
Returns: teachers array sorted by rating
```

### Update Teacher Profile with NID
```bash
POST /api/profile/teacher
Authorization: Bearer <token>
{
  "nidCardImageUrl": "https://...",
  "subjects": ["Math", "English"],
  ...
}
```

---

## 🎯 Files Changed Summary

**Backend:**
- ✅ `/models/Announcement.js` - NEW
- ✅ `/controllers/announcementController.js` - NEW
- ✅ `/routes/announcementRoutes.js` - NEW
- ✅ `/models/TeacherProfile.js` - MODIFIED (NID fields)
- ✅ `/controllers/profileController.js` - MODIFIED (getTopTeachers)
- ✅ `/routes/profileRoutes.js` - MODIFIED (top-teachers route)
- ✅ `/server.js` - MODIFIED (added /api/announcements)

**Frontend:**
- ✅ `/ui/dashboard/widgets/notice_board.dart` - NEW
- ✅ `/ui/dashboard/widgets/top_teachers.dart` - NEW
- ✅ `/core/services/announcement_service.dart` - NEW
- ✅ `/core/services/top_teachers_service.dart` - NEW
- ✅ `/core/services/service_locator.dart` - MODIFIED (registered services)
- ✅ `/core/services/profile_service.dart` - MODIFIED (NID update)
- ✅ `/ui/dashboard/tab/home_tab.dart` - MODIFIED (widgets integrated)
- ✅ `/ui/dashboard/tab/profile_tab.dart` - MODIFIED (NID section)
- ✅ `/ui/auth/login_page.dart` - MODIFIED (validation + UI)
- ✅ `/ui/auth/register_page.dart` - MODIFIED (password confirm + toggles)
- ✅ `/ui/auth/otp_page.dart` - MODIFIED (auto-trigger + countdown)

---

## ✅ Testing Checklist

- [ ] **NoticeBoard**: See announcements on home page
- [ ] **Top Teachers**: See ranked teachers on home page  
- [ ] **NID Upload**: Upload image in profile (teacher account)
- [ ] **Login**: Email validation works, password toggle works
- [ ] **Signup**: Password confirmation, eye toggles, validation works
- [ ] **OTP**: Auto-sends, countdown displays, resend works
- [ ] **Flutter Analyze**: 0 issues (run `flutter analyze`)

---

## 🐛 Debugging Tips

### If NoticeBoard doesn't show:
1. Check backend: `GET /api/announcements/active`
2. Create announcement: `POST /api/announcements`
3. Verify displayStartDate is <= now

### If Top Teachers doesn't show:
1. Check teachers in database have ratings
2. Verify: `GET /profile/top-teachers`
3. Teachers must have isVerified=true

### If OTP doesn't send:
1. Check email config in backend
2. Verify Nodemailer setup
3. Check logs for email errors

### If NID upload fails:
1. Ensure image_picker plugin in pubspec.yaml
2. Check TeacherProfile model has nidCardImageUrl field
3. Verify profile endpoint accepts nidCardImageUrl

---

## 📞 Support

For issues or questions about new features, check:
- `/IMPLEMENTATION_SUMMARY.md` - Full technical details
- `/PROJECT_FEATURES_OVERVIEW.md` - Overall architecture
- Backend routes in `/routes/*`
- Frontend widgets in `/ui/dashboard/widgets/`

