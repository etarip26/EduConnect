# Complete End-to-End Test Workflow

## System Overview
This test validates the complete data flow across three user types: Admin, Student, and Teacher.

---

## Phase 1: Setup & Admin Dashboard Verification

### 1.1 Admin Login & Dashboard
**Steps:**
1. Launch the app and login with admin credentials
   - Email: `admin@example.com`
   - Password: (your admin password)
2. Navigate to Admin Dashboard (Admin Tab)
3. **Verify:**
   - Dashboard loads without errors (check for error messages at bottom)
   - Can see Platform Overview card
   - Can see stats cards (Active Tuitions, Pending Approvals, Demo Requests)
   - Can see Users, Teachers, Tuitions sections
   - All sections load data without crashing

**Expected Result:** ✅ Admin dashboard displays all data correctly, no cascading errors

---

## Phase 2: Student Registration & Profile Approval

### 2.1 Create Student Account
**Steps:**
1. Sign out from admin
2. Click "Sign Up" or "Don't have an account?" link
3. Select **Student** as user type
4. Fill form:
   - Name: `Test Student Dhaka`
   - Email: `student@university.dhaka.edu` (must use valid email format)
   - Phone: `+8801700000001`
   - Password: `TestPass123!`
5. Verify email via OTP if required
6. Complete signup

**Expected Result:** ✅ Student account created and logged in

### 2.2 Student Profile Completion
**Steps:**
1. Go to Profile Tab
2. Click Edit Profile button
3. Fill Student-specific fields:
   - **Class Level:** Class 10
   - **School:** University of Dhaka (or any school)
   - **City:** Dhaka
   - **Area:** Gulshan
   - **Guardian Name:** Parent Name
   - **Guardian Phone:** `+8801600000001`
   - **Guardian NID:** `1234567890123`
   - **Location Coordinates:** (auto-filled or manual)
     - Latitude: 23.8103
     - Longitude: 90.4125
4. Upload profile picture (optional)
5. Click Save Profile
6. **Verify:** Profile shows status (should show "Pending Approval" or similar)

**Expected Result:** ✅ Student profile submitted for admin approval

### 2.3 Logout & Return Admin - Approve Student Profile
**Steps:**
1. Logout from student account
2. Login as admin
3. Go to Admin Dashboard > Users/Profiles section
4. Find "Test Student Dhaka" in pending approvals
5. Click Approve button
6. **Verify:** Status changes to "Approved"

**Expected Result:** ✅ Student profile approved by admin

---

## Phase 3: Teacher Registration & Profile Approval

### 3.1 Create Teacher Account
**Steps:**
1. Logout from admin
2. Click "Sign Up"
3. Select **Teacher** as user type
4. Fill form:
   - Name: `Test Teacher Expert`
   - Email: `teacher@university.dhaka.edu`
   - Phone: `+8801700000002`
   - Password: `TestPass123!`
5. Verify email via OTP if required
6. Complete signup

**Expected Result:** ✅ Teacher account created and logged in

### 3.2 Teacher Profile Completion
**Steps:**
1. Go to Profile Tab
2. Click Edit Profile button
3. Fill Teacher-specific fields:
   - **Subjects:** Mathematics, Physics, Chemistry (comma-separated)
   - **Class Levels:** Class 8-10
   - **University:** University of Dhaka
   - **Department:** Computer Science
   - **Job Title:** Senior Tutor
   - **Min Salary:** 500
   - **Max Salary:** 2000
   - **Availability Days:** Mon, Tue, Wed, Thu, Fri (comma-separated)
   - **Availability Time:** 3PM-8PM
   - **About:** "Experienced in teaching science subjects"
   - **NID:** (Optional - leave blank)
4. Upload profile picture (optional)
5. Click Save Profile

**Expected Result:** ✅ Teacher profile submitted for admin approval

### 3.3 Admin Approves Teacher Profile
**Steps:**
1. Logout from teacher
2. Login as admin
3. Go to Admin Dashboard > Teachers/Profiles section
4. Find "Test Teacher Expert" in pending approvals
5. Click Approve button
6. **Verify:** Status changes to "Approved"

**Expected Result:** ✅ Teacher profile approved by admin

---

## Phase 4: Student Posts Tuition

### 4.1 Student Login & Post Tuition
**Steps:**
1. Logout from admin
2. Login as student (`student@university.dhaka.edu`)
3. Go to **Home Tab** → Click "Post Tuition" quick action button
   - OR go to **Tuition Tab** → Click "Post a New Tuition" button
   - OR go to **Profile Tab** → Click "Post" button in "My Tuition Posts" section
4. Fill Tuition Form:
   - **Title:** Mathematics Class 10 Tuition
   - **Details:** Need experienced tutor for Class 10 Math (Geometry & Algebra focus)
   - **Class Level:** Class 10
   - **Subjects:** Mathematics
   - **Min Salary:** 500
   - **Max Salary:** 1500
   - **City:** Dhaka
   - **Area:** Gulshan
   - **Coordinates:** 23.8103, 90.4125
5. Click "Create Tuition" button
6. **Verify:** Success message appears

**Expected Result:** ✅ Tuition post created and submitted for approval

---

## Phase 5: Admin Approves Tuition Post

### 5.1 Admin Reviews & Approves Tuition
**Steps:**
1. Logout from student
2. Login as admin
3. Go to Admin Dashboard > Tuitions section or "Pending Approvals"
4. Find "Mathematics Class 10 Tuition" in pending tuitions
5. Click Approve button
6. **Verify:** Status changes to "Approved"

**Expected Result:** ✅ Tuition post now visible to all teachers

---

## Phase 6: Teacher Applies to Tuition

### 6.1 Teacher Searches & Applies
**Steps:**
1. Logout from admin
2. Login as teacher (`teacher@university.dhaka.edu`)
3. Go to **Search Tab** or **Tuition Tab**
4. Find "Mathematics Class 10 Tuition" posted by the student
5. Click on the tuition card → View Details
6. Click **"Apply Now"** button
7. (Optional) Add application message: "I'm interested in this position"
8. Click Submit Application
9. **Verify:** Success message shows

**Expected Result:** ✅ Teacher application submitted for admin approval

---

## Phase 7: Admin Approves Teacher Application

### 7.1 Admin Reviews Applications
**Steps:**
1. Logout from teacher
2. Login as admin
3. Go to Admin Dashboard > Applications/Pending Approvals section
4. Find the teacher application from "Test Teacher Expert" for the Math tuition
5. **Review:** Can see applicant name, qualifications, subjects
6. Click **Approve** button
7. **Verify:** Status changes to "Approved"
8. (Optional) Click second teacher to test "max 2 teachers" limit - reject or leave pending

**Expected Result:** ✅ Teacher application approved; match created

---

## Phase 8: Admin Sends Notifications & Messages

### 8.1 Admin Sends Notification
**Steps:**
1. In Admin Dashboard
2. Find the matched tuition or recent approvals
3. Look for "Send Notification" or messaging feature
4. Send notification to student about teacher match
5. Send notification to teacher about student match
6. **Verify:** Notifications appear in both accounts' notification centers

**Expected Result:** ✅ Both student and teacher receive notifications

### 8.2 Admin Sends Direct Messages
**Steps:**
1. Go to Admin Dashboard > Users/Direct Messaging section
2. Select student account ("Test Student Dhaka")
3. Send message: "Your tuition posting has been matched with a qualified teacher"
4. Click Send
5. Select teacher account ("Test Teacher Expert")
6. Send message: "You have been matched with a student for Mathematics tuition"
7. Click Send
8. **Verify:** Messages sent successfully

**Expected Result:** ✅ One-way messages sent from admin to both users

---

## Phase 9: Student Views Approved Teachers & Approves Match

### 9.1 Student Reviews Matched Teachers
**Steps:**
1. Logout from admin
2. Login as student
3. Go to **Profile Tab** > My Tuition Posts section
4. Click on "Mathematics Class 10 Tuition"
5. **Verify:** Can see approved teachers list (should show 1-2 teachers max)
6. View teacher info:
   - Name: Test Teacher Expert
   - Subjects: Mathematics, Physics, Chemistry
   - Experience/qualifications
7. See option to "Approve" or "Chat" with teacher

**Expected Result:** ✅ Student can see approved teachers for their tuition

### 9.2 Student Approves Teacher
**Steps:**
1. Click "Approve" button next to teacher name
2. **Verify:** Teacher status changes to "Approved/Connected"

**Expected Result:** ✅ Match confirmed from student side

---

## Phase 10: Teacher Views Student Info & Initiates Chat

### 10.1 Teacher Views Student Information
**Steps:**
1. Logout from student
2. Login as teacher
3. Go to **Applications/My Matches** section
4. Find the matched tuition from "Test Student Dhaka"
5. **Verify:** Can see student basic info:
   - Name: Test Student Dhaka
   - Institution: University of Dhaka
   - Parent Contact: +8801600000001
6. See option to "Chat" with student

**Expected Result:** ✅ Teacher can see student details

### 10.2 Teacher Initiates Chat
**Steps:**
1. Click "Chat with Student" or messaging icon
2. Enter message: "Hello! I'm your assigned tutor. When would you like to start our first session?"
3. Click Send
4. **Verify:** Message appears in chat

**Expected Result:** ✅ Teacher sends message to student

---

## Phase 11: Student Receives & Responds to Chat

### 11.1 Student Receives Message
**Steps:**
1. Logout from teacher
2. Login as student
3. Go to **Chat/Messages section**
4. **Verify:** Can see conversation from "Test Teacher Expert"
5. See previous message: "Hello! I'm your assigned tutor..."

**Expected Result:** ✅ Student receives teacher's message

### 11.2 Student Responds
**Steps:**
1. Click on conversation
2. Type reply: "Hi! I'm available on Monday and Wednesday after 4 PM. Looking forward to working with you!"
3. Click Send
4. **Verify:** Message appears in chat

**Expected Result:** ✅ Student responds to teacher

---

## Phase 12: Demo Class Booking (Optional)

### 12.1 Schedule Demo Class
**Steps:**
1. In student or teacher chat interface
2. Look for "Schedule Demo" or "Book Demo Class" button
3. Select date and time: e.g., Tomorrow at 5 PM
4. Enter meeting link or platform (Zoom, Google Meet, etc.)
5. Click "Schedule"
6. **Verify:** Both parties receive notification

**Expected Result:** ✅ Demo class scheduled

---

## Test Completion Checklist

### Admin Workflow ✅
- [x] Login to admin dashboard without errors
- [x] View pending approvals
- [x] Approve student profile
- [x] Approve teacher profile
- [x] Approve tuition post
- [x] Approve teacher application
- [x] Send notifications
- [x] Send direct messages

### Student Workflow ✅
- [x] Register account (University of Dhaka)
- [x] Complete profile (pending approval)
- [x] Profile approved by admin
- [x] Post tuition via three different entry points
- [x] View approved teachers (1-2)
- [x] Approve teacher match
- [x] View chat with teacher
- [x] Receive & respond to messages

### Teacher Workflow ✅
- [x] Register account
- [x] Complete profile (NID optional)
- [x] Profile approved by admin
- [x] Apply to approved tuition post
- [x] Application approved by admin
- [x] View student basic info
- [x] Initiate chat with student
- [x] Receive student messages

---

## Known Issues & Notes

1. **Admin Dashboard Errors:** Fixed cascading error handling - each API call is now independent
2. **Profile Approval:** Admin must approve both before tuition posting works
3. **Application Limit:** Maximum 2 teachers can be approved per tuition post
4. **Notifications:** Should be queued and delivered after approvals
5. **Chat:** One-on-one messaging available after match confirmation

---

## Rollback Instructions

If test fails at any step:

1. Clear all test data: `node delete-test-users.js` (backend folder)
2. Stop backend: `Ctrl+C`
3. Restart backend: `node server.js`
4. Hot reload Flutter: `R` key in terminal
5. Start over from Phase 1

---

## Success Criteria

All phases complete without:
- ❌ Crash or uncaught exceptions
- ❌ Error messages at bottom of screens
- ❌ Cascading failures from one API call
- ❌ Missing data or UI elements
- ✅ Smooth transitions between user roles
- ✅ Proper notifications & messaging
- ✅ Complete data flow from signup to chat
