package com.wepost.controller;

import com.wepost.dao.PostDAO;
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

/**
 * Controller xử lý luồng trang chủ: Load bảng tin (Global Feed) / Post dữ liệu
 */
@WebServlet({ "/home", "/post" })
public class HomeServlet extends HttpServlet {

    private final PostDAO postDAO = new PostDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);

        // Security Authentication Filter (Session Hijack Prevention / Negative Testing
        // Constraint Layer)
        if (session == null || session.getAttribute("currentUser") == null) {
            // Chưa đăng nhập thì phải redirect về login.
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        User currentUser = (User) session.getAttribute("currentUser");

        // Luồng lấy Data Search (nếu có tham số `q` từ Form HTML)
        String searchQuery = request.getParameter("q");
        List<Post> feedPosts;

        if (searchQuery != null && !searchQuery.trim().isEmpty()) {
            feedPosts = postDAO.searchPostsByKeyword(searchQuery, currentUser.getUserId());
            request.setAttribute("searchQuery", searchQuery); // Bind trở lại Textbox
        } else {
            feedPosts = postDAO.getGlobalFeed(currentUser.getUserId());
        }

        // Truyền list post Model vào JSTL để loop ngoài trang jsp
        request.setAttribute("postsList", feedPosts);

        // Trả Front-end view là home.jsp
        // Lưu ý: Đổi tên HTML cũ home.html sang JSP để nhúng code Java
        request.getRequestDispatcher("/home.jsp").forward(request, response);
    }

    // Endpoint POST sử dụng để 'Đăng bài mới' lên DB.
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8"); // Encoding tiếng việt

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("currentUser") == null) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        User user = (User) session.getAttribute("currentUser");
        String content = request.getParameter("content");

        // Edge case: Đăng bài trống.
        if (content != null && !content.trim().isEmpty()) {
            // Xử lý Escape String JS / XSS sẽ chạy trên Template <c:out> JSP hoặc
            // encodeContent() custom nếu muốn
            postDAO.createPost(user.getUserId(), content);
        }

        // Post xong reload Data mới nhất
        response.sendRedirect(request.getContextPath() + "/home");
    }
}
