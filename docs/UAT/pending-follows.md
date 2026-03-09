# User Acceptance Testing (UAT)
## Feature: Pending Follows / Follow Back Suggestion (Gợi ý Theo dõi lại)

### 1. Feature Name
- Pending Follow Back (Hiển thị danh sách Người muốn nhắn tin / Theo dõi bạn trên trang Khám Phá)

### 2. Objective
- Nâng cấp Trang Khám Phá (`explore.jsp`): Bổ sung thêm một phân hệ hiển thị những người đã "Theo dõi" mình nhưng mình chưa "Theo dõi lại" họ.
- Mục đích: Giúp người dùng biết được ai đang muốn kết nối và nhắn tin với mình, tạo sự thuận tiện click 1 phát là thành "Bạn bè" để chat được ngay.

### 3. User Story
- Là một người dùng, khi tôi được một người lạ (ví dụ Alex) bấm "Theo dõi", tài khoản của tôi lúc này chưa biết Alex là ai nên chưa thể trò chuyện 1-1.
- Khi tôi vào mục "Khám phá", tôi muốn thấy ngay danh sách "Những người trót lọt muốn trò chuyện với bạn" hiển thị nổi bật ở phía trên.
- Tôi bấm "Xem hồ sơ" của Alex hoặc bấm Follow trực tiếp để 2 bên chính thức trở thành Bạn Bè và mở khóa Chat riêng tư.

### 4. Scope (Phạm vi công việc)
- **Backend (Java):** 
  - Sửa `UserDAO.java`: Thêm hàm `getPendingFollowers(int myUserId)` dùng truy vấn SQL: Lọc ra những người `ĐÃ FOLLOW MÌNH` nhưng `MÌNH CHƯA FOLLOW LẠI`.
  - Sửa `ExploreServlet.java`: Gọi hàm lấy list những người Pending này. Truyền `pendingUsers` ra cho Giao diện.
- **Frontend (JSP/HTML/CSS):** 
  - Trong `explore.jsp`, kiểm tra nếu `pendingUsers` có dữ liệu thì in ra một Hàng/Lưới riêng mang tên "Những người muốn kết nối/nhắn tin với bạn" nằm trên list Khám Phá thông thường.

### 5. Functional Test Cases
- **TC01:** Sarah (ID: 3) bấm theo dõi Duong (ID: 1). Duong chưa theo dõi lại. 
  -> Duong mở `/explore` -> Thấy Sarah nằm trong mục "Người muốn kết nối".
- **TC02:** Duong bấm vào Sarah, ấn Theo Dõi lại. -> Sarah biến mất khỏi mục "Người muốn kết nối" của Duong vì nay đã là Bạn Bè Mutual.
- **TC03:** Danh sách này trống (không có ai theo dõi đơn phương) -> Ẩn hoàn toàn khung chữ "Những người muốn kết nối với bạn", giữ nguyên phần Tìm kiếm người lạ như cũ.

### 6. Edge Cases
- Số lượng người hâm mộ lên đến hàng nghìn người -> Chỉ lấy `TOP 10` người mới nhất gạ gẫm mình để trên giao diện.

### 7. Boundary Conditions
- Ngăn việc người dùng A xuất hiện cả ở mục "Người muốn kết nối" và mục "Gợi ý từ cộng đồng". Xử lý loại trừ bằng SQL.

### 8. Negative Testing
- Chưa đăng nhập truy cập Explore -> Chuyển hướng ra Login, không sập DB.

### 9. Security/Performance/Rollback Impact
- **Security Impact:** Truy vấn cực kì an toàn (Read-Only) kết hợp phép truy vấn con (Subquery `NOT EXISTS`) bảo toàn Data.
- **Database Impact:** Table Friends sẽ phải JOIN với table Users và làm Subquery. Hệ thống SQL Server sẽ tối ưu nhờ Index đã tạo trước đó.
- **Performance Impact:** Kéo Data rất nhẹ, dưới 10 milliseconds.
- **Risk Level:** **Thấp (Low)**. Tính năng Add-on UI cho cụm Explore.
- **Rollback Plan:** Xóa hiển thị list `pendingUsers` trên trang Explore.

---
*Vui lòng duyệt UAT bằng lệnh "Đồng ý làm phần theo dõi lại" để hệ thống chạy mã Backend nhé!*
