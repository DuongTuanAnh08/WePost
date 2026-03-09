<%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
        <!DOCTYPE html>
        <html lang="vi">

        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>WePost Admin - Quản lý Người dùng</title>
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

                .admin-table {
                    width: 100%;
                    border-collapse: collapse;
                    margin-top: 20px;
                    background: var(--surface-color);
                    border-radius: 12px;
                    overflow: hidden;
                    border: 1px solid var(--border-color);
                }

                .admin-table th,
                .admin-table td {
                    padding: 15px;
                    text-align: left;
                    border-bottom: 1px solid var(--border-color);
                }

                .admin-table th {
                    background-color: rgba(255, 255, 255, 0.02);
                    font-weight: bold;
                    color: var(--text-muted);
                }

                .status-badge {
                    padding: 5px 10px;
                    border-radius: 20px;
                    font-size: 12px;
                    font-weight: bold;
                }

                .status-active {
                    background: rgba(0, 186, 124, 0.1);
                    color: #00ba7c;
                }

                .status-banned {
                    background: rgba(249, 24, 128, 0.1);
                    color: #f91880;
                }
            </style>
        </head>

        <body style="background-color: var(--bg-color); color: var(--text-main);">
            <div class="admin-sidebar">
                <h2 style="margin-bottom: 30px; padding-left: 10px; color: var(--primary-color);">WePost Admin</h2>
                <a href="${pageContext.request.contextPath}/admin/dashboard"><i class="fas fa-chart-line"
                        style="width: 25px;"></i> Tổng quan</a>
                <a href="${pageContext.request.contextPath}/admin/users" class="active"><i class="fas fa-users"
                        style="width: 25px;"></i> Người dùng</a>
                <a href="${pageContext.request.contextPath}/admin/posts"><i class="fas fa-file-alt"
                        style="width: 25px;"></i> Bài viết</a>
                <a href="${pageContext.request.contextPath}/home" style="margin-top: 50px; color: var(--text-muted);"><i
                        class="fas fa-arrow-left" style="width: 25px;"></i> Thoát Admin</a>
            </div>

            <div class="admin-main">
                <h1 style="margin-bottom: 30px;">Quản lý Người dùng</h1>

                <table class="admin-table">
                    <thead>
                        <tr>
                            <th>ID</th>
                            <th>Người dùng</th>
                            <th>Vai trò</th>
                            <th>Trạng thái</th>
                            <th>Hành động</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach var="user" items="${listUsers}">
                            <tr>
                                <td>#${user.userId}</td>
                                <td>
                                    <div style="font-weight: bold;">${user.fullName}</div>
                                    <div style="color: var(--text-muted); font-size: 13px;">@${user.username}</div>
                                </td>
                                <td>${user.role}</td>
                                <td>
                                    <c:choose>
                                        <c:when test="${user.banned}">
                                            <span class="status-badge status-banned">Bị Khóa</span>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="status-badge status-active">Hoạt động</span>
                                        </c:otherwise>
                                    </c:choose>
                                </td>
                                <td>
                                    <c:if test="${currentUser.userId != user.userId}">
                                        <form action="${pageContext.request.contextPath}/admin/users" method="POST"
                                            style="margin: 0;">
                                            <input type="hidden" name="action" value="ban_unban">
                                            <input type="hidden" name="userId" value="${user.userId}">
                                            <c:choose>
                                                <c:when test="${user.banned}">
                                                    <input type="hidden" name="isBanned" value="false">
                                                    <button type="submit" class="btn-primary"
                                                        style="background-color: #00ba7c; padding: 6px 12px; font-size: 13px;">Mở
                                                        khóa</button>
                                                </c:when>
                                                <c:otherwise>
                                                    <input type="hidden" name="isBanned" value="true">
                                                    <button type="submit" class="btn-primary"
                                                        style="background-color: #f91880; padding: 6px 12px; font-size: 13px;"
                                                        onclick="return confirm('Khóa tài khoản này? Người này sẽ không thể đăng nhập.');">Khóa
                                                        Nick</button>
                                                </c:otherwise>
                                            </c:choose>
                                        </form>
                                    </c:if>
                                </td>
                            </tr>
                        </c:forEach>
                    </tbody>
                </table>
            </div>
        </body>

        </html>