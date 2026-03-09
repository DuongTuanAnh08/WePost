<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
    <%@ taglib uri="jakarta.tags.core" prefix="c" %>
        <%@ taglib uri="jakarta.tags.functions" prefix="fn" %>
            <!DOCTYPE html>
            <html lang="vi">

            <head>
                <meta charset="UTF-8">
                <meta name="viewport" content="width=device-width, initial-scale=1.0">
                <title>Chỉnh sửa Hồ Sơ / WePost</title>
                <!-- Thiết lập Base URL để load tĩnh CSS -->
                <base href="${pageContext.request.contextPath}/">
                <link rel="stylesheet" href="css/style.css">
                <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap"
                    rel="stylesheet">
                <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
                <style>
                    .edit-container {
                        max-width: 600px;
                        margin: 0 auto;
                        padding: 40px 20px;
                    }

                    .edit-header {
                        margin-bottom: 30px;
                        display: flex;
                        align-items: center;
                        gap: 15px;
                    }

                    .edit-title {
                        font-size: 24px;
                        font-weight: 800;
                    }

                    .form-group {
                        margin-bottom: 25px;
                    }

                    .form-label {
                        display: block;
                        margin-bottom: 8px;
                        font-weight: 600;
                        color: var(--text-main);
                    }

                    .form-input {
                        width: 100%;
                        padding: 12px;
                        background: var(--surface-color);
                        border: 1px solid var(--border-color);
                        border-radius: var(--radius-md);
                        color: var(--text-main);
                        font-size: 15px;
                        transition: all 0.2s;
                    }

                    .form-input:focus {
                        outline: none;
                        border-color: var(--primary-color);
                    }

                    .form-textarea {
                        width: 100%;
                        padding: 12px;
                        background: var(--surface-color);
                        border: 1px solid var(--border-color);
                        border-radius: var(--radius-md);
                        color: var(--text-main);
                        font-size: 15px;
                        font-family: inherit;
                        resize: vertical;
                        min-height: 100px;
                        transition: all 0.2s;
                    }

                    .form-textarea:focus {
                        outline: none;
                        border-color: var(--primary-color);
                    }

                    .error-message {
                        color: var(--danger-color);
                        background: rgba(239, 68, 68, 0.1);
                        padding: 15px;
                        border-radius: var(--radius-md);
                        margin-bottom: 20px;
                        font-weight: 500;
                    }

                    .avatar-upload-area {
                        display: flex;
                        align-items: center;
                        gap: 20px;
                        margin-bottom: 30px;
                    }

                    .avatar-preview {
                        width: 100px;
                        height: 100px;
                        border-radius: 50%;
                        object-fit: cover;
                        border: 2px solid var(--primary-color);
                    }

                    .upload-btn {
                        background: var(--surface-color);
                        border: 1px solid var(--border-color);
                        color: var(--text-main);
                        padding: 8px 16px;
                        border-radius: var(--radius-md);
                        cursor: pointer;
                        font-weight: 600;
                        font-size: 14px;
                        transition: all 0.2s;
                    }

                    .upload-btn:hover {
                        background: var(--border-color);
                    }

                    #avatarFile,
                    #coverFile {
                        display: none;
                    }

                    .cover-preview {
                        width: 100%;
                        height: 150px;
                        border-radius: var(--radius-md);
                        object-fit: cover;
                        border: 2px solid var(--border-color);
                        margin-bottom: 10px;
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
                            <li class="nav-item" onclick="window.location.href='explore'">
                                <i class="fas fa-hashtag"></i>
                                <span class="nav-label">Khám phá</span>
                            </li>
                            <li class="nav-item" onclick="window.location.href='messages'">
                                <i class="fas fa-envelope"></i>
                                <span class="nav-label">Tin nhắn</span>
                            </li>
                            <li class="nav-item active" onclick="window.location.href='profile'">
                                <i class="far fa-user"></i>
                                <span class="nav-label">Hồ sơ</span>
                            </li>
                        </ul>
                    </nav>

                    <!-- Main Content -->
                    <main class="main-content" style="padding: 0; background: var(--bg-color);">

                        <div class="edit-container">
                            <div class="edit-header">
                                <i class="fas fa-arrow-left"
                                    style="font-size: 20px; cursor: pointer; color: var(--text-muted);"
                                    onclick="history.back()"></i>
                                <h2 class="edit-title">Tùy chỉnh thông tin của bạn</h2>
                            </div>

                            <c:if test="${not empty error}">
                                <div class="error-message">
                                    <i class="fas fa-exclamation-circle" style="margin-right: 5px;"></i>
                                    <c:out value="${error}" />
                                </div>
                            </c:if>

                            <!-- 
                    ENCTYPE MUST BE MULTIPART FOR IMAGE UPLOADS ! 
                -->
                            <form action="edit-profile" method="POST" enctype="multipart/form-data">

                                <!-- Bìa (Cover) Chọn Tệp -->
                                <div class="form-group"
                                    style="padding-bottom: 20px; border-bottom: 1px solid var(--border-color);">
                                    <label class="form-label">Ảnh Bìa (Cover Photo)</label>

                                    <c:set var="userCover" value="images/covers/${user.coverUrl}" />
                                    <c:if test="${empty user.coverUrl || user.coverUrl == 'default-cover.jpg'}">
                                        <c:set var="userCover"
                                            value="https://images.unsplash.com/photo-1579546929518-9e396f3cc809?q=80&w=1000&auto=format&fit=crop" />
                                    </c:if>

                                    <!-- Khối hiển thị ảnh trước khi Up -->
                                    <img id="previewCover" src="${userCover}" alt="Cover Preview" class="cover-preview">

                                    <div>
                                        <label for="coverFile" class="upload-btn">
                                            <i class="fas fa-image" style="margin-right: 5px;"></i> Đổi Ảnh Bìa
                                        </label>
                                        <input type="file" id="coverFile" name="coverFile"
                                            accept="image/png, image/jpeg, image/gif">
                                        <span
                                            style="font-size: 13px; color: var(--text-muted); margin-left: 10px;">Thích
                                            hợp cho ảnh ngang</span>
                                    </div>
                                </div>

                                <!-- Avatar Chọn Tệp -->
                                <div class="form-group">
                                    <label class="form-label">Ảnh đại diện (Avatar)</label>
                                    <div class="avatar-upload-area">

                                        <c:set var="userAva" value="images/avatars/${user.avatarUrl}" />
                                        <c:if test="${empty user.avatarUrl || user.avatarUrl == 'default-avatar.png'}">
                                            <c:set var="userAva"
                                                value="https://ui-avatars.com/api/?name=${fn:escapeXml(user.fullName)}&background=3b82f6&color=fff" />
                                        </c:if>

                                        <!-- Khối hiển thị ảnh trước khi Up -->
                                        <img id="previewImage" src="${userAva}" alt="Avatar Preview"
                                            class="avatar-preview">

                                        <!-- Khối thao tác JS giả lập HTML File Input -->
                                        <div>
                                            <label for="avatarFile" class="upload-btn">
                                                <i class="fas fa-camera" style="margin-right: 5px;"></i> Tải ảnh mới lên
                                            </label>
                                            <input type="file" id="avatarFile" name="avatarFile"
                                                accept="image/png, image/jpeg, image/gif">
                                            <div style="font-size: 12px; color: var(--text-muted); margin-top: 10px;">
                                                Định dạng hỗ trợ: JPG, PNG, GIF (Tối đa 10MB)</div>
                                        </div>
                                    </div>
                                </div>

                                <div class="form-group">
                                    <label for="fullName" class="form-label">Tên hiển thị</label>
                                    <input type="text" id="fullName" name="fullName" class="form-input"
                                        value="<c:out value='${user.fullName}' />"
                                        placeholder="Thêm tên mà bạn muốn mọi người gọi bạn..." required>
                                </div>

                                <div class="form-group">
                                    <label for="bio" class="form-label">Tiểu sử</label>
                                    <textarea id="bio" name="bio" class="form-textarea"
                                        placeholder="Mô tả bản thân một cách ngắn gọn. Cái gì nổi bật về bạn?"><c:out value="${user.bio}" /></textarea>
                                    <div
                                        style="font-size: 12px; color: var(--text-muted); text-align: right; margin-top: 5px;">
                                        Tối đa 500 ký tự</div>
                                </div>

                                <div style="margin-top: 40px; text-align: right;">
                                    <button type="button" class="btn-outline" style="margin-right: 15px;"
                                        onclick="history.back()">Hủy bỏ</button>
                                    <button type="submit" class="btn-primary"
                                        style="padding: 12px 30px; font-weight: 700; font-size: 15px;">Lưu Thay
                                        Đổi</button>
                                </div>
                            </form>

                        </div>
                    </main>
                </div>

                <!-- Script Tự Đổi Ảnh Nhìn Thấy Cho Ngầu Khi Ấn Chọn File -->
                <script>
                    document.getElementById('avatarFile').addEventListener('change', function (event) {
                        const file = event.target.files[0];
                        if (file) {
                            // Giới hạn 10MB logic Front-End
                            if (file.size > 10 * 1024 * 1024) {
                                alert("Tệp của bạn quá lớn! Giới hạn tối đa là 10MB.");
                                this.value = '';
                                return;
                            }

                            const reader = new FileReader();
                            reader.onload = function (e) {
                                document.getElementById('previewImage').src = e.target.result;
                            }
                            reader.readAsDataURL(file);
                        }
                    });

                    document.getElementById('coverFile').addEventListener('change', function (event) {
                        const file = event.target.files[0];
                        if (file) {
                            if (file.size > 10 * 1024 * 1024) {
                                alert("Tệp bìa của bạn quá lớn! Giới hạn 10MB.");
                                this.value = '';
                                return;
                            }
                            const reader = new FileReader();
                            reader.onload = function (e) {
                                document.getElementById('previewCover').src = e.target.result;
                            }
                            reader.readAsDataURL(file);
                        }
                    });
                </script>
            </body>

            </html>