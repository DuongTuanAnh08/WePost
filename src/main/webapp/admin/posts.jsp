<%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
        <!DOCTYPE html>
        <html lang="vi">

        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>WePost Admin - Quản lý Bài viết</title>
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

                .content-cell {
                    max-width: 400px;
                    white-space: nowrap;
                    overflow: hidden;
                    text-overflow: ellipsis;
                }
            </style>
        </head>

        <body style="background-color: var(--bg-color); color: var(--text-main);">
            <div class="admin-sidebar">
                <h2 style="margin-bottom: 30px; padding-left: 10px; color: var(--primary-color);">WePost Admin</h2>
                <a href="${pageContext.request.contextPath}/admin/dashboard"><i class="fas fa-chart-line"
                        style="width: 25px;"></i> Tổng quan</a>
                <a href="${pageContext.request.contextPath}/admin/users"><i class="fas fa-users"
                        style="width: 25px;"></i> Người dùng</a>
                <a href="${pageContext.request.contextPath}/admin/posts" class="active"><i class="fas fa-file-alt"
                        style="width: 25px;"></i> Bài viết</a>
                <a href="${pageContext.request.contextPath}/home" style="margin-top: 50px; color: var(--text-muted);"><i
                        class="fas fa-arrow-left" style="width: 25px;"></i> Thoát Admin</a>
            </div>

            <div class="admin-main">
                <h1 style="margin-bottom: 30px;">Quản lý Bài viết</h1>

                <table class="admin-table">
                    <thead>
                        <tr>
                            <th>ID</th>
                            <th>Tác giả</th>
                            <th>Nội dung</th>
                            <th>Thống kê</th>
                            <th>Hành động</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach var="post" items="${listPosts}">
                            <tr>
                                <td>#${post.postId}</td>
                                <td>
                                    <div style="font-weight: bold;">${post.authorName}</div>
                                    <div style="color: var(--text-muted); font-size: 13px;">@${post.authorUsername}
                                    </div>
                                </td>
                                <td class="content-cell" title="${post.content}">${post.content}</td>
                                <td>
                                    <span style="color: var(--text-muted); margin-right: 10px;"><i
                                            class="fas fa-heart"></i> ${post.likeCount}</span>
                                    <span style="color: var(--text-muted);"><i class="fas fa-comment"></i>
                                        ${post.commentCount}</span>
                                </td>
                                <td>
                                    <form action="${pageContext.request.contextPath}/admin/posts" method="POST"
                                        style="margin: 0;">
                                        <input type="hidden" name="action" value="delete">
                                        <input type="hidden" name="postId" value="${post.postId}">
                                        <button type="submit" class="btn-primary"
                                            style="background-color: #f91880; padding: 6px 12px; font-size: 13px;"
                                            onclick="return confirm('Xóa vĩnh viễn bài đăng này?');">Xóa bài</button>
                                    </form>
                                </td>
                            </tr>
                        </c:forEach>
                    </tbody>
                </table>
            </div>
        </body>

        </html>