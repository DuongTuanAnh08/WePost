# UAT - WePost: Tính năng Đăng bài, Nhắn tin (WebSockets Real-time), Trang cá nhân và Khám phá

## Feature Name
Mạng xã hội WePost (Trang chủ chung, Tìm kiếm, Đăng bài, Nhắn tin Real-time WebSockets, Trang cá nhân)

## Objective
Ngôn ngữ sử dụng: Java Servlet, Java API for WebSocket, JSP/HTML, CSS, SQL Server.
Mục tiêu: Xây dựng nền tảng mạng xã hội cơ bản. Nổi bật với hệ thống Trang chủ hiển thị bài viết từ cộng đồng, thanh tìm kiếm chủ đề. Cung cấp đầy đủ các tính năng tương tác với hệ thống Nhắn tin theo thời gian thực (Real-time) sử dụng WebSockets, và thiết lập Profile cá nhân. Hệ thống phải đảm bảo hoạt động an toàn, bảo mật và lưu trữ bằng SQL Server.

## Scope
1. **Trang chủ chính (Khám phá & Đăng bài):** Hiển thị toàn bộ các bài đăng của người dùng trên toàn hệ thống (cả người đã theo dõi và chưa theo dõi). Người dùng có thể soạn bài đăng mới từ trang này.
2. **Tìm kiếm (Search):** Thanh tìm kiếm trên trang chủ cho phép tìm bài đăng theo từ khóa (chủ đề bài viết).
3. **Tính năng nhắn tin (Chat Real-time):** Cho phép xem danh sách người dùng và gửi/nhận tin nhắn ngay lập tức mà không cần tải lại trang thông qua kết nối **WebSocket**.
4. **Trang cá nhân (Profile):** Hiển thị Avatar, Chú thích (Bio), và danh sách các bài đăng do chính người dùng đó đã đăng. Cho phép cập nhật thông tin cá nhân.
5. **Trang hoạt động (Following Feed):** Một tab hoặc trang riêng hiển thị các bài đăng của những người bạn đã theo dõi.

## User Story
- Là một người dùng, tôi muốn xem Trang chủ chính với bài viết từ nhiều người khác (theo dõi/chưa theo dõi) để khám phá nội dung mới.
- Là một người dùng, tôi muốn có thanh tìm kiếm trên trang chủ để tìm kiếm các bài viết theo chủ đề yêu thích.
- Là một người dùng, tôi muốn có trang cá nhân của riêng mình để cập nhật Avatar, viết chú thích bản thân và xem lại các bài tôi đã đăng.
- Là một người dùng, tôi muốn nhắn tin trò chuyện trực tiếp (Real-time) với bạn bè hoặc người dùng khác ngay lập tức không cần tải lại trang.

## Functional Test Cases

### 1. Nguồn dữ liệu Trang chủ & Đăng bài
| Test ID | Mô tả | Đầu vào | Kết quả mong đợi |
|---------|--------|---------|------------------|
| TC-HOME-01 | Hiển thị Trang chủ | Đăng nhập tài khoản, truy cập vào URL /home. | Danh sách toàn bộ bài viết từ cộng đồng (theo dõi và chưa theo dõi) được hiển thị, ưu tiên bài viết mới. |
| TC-POST-01 | Đăng bài thành công | Tại Trang chủ, nhập "Chào WePost", nhấn Đăng. | Bài đăng được lưu vào CSDL. Hiển thị ngay trên Trang cá nhân và đẩy lên Trang chủ chung. |

### 2. Tìm kiếm Bài viết (Search)
| Test ID | Mô tả | Đầu vào | Kết quả mong đợi |
|---------|--------|---------|------------------|
| TC-SRCH-01 | Tìm kiếm theo từ khóa có bài viết | Gõ "lập trình" vào ô Search, nhấn Enter. | Hiển thị kết quả danh sách bài viết nội dung liên quan tới "lập trình". |
| TC-SRCH-02 | Tìm kiếm từ khóa không tồn tại | Gõ ký tự ngẫu nhiên vào ô Search. | Hiển thị thông báo "Không tìm thấy bài viết nào phù hợp". |

