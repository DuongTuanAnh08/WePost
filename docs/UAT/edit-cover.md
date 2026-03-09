# User Acceptance Testing (UAT)
## Feature: Edit Cover Image (Chỉnh sửa ảnh bìa)

### 1. Feature Name
- Edit Cover Image (Cập nhật Ảnh Bìa)

### 2. Objective
- Cho phép người dùng tùy biến giao diện trang Cá nhân (Profile) của mình bằng cách thay đổi Ảnh bìa (Cover Image) phía sau Avatar.
- Tăng tính cá nhân hóa và làm phong phú trải nghiệm thị giác.

### 3. User Story
- Là một người dùng, tôi vào trang Hồ sơ của mình và thấy nền Ảnh bìa hiện tại chỉ là một màu xám mặc định.
- Tôi bấm "Chỉnh sửa hồ sơ" và nhìn thấy mục "tải lên thẻ Ảnh Bìa" mới.
- Tôi chọn một bức tranh phong cảnh yêu thích từ máy tính và ấn "Lưu Thay Đổi".
- Hệ thống tải ảnh của tôi lên Server và ngay lập tức trang Hồ sơ của tôi ngập tràn màu sắc của bức ảnh phong cảnh đó.

### 4. Scope (Phạm vi công việc)
- **Database (SQL Server):** 
  - Cập nhật cấu trúc bảng `Users`: Thêm trường `CoverUrl NVARCHAR(255) DEFAULT 'default-cover.jpg'`.
- **Backend (Java):** 
  - Sửa model `User.java` (thêm thuộc tính `coverUrl`).
  - Sửa `UserDAO.java`: Thêm `CoverUrl` vào tất cả các truy vấn (Select, Insert), và cập nhật hàm `updateProfile(...)` để nhận thêm tham số ảnh bìa.
  - Sửa `EditProfileServlet.java`: Đọc thêm `Part` để bắt tệp tin `coverFile` được Gửi từ Form. Lưu tệp thư mục `images/covers`.
- **Frontend (JSP/HTML/CSS):** 
  - Thêm khu vực tải ảnh bìa (Cover Image Preview) vào `edit-profile.jsp`.
  - Chỉnh sửa file `profile.jsp`: Render thẻ `<img src="images/covers/${profileUser.coverUrl}">` lên vị trí của class `.profile-cover`.

### 5. Functional Test Cases
- **TC01:** Bấm "Chỉnh sửa hồ sơ", chọn 1 ảnh cho Avatar, 1 ảnh cho Bìa &rarr; Lưu thành công cả 2.
- **TC02:** Chỉ chọn ảnh Bìa, không chọn ảnh Avatar &rarr; Lưu thành công ảnh Bìa, Avatar giữ nguyên ảnh cũ.
- **TC03:** Trang Profile hiển thị đúng ảnh Bìa khớp với kích thước dài, hình ảnh tự động căn giữa và không bị méo (Object-fit: cover).

### 6. Edge Cases & Boundary Conditions
- **Dung lượng file lớn:** Thiết lập thuộc tính giới hạn `maxFileSize` trong Servlet là 10MB/ảnh bìa. File vượt rào bị Backend chặn.
- **Loại tệp không an toàn:** Backend kiểm tra MIME type bắt buộc phải là `image/png`, `image/jpeg` hoặc `image/gif`.

### 7. Negative Testing
- Người dùng tải lên File PDF hoặc File thực thi .EXE dưới dạng thẻ Ảnh bìa &rarr; Backend bắt lỗi "ContentType" và huỷ lưu, đẩy ra thông báo lỗi đỏ trên form.

### 8. Database & Security Impact
- **Security Impact:** Ảnh tải lên được đổi tên thành chuỗi `UUID` ngẫu nhiên để chống Path Traversal và không làm trùng lặp các ảnh.
- **Database Impact:** Phải chạy duy nhất 1 lệnh `ALTER TABLE Users ADD CoverUrl NVARCHAR(255) DEFAULT 'default-cover.jpg';` ở máy trạm của bạn. (Code sẽ tự lo đoạn Insert/Update).
- **Risk Level:** **Trung Bình (Medium)** (Yêu cầu thay đổi luồng Upload và can thiệp Database Migration).
- **Rollback Plan:** Xóa hiển thị ảnh bìa trên UI Profile, rollback `UserDAO` về bản lưu trước đó.

---
*Vui lòng duyệt UAT bằng lệnh "Đồng ý làm ảnh bìa" để hệ thống bắt máy tính khởi chạy đoạn mã Upload Cover nhé!*
