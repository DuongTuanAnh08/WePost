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
import java.util.List;

@WebServlet("/explore")
public class ExploreServlet extends HttpServlet {

    private final UserDAO userDAO = new UserDAO();
    private final com.wepost.dao.FriendDAO friendDAO = new com.wepost.dao.FriendDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("currentUser") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        User currUser = (User) session.getAttribute("currentUser");
        String keyword = request.getParameter("q");

        List<User> exploreUsers;
        List<User> pendingUsers = friendDAO.getPendingFollowers(currUser.getUserId());

        if (keyword != null && !keyword.trim().isEmpty()) {
            // Có từ khóa -> Tìm kiếm
            exploreUsers = userDAO.searchUsers(keyword.trim(), currUser.getUserId());
            request.setAttribute("searchKeyword", keyword.trim());
        } else {
            // Không từ khóa -> Đề xuất mặc định
            exploreUsers = userDAO.getRecommendedUsers(currUser.getUserId());
            // Loại bỏ những người đã nằm trong list Pending ra khỏi Khấu Explore để đỡ
            // trùng
            if (!pendingUsers.isEmpty() && !exploreUsers.isEmpty()) {
                exploreUsers.removeIf(u -> pendingUsers.stream().anyMatch(pu -> pu.getUserId() == u.getUserId()));
            }
        }

        request.setAttribute("exploreUsers", exploreUsers);
        request.setAttribute("pendingUsers", pendingUsers);
        request.getRequestDispatcher("/explore.jsp").forward(request, response);
    }
}