### 3. Trang Cá nhân (Profile)
| Test ID | Mô tả | Đầu vào | Kết quả mong đợi |
|---------|--------|---------|------------------|
| TC-PROF-01 | Xem trang cá nhân & Bạn bè | Truy cập trang cá nhân. | Hiển thị Avatar, Chú thích và Danh sách bài đăng. |

### 4. Tính năng Nhắn tin (Nhắn tin Real-time WebSockets)
| Test ID | Mô tả | Đầu vào | Kết quả mong đợi |
|---------|--------|---------|------------------|
| TC-MSG-01 | Gửi/Nhận tin nhắn thời gian thực | User A và User B mở cửa sổ chat. User A soạn "Alo" gửi cho User B. | Ngay khi A gửi, tin nhắn hiển thị ngay lập tức lên màn hình của B qua WebSocket không cần reload trang. |
| TC-MSG-02 | Lưu trữ lịch sử tin nhắn | User A reload lại trang chat. | Toàn bộ lịch sử tin nhắn cũ đã gửi/nhận trước đó được load lại từ CSDL SQL Server hiển thị đầy đủ. |

## Edge Cases
- WebSocket bị đứt kết nối (mất mạng): Phía Client (JavaScript) cần có cơ chế tái kết nối tự động (Re-connect) khi có mạng trở lại.
- Dữ liệu rác gửi qua WebSocket.

## Boundary Conditions
- Ngăn chặn việc Flood mạng WebSocket (Gửi quá nhiều tin nhắn liên tục trong 1 giây).

## Negative Testing
- Client cố gắng kết nối WebSocket Endpoint mà không có HTTP Session Authentication.
- Xử lý: Server Node chối bỏ kết nối (Disconnect Request trong ServerEndpoint Configurator).

## Security Testing (Security Impact)
- **SQL Injection:** Mọi input (Nội dung bài viết, Tìm kiếm chủ đề, Tin nhắn, Chú thích) đều sử dụng `PreparedStatement`.
- **XSS (Cross-Site Scripting):** Mọi nội dung text (đặc biệt là tin nhắn Real-time nhận qua WebSocket) cần được HTML-encoded (Ví dụ: dùng `TextNode` thay vì `innerHTML` khi đính chuỗi trong Vanilla JS) trước khi đẩy ra View.
- **WebSocket Auth Hijacking:** WebSocket endpoint cần được bảo mật và xác thực thông qua quá trình Handshake (Lấy Session ID từ HTTP Session và map với WebSocket Session).

## Performance Testing (Performance Impact)
- Rủi ro tràn ngập bộ nhớ do quản lý WebSocket Session: Cần xóa session (`remove()`) khỏi danh sách Concurrent HashMap quản lý User khi họ `onClose` hoặc `onError`.

## Database Impact
Các cấu trúc Table:
- Bảng `Users` (UserID, Username, PasswordHash, AvatarUrl, Bio, Role)
- Bảng `Friends` (FriendshipID, User1_ID, User2_ID, Status - Trạng thái theo dõi)
- Bảng `Posts` (PostID, UserID, Content, CreatedAt)
- Bảng `Messages` (MessageID, SenderID, ReceiverID, Content, SentAt)

## Rollback Plan (Rollback Impact)
- Nếu WebSocket gặp lỗi quá tải bộ nhớ trên JVM, tính năng nhắn tin sẽ tạm thời disable trong file config và chuyển về chế độ AJAX Polling/Tải lại trang truyền thống trong quá trình fix lỗi Server.

## Risk Level
High (Áp dụng WebSockets có thể có vấn đề rủi ro cao về Resource Leak trên Java Web Server nếu quản lý Connection/Session lỏng lẻo).

---
*Vui lòng xem và phê duyệt UAT này trước khi triển khai code!*
