package com.wepost.controller;

import com.wepost.dao.PostDAO;
import com.wepost.model.User;
import com.wepost.model.Comment;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;

@WebServlet("/post-action")
public class PostActionServlet extends HttpServlet {

    private final PostDAO postDAO = new PostDAO();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("currentUser") == null) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            out.print("{\"success\":false,\"message\":\"Unauthorized\"}");
            return;
        }

        User user = (User) session.getAttribute("currentUser");
        String action = request.getParameter("action");
        String postIdStr = request.getParameter("postId");

        if (action == null || postIdStr == null) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            out.print("{\"success\":false,\"message\":\"Missing parameters\"}");
            return;
        }

        int postId;
        try {
            postId = Integer.parseInt(postIdStr);
        } catch (NumberFormatException e) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            out.print("{\"success\":false,\"message\":\"Invalid postId\"}");
            return;
        }

        try {
            switch (action) {
                case "like":
                    boolean likeSuccess = postDAO.toggleLike(user.getUserId(), postId);
                    out.print("{\"success\":" + likeSuccess + "}");
                    break;

                case "comment":
                    String content = request.getParameter("content");
                    if (content == null || content.trim().isEmpty()) {
                        out.print("{\"success\":false,\"message\":\"Comment content cannot be empty\"}");
                        return;
                    }
                    boolean commentSuccess = postDAO.addComment(user.getUserId(), postId, content.trim());
                    out.print("{\"success\":" + commentSuccess + "}");
                    break;

                case "repost":
                    // Content cho repost có thể để mặc định là "Đã chia sẻ một bài viết"
                    String repostContent = "Tôi đã chia sẻ bài viết này!";
                    boolean repostSuccess = postDAO.createRepost(user.getUserId(), repostContent, postId);
                    out.print("{\"success\":" + repostSuccess + "}");
                    break;

                case "get_comments":
                    List<Comment> comments = postDAO.getCommentsByPostId(postId);
                    // Dựng JSON tay cho lẹ, nếu dùng thư viện GSON thì càng tốt, mình trả HTML
                    // Fragment luôn cho nhàn Front-end nhé.
                    StringBuilder html = new StringBuilder();
                    for (Comment c : comments) {
                        html.append(
                                "<div class='comment-item' style='display: flex; gap: 10px; margin-bottom: 10px; padding: 10px; background: rgba(255,255,255,0.05); border-radius: 8px;'>");
                        html.append("<img src='images/avatars/").append(c.getAuthorAvatar())
                                .append("' style='width:30px; height:30px; border-radius:50%; object-fit: cover;'>");
                        html.append("<div>");
                        html.append("<div style='font-weight:bold; font-size: 14px;'>").append(c.getAuthorName())
                                .append("</div>");
                        html.append("<div style='font-size: 14px;'>")
                                .append(c.getContent().replace("<", "&lt;").replace(">", "&gt;")).append("</div>");
                        html.append("</div>");
                        html.append("</div>");
                    }
                    out.print("{\"success\":true,\"html\":\""
                            + html.toString().replace("\"", "\\\"").replace("\n", "\\n") + "\"}");
                    break;

                default:
                    response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                    out.print("{\"success\":false,\"message\":\"Unknown action\"}");
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            out.print("{\"success\":false,\"message\":\"Server error\"}");
        }
    }
}
