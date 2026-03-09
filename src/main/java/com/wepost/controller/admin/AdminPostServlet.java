package com.wepost.controller.admin;

import com.wepost.dao.PostDAO;
import com.wepost.model.Post;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.List;

@WebServlet("/admin/posts")
public class AdminPostServlet extends HttpServlet {
    private final PostDAO postDAO = new PostDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        List<Post> listPosts = postDAO.getAllPostsAdmin();
        request.setAttribute("listPosts", listPosts);
        request.getRequestDispatcher("/admin/posts.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getParameter("action");
        if ("delete".equals(action)) {
            int postId = Integer.parseInt(request.getParameter("postId"));
            postDAO.deletePost(postId);
        }
        response.sendRedirect(request.getContextPath() + "/admin/posts");
    }
}
