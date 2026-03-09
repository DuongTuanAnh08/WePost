# User Acceptance Testing (UAT)
## Feature: Edit Profile (Chỉnh sửa hồ sơ)

### 1. Feature Name
- Edit Profile (Cập nhật thông tin cá nhân)

### 2. Objective
- Cho phép người dùng cá nhân hóa tài khoản của mình trên WePost.
- Người dùng có thể thay đổi "Tên hiển thị" (FullName) và "Tiểu sử" (Bio) để giới thiệu bản thân với những người theo dõi khác.

### 3. User Story
- Là một người dùng, sau khi đăng ký tài khoản, tiểu sử của tôi là mặc định ("Xin chào, tôi là thành viên WePost!").
- Khi tôi vào trang "Hồ sơ" của chính mình, tôi thấy nút "Chỉnh sửa hồ sơ".
- Khi bấm vào nút đó, tôi được chuyển đến một trang biểu mẫu biểu diễn các thông tin hiện tại của tôi.
- Tôi thay đổi tên và viết một đoạn tiểu sử mới, sau đó ấn "Lưu thay đổi".
- Hệ thống cập nhật thông tin và đưa tôi trở lại trang Hồ sơ với dữ liệu mới tinh.

### 4. Scope (Phạm vi công việc)
- **Backend (Java):** 
  - Sửa `UserDAO.java`: Thêm hàm `updateProfile(int userId, String fullName, String bio)`.
  - Tạo `EditProfileServlet.java`: 
    - `doGet`: Xử lý hiển thị form chỉnh sửa, nạp dữ liệu cũ của User.
    - `doPost`: Nhận dữ liệu text từ form, gọi DAO cập nhật DB, và cập nhật lại `Session` hiện tại.
- **Frontend (JSP/HTML/CSS):** 
  - Tạo trang `edit-profile.jsp` với form nhập liệu đẹp mắt (Input field cho Tên, Textarea cho Tiểu sử).
  - Cập nhật nút "Chỉnh sửa hồ sơ" trong `profile.jsp` để link sang trang `/edit-profile`.

### 5. Functional Test Cases
- **TC01:** Bấm "Chỉnh sửa hồ sơ" &rarr; Trang Web nạp đúng dữ liệu Tên và Tiểu sử cũ vào các ô nhập liệu.
- **TC02:** Thay tên thành "Người dùng ẩn danh" và Bio mới &rarr; Bấm Lưu &rarr; DB ghi nhận, Session cập nhật, chuyển về `/profile`, giao diện hiển thị tên mới lập tức.
- **TC03:** Bỏ trống trường tên hiển thị (FullName) &rarr; Hệ thống chặn lại không cho submit qua tính năng `required` của HTML và kiểm tra ở Backend.

### 6. Edge Cases & Boundary Conditions
- Cố tình nhập chuỗi quá dài cho phần Tiểu sử (lớn hơn 255 ký tự tùy schemas DB) &rarr; Backend tự động cắt xén chuỗi (trim/substring) hoặc chặn lỗi trước khi gọi SQL để tránh sập Server.
- Cố tình gõ mã độc JS `<script>alert(1)</script>` vào phần Tiểu sử &rarr; Hệ thống vẫn lưu nội dung dưới dạng văn bản và quá trình render ở Profile được dọn dẹp bằng `<c:out>` của JSTL (ngăn XSS tuyệt đối).

### 7. Negative Testing
- Chưa Đăng nhập mà cố truy cập URL `/edit-profile` &rarr; Bị đá văng về `/login`.
- Đăng nhập bằng tài khoản A nhưng cố tình giả mạo (thêm id vào form để sửa cho tài khoản B) &rarr; Servlet chỉ lấy `userId` từ `Session` cục bộ, tuyệt đối không lấy từ form ẩn, bảo mật tuyệt đối.

### 8. Security/Performance/Rollback Impact
- **Security Impact:** Bảo vệ chống XSS và IDOR (kiểm soát thay đổi dị thường qua Session). Dùng PreparedStatement chống SQL Injection.
- **Database Impact:** Câu lệnh `UPDATE Users SET FullName=?, Bio=? WHERE UserID=?`. Tác động trực tiếp lên 1 dòng, siêu nhẹ.
- **Performance Impact:** Instant update.
- **Risk Level:** **Trung bình (Medium)** do có thao tác Ghi (Write) vào Database.
- **Rollback Plan:** Xóa `EditProfileServlet`, phục hồi nút "Chỉnh sửa hồ sơ" thành thẻ button chết.

---
*Vui lòng phản hồi "Đồng ý làm phần chỉnh sửa hồ sơ" để AI bắt đầu viết Code Servlet và Form UI nhé!*
