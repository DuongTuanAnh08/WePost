package com.wepost.dao;

import com.wepost.db.DBConnection;
import com.wepost.model.Post;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class ProfileDAO {

    /**
     * Lấy danh sách các bài đăng của một User cụ thể (dựa vào UserID)
     * Trả về danh sách Post kèm theo tên tác giả
     */
    public List<Post> getPostsByUserId(int userId) {
        List<Post> posts = new ArrayList<>();
        String sql = "SELECT p.PostID, p.UserID, p.Content, p.CreatedAt, " +
                "u.Username, u.FullName, u.AvatarUrl " +
                "FROM Posts p " +
                "INNER JOIN Users u ON p.UserID = u.UserID " +
                "WHERE p.UserID = ? " +
                "ORDER BY p.CreatedAt DESC";

        try (Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {

            // Truyền UserId vào parameter tránh SQL Injections
            ps.setInt(1, userId);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    posts.add(mapResultSetToPost(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return posts;
    }

    private Post mapResultSetToPost(ResultSet rs) throws SQLException {
        Post post = new Post();
        post.setPostId(rs.getInt("PostID"));
        post.setUserId(rs.getInt("UserID"));
        post.setContent(rs.getString("Content"));
        post.setCreatedAt(rs.getTimestamp("CreatedAt"));

        post.setAuthorName(rs.getString("FullName"));
        post.setAuthorUsername(rs.getString("Username"));
        post.setAuthorAvatar(rs.getString("AvatarUrl"));
        return post;
    }
}
