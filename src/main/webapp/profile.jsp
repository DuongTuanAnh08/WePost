<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
    <%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
        <%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
            <!DOCTYPE html>
            <html lang="vi">

            <head>
                <meta charset="UTF-8">
                <meta name="viewport" content="width=device-width, initial-scale=1.0">
                <title>
                    <c:out value="${profileUser.fullName}" /> / WePost
                </title>
                <!-- Thiết lập Base URL -->
                <base href="${pageContext.request.contextPath}/">
                <link rel="stylesheet" href="css/style.css">
                <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap"
                    rel="stylesheet">
                <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
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
                            <li class="nav-item" onclick="window.location.href='explore'">
                                <i class="fas fa-hashtag"></i>
                                <span class="nav-label">Khám phá</span>
                            </li>
                            <li class="nav-item" onclick="window.location.href='messages'">
                                <i class="far fa-envelope"></i>
                                <span class="nav-label">Tin nhắn</span>
                            </li>
                            <li class="nav-item active" onclick="window.location.href='profile'">
                                <i class="fas fa-user"></i>
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
                        </ul>
                    </nav>

                    <!-- Main Content (Profile) -->
                    <main class="main-content">
                        <!-- Header trang Profile -->
                        <!-- Header trang Profile đã được ẩn theo yêu cầu -->

                        <!-- Profile Info section. (Nạp Data từ DB SQL Server ProfileDAO) -->
                        <section class="profile-header">
                            <c:set var="userCover" value="images/covers/${profileUser.coverUrl}" />
                            <c:if test="${empty profileUser.coverUrl || profileUser.coverUrl == 'default-cover.jpg'}">
                                <c:set var="userCover"
                                    value="https://images.unsplash.com/photo-1579546929518-9e396f3cc809?q=80&w=1000&auto=format&fit=crop" />
                            </c:if>
                            <div class="profile-cover"
                                style="background-image: url('${userCover}'); background-size: cover; background-position: center;">
                            </div>
                            <div class="profile-info">

                                <c:choose>
                                    <c:when
                                        test="${not empty profileUser.avatarUrl && profileUser.avatarUrl != 'default-avatar.png'}">
                                        <img src="images/avatars/${profileUser.avatarUrl}" alt="Avatar"
                                            class="profile-avatar-large">
                                    </c:when>
                                    <c:otherwise>
                                        <img src="https://ui-avatars.com/api/?name=${fn:escapeXml(profileUser.fullName)}&background=random"
                                            alt="Avatar" class="profile-avatar-large">
                                    </c:otherwise>
                                </c:choose>

                                <!-- Chỉ hiện Nút Chỉnh Sửa nếu Đang xem Profile của chính mình (Auth Session Constraint) -->
                                <div class="profile-actions">
                                    <c:choose>
                                        <c:when test="${isMine}">
                                            <button class="btn-outline"
                                                onclick="window.location.href='edit-profile'">Chỉnh sửa hồ sơ</button>
                                        </c:when>
                                        <c:otherwise>
                                            <!-- Ngược lại: User Khác -> Hiện nút Kết bạn / Theo dõi -->
                                            <form action="api/follow" method="POST" style="margin: 0;">
                                                <input type="hidden" name="username"
                                                    value="<c:out value='${profileUser.username}' />">
                                                <c:choose>
                                                    <c:when test="${isFollowing}">
                                                        <input type="hidden" name="action" value="unfollow">
                                                        <button type="submit" class="btn-outline"
                                                            style="padding: 8px 16px;">Hủy Theo dõi</button>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <input type="hidden" name="action" value="follow">
                                                        <button type="submit" class="btn-primary"
                                                            style="padding: 8px 16px;">Theo dõi</button>
                                                    </c:otherwise>
                                                </c:choose>
                                            </form>
                                        </c:otherwise>
                                    </c:choose>
                                </div>

                                <div style="margin-top: 10px;">
                                    <h2 class="profile-name">
                                        <c:out value="${profileUser.fullName}" />
                                    </h2>
                                    <div class="profile-handle">@
                                        <c:out value="${profileUser.username}" />
                                    </div>

                                    <!-- Escape Bio XSS Protection -->
                                    <p class="profile-bio">
                                        <c:out value="${profileUser.bio}" />
                                    </p>

                                    <div style="display:flex; gap: 16px; font-size: 15px;">
                                        <span style="color: var(--text-muted);"><strong style="color:var(--text-main);">
                                                <c:out value="${countFollowing}" />
                                            </strong> Đang theo dõi</span>
                                        <span style="color: var(--text-muted);"><strong style="color:var(--text-main);">
                                                <c:out value="${countFollowers}" />
                                            </strong> Người theo dõi</span>
                                    </div>
                                </div>
                            </div>
                        </section>

                        <!-- Tabs -->
                        <div style="display:flex; border-bottom: 1px solid var(--border-color); padding-top: 10px;">
                            <a href="profile?u=${profileUser.username}&tab=posts"
                                style="padding:15px; flex:1; text-align:center; font-weight:700; color: ${activeTab == 'posts' ? 'var(--text-main)' : 'var(--text-muted)'}; border-bottom: ${activeTab == 'posts' ? '3px solid var(--primary-color)' : 'none'}; text-decoration: none;">
                                Bài đăng</a>
                            <a href="profile?u=${profileUser.username}&tab=likes"
                                style="padding:15px; flex:1; text-align:center; font-weight:700; color: ${activeTab == 'likes' ? 'var(--text-main)' : 'var(--text-muted)'}; border-bottom: ${activeTab == 'likes' ? '3px solid var(--primary-color)' : 'none'}; text-decoration: none;">
                                Lượt thích</a>
                        </div>

                        <!-- List User's own Posts (Hiển thị Lịch sử bài tự đăng) -->
                        <section class="feed">
                            <c:if test="${empty userPosts}">
                                <div style="padding: 20px; text-align: center; color: var(--text-muted);">
                                    Người dùng này chưa đăng bài viết nào.
                                </div>
                            </c:if>

                            <c:forEach var="post" items="${userPosts}">
                                <article class="post">
                                    <div style="display:flex; flex-direction: column; width: 100%;">
                                        <!-- Note repost nếu có -->
                                        <c:if test="${post.originalPostId > 0}">
                                            <div
                                                style="color: var(--text-muted); font-size: 13px; font-weight: 600; margin-bottom: 8px;">
                                                <i class="fas fa-retweet" style="margin-right: 5px;"></i>
                                                ${post.authorName} đã đăng lại
                                            </div>
                                        </c:if>

                                        <div style="display:flex; gap: 16px;">
                                            <c:choose>
                                                <c:when
                                                    test="${not empty post.authorAvatar && post.authorAvatar != 'default-avatar.png'}">
                                                    <img src="images/avatars/${post.authorAvatar}" alt="Avatar"
                                                        class="avatar">
                                                </c:when>
                                                <c:otherwise>
                                                    <img src="https://ui-avatars.com/api/?name=${fn:escapeXml(post.authorName)}&background=3b82f6&color=fff"
                                                        alt="Avatar" class="avatar">
                                                </c:otherwise>
                                            </c:choose>

                                            <div class="post-content-area" style="flex-grow: 1;">
                                                <div class="post-header">
                                                    <span class="post-author">
                                                        <c:out value="${post.authorName}" />
                                                    </span>
                                                    <span class="post-username">@
                                                        <c:out value="${post.authorUsername}" />
                                                    </span>
                                                    <span class="post-time">·
                                                        <c:out value="${post.createdAt}" />
                                                    </span>
                                                </div>

                                                <p class="post-text">
                                                    <c:out value="${post.content}" />
                                                </p>

                                                <!-- Hiển thị nội dung bài gốc nếu REPOST -->
                                                <c:if test="${post.originalPostId > 0 && post.originalPost != null}">
                                                    <div
                                                        style="border: 1px solid var(--border-color); border-radius: var(--radius-md); padding: 12px; margin-top: 10px; background: rgba(0,0,0,0.2);">
                                                        <div class="post-header">
                                                            <c:choose>
                                                                <c:when
                                                                    test="${post.originalPost.authorAvatar != 'default-avatar.png'}">
                                                                    <img src="images/avatars/${post.originalPost.authorAvatar}"
                                                                        alt="Original Avatar"
                                                                        style="width:24px; height:24px; border-radius:50%; object-fit:cover; margin-right:5px;">
                                                                </c:when>
                                                                <c:otherwise>
                                                                    <img src="https://ui-avatars.com/api/?name=${fn:escapeXml(post.originalPost.authorName)}&background=3b82f6&color=fff"
                                                                        alt="Original Avatar"
                                                                        style="width:24px; height:24px; border-radius:50%; object-fit:cover; margin-right:5px;">
                                                                </c:otherwise>
                                                            </c:choose>
                                                            <span class="post-author" style="font-size: 14px;">
                                                                <c:out value="${post.originalPost.authorName}" />
                                                            </span>
                                                            <span class="post-username" style="font-size: 13px;">@
                                                                <c:out value="${post.originalPost.authorUsername}" />
                                                            </span>
                                                        </div>
                                                        <p class="post-text" style="font-size: 15px; margin-top: 8px;">
                                                            <c:out value="${post.originalPost.content}" />
                                                        </p>
                                                    </div>
                                                </c:if>

                                                <!-- Hành động: Like, Comment, Repost -->
                                                <div class="post-actions"
                                                    style="display:flex; gap: 40px; margin-top:12px; color: var(--text-muted); user-select: none;">
                                                    <span
                                                        style="cursor:pointer; display: flex; align-items: center; gap: 8px; transition: color 0.2s;"
                                                        onclick="toggleComments(${post.postId})" class="action-btn">
                                                        <i class="far fa-comment"></i> <span
                                                            id="ccount-${post.postId}">${post.commentCount}</span>
                                                    </span>

                                                    <span
                                                        style="cursor:pointer; display: flex; align-items: center; gap: 8px; transition: color 0.2s;"
                                                        onclick="doRepost(${post.postId})" class="action-btn">
                                                        <i class="fas fa-retweet"></i> <span
                                                            id="rcount-${post.postId}">${post.repostCount}</span>
                                                    </span>

                                                    <span
                                                        style="cursor:pointer; display: flex; align-items: center; gap: 8px; transition: color 0.2s; color: ${post.likedByCurrentUser ? 'var(--danger-color)' : 'inherit'}"
                                                        onclick="toggleLike(${post.postId}, this)" class="action-btn">
                                                        <i
                                                            class="${post.likedByCurrentUser ? 'fas' : 'far'} fa-heart"></i>
                                                        <span class="like-count">${post.likeCount}</span>
                                                    </span>
                                                </div>

                                                <!-- Khu vực Comment (Ẩn mặc định) -->
                                                <div id="comments-section-${post.postId}"
                                                    style="display: none; margin-top: 15px; padding-top: 15px; border-top: 1px solid var(--border-color);">
                                                    <div id="comments-list-${post.postId}"
                                                        style="margin-bottom: 15px; max-height: 300px; overflow-y: auto;">
                                                        <div
                                                            style="text-align: center; color: var(--text-muted); font-size: 13px;">
                                                            Đang tải...</div>
                                                    </div>

                                                    <div style="display:flex; gap: 10px;">
                                                        <input type="text" id="comment-input-${post.postId}"
                                                            placeholder="Viết bình luận..."
                                                            style="flex-grow:1; background: var(--surface-color); border: 1px solid var(--border-color); border-radius: var(--radius-full); padding: 8px 15px; color: var(--text-main); outline:none;">
                                                        <button type="button" onclick="sendComment(${post.postId})"
                                                            style="background: var(--primary-color); color: white; border: none; padding: 0 15px; border-radius: var(--radius-full); cursor: pointer; font-weight: 600;">Gửi</button>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </article>
                            </c:forEach>
                        </section>
                    </main>
                </div>

                <script>
                    function toggleLike(postId, element) {
                        const icon = element.querySelector('i');
                        const countSpan = element.querySelector('.like-count');

                        const isLiked = icon.classList.contains('fas');
                        if (isLiked) {
                            icon.classList.remove('fas');
                            icon.classList.add('far');
                            element.style.color = 'inherit';
                            countSpan.innerText = parseInt(countSpan.innerText) - 1;
                        } else {
                            icon.classList.remove('far');
                            icon.classList.add('fas');
                            element.style.color = 'var(--danger-color)';
                            countSpan.innerText = parseInt(countSpan.innerText) + 1;
                        }

                        fetch('post-action', {
                            method: 'POST',
                            headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                            body: 'action=like&postId=' + postId
                        }).then(res => res.json()).then(data => {
                            if (!data.success) {
                                alert("Có lỗi xảy ra, vui lòng thử lại!");
                                window.location.reload();
                            }
                        }).catch(e => {
                            window.location.reload();
                        });
                    }

                    function doRepost(postId) {
                        if (confirm("Bạn có muốn đăng lại bài viết này lên tường nhà?")) {
                            fetch('post-action', {
                                method: 'POST',
                                headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                                body: 'action=repost&postId=' + postId
                            }).then(res => res.json()).then(data => {
                                if (data.success) {
                                    alert("Đăng lại thành công!");
                                    let span = document.getElementById('rcount-' + postId);
                                    span.innerText = parseInt(span.innerText) + 1;
                                } else {
                                    alert(data.message || "Không thể đăng lại!");
                                }
                            });
                        }
                    }

                    function toggleComments(postId) {
                        const section = document.getElementById('comments-section-' + postId);
                        if (section.style.display === 'none') {
                            section.style.display = 'block';
                            loadComments(postId);
                        } else {
                            section.style.display = 'none';
                        }
                    }

                    function loadComments(postId) {
                        fetch('post-action', {
                            method: 'POST',
                            headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                            body: 'action=get_comments&postId=' + postId
                        })
                            .then(res => res.json())
                            .then(data => {
                                if (data.success) {
                                    document.getElementById('comments-list-' + postId).innerHTML = data.html || "<div style='text-align:center; color: var(--text-muted); font-size:13px;'>Chưa có bình luận nào.</div>";
                                }
                            });
                    }

                    function sendComment(postId) {
                        const input = document.getElementById('comment-input-' + postId);
                        const content = input.value.trim();
                        if (!content) return;

                        fetch('post-action', {
                            method: 'POST',
                            headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                            body: 'action=comment&postId=' + postId + '&content=' + encodeURIComponent(content)
                        })
                            .then(res => res.json())
                            .then(data => {
                                if (data.success) {
                                    input.value = '';
                                    let span = document.getElementById('ccount-' + postId);
                                    span.innerText = parseInt(span.innerText) + 1;
                                    loadComments(postId);
                                } else {
                                    alert(data.message || "Lỗi bình luận!");
                                }
                            });
                    }
                </script>
            </body>

            </html>