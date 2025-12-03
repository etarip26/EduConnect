# Admin Dashboard Quick Reference

## Tab Overview & Usage

### 1. **Overview Tab** 📊
Real-time platform statistics and metrics.

**What You See:**
- Total Users count
- Active Students & verified
- Active Teachers count
- Active Tuitions & pending
- Total Admin accounts
- Suspended accounts

**Use Case:** Check platform health and key metrics at a glance.

---

### 2. **Profile Approvals Tab** ✅
Manage user profile verification.

**How to Use:**
1. View list of pending profiles
2. Review user name, email, and role
3. Click **Approve** to allow them to post/apply
4. Click **Reject** to deny with reason

**When to Approve:**
- Student has completed profile
- Teacher credentials look legitimate
- All required fields are filled

**When to Reject:**
- Profile incomplete
- Missing verification documents
- Suspicious information
- Violates platform guidelines

---

### 3. **Tuition Posts Tab** 📝
Control which tuition job postings are visible.

**How to Use:**
1. View pending tuition posts from students
2. Read title, description, class level, subjects
3. Click **Approve** to make visible to teachers
4. Click **Reject** with reason if inappropriate

**When to Approve:**
- Post details are clear and legitimate
- Salary range is reasonable
- No spam or inappropriate content
- All required information provided

**When to Reject:**
- Unclear or missing details
- Unreasonable salary (too low/high)
- Duplicate posting
- Violates guidelines
- Teacher not eligible (unapproved profile)

---

### 4. **NID Verification Tab** 📋
Verify teacher identity documents.

**How to Use:**
1. View pending NID (National ID) documents
2. Check NID number, full name, DOB
3. Verify document hasn't expired
4. Click **Verify** if documents are legitimate
5. Can reject if documents invalid/fake

**Why It Matters:**
- Ensures teachers are real people
- Prevents identity fraud
- Required before teacher credential verification

**After Verification:**
- Teacher can complete full profile verification
- Teacher can apply to tuitions

---

### 5. **User Bans Tab** 🚫
Manage user accounts that violate platform rules.

**How to Use:**
1. View all users with their ban status
2. Users already banned show "Banned" badge with reason
3. Click **Ban User** to ban account with reason
4. Click **Unban** to restore banned user access

**When to Ban:**
- Repeated rule violations
- Spam or harassment
- Fraudulent activity
- Payment issues
- User request

**Ban Reason Examples:**
- "Repeated inappropriate messages"
- "Spam postings"
- "Profile with fake information"
- "Multiple failed payments"
- "Violating community guidelines"

---

### 6. **Notices Tab** 📢
Post announcements to all users on the platform.

**How to Use:**
1. Click **Create Notice** button
2. Fill in:
   - **Title**: Short headline (e.g., "Maintenance Schedule")
   - **Content**: Full announcement text
   - **Priority**: low/medium/high/critical
3. Click **Create**

**Priority Levels:**
- **Low** (gray) - Non-urgent information
- **Medium** (cyan) - Standard announcements
- **High** (pink) - Important updates
- **Critical** (red) - Urgent issues

**Notice Examples:**
- "System maintenance on Sunday 2-4 AM"
- "New feature: Video tutoring added"
- "Important: Verify your email address"
- "Security: Change password if you saw this"

**After Creating:**
- Notice appears for all users
- Sorted by priority (critical first)
- Stays until admin deletes it

---

### 7. **Users Tab** 👥
Complete user management and account control.

**What You See:**
- Complete list of all users
- User name, email, phone
- User role (admin, teacher, student)
- Account status (active/suspended)
- Approval status
- Ban status

**Available Actions:**
- View detailed user profile
- Suspend/activate account
- Change user role
- Delete account
- Ban/unban user

---

## Quick Tips

### ⚡ Speed Tips
- Use **Overview** tab first to assess workload
- Check **Profile Approvals** for quick user approval
- **Tuition Posts** needs review - don't approve too quickly
- **NID Verification** is critical - be thorough
- **User Bans** should have clear documentation

### 🔍 Review Checklist

**Before Approving Profile:**
- [ ] Email verified?
- [ ] Phone number filled?
- [ ] All required fields complete?
- [ ] Profile picture appropriate?
- [ ] No suspicious information?

**Before Approving Tuition Post:**
- [ ] Student profile approved?
- [ ] Post details complete and clear?
- [ ] Subjects/class level appropriate?
- [ ] Salary realistic?
- [ ] No spam/duplicates?

**Before Verifying NID:**
- [ ] Document images clear?
- [ ] NID number readable?
- [ ] Dates not expired?
- [ ] Document looks authentic?
- [ ] Name matches other records?

---

## Common Issues & Solutions

### Issue: "Can't see pending profiles"
**Solution:** Check if you're logged in as admin. Only admins see these tabs.

### Issue: "User still can't post after approval"
**Solution:** Make sure you approved their PROFILE (tab 2), not just activated account (tab 7). Both may be needed.

### Issue: "Tuition post still not visible"
**Solution:** You approved it, but also make sure the STUDENT'S profile is approved (tab 2).

### Issue: "Want to see rejected reasons"
**Solution:** Reasons are stored in system - contact support to retrieve them.

### Issue: "Accidentally banned wrong user"
**Solution:** Go to Tab 5 (User Bans), find user, click Unban immediately.

---

## Approval Workflow

```
New User Registers
    ↓
User Creates Profile
    ↓
Admin Reviews in "Profile Approvals" Tab
    ├─→ ✅ Approve → User can post/apply
    └─→ ❌ Reject → User gets rejection reason, can resubmit

(For Teachers Only)
    ↓
Teacher Submits NID Document
    ↓
Admin Reviews in "NID Verification" Tab
    ├─→ ✅ Verify → Teacher verified
    └─→ ❌ Reject → Teacher can resubmit

(For Posts)
Student Creates Tuition Post
    ↓
Admin Reviews in "Tuition Posts" Tab
    ├─→ ✅ Approve → Post visible to teachers
    └─→ ❌ Reject → Student gets reason, can revise

(If Violation Occurs)
Admin Goes to "User Bans" Tab
    ↓
Admin Bans User with Reason
    ↓
User Cannot Login (blocked)
```

---

## Best Practices

### ✅ DO:
- Review profiles thoroughly before approval
- Document ban reasons clearly
- Check NID documents carefully
- Use appropriate notice priorities
- Keep explanations for rejections helpful
- Test changes on demo account first

### ❌ DON'T:
- Approve without reviewing
- Ban without warning (for first offense)
- Use vague ban reasons
- Approve obvious spam posts
- Change user roles without reason
- Delete accounts as suspension

---

## Support

**For API Issues:**
- Check backend logs
- Verify token is still valid
- Check network connectivity

**For Database Issues:**
- Check MongoDB connection
- Verify indexes created
- Check disk space

**For Frontend Issues:**
- Clear browser cache
- Check console for errors
- Verify API URL is correct

---

**Version**: 1.0
**Last Updated**: Current Session
**Status**: Ready for Admin Use
