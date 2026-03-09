package com.wepost.controller;

import com.wepost.dao.UserDAO;
import com.wepost.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

@WebServlet("/login")
public class LoginServlet extends HttpServlet {

    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Trả về trang giao diện đăng nhập (ẩn hiện giờ)
        request.getRequestDispatcher("/login.html").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String username = request.getParameter("username");
        String passwordHash = request.getParameter("password"); // Trong thực tế sẽ được hashing bằng BCrypt

        // Chống SQL Injection bằng Object DAO (đã dùng PreparedStatement)
        User user = userDAO.authenticate(username, passwordHash);

        if (user != null) {
            // Kiểm tra trạng thái Ban
            if (user.isBanned()) {
                request.setAttribute("errorMessage", "Tài khoản của bạn đã bị khóa do vi phạm.");
                request.getRequestDispatcher("/login.html").forward(request, response);
                return;
            }

            // Mở Session Hijacking Prevention (Thiết lập Session ID gốc)
            HttpSession session = request.getSession();
            session.setAttribute("currentUser", user);

            // Đăng nhập thành công, Redirect về Trang Chủ chung (News Feed)
            response.sendRedirect(request.getContextPath() + "/home");
        } else {
            // Authentication Failed
            request.setAttribute("errorMessage", "Tài khoản hoặc mật khẩu không chính xác.");
            request.getRequestDispatcher("/login.html").forward(request, response);
        }
    }
}
