package com.wepost.controller;

import com.wepost.dao.FriendDAO;
import com.wepost.dao.PostDAO;
import com.wepost.dao.UserDAO;
import com.wepost.model.Post;
import com.wepost.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;

@WebServlet("/profile")
public class ProfileServlet extends HttpServlet {

    private final UserDAO userDAO = new UserDAO();
    private final PostDAO postDAO = new PostDAO();
    private final FriendDAO friendDAO = new FriendDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("currentUser") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        User currUser = (User) session.getAttribute("currentUser");
        String targetUsername = request.getParameter("u");
        User targetUser;
        boolean isMine = false;
        boolean isFollowing = false;

        if (targetUsername == null || targetUsername.trim().isEmpty()
                || targetUsername.equals(currUser.getUsername())) {
            targetUser = currUser;
            isMine = true;
        } else {
            targetUser = userDAO.getUserByUsername(targetUsername);
            if (targetUser == null) {
                response.sendError(HttpServletResponse.SC_NOT_FOUND, "Người dùng không tồn tại");
                return;
            }
            // Check in Database if I am following this user
            isFollowing = friendDAO.isFollowing(currUser.getUserId(), targetUser.getUserId());
        }

        int countFollowing = friendDAO.countFollowing(targetUser.getUserId());
        int countFollowers = friendDAO.countFollowers(targetUser.getUserId());

        String tab = request.getParameter("tab");
        List<Post> userPosts;
        if ("likes".equals(tab)) {
            userPosts = postDAO.getLikedPostsByUserId(targetUser.getUserId(), currUser.getUserId());
        } else {
            userPosts = postDAO.getPostsByUserId(targetUser.getUserId(), currUser.getUserId());
        }

        request.setAttribute("profileUser", targetUser);
        request.setAttribute("userPosts", userPosts);
        request.setAttribute("isMine", isMine);
        request.setAttribute("isFollowing", isFollowing);
        request.setAttribute("countFollowing", countFollowing);
        request.setAttribute("countFollowers", countFollowers);
        request.setAttribute("activeTab", tab != null && tab.equals("likes") ? "likes" : "posts");

        request.getRequestDispatcher("/profile.jsp").forward(request, response);
    }
}
