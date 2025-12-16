# EduConnect End-to-End Test - API Manual Testing Guide

## Backend Status ✅
- **Server:** http://localhost:5000
- **Database:** MongoDB Connected
- **Status:** Running and ready for testing

## Test Scenario: Complete User Flow

### Tools Needed:
- **Postman** (Download: https://www.postman.com/downloads/)
- **OR curl commands** in PowerShell
- **Browser** for checking responses

---

## Phase 1: Admin Login & Get Auth Token

### API Endpoint
```
POST http://localhost:5000/api/auth/login
```

### Request Body (JSON):
```json
{
  "email": "admin@example.com",
  "password": "your_admin_password"
}
```

### Expected Response:
```json
{
  "success": true,
  "user": {
    "id": "admin_id",
    "name": "Admin User",
    "email": "admin@example.com",
    "role": "admin"
  },
  "token": "eyJhbGciOiJIUzI1NiIs..."
}
```

### Next Step:
**Save the token** from the response - you'll need it for all subsequent admin requests.
In Postman: Set header `Authorization: Bearer <token>`

---

## Phase 2: Create Student Account

### API Endpoint
```
POST http://localhost:5000/api/auth/signup
```

### Request Body:
```json
{
  "name": "Test Student Dhaka",
  "email": "student@university.dhaka.edu",
  "phone": "+8801700000001",
  "password": "TestPass123!",
  "role": "student"
}
```

### Expected Response:
```json
{
  "success": true,
  "user": {
    "id": "student_id",
    "email": "student@university.dhaka.edu",
    "role": "student",
    "isProfileApproved": false
  },
  "token": "student_token_here"
}
```

### Important:
- **Save the student token** - you'll use it to create student profile
- Note the `isProfileApproved: false` - profile needs admin approval

---

## Phase 3: Student Completes Profile

### API Endpoint
```
POST http://localhost:5000/api/profile/student
```

### Headers:
```
Authorization: Bearer <student_token>
Content-Type: application/json
```

### Request Body:
```json
{
  "classLevel": "Class 10",
  "school": "University of Dhaka",
  "guardianName": "Parent Name",
  "guardianPhone": "+8801600000001",
  "guardianNidNumber": "1234567890123",
  "city": "Dhaka",
  "area": "Gulshan",
  "location": {
    "lat": 23.8103,
    "lng": 90.4125
  }
}
```

### Expected Response:
```json
{
  "success": true,
  "message": "Profile created successfully",
  "profile": {
    "_id": "profile_id",
    "userId": "student_id",
    "classLevel": "Class 10",
    "school": "University of Dhaka",
    ...
  }
}
```

---

## Phase 4: Admin Approves Student Profile

### Check Pending Profiles
```
GET http://localhost:5000/api/admin/users?filter=pending
```
**Headers:** `Authorization: Bearer <admin_token>`

### Approve Profile
```
POST http://localhost:5000/api/admin/approve-profile
```

### Request Body:
```json
{
  "userId": "student_id",
  "isApproved": true
}
```

### Expected Response:
```json
{
  "success": true,
  "message": "Profile approved"
}
```

---

## Phase 5: Create Teacher Account

### API Endpoint
```
POST http://localhost:5000/api/auth/signup
```

### Request Body:
```json
{
  "name": "Test Teacher Expert",
  "email": "teacher@university.dhaka.edu",
  "phone": "+8801700000002",
  "password": "TestPass123!",
  "role": "teacher"
}
```

### Save the teacher token for later use

---

## Phase 6: Teacher Completes Profile

### API Endpoint
```
POST http://localhost:5000/api/profile/teacher
```

### Headers:
```
Authorization: Bearer <teacher_token>
```

### Request Body:
```json
{
  "subjects": ["Mathematics", "Physics", "Chemistry"],
  "classLevels": ["Class 8", "Class 9", "Class 10"],
  "university": "University of Dhaka",
  "department": "Computer Science",
  "jobTitle": "Senior Tutor",
  "salaryMin": 500,
  "salaryMax": 2000,
  "availabilityDays": ["Mon", "Tue", "Wed", "Thu", "Fri"],
  "availabilityTime": "3PM-8PM",
  "about": "Experienced in teaching science subjects",
  "nid": null
}
```

---

## Phase 7: Admin Approves Teacher Profile

```
POST http://localhost:5000/api/admin/approve-profile
```

### Request Body:
```json
{
  "userId": "teacher_id",
  "isApproved": true
}
```

---

## Phase 8: Student Posts Tuition

### API Endpoint
```
POST http://localhost:5000/api/tuition/posts
```

### Headers:
```
Authorization: Bearer <student_token>
Content-Type: application/json
```

### Request Body:
```json
{
  "title": "Mathematics Class 10 Tuition",
  "details": "Need experienced tutor for Class 10 Math (Geometry & Algebra focus)",
  "classLevel": "Class 10",
  "subjects": ["Mathematics"],
  "salaryMin": 500,
  "salaryMax": 1500,
  "location": {
    "city": "Dhaka",
    "area": "Gulshan",
    "lat": 23.8103,
    "lng": 90.4125
  }
}
```

### Expected Response:
```json
{
  "success": true,
  "message": "Tuition post created successfully",
  "tuitionPost": {
    "_id": "tuition_id",
    "posterId": "student_id",
    "status": "pending",
    ...
  }
}
```

### Important:
- Status is `pending` - needs admin approval before teacher can see it
- **Save the tuition_id** for next step

---

## Phase 9: Admin Approves Tuition Post

### Get Pending Tuitions
```
GET http://localhost:5000/api/admin/tuitions?filter=pending
```

### Approve Tuition
```
POST http://localhost:5000/api/admin/tuition/approve
```

### Request Body:
```json
{
  "tuitionId": "tuition_id",
  "isApproved": true
}
```

---

## Phase 10: Teacher Applies to Tuition

### Get Approved Tuitions
```
GET http://localhost:5000/api/tuition/posts
```
**Headers:** `Authorization: Bearer <teacher_token>`

### Apply to Tuition
```
POST http://localhost:5000/api/tuition/apply
```

### Headers:
```
Authorization: Bearer <teacher_token>
```

### Request Body:
```json
{
  "tuitionPostId": "tuition_id",
  "applicationMessage": "I'm interested in this position and have experience teaching mathematics"
}
```

### Expected Response:
```json
{
  "success": true,
  "message": "Application submitted successfully",
  "application": {
    "_id": "application_id",
    "tuitionPostId": "tuition_id",
    "applicantId": "teacher_id",
    "status": "pending"
  }
}
```

---

## Phase 11: Admin Approves Teacher Application

### Get Pending Applications
```
GET http://localhost:5000/api/admin/tuition-applications?filter=pending
```

### Approve Application
```
POST http://localhost:5000/api/admin/tuition-application/approve
```

### Request Body:
```json
{
  "applicationId": "application_id",
  "isApproved": true
}
```

---

## Phase 12: Admin Sends Notification

### Send to Student
```
POST http://localhost:5000/api/notifications/send
```

### Request Body:
```json
{
  "userId": "student_id",
  "title": "Tuition Match",
  "message": "Your tuition posting has been matched with qualified teacher: Test Teacher Expert",
  "type": "match"
}
```

### Send to Teacher
```
POST http://localhost:5000/api/notifications/send
```

### Request Body:
```json
{
  "userId": "teacher_id",
  "title": "Tuition Match",
  "message": "You have been matched with student for Mathematics tuition",
  "type": "match"
}
```

---

## Phase 13: Admin Sends Direct Messages

### Send to Student
```
POST http://localhost:5000/api/admin/direct-message
```

### Request Body:
```json
{
  "recipientId": "student_id",
  "message": "Your tuition posting has been matched with a qualified teacher. You can now communicate with the teacher."
}
```

### Send to Teacher
```
POST http://localhost:5000/api/admin/direct-message
```

### Request Body:
```json
{
  "recipientId": "teacher_id",
  "message": "You have been matched with a student. You can now view the student details and chat."
}
```

---

## Phase 14: Student Views Approved Teachers

### Get My Tuition
```
GET http://localhost:5000/api/tuition/posts/my
```
**Headers:** `Authorization: Bearer <student_token>`

### Get Approved Teachers for Tuition
```
GET http://localhost:5000/api/tuition/posts/{tuition_id}/approved-applications
```

### Expected Response:
```json
{
  "success": true,
  "approvedTeachers": [
    {
      "_id": "teacher_id",
      "name": "Test Teacher Expert",
      "subjects": ["Mathematics", "Physics", "Chemistry"],
      "jobTitle": "Senior Tutor",
      "status": "approved"
    }
  ]
}
```

---

## Phase 15: Student Approves Teacher

### Approve Match
```
POST http://localhost:5000/api/match/approve
```

### Headers:
```
Authorization: Bearer <student_token>
```

### Request Body:
```json
{
  "teacherId": "teacher_id",
  "tuitionPostId": "tuition_id"
}
```

---

## Phase 16: Teacher Views Student Info

### Get My Matches
```
GET http://localhost:5000/api/match/my-matches
```
**Headers:** `Authorization: Bearer <teacher_token>`

### Expected Response:
```json
{
  "success": true,
  "matches": [
    {
      "tuitionId": "tuition_id",
      "studentId": "student_id",
      "studentName": "Test Student Dhaka",
      "institution": "University of Dhaka",
      "parentPhone": "+8801600000001",
      "status": "active"
    }
  ]
}
```

---

## Phase 17: Student-Teacher Chat

### Start Chat (Student)
```
POST http://localhost:5000/api/chat/create-or-get
```

### Headers:
```
Authorization: Bearer <student_token>
```

### Request Body:
```json
{
  "participantId": "teacher_id"
}
```

### Send Message
```
POST http://localhost:5000/api/chat/send-message
```

### Headers:
```
Authorization: Bearer <student_token>
```

### Request Body:
```json
{
  "roomId": "chat_room_id",
  "message": "Hello! I'm your student. When would you like to start our first session?"
}
```

### Expected Response:
```json
{
  "success": true,
  "message": {
    "_id": "message_id",
    "senderId": "student_id",
    "content": "Hello! I'm your student...",
    "timestamp": "2025-12-17T...",
    "read": false
  }
}
```

---

## Phase 18: Teacher Responds to Chat

### Get Chat Rooms
```
GET http://localhost:5000/api/chat/rooms/my
```
**Headers:** `Authorization: Bearer <teacher_token>`

### Get Chat Messages
```
GET http://localhost:5000/api/chat/messages/{room_id}
```

### Send Response
```
POST http://localhost:5000/api/chat/send-message
```

### Headers:
```
Authorization: Bearer <teacher_token>
```

### Request Body:
```json
{
  "roomId": "chat_room_id",
  "message": "Hi! I'm your assigned tutor. I'm available on Monday and Wednesday after 4 PM. Looking forward to working with you!"
}
```

---

## Quick PowerShell Test Command

```powershell
# Test backend health
$response = Invoke-WebRequest -Uri "http://localhost:5000/api/health" -TimeoutSec 5
Write-Host "Backend Status: $($response.StatusCode)"

# Test login
$loginBody = @{
    email = "admin@example.com"
    password = "your_password"
} | ConvertTo-Json

$loginResponse = Invoke-WebRequest -Uri "http://localhost:5000/api/auth/login" `
    -Method POST `
    -Headers @{"Content-Type"="application/json"} `
    -Body $loginBody

$token = ($loginResponse.Content | ConvertFrom-Json).token
Write-Host "Admin Token: $token"
```

---

## Success Criteria Checklist

✅ Student account created  
✅ Student profile completed and approved by admin  
✅ Teacher account created  
✅ Teacher profile completed and approved by admin  
✅ Student posted tuition successfully  
✅ Admin approved tuition post  
✅ Teacher applied to tuition  
✅ Admin approved teacher application  
✅ Notifications sent to both users  
✅ Direct messages sent to both users  
✅ Student can see approved teachers (1-2)  
✅ Student approves teacher match  
✅ Teacher can see student basic info  
✅ Student and teacher can chat  
✅ Messages appear in both directions  

---

## Troubleshooting

| Issue | Solution |
|-------|----------|
| "Invalid server response" | Check backend is running: `node server.js` |
| "Unauthorized" | Verify token in Authorization header |
| "User not found" | Check user ID in request body |
| "Profile not approved" | Admin must approve profile before posting tuition |
| "No tuitions available" | Check tuition status is "approved" |
| "Cannot apply to tuition" | Check your profile is approved |

---

## Reference URLs

**Admin Dashboard:** (Once Flutter app works)  
**Backend Health:** http://localhost:5000/api/health  
**API Documentation:** Check backend/docs/openapi.yaml  

