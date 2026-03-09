# User Acceptance Testing (UAT)
## Feature: Explore Page (Trang Khám Phá)

### 1. Feature Name
- Explore Page & User Search (Trang Khám Phá & Tìm kiếm Người dùng)

### 2. Objective
- Xây dựng một không gian (Trang Khám Phá) giúp người dùng tìm kiếm những tài khoản khác trên nền tảng WePost.
- Cho phép người dùng nhập từ khóa để tìm qua Tên hiển thị (FullName) hoặc Tên đăng nhập (Username).
- Hiển thị danh sách đề xuất người dùng ngẫu nhiên nếu không sử dụng ô tìm kiếm.

### 3. User Story
- Là một thành viên WePost, tôi muốn bấm vào mục "Khám phá" trên thanh công cụ bên trái.
- Tại đây, tôi muốn thấy danh sách một số tài khoản nổi bật hoặc mới tham gia để có thể bấm vào xem thông tin và "Theo dõi" họ.
- Tôi cũng muốn một thanh tìm kiếm ở góc trên để tìm đích danh bạn bè của tôi theo tên.
- Khi tôi nhấp vào một hồ sơ tìm được, hệ thống phải chuyển tôi tới trang Hồ sơ cá nhân của người đó.

### 4. Scope (Phạm vi công việc)
- **Backend (Java):** 
  - Khai báo thêm hàm `searchUsers(keyword)` và `getRecommendedUsers(limit, currentUserId)` trong `UserDAO` xử lý từ khóa bằng lệnh `LIKE '%...%'`.
  - Tạo `ExploreServlet.java` quản lý luồng Route GET request `/explore`.
- **Frontend (JSP/HTML/CSS):** 
  - Giao diện hóa trang `explore.jsp` thừa kế layout Sidebar của nền tảng WePost.
  - Vùng trung tâm sẽ là thanh Input Search (Gửi GET Query) và hiển thị dạng Card lưới (Grid) User List (Avatar, Tên, Bio, Nút xem hồ sơ).
  - Đồng bộ hóa toàn bộ Link Menu `Khám phá` ở các trang `home.jsp`, `chat.jsp`, `profile.jsp`.

### 5. Functional Test Cases
- **TC01:** Truy cập mặc định `/explore` -> Trả về danh sách tài khoản hợp lệ từ DB (Ngoại trừ tài khoản của chính mình).
- **TC02:** Gõ từ khóa tìm kiếm "Alex" vào ô Search và Submit (`/explore?q=Alex`) -> Trả về được "Alex Developer".
- **TC03:** Gõ từ khóa không tồn tại "HieuThuHai123" -> Web báo lỗi nhẹ nhàng "Không tìm thấy ai phù hợp".
- **TC04:** Click vào 1 Card kết quả (Ví dụ nhấn vào ảnh/Tên của Alex) -> Chuyển hướng đúng về `/profile?u=alexdev`.

### 6. Edge Cases
- Người dùng truyền mã độc SQL vào Text Search (`/explore?q=' OR 1=1 --`) -> PreparedStatement trong `UserDAO` bắt và vô hiệu hóa mối nguy.

### 7. Boundary Conditions
- Ngăn việc Search truy vấn kéo sập toàn bộ Database (Ví dụ nếu WePost có 1 triệu người dùng và không gõ tìm kiếm) -> Chỉ `LIMIT 50` hoặc `TOP 50` hồ sơ trên mỗi lượt render.

### 8. Negative Testing
- Người dùng vô danh (chưa đăng nhập) tự gõ link điều hướng tới `/explore` -> Filter Middleware Session bắt chặn và đá văng về `/login`.

### 9. Security/Performance/Rollback Impact
- **Security Impact:** Truy vấn mức độ Đọc (Read-only) không làm thay đổi Database. Input Search sẽ được Encode XSS trước khi đính vào URL hoặc in lên JSP.
- **Database Impact:** Có thiết lập Index trên cột `Username` ở lần đầu khởi tạo Database, tốc độ sẽ chịu tải lớn tốt ngang ngửa Feed.
- **Performance Impact:** Low (Thấp). Câu lệnh `LIKE` có bọc `%` nên chạy ngang bằng lệnh Select cơ bản.
- **Risk Level:** **Low (Thấp)**. Tính năng hoàn toàn độc lập với hệ luồng Post và Chat.
- **Rollback Plan:** Xóa bỏ `ExploreServlet` và `explore.jsp` nếu cần phục hồi.

---
*Để tuân thủ Rule số 11 (Luôn duyệt UAT trước khi code), hãy nhắn xác nhận duyệt tài liệu này để tôi xuất code Backend xử lý Tìm Khám Phá!*
