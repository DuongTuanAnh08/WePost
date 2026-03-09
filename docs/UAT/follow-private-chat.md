# User Acceptance Testing (UAT)
## Feature: Follow User & Private Chat (Nhắn tin riêng tư giữa người theo dõi)

### 1. Feature Name
- Follow User and Private Messaging (Theo dõi người dùng & Nhắn tin riêng tư)

### 2. Objective
- Xây dựng chức năng cho phép người dùng ấn "Theo dõi" (Follow) nhau trên trang Hồ sơ (Profile).
- Trích xuất danh sách những người "Theo dõi lẫn nhau" (Mutual Following / Friends).
- Cải tiến hệ thống WebSockets: Chuyển đổi từ "Phòng chat cộng đồng (Global)" hiện tại sang "Chat riêng tư 1-1" dựa trên danh sách bạn bè đã theo dõi nhau.

### 3. User Story
- Là một người dùng, tôi muốn xem Hồ sơ của người khác và ấn nút "Theo dõi" họ.
- Khi cả hai tôi và người đó đều ấn Theo dõi nhau, chúng tôi trở thành "Bạn bè".
- Là một người dùng, tôi muốn mở trang Tin Nhắn, nhìn thấy danh sách bạn bè của mình bên cột trái.
- Khi tôi bấm vào tên một người bạn, tôi có thể gửi tin nhắn riêng tư vào khung chat màn hình chính mà không ai khác đọc được.

### 4. Scope (Phạm vi công việc)
- **Backend (Java):** 
  - Tạo `FriendDAO` xử lý Data kết bạn (Follow/Unfollow) vào bảng `Friends` của SQL Server.
  - Sửa `ProfileServlet` để tiếp nhận lệnh bấm "Theo dõi" từ Giao diện.
  - Sửa `ChatServlet` lấy danh sách Bạn bè hợp lệ truyền ra cho trang Chat.
  - Cập nhật luồng `ChatEndpoint.java` để gửi tin nhắn point-to-point (1-1) dựa trên `receiverUsername` thay vì Broadcast toàn mạng như hiện tại.
- **Frontend (JSP/HTML/CSS):** 
  - Đấu nối logic API cho nút bấm Theo Dõi ở `profile.jsp`.
  - Cập nhật giao diện `chat.jsp` hiển thị đúng danh sách bạn bè bên trái, và tải lịch sử chat đúng của người đang được chọn.

### 5. Functional Test Cases
- **TC01:** Người dùng A vào trang Profile của B -> Nút "Theo dõi" hiển thị. Bấm vào => Lưu DB thành công trạng thái A Following B.
- **TC02:** Nếu A đã theo dõi B, nút đổi thành "Hủy theo dõi" -> Bấm vào => Hủy thành công.
- **TC03:** B theo dõi lại A. Truy cập trang `chat.jsp` của cả A và B -> Thấy tên đối phương xuất hiện ở Sidebar bên trái cấu hình "Bạn bè".
- **TC04:** Mở cửa sổ ẩn danh (2 Tab cho A và B). A nhắn tin cho B => Chỉ B nhận được Real-time. C (người không liên quan) không nhận được.
- **TC05:** Nếu A gửi báo cáo Realtime lên WebSocket mà không chọn Bạn bè nào => Server từ chối không văng Exception.

### 6. Edge Cases
- Người dùng tự cố ý chạy script JS để Follow... chính mình (ID A = ID A) => Chặn ở mức DB và Java Backend.
- Kẻ xấu dùng WebSocket API tự bóp méo gói JSON nhằm gửi tin nhắn sang một tài khoản họ chưa hề kết bạn => WebSocket Channel sẽ kiểm tra chéo DB (hoặc Session Cache) xem 2 người có là bạn chưa rồi mới chuyển tiếp.

### 7. Boundary Conditions
- Ngăn việc người dùng bấm Follow 2 lần liên tục gây Duplicate Key trong Database (Khắc phục bằng lệnh IF EXISTS ở tầng SQL DAO).
- Giới hạn tải 100 User bạn bè ở Sidebar để tránh treo DOM của giao diện Chat.

### 8. Negative Testing
- Gửi gói tin nhắn trống hoặc null lên luồng Chat riêng tư => Server ném bỏ gói JSON.
- Đổi URL `/profile?u=TaiKhoanAo_KoCoThuc` và cố gọi hàm Follow API => Hệ thống trả về lỗi 404/Bad Request hợp lệ.

### 9. Security/Performance/Rollback Impact
- **Security Impact:** Tin nhắn được mã hóa JSON phải được xử lý `<c:out>` XSS Protection cẩn trọng tột độ vì nó là tin nhắn cá nhân. WebSocket cần xác nhận JWT/Session trước khi Allow mở luồng Socket Endpoint Point-to-Point. Kiểm tra quyền Follow lẫn nhau ở server thay vì JS.
- **Database Impact:** Table `Friends` và Table `Messages` (nếu bắt đầu chèn history xuống SQL Server) sẽ tăng dữ liệu. Đã có Index từ tập lệnh `database.sql` gốc nên tốc độ sẽ đủ đáp ứng.
- **Performance Impact:** Xử lý logic Point-to-Point (1:1) trong WebSocket đòi hỏi Server phải Map từng `Session` vào cấu trúc `Map<String, Session>` (User - Session), thay vì Set rỗng tuếch như hiện tại. Sẽ tốn RAM hơn một tí nhưng quản lý phân minh.
- **Risk Level:** **High**. Chạm sâu vào Core WebSockets Real-time Architecture và CSDL.
- **Rollback Plan:** Nếu tính năng gây Crash Server, Revert file `ChatEndpoint.java` về bản Global Chat (Lịch sử Commit cũ hoặc backup text cục bộ).

---
*Vui lòng phản hồi chấp nhận tài liệu UAT này để tiếp tục thực thi mã Core System Java!*
