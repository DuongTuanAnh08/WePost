package com.wepost.controller.admin;

import com.wepost.dao.UserDAO;
import com.wepost.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.List;

@WebServlet("/admin/users")
public class AdminUserServlet extends HttpServlet {
    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        List<User> listUsers = userDAO.getAllUsers();
        request.setAttribute("listUsers", listUsers);
        request.getRequestDispatcher("/admin/users.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getParameter("action");
        if ("ban_unban".equals(action)) {
            int userId = Integer.parseInt(request.getParameter("userId"));
            boolean isBanned = Boolean.parseBoolean(request.getParameter("isBanned"));

            // Validate: Không được khóa bản thân
            HttpSession session = request.getSession();
            User currentUser = (User) session.getAttribute("currentUser");
            if (currentUser != null && currentUser.getUserId() != userId) {
                userDAO.updateUserStatus(userId, isBanned);
            }
        }
        response.sendRedirect(request.getContextPath() + "/admin/users");
    }
}
