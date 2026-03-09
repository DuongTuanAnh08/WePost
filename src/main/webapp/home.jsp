<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
    <%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
        <%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
            <!DOCTYPE html>
            <html lang="vi">

            <head>
                <meta charset="UTF-8">
                <meta name="viewport" content="width=device-width, initial-scale=1.0">
                <title>Trang chủ / WePost</title>
                <!-- Trỏ đến Servlet gốc -->
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
                            <li class="nav-item active" onclick="window.location.href='home'">
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
                            <li class="nav-item" style="margin-top: auto; color: var(--danger-color);"
                                onclick="window.location.href='logout'">
                                <i class="fas fa-sign-out-alt"></i>
                                <span class="nav-label">Đăng xuất</span>
                            </li>
                        </ul>
                    </nav>

                    <!-- Main Content -->
                    <main class="main-content">
                        <header class="top-header">
                            <h2 class="page-title">
                                <c:choose>
                                    <c:when test="${not empty searchQuery}">Kết quả cho:
                                        <c:out value="${searchQuery}" />
                                    </c:when>
                                    <c:otherwise>Dành cho bạn</c:otherwise>
                                </c:choose>
                            </h2>

                            <!-- Thanh tìm kiếm sử dụng form GET Map về HomeServlet -->
                            <div class="search-container">
                                <form action="home" method="GET">
                                    <input type="text" name="q" class="search-input"
                                        value="<c:out value='${searchQuery}'/>" placeholder="Tìm bài viết WePost">
                                    <button type="submit"
                                        style="background:transparent; border:none; position: absolute; right: 16px; top: 12px; cursor:pointer;">
                                        <i class="fas fa-search" style="color: var(--text-muted);"></i>
                                    </button>
                                </form>
                            </div>
                        </header>

                        <!-- Composer / Create Post: Gửi dữ liệu bằng POST cho CreatePost Endpoint -->
                        <section class="composer-box">
                            <!-- Session current user Avatar -->
                            <c:choose>
                                <c:when
                                    test="${not empty currentUser.avatarUrl && currentUser.avatarUrl != 'default-avatar.png'}">
                                    <img src="images/avatars/${currentUser.avatarUrl}" alt="Avatar" class="avatar">
                                </c:when>
                                <c:otherwise>
                                    <img src="https://ui-avatars.com/api/?name=${fn:escapeXml(currentUser.fullName)}&background=3b82f6&color=fff"
                                        alt="Avatar" class="avatar">
                                </c:otherwise>
                            </c:choose>
                            <form action="post" method="POST" class="composer-input-area" style="width: 100%;">
                                <!-- Bắt buộc Required theo UAT -->
                                <textarea name="content" id="postComposer" class="composer-textarea" rows="3"
                                    placeholder="Chuyện gì đang xảy ra? (Tối đa 500 ký tự)" required></textarea>

                                <div id="composerWarning"
                                    style="color: var(--danger-color); font-size: 13px; font-weight: 500; display: none; margin-bottom: 8px;">
                                    Bạn đã nhập tối đa 500 ký tự!
                                </div>

                                <div class="composer-actions">
                                    <div id="charCount"
                                        style="color: var(--text-muted); font-size: 13px; margin-right: 15px;">0/500
                                    </div>
                                    <button type="submit" class="btn-primary">Đăng</button>
                                </div>
                            </form>
                        </section>

                        <!-- News Feed Dynamic Loading từ DAO -->
                        <section class="feed">
                            <!-- Check if Posts list is empty due to search -->
                            <c:if test="${empty postsList}">
                                <div style="padding: 20px; text-align: center; color: var(--text-muted);">
                                    Không tìm thấy bài viết nào phù hợp. (No posts found).
                                </div>
                            </c:if>

                            <!-- JSTL Foreach Loop Data -->
                            <c:forEach var="post" items="${postsList}">
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
                                                        <!-- Danh sách Comment load bằng AJAX -->
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
                <!-- Scripts xử lý AJAX tương tác Bài viết -->
                <script>
                    function toggleLike(postId, element) {
                        const icon = element.querySelector('i');
                        const countSpan = element.querySelector('.like-count');

                        // Fake UI immediate update
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

                        // Gọi API Background
                        fetch('post-action', {
                            method: 'POST',
                            headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                            body: 'action=like&postId=' + postId
                        }).then(res => res.json()).then(data => {
                            if (!data.success) {
                                alert("Có lỗi xảy ra, vui lòng thử lại!");
                                window.location.reload(); // Revert
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
                                    loadComments(postId); // Reload danh sách ngay lập tức
                                } else {
                                    alert(data.message || "Lỗi bình luận!");
                                }
                            });
                    }

                    // Auto-resize cho textarea đăng bài (Composer)
                    const postComposer = document.getElementById('postComposer');
                    const charCount = document.getElementById('charCount');
                    const composerWarning = document.getElementById('composerWarning');

                    if (postComposer) {
                        postComposer.addEventListener('input', function () {
                            // Giới hạn hiển thị và gõ tiếng Việt max 500 ký tự (Chắn bù lỗ hổng unicode)
                            if (this.value.length > 500) {
                                this.value = this.value.substring(0, 500);
                            }

                            // Đếm ký tự
                            const currentLen = this.value.length;
                            charCount.textContent = currentLen + "/500";

                            // Cảnh báo nếu full
                            if (currentLen >= 500) {
                                composerWarning.style.display = 'block';
                                charCount.style.color = 'var(--danger-color)';
                            } else {
                                composerWarning.style.display = 'none';
                                charCount.style.color = 'var(--text-muted)';
                            }

                            this.style.height = 'auto'; // Reset để tính lại cao thực tế
                            let currentHeight = this.scrollHeight;

                            // Giới hạn max-height 300px trước khi bật scrollbar
                            if (currentHeight > 300) {
                                this.style.height = '300px';
                                this.style.overflowY = 'auto';
                            } else {
                                this.style.height = currentHeight + 'px';
                                this.style.overflowY = 'hidden';
                            }
                        });
                    }
                </script>
            </body>

            </html>