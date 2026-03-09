<%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
        <!DOCTYPE html>
        <html lang="vi">

        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>WePost Admin - Dashboard</title>
            <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
            <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
            <style>
                .admin-sidebar {
                    background-color: var(--surface-color);
                    padding: 20px;
                    width: 250px;
                    height: 100vh;
                    position: fixed;
                    border-right: 1px solid var(--border-color);
                }

                .admin-sidebar a {
                    display: block;
                    padding: 12px 16px;
                    color: var(--text-main);
                    text-decoration: none;
                    border-radius: 8px;
                    margin-bottom: 8px;
                }

                .admin-sidebar a:hover,
                .admin-sidebar a.active {
                    background-color: rgba(29, 155, 240, 0.1);
                    color: var(--primary-color);
                }

                .admin-main {
                    margin-left: 250px;
                    padding: 30px;
                }

                .stat-card {
                    background: var(--surface-color);
                    padding: 20px;
                    border-radius: 12px;
                    border: 1px solid var(--border-color);
                    display: flex;
                    align-items: center;
                    gap: 20px;
                    flex: 1;
                }

                .stat-icon {
                    font-size: 30px;
                    color: var(--primary-color);
                    width: 60px;
                    height: 60px;
                    display: flex;
                    align-items: center;
                    justify-content: center;
                    background: rgba(29, 155, 240, 0.1);
                    border-radius: 50%;
                }

                .stat-value {
                    font-size: 28px;
                    font-weight: bold;
                }

                .stat-label {
                    color: var(--text-muted);
                    font-size: 14px;
                }
            </style>
        </head>

        <body style="background-color: var(--bg-color); color: var(--text-main);">
            <div class="admin-sidebar">
                <h2 style="margin-bottom: 30px; padding-left: 10px; color: var(--primary-color);">WePost Admin</h2>
                <a href="${pageContext.request.contextPath}/admin/dashboard" class="active"><i class="fas fa-chart-line"
                        style="width: 25px;"></i> Tổng quan</a>
                <a href="${pageContext.request.contextPath}/admin/users"><i class="fas fa-users"
                        style="width: 25px;"></i> Người dùng</a>
                <a href="${pageContext.request.contextPath}/admin/posts"><i class="fas fa-file-alt"
                        style="width: 25px;"></i> Bài viết</a>
                <a href="${pageContext.request.contextPath}/home" style="margin-top: 50px; color: var(--text-muted);"><i
                        class="fas fa-arrow-left" style="width: 25px;"></i> Thoát Admin</a>
            </div>

            <div class="admin-main">
                <h1 style="margin-bottom: 30px;">Bảng điều khiển</h1>
                <div style="display: flex; gap: 20px; margin-bottom: 30px;">
                    <div class="stat-card">
                        <div class="stat-icon"><i class="fas fa-user-friends"></i></div>
                        <div>
                            <div class="stat-value">${totalUsers}</div>
                            <div class="stat-label">Tổng Tài Khoản</div>
                        </div>
                    </div>
                    <div class="stat-card">
                        <div class="stat-icon" style="color: #00ba7c; background: rgba(0, 186, 124, 0.1);"><i
                                class="fas fa-pencil-alt"></i></div>
                        <div>
                            <div class="stat-value">${totalPosts}</div>
                            <div class="stat-label">Tổng Bài Đăng</div>
                        </div>
                    </div>
                    <div class="stat-card">
                        <div class="stat-icon" style="color: #f91880; background: rgba(249, 24, 128, 0.1);"><i
                                class="fas fa-eye"></i></div>
                        <div>
                            <div class="stat-value">${totalVisits}</div>
                            <div class="stat-label">Lượt truy cập Web</div>
                        </div>
                    </div>
                </div>

                <div class="stat-card" style="flex-direction: column; align-items: flex-start;">
                    <h3>Hướng dẫn Quản trị</h3>
                    <p style="color: var(--text-muted); line-height: 1.8;">
                        - <b>Người dùng:</b> Xem danh sách toàn bộ tài khoản. Bạn có thể khóa (Ban) các tài khoản vi
                        phạm hoặc spam. Người bị khóa sẽ không thể đăng nhập.<br>
                        - <b>Bài viết:</b> Quản lý toàn bộ nội dung mà người dùng đã đăng. Bạn có quyền xóa vĩnh viễn
                        các nội dung xấu khỏi hệ thống.
                    </p>
                </div>
            </div>
        </body>

        </html>