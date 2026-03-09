package com.wepost.controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

@WebServlet("/messages")
public class ChatServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("currentUser") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        // Tải danh sách bạn bè, hoặc giao diện mặc định chat
        com.wepost.dao.FriendDAO friendDAO = new com.wepost.dao.FriendDAO();
        java.util.List<com.wepost.model.User> friendList = friendDAO
                .getMutualFriends(((com.wepost.model.User) session.getAttribute("currentUser")).getUserId());
        request.setAttribute("friendList", friendList);

        // Hiện tại ta trực tiếp sang JSP
        request.getRequestDispatcher("/chat.jsp").forward(request, response);
    }
}
