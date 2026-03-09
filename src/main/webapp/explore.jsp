<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
    <%@ taglib uri="jakarta.tags.core" prefix="c" %>
        <%@ taglib uri="jakarta.tags.functions" prefix="fn" %>
            <!DOCTYPE html>
            <html lang="vi">

            <head>
                <meta charset="UTF-8">
                <meta name="viewport" content="width=device-width, initial-scale=1.0">
                <title>Khám phá / WePost</title>
                <!-- Thiết lập Base URL để load tĩnh CSS -->
                <base href="${pageContext.request.contextPath}/">
                <link rel="stylesheet" href="css/style.css">
                <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap"
                    rel="stylesheet">
                <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
                <style>
                    .search-hero {
                        padding: 30px 20px;
                        background: linear-gradient(180deg, rgba(59, 130, 246, 0.1) 0%, transparent 100%);
                        border-bottom: 1px solid var(--border-color);
                    }

                    .huge-search-input {
                        width: 100%;
                        padding: 16px 24px;
                        background: var(--surface-color);
                        border: 1px solid var(--border-color);
                        border-radius: 30px;
                        font-size: 16px;
                        color: var(--text-main);
                        box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);
                        transition: all 0.3s;
                    }

                    .huge-search-input:focus {
                        outline: none;
                        border-color: var(--primary-color);
                        box-shadow: 0 0 0 4px rgba(59, 130, 246, 0.15);
                    }

                    .relative-box {
                        position: relative;
                        max-width: 600px;
                        margin: 0 auto;
                    }

                    .search-btn {
                        position: absolute;
                        right: 8px;
                        top: 8px;
                        bottom: 8px;
                        background: var(--primary-color);
                        border: none;
                        border-radius: 20px;
                        color: white;
                        padding: 0 20px;
                        cursor: pointer;
                        font-weight: 600;
                    }

                    .explore-grid {
                        display: grid;
                        grid-template-columns: repeat(auto-fill, minmax(200px, 1fr));
                        gap: 20px;
                        padding: 20px;
                    }

                    .user-card {
                        background-color: var(--surface-color);
                        border: 1px solid var(--border-color);
                        border-radius: var(--radius-md);
                        padding: 24px 16px;
                        text-align: center;
                        transition: transform 0.2s;
                        display: flex;
                        flex-direction: column;
                        align-items: center;
                    }

                    .user-card:hover {
                        transform: translateY(-4px);
                        border-color: var(--primary-color);
                    }

                    .user-card-name {
                        font-weight: 700;
                        margin-top: 12px;
                        font-size: 16px;
                        color: var(--text-main);
                    }

                    .user-card-handle {
                        font-size: 13px;
                        color: var(--text-muted);
                        margin-bottom: 15px;
                    }

                    .btn-view-profile {
                        margin-top: auto;
                        background: transparent;
                        border: 1px solid var(--border-color);
                        color: var(--text-main);
                        padding: 8px 16px;
                        border-radius: 20px;
                        font-size: 13px;
                        font-weight: 600;
                        cursor: pointer;
                        width: 100%;
                        transition: all 0.2s;
                    }

                    .btn-view-profile:hover {
                        background: var(--primary-color);
                        border-color: var(--primary-color);
                        color: white;
                    }

                    a.card-link {
                        text-decoration: none;
                        color: inherit;
                        display: contents;
                    }
                </style>
            </head>

            <body>
                <div class="app-container">
                    <!-- Sidebar Navigation -->
                    <nav class="sidebar">
                        <h1 class="logo">WePost</h1>
                        <ul class="nav-menu">
                            <li class="nav-item" onclick="window.location.href='home'">
                                <i class="fas fa-home"></i>
                                <span class="nav-label">Trang chủ</span>
                            </li>
                            <li class="nav-item active" onclick="window.location.href='explore'">
                                <i class="fas fa-hashtag"></i>
                                <span class="nav-label">Khám phá</span>
                            </li>
                            <li class="nav-item" onclick="window.location.href='messages'">
                                <i class="fas fa-envelope"></i>
                                <span class="nav-label">Tin nhắn</span>
                            </li>
                            <li class="nav-item" onclick="window.location.href='profile'">
                                <i class="far fa-user"></i>
                                <span class="nav-label">Hồ sơ</span>
                            </li>
                            <!-- Nút Admin (Chỉ hiện cho Role ADMIN) -->
                            <c:if test="${currentUser != null && currentUser.role == 'ADMIN'}">
                                <li class="nav-item" onclick="window.location.href='admin/dashboard'"
                                    style="color: var(--primary-color);">
                                    <i class="fas fa-shield-alt"></i>
                                    <span class="nav-label">Quản trị</span>
                                </li>
                            </c:if>
                            <!-- Nút Đăng xuất -->
                        </ul>
                    </nav>

                    <!-- Main Content -->
                    <main class="main-content" style="padding: 0;">
                        <header class="top-header"
                            style="border-bottom: 1px solid var(--border-color); padding: 16px 20px;">
                            <h2 class="page-title">Khám phá</h2>
                        </header>

                        <div class="search-hero">
                            <form action="explore" method="GET" class="relative-box">
                                <input type="text" name="q" class="huge-search-input"
                                    placeholder="Tìm kiếm mọi người trên WePost..."
                                    value="<c:out value='${searchKeyword}' />">
                                <button type="submit" class="search-btn">Tìm kiếm</button>
                            </form>
                        </div>

                        <!-- Pending Users / Người chờ kết nối -->
                        <c:if test="${not empty pendingUsers}">
                            <div style="padding: 20px 20px 0;">
                                <h3 style="font-size: 18px; margin-bottom: 10px; color: var(--primary-color);">
                                    <i class="fas fa-star" style="margin-right: 8px;"></i> Những người muốn kết nối với
                                    bạn
                                </h3>
                            </div>
                            <div class="explore-grid" style="padding-bottom: 0; padding-top: 10px;">
                                <c:forEach var="pu" items="${pendingUsers}">
                                    <c:set var="puAva" value="images/avatars/${pu.avatarUrl}" />
                                    <c:if test="${empty pu.avatarUrl || pu.avatarUrl == 'default-avatar.png'}">
                                        <c:set var="puAva"
                                            value="https://ui-avatars.com/api/?name=${fn:escapeXml(pu.fullName)}&background=10b981&color=fff" />
                                    </c:if>

                                    <div class="user-card"
                                        style="border-color: var(--primary-color); background: rgba(59, 130, 246, 0.03);">
                                        <img src="${puAva}" alt="Avatar"
                                            style="width: 80px; height: 80px; border-radius: 50%; object-fit: cover; margin-bottom: 12px; border: 3px solid var(--primary-color);">
                                        <div class="user-card-name">
                                            <c:out value="${pu.fullName}" />
                                        </div>
                                        <div class="user-card-handle">@
                                            <c:out value="${pu.username}" />
                                        </div>

                                        <a href="profile?u=<c:out value='${pu.username}' />"
                                            style="width: 100%; text-decoration: none;">
                                            <button class="btn-primary"
                                                style="width: 100%; padding: 8px 16px; border-radius: 20px; font-weight: 600;">Xem
                                                & Theo dõi</button>
                                        </a>
                                    </div>
                                </c:forEach>
                            </div>
                            <hr style="border: 0; border-top: 1px solid var(--border-color); margin: 20px 20px 0;">
                        </c:if>

                        <div style="padding: 20px 20px 0;">
                            <h3 style="font-size: 18px; margin-bottom: 10px;">
                                <c:choose>
                                    <c:when test="${not empty searchKeyword}">
                                        Kết quả cho "
                                        <c:out value="${searchKeyword}" />"
                                    </c:when>
                                    <c:otherwise>
                                        Gợi ý từ cộng đồng WePost
                                    </c:otherwise>
                                </c:choose>
                            </h3>
                        </div>

                        <div class="explore-grid">
                            <c:if test="${empty exploreUsers}">
                                <div
                                    style="grid-column: 1 / -1; text-align: center; padding: 40px; color: var(--text-muted);">
                                    <i class="fas fa-search"
                                        style="font-size: 48px; margin-bottom: 16px; opacity: 0.5;"></i>
                                    <h3>Không tìm thấy ai phù hợp</h3>
                                    <p>Hãy thử tìm kiếm bằng một từ khóa khác nhé.</p>
                                </div>
                            </c:if>

                            <c:forEach var="u" items="${exploreUsers}">
                                <!-- Nạp Avatar Logic -->
                                <c:set var="uAva" value="images/avatars/${u.avatarUrl}" />
                                <c:if test="${empty u.avatarUrl || u.avatarUrl == 'default-avatar.png'}">
                                    <c:set var="uAva"
                                        value="https://ui-avatars.com/api/?name=${fn:escapeXml(u.fullName)}&background=random" />
                                </c:if>

                                <div class="user-card">
                                    <img src="${uAva}" alt="Avatar"
                                        style="width: 80px; height: 80px; border-radius: 50%; object-fit: cover; margin-bottom: 12px; border: 3px solid var(--border-color);">
                                    <div class="user-card-name">
                                        <c:out value="${u.fullName}" />
                                    </div>
                                    <div class="user-card-handle">@
                                        <c:out value="${u.username}" />
                                    </div>

                                    <a href="profile?u=<c:out value='${u.username}' />"
                                        style="width: 100%; text-decoration: none;">
                                        <button class="btn-view-profile">Xem hồ sơ</button>
                                    </a>
                                </div>
                            </c:forEach>
                        </div>
                    </main>
                </div>
            </body>

            </html>