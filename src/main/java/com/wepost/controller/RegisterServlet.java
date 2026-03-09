package com.wepost.controller;

import com.wepost.dao.UserDAO;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet("/register")
public class RegisterServlet extends HttpServlet {

    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Trả về view đăng ký
        request.getRequestDispatcher("/register.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8"); // Xử lý Tiếng Việt

        String username = request.getParameter("username");
        String passwordHash = request.getParameter("password"); // Thực tế sẽ sử dụng BCrypt
        String confirmPassword = request.getParameter("confirmPassword");
        String fullName = request.getParameter("fullName");

        // 1. Kiểm tra Validate Regex
        if (username == null || username.trim().isEmpty() || passwordHash == null || fullName == null) {
            request.setAttribute("errorMessage", "Vui lòng nhập đầy đủ tất cả thông tin.");
            request.getRequestDispatcher("/register.jsp").forward(request, response);
            return;
        }

        // 2. Validate mật khẩu khớp
        if (!passwordHash.equals(confirmPassword)) {
            request.setAttribute("errorMessage", "Mật khẩu xác nhận không trùng khớp.");
            request.getRequestDispatcher("/register.jsp").forward(request, response);
            return;
        }

        // 3. Kiểm tra xem Username đã tồn tại trong Database chưa
        if (userDAO.checkUsernameExists(username)) {
            request.setAttribute("errorMessage", "Tên đăng nhập này đã có người sử dụng. Vui lòng chọn tên khác!");
            request.getRequestDispatcher("/register.jsp").forward(request, response);
            return;
        }

        // 4. Nếu toàn bộ OK -> Gọi Database để chèn bản ghi mới
        boolean success = userDAO.registerUser(username, passwordHash, fullName);
        if (success) {
            // Đăng ký thành công -> Bắn thêm tham số sang trang đăng nhập để hiển thị màu
            // xanh
            request.setAttribute("successMessage", "Đăng ký thành công! Hãy đăng nhập hệ thống.");
            request.getRequestDispatcher("/login.jsp").forward(request, response);
        } else {
            // Lỗi kỹ thuật từ Database
            request.setAttribute("errorMessage", "Đã xảy ra lỗi cơ sở dữ liệu khi tạo tài khoản. Vui lòng thử lại.");
            request.getRequestDispatcher("/register.jsp").forward(request, response);
        }
    }
}
