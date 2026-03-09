package com.wepost.controller;

import com.wepost.dao.FriendDAO;
import com.wepost.dao.UserDAO;
import com.wepost.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

@WebServlet("/api/follow")
public class FollowServlet extends HttpServlet {

    private final FriendDAO friendDAO = new FriendDAO();
    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("currentUser") == null) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            return;
        }

        User currUser = (User) session.getAttribute("currentUser");
        String action = request.getParameter("action");
        String targetUsername = request.getParameter("username");

        if (action == null || targetUsername == null) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            return;
        }

        User targetUser = userDAO.getUserByUsername(targetUsername);
        if (targetUser == null) {
            response.setStatus(HttpServletResponse.SC_NOT_FOUND);
            return;
        }

        boolean success = false;
        if ("follow".equals(action)) {
            success = friendDAO.followUser(currUser.getUserId(), targetUser.getUserId());
        } else if ("unfollow".equals(action)) {
            success = friendDAO.unfollowUser(currUser.getUserId(), targetUser.getUserId());
        }

        if (success) {
            // Send URL redirect back logic for simple form submission support
            // but we can also handle JSON response if called by Fetch.
            // Support form submission to redirect back
            response.sendRedirect(request.getContextPath() + "/profile?u=" + targetUsername);
        } else {
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Lỗi thao tác Database");
        }
    }
}
