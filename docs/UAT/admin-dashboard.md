# UAT: Admin Dashboard & Management

## Feature Definition
* **Feature Name:** Admin Dashboard & Management
* **Objective:** Tạo trang dành riêng cho Admin để quản lý tổng quan hệ thống (số lượng truy cập, tài khoản), kiểm duyệt nội dung (quản lý/xóa bài đăng) và xử lý vi phạm (khóa/ban người dùng).
* **User Story:** Là một Admin, tôi muốn xem thống kê số liệu hoạt động và danh sách người dùng/bài đăng để có thể xóa bài viết vi phạm hoặc cấm (ban) các tài khoản gửi spam, bảo vệ cộng đồng.
* **Security Impact:** Yêu cầu xác thực phân quyền mạnh (Role-based Authorization) tại Server (Custom Filter/Servlet). User thường không thể truy cập dù có Link. Các thao tác Ban/Delete yêu cầu HTTP POST bảo mật.
* **Database Impact:** 
  - Cần thêm trường dữ liệu `IsBanned BIT DEFAULT 0` vào bảng `Users` hiện tại.
  - Sử dụng cơ chế Application-level context hoặc tạo bảng DB con để theo dõi "Lượt truy cập trang web".
* **Performance Impact:** Truy vấn thống kê (COUNT) và lấy toàn bộ danh sách lên bảng có thể nặng nếu không phân trang. Query sẽ được tối ưu dùng `SELECT COUNT` trực tiếp.
* **Rollback Impact:** Dễ. Có thể thu hồi tính năng Admin mà không làm kẹt ứng dụng gốc.
* **Risk Level:** Cao (Vì tính năng liên quan đến bảo mật, quản trị viên có khả năng xóa và sửa dữ liệu của người dùng khác).

## Scope
1. **Admin Dashboard UI:** Giao diện có màu sắc tách biệt (Dark/Red/Blue) để không nhầm với trang Feed. Có các thẻ thống kê: Tổng Users, Tổng Bài Đăng, Hệ đếm Lượt truy cập web.
2. **Quản trị User (Moderation):** Bảng hiển thị người dùng, trạng thái, có nút Ban / Unban.
3. **Quản trị Post:** Bảng hiển thị list bài đăng (ID, Content short, Tác giả), có nút Xóa.
4. **Lớp bảo mật AdminFilter:** Bảo vệ toàn bộ folder hoặc mapping `/admin/*`.

## Functional Test Cases
| Test ID | Mô Tả | Kết quả mong muốn |
|---------|-------|-------------------|
| FTC01 | Tài khoản Role = 'ADMIN' truy cập link `/admin` | Truy cập thành công, giao diện thống kê tải đầy đủ. |
| FTC02 | Tài khoản Role = 'USER' hoặc chưa Login truy cập `/admin` | Chặn truy cập, ép chuyển hướng về `/home` hoặc `/login`. |
| FTC03 | Admin bấm "Khóa (Ban)" Tài khoản User X | Tài khoản X bị đổi trạng thái IsBanned = 1, User X khi đăng nhập sẽ dính thông báo "Bị khóa". |
| FTC04 | Admin bấm "Xóa" một bài đăng Y | Bài đăng Y bị xóa khỏi Database, biến mất trên trang chủ mọi người dùng. |

## Edge Cases
- Admin ấn nhầm nút Khóa chính bản thân mình (Hệ thống phải làm mờ nút khóa đối với row của chính mình).
- Cơ chế đếm Visit: Load trang liên tục (F5) có nên tính là truy cập mới không? Hệ thống sẽ đếm theo số Session Unique mới sinh ra để chính xác hơn là Pageview thuần.

## Boundary Conditions
- Số lượng User/Post quá nhiều làm phình giao diện Bảng (Table). UX sẽ áp dụng Max-height và cuộn.

## Negative Testing
- Hacker dùng Acc Role 'USER' và submit fake POST request lên Server `/admin/ban?userId=2`. Hệ thống phải quăng lỗi HTTP 403 Forbidden.

## Security Testing
- Role Check phải nằm sâu trong Servlet Filter, chứ không chỉ là ẩn nút "Chuyển trang Admin" trên giao diện HTML bằng CSS.

## Performance Testing
- Việc tải danh sách User nên giới hạn chỉ chọn (SELECT) những trường cần thiết (`UserID, Username, IsBanned, Role`) để truyền Object nhẹ thay vì đem toàn bộ Mật khẩu, ảnh bìa, Avatar về RAM xử lý.

## Rollback Plan
- Drop column `IsBanned` trong DB. Bỏ AdminServlet và config mapping. Mọi thứ trở về nguyên vẹn như trước.
