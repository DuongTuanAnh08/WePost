<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
    <%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
        <!DOCTYPE html>
        <html lang="vi">

        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>Đăng nhập / WePost</title>
            <!-- Thiết lập Base URL để load tĩnh CSS -->
            <base href="${pageContext.request.contextPath}/">
            <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap"
                rel="stylesheet">
            <style>
                /* CSS nội bộ riêng cho form Đăng nhập đảm bảo Aesthetics Premium */
                :root {
                    --bg-color: #0f172a;
                    --surface-color: #1e293b;
                    --primary-color: #3b82f6;
                    --primary-hover: #2563eb;
                    --text-main: #f8fafc;
                    --text-muted: #94a3b8;
                    --border-color: #334155;
                    --danger-color: #ef4444;
                    --radius-md: 12px;
                    --radius-lg: 16px;
                }

                * {
                    margin: 0;
                    padding: 0;
                    box-sizing: border-box;
                    font-family: 'Inter', system-ui, sans-serif;
                }

                body {
                    background-color: var(--bg-color);
                    color: var(--text-main);
                    display: flex;
                    justify-content: center;
                    align-items: center;
                    min-height: 100vh;
                    -webkit-font-smoothing: antialiased;
                }

                .auth-container {
                    background-color: var(--surface-color);
                    width: 100%;
                    max-width: 420px;
                    padding: 40px;
                    border-radius: var(--radius-lg);
                    box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.5);
                    border: 1px solid var(--border-color);
                }

                .logo-text {
                    font-size: 32px;
                    font-weight: 800;
                    color: var(--primary-color);
                    text-align: center;
                    margin-bottom: 8px;
                    letter-spacing: -1px;
                }

                .subtitle {
                    text-align: center;
                    color: var(--text-muted);
                    margin-bottom: 32px;
                    font-size: 15px;
                }

                .form-group {
                    margin-bottom: 20px;
                }

                .form-label {
                    display: block;
                    margin-bottom: 8px;
                    font-size: 14px;
                    font-weight: 500;
                    color: var(--text-muted);
                }

                .form-input {
                    width: 100%;
                    background-color: var(--bg-color);
                    border: 1px solid var(--border-color);
                    color: var(--text-main);
                    padding: 12px 16px;
                    border-radius: var(--radius-md);
                    font-size: 15px;
                    transition: all 0.2s;
                }

                .form-input:focus {
                    outline: none;
                    border-color: var(--primary-color);
                    box-shadow: 0 0 0 3px rgba(59, 130, 246, 0.1);
                }

                .btn-submit {
                    width: 100%;
                    background-color: var(--primary-color);
                    color: white;
                    border: none;
                    padding: 14px;
                    border-radius: var(--radius-md);
                    font-size: 16px;
                    font-weight: 600;
                    cursor: pointer;
                    transition: all 0.2s;
                    margin-top: 10px;
                }

                .btn-submit:hover {
                    background-color: var(--primary-hover);
                    transform: translateY(-2px);
                }

                .error-message {
                    background-color: rgba(239, 68, 68, 0.1);
                    color: var(--danger-color);
                    padding: 12px;
                    border-radius: var(--radius-md);
                    border: 1px solid rgba(239, 68, 68, 0.2);
                    margin-bottom: 20px;
                    font-size: 14px;
                    text-align: center;
                }

                .footer-link {
                    text-align: center;
                    margin-top: 24px;
                    font-size: 14px;
                    color: var(--text-muted);
                }

                .footer-link a {
                    color: var(--primary-color);
                    text-decoration: none;
                    font-weight: 500;
                }

                .footer-link a:hover {
                    text-decoration: underline;
                }
            </style>
        </head>

        <body>

            <div class="auth-container">
                <h1 class="logo-text">WePost</h1>
                <p class="subtitle">Kết nối với thế giới của bạn</p>

                <!-- Hiển thị Alert nếu Đăng nhập thất bại (Dựa vào String ErrorMessage Java ném sang) -->
                <c:if test="${not empty errorMessage}">
                    <div class="error-message">
                        <c:out value="${errorMessage}" />
                    </div>
                </c:if>

                <!-- Hiển thị Alert khi Đăng ký thành công -->
                <c:if test="${not empty successMessage}">
                    <div class="error-message"
                        style="background-color: rgba(34, 197, 94, 0.1); color: #22c55e; border-color: rgba(34, 197, 94, 0.2);">
                        <c:out value="${successMessage}" />
                    </div>
                </c:if>

                <!-- Endpoint: LoginServlet (POST) -->
                <form action="login" method="POST">
                    <div class="form-group">
                        <label for="username" class="form-label">Tên người dùng</label>
                        <input type="text" id="username" name="username" class="form-input"
                            placeholder="Nhập tên đăng nhập của bạn (VD: alexdev)" required>
                    </div>

                    <div class="form-group">
                        <label for="password" class="form-label">Mật khẩu</label>
                        <!-- Tham khảo Dummy Data: Sử dụng password (hash_123) để test Login -->
                        <input type="password" id="password" name="password" class="form-input"
                            placeholder="Nhập mật khẩu (VD: hash_123)" required>
                    </div>

                    <button type="submit" class="btn-submit">Đăng nhập ngay</button>
                </form>

                <div class="footer-link">
                    Chưa có tài khoản? <a href="register">Đăng ký ngay</a>
                </div>
            </div>

        </body>

        </html>