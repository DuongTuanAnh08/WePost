# User Acceptance Testing (UAT)
## Feature: Post Interactions (Like, Comment, Repost)

### 1. Feature Name
- Tương tác bài viết (Thích, Bình luận, Đăng lại)

### 2. Objective
- Xóa bỏ sự nhàm chán của bảng feed một chiều, mang lại sự tương tác qua lại giữa các người dùng WePost.
- Cho phép người dùng thể hiện cảm xúc (Like), nêu lên quan điểm (Comment), và chia sẻ lại bài viết hay (Repost) lên tường của mình.

### 3. User Story
- **Like:** Khi tôi lướt xem bài viết, tôi thấy nút "Trái tim". Khi click vào, trái tim chuyển màu đỏ và số lượt thích tăng lên 1 lượng. Nhấp lần nữa thì hủy thích.
- **Comment:** Tôi thấy nút "Bình luận". Khi click vào, một ô nhập hiện ra để tôi gõ ý kiến của mình, sau đó gửi đi. Dưới bài viết sẽ hiển thị danh sách các bình luận của mọi người.
- **Repost (Đăng lại):** Khi tôi đọc được một bài viết tâm đắc, tôi muốn nhấn "Đăng lại". Hệ thống sẽ tạo một bài đăng mới trên tường nhà tôi, trích dẫn lại nguyên văn bài viết gốc đó.

### 4. Scope (Phạm vi công việc)
- **Database (SQL Server):** 
  - Tạo bảng `Likes` (Lưu ai thích bài nào: `UserID`, `PostID`, `CreatedAt`).
  - Tạo bảng `Comments` (Lưu bình luận: `CommentID`, `PostID`, `UserID`, `Content`, `CreatedAt`).
  - Cập nhật bảng `Posts`: Thêm trường `OriginalPostID` (NULLABLE) để đánh dấu đó là bài đăng lại (Repost).
- **Backend (Java):** 
  - 3 API Servlets (hoặc gộp chung thành `PostActionServlet`): Quản lý luồng POST Request khi người dùng nhấn Like, Gửi Comment, hoặc bấm Repost.
  - `PostDAO.java`: Thêm hàm `toggleLike()`, `addComment()`, `getCommentsByPost()`, `repost()`.
  - Cập nhật Model (POJO): Thay đổi đối tượng `Post` để nó mang thêm biến `likeCount`, `commentCount`, `repostCount`, `isLikedByCurrentUser`, `originalPostID`.
- **Frontend (JSP/HTML/CSS):** 
  - Gắn sự kiện AJAX Form hoặc Submit trực tiếp vào các nút `fa-heart` (Thích), `fa-comment` (Bình luận), `fa-retweet` (Đăng lại) trong luồng lặp `<c:forEach>` ở cả `home.jsp` và `profile.jsp`.
  - Dựng UI Modal / Collapse cho khu vực hiển thị danh sách Comment.

### 5. Functional Test Cases
- **TC01 (Like):** Bấm "Thích" &rarr; Web gọi `/api/like` &rarr; Nút đổi thành Heart đỏ đậm (`fas fa-heart`), số đếm Tăng 1.
- **TC02 (Comment):** Nhập Text bình luận vào text-box dưới bài viết &rarr; Bấm Gửi &rarr; Reload / AJAX báo thành công &rarr; Hiện khung comment của User đó ở dưới.
- **TC03 (Repost):** Bấm "Đăng lại" &rarr; Database Insert 1 dòng Post mới mà `OriginalPostID = bài cũ` &rarr; Sang trang Hồ sơ của người Vừa Đăng Lại sẽ thấy bài viết dạng "A đã đăng lại bài của B".

### 6. Edge Cases & Boundary Conditions
- Cố tình Comment một chuỗi Toàn Dấu Cách rỗng &rarr; Frontend JS chặn, Backend Servlet cắt vứt `trim()` rồi báo lỗi chứ ko Insert Rác vào Database.
- 1 Người dùng bấm Like 100 lần vào 1 bài bằng Script (Spam) &rarr; SQL Constrain khóa duy nhất `UNIQUE(UserID, PostID)` trong bảng `Likes` sẽ từ chối hoặc Backend dùng Toggle (Like/Unlike) nên Count chỉ dao động 0-1, không thể hack lên số ảo.

### 7. Negative Testing
- Bấm Thích/Comment khi phiên đăng nhập hết hạn (Session chết) &rarr; Backend chặn và điều hướng về trang `/login` ngay tắp lự.

### 8. Database, Security & Rollback Impact
- **Security Impact:** Bảo vệ chống XSS cực cao trên nội dung Comment bằng kỹ thuật JSTL `<c:out>`. Chống SQL Injection triệt để trên thông số Text nhập vào.
- **Database Impact:** Phải chạy script SQL tạo thêm 2 Bảng `Likes`, `Comments` & 1 dòng `ALTER TABLE Posts`. Cấu trúc DB thay đổi đáng kể.
- **Performance Impact:** Rất nhiều truy vấn (JOIN CSDL) được thực thi để tính ra Tổng số Like, Tổng Bình luận của từng bài. Sẽ thiết kế Câu Query gộp (Sub-query/Count) gọn gàng nhất cho `PostDAO`.
- **Risk Level:** **Cao (High)** vì Tác động cả Frontend, Backend và cấu trúc Cơ sở dữ liệu, sửa đổi vòng lặp render Bài viết trên toàn Web.
- **Rollback Plan:** Xóa hiển thị Thanh Công Cụ Tương tác (3 nút) dưới mỗi bài viết, Rollback SQL Database.

---
*Vui lòng duyệt UAT bằng câu lệnh **"Duyệt làm phần tương tác bài viết"** để tiếp tục!*
