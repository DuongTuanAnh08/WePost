package com.wepost.dao;

import com.wepost.db.DBConnection;
import com.wepost.model.Post;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class PostDAO {

    /**
     * Tối ưu truy vấn SQL: Lấy 50 bài viết mới nhất trên toàn hệ
     * thống kèm join User table và đếm Like, Comment, Repost
     */
    public List<Post> getGlobalFeed(int currentUserId) {
        List<Post> posts = new ArrayList<>();
        String sql = "SELECT TOP 50 p.PostID, p.UserID, p.Content, p.OriginalPostID, p.CreatedAt, " +
                "u.Username, u.FullName, u.AvatarUrl, " +
                "(SELECT COUNT(*) FROM Likes WHERE PostID = p.PostID) as LikeCount, " +
                "(SELECT COUNT(*) FROM Comments WHERE PostID = p.PostID) as CommentCount, " +
                "(SELECT COUNT(*) FROM Posts WHERE OriginalPostID = p.PostID) as RepostCount, " +
                "(SELECT CASE WHEN EXISTS (SELECT 1 FROM Likes WHERE PostID = p.PostID AND UserID = ?) THEN 1 ELSE 0 END) as IsLiked "
                +
                "FROM Posts p " +
                "INNER JOIN Users u ON p.UserID = u.UserID " +
                "ORDER BY p.CreatedAt DESC";

        try (Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, currentUserId);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    posts.add(mapResultSetToPost(rs, conn));
                }
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }
        return posts;
    }

    /**
     * Tìm kiếm bài viết bằng LIKE Operator
     */
    public List<Post> searchPostsByKeyword(String keyword, int currentUserId) {
        List<Post> posts = new ArrayList<>();
        String sql = "SELECT TOP 20 p.PostID, p.UserID, p.Content, p.OriginalPostID, p.CreatedAt, " +
                "u.Username, u.FullName, u.AvatarUrl, " +
                "(SELECT COUNT(*) FROM Likes WHERE PostID = p.PostID) as LikeCount, " +
                "(SELECT COUNT(*) FROM Comments WHERE PostID = p.PostID) as CommentCount, " +
                "(SELECT COUNT(*) FROM Posts WHERE OriginalPostID = p.PostID) as RepostCount, " +
                "(SELECT CASE WHEN EXISTS (SELECT 1 FROM Likes WHERE PostID = p.PostID AND UserID = ?) THEN 1 ELSE 0 END) as IsLiked "
                +
                "FROM Posts p " +
                "INNER JOIN Users u ON p.UserID = u.UserID " +
                "WHERE p.Content LIKE ? " +
                "ORDER BY p.CreatedAt DESC";

        try (Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, currentUserId);
            ps.setString(2, "%" + keyword + "%");

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    posts.add(mapResultSetToPost(rs, conn));
                }
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }
        return posts;
    }

    /**
     * Lấy danh sách bài viết theo UserID (dùng cho tab Profile)
     */
    public List<Post> getPostsByUserId(int requestedUserId, int currentUserId) {
        List<Post> posts = new ArrayList<>();
        String sql = "SELECT p.PostID, p.UserID, p.Content, p.OriginalPostID, p.CreatedAt, " +
                "u.Username, u.FullName, u.AvatarUrl, " +
                "(SELECT COUNT(*) FROM Likes WHERE PostID = p.PostID) as LikeCount, " +
                "(SELECT COUNT(*) FROM Comments WHERE PostID = p.PostID) as CommentCount, " +
                "(SELECT COUNT(*) FROM Posts WHERE OriginalPostID = p.PostID) as RepostCount, " +
                "(SELECT CASE WHEN EXISTS (SELECT 1 FROM Likes WHERE PostID = p.PostID AND UserID = ?) THEN 1 ELSE 0 END) as IsLiked "
                +
                "FROM Posts p " +
                "INNER JOIN Users u ON p.UserID = u.UserID " +
                "WHERE p.UserID = ? " +
                "ORDER BY p.CreatedAt DESC";

        try (Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, currentUserId);
            ps.setInt(2, requestedUserId);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    posts.add(mapResultSetToPost(rs, conn));
                }
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }
        return posts;
    }

    /**
     * Lấy danh sách bài viết mà User đã Thích (Lượt thích)
     */
    public List<Post> getLikedPostsByUserId(int requestedUserId, int currentUserId) {
        List<Post> posts = new ArrayList<>();
        String sql = "SELECT p.PostID, p.UserID, p.Content, p.OriginalPostID, p.CreatedAt, " +
                "u.Username, u.FullName, u.AvatarUrl, " +
                "(SELECT COUNT(*) FROM Likes WHERE PostID = p.PostID) as LikeCount, " +
                "(SELECT COUNT(*) FROM Comments WHERE PostID = p.PostID) as CommentCount, " +
                "(SELECT COUNT(*) FROM Posts WHERE OriginalPostID = p.PostID) as RepostCount, " +
                "(SELECT CASE WHEN EXISTS (SELECT 1 FROM Likes WHERE PostID = p.PostID AND UserID = ?) THEN 1 ELSE 0 END) as IsLiked "
                +
                "FROM Posts p " +
                "INNER JOIN Users u ON p.UserID = u.UserID " +
                "INNER JOIN Likes l ON p.PostID = l.PostID " +
                "WHERE l.UserID = ? " +
                "ORDER BY l.CreatedAt DESC";

        try (Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, currentUserId);
            ps.setInt(2, requestedUserId);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    posts.add(mapResultSetToPost(rs, conn));
                }
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }
        return posts;
    }

    /**
     * Lấy duy nhất 1 bài viết bằng PostID (để phục vụ Repost)
     */
    public Post getPostById(int postId, int currentUserId, Connection conn) {
        String sql = "SELECT p.PostID, p.UserID, p.Content, p.OriginalPostID, p.CreatedAt, " +
                "u.Username, u.FullName, u.AvatarUrl, " +
                "(SELECT COUNT(*) FROM Likes WHERE PostID = p.PostID) as LikeCount, " +
                "(SELECT COUNT(*) FROM Comments WHERE PostID = p.PostID) as CommentCount, " +
                "(SELECT COUNT(*) FROM Posts WHERE OriginalPostID = p.PostID) as RepostCount, " +
                "(SELECT CASE WHEN EXISTS (SELECT 1 FROM Likes WHERE PostID = p.PostID AND UserID = ?) THEN 1 ELSE 0 END) as IsLiked "
                +
                "FROM Posts p " +
                "INNER JOIN Users u ON p.UserID = u.UserID " +
                "WHERE p.PostID = ?";

        // Sử dụng connection có sẵn hoặc mượn mới
        boolean shouldClose = false;
        try {
            if (conn == null || conn.isClosed()) {
                conn = DBConnection.getConnection();
                shouldClose = true;
            }
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, currentUserId);
                ps.setInt(2, postId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        Post p = new Post();
                        p.setPostId(rs.getInt("PostID"));
                        p.setUserId(rs.getInt("UserID"));
                        p.setContent(rs.getString("Content"));
                        p.setOriginalPostId(rs.getInt("OriginalPostID"));
                        p.setCreatedAt(rs.getTimestamp("CreatedAt"));
                        p.setAuthorName(rs.getString("FullName"));
                        p.setAuthorUsername(rs.getString("Username"));
                        p.setAuthorAvatar(rs.getString("AvatarUrl"));
                        p.setLikeCount(rs.getInt("LikeCount"));
                        p.setCommentCount(rs.getInt("CommentCount"));
                        p.setRepostCount(rs.getInt("RepostCount"));
                        p.setLikedByCurrentUser(rs.getInt("IsLiked") == 1);
                        return p;
                    }
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            if (shouldClose && conn != null) {
                try {
                    conn.close();
                } catch (SQLException e) {
                }
            }
        }
        return null; // Không tìm thấy
    }

    /**
     * Tạo bài đăng mới sử dụng PreparedStatement.
     */
    public boolean createPost(int userId, String content) {
        return createRepost(userId, content, 0);
    }

    public boolean createRepost(int userId, String content, int originalPostId) {
        String sql = "INSERT INTO Posts (UserID, Content, OriginalPostID) VALUES (?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, userId);
            ps.setString(2, content);
            if (originalPostId > 0) {
                ps.setInt(3, originalPostId);
            } else {
                ps.setNull(3, java.sql.Types.INTEGER);
            }

            int rowsAffected = ps.executeUpdate();
            return rowsAffected > 0;

        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     * Tính năng Like / Unlike Toggle
     */
    public boolean toggleLike(int userId, int postId) {
        // Kiểm tra xem đã like chưa
        String checkSql = "SELECT 1 FROM Likes WHERE UserID = ? AND PostID = ?";
        boolean isLiked = false;
        try (Connection conn = DBConnection.getConnection();
                PreparedStatement checkPs = conn.prepareStatement(checkSql)) {
            checkPs.setInt(1, userId);
            checkPs.setInt(2, postId);
            try (ResultSet rs = checkPs.executeQuery()) {
                if (rs.next())
                    isLiked = true;
            }

            if (isLiked) {
                // Đã like -> Xóa (Unlike)
                String delSql = "DELETE FROM Likes WHERE UserID = ? AND PostID = ?";
                try (PreparedStatement delPs = conn.prepareStatement(delSql)) {
                    delPs.setInt(1, userId);
                    delPs.setInt(2, postId);
                    return delPs.executeUpdate() > 0;
                }
            } else {
                // Chưa like -> Thêm (Like)
                String insSql = "INSERT INTO Likes (UserID, PostID) VALUES (?, ?)";
                try (PreparedStatement insPs = conn.prepareStatement(insSql)) {
                    insPs.setInt(1, userId);
                    insPs.setInt(2, postId);
                    return insPs.executeUpdate() > 0;
                }
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     * Tính năng Thêm Bình luận
     */
    public boolean addComment(int userId, int postId, String content) {
        String sql = "INSERT INTO Comments (UserID, PostID, Content) VALUES (?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setInt(2, postId);
            ps.setString(3, content);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     * Lấy danh sách bình luận của 1 bài viết
     */
    public List<com.wepost.model.Comment> getCommentsByPostId(int postId) {
        List<com.wepost.model.Comment> comments = new ArrayList<>();
        String sql = "SELECT c.CommentID, c.PostID, c.UserID, c.Content, c.CreatedAt, " +
                "u.Username, u.FullName, u.AvatarUrl " +
                "FROM Comments c " +
                "INNER JOIN Users u ON c.UserID = u.UserID " +
                "WHERE c.PostID = ? ORDER BY c.CreatedAt ASC";
        try (Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, postId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    com.wepost.model.Comment c = new com.wepost.model.Comment();
                    c.setCommentId(rs.getInt("CommentID"));
                    c.setPostId(rs.getInt("PostID"));
                    c.setUserId(rs.getInt("UserID"));
                    c.setContent(rs.getString("Content"));
                    c.setCreatedAt(rs.getTimestamp("CreatedAt"));
                    c.setAuthorUsername(rs.getString("Username"));
                    c.setAuthorName(rs.getString("FullName"));
                    c.setAuthorAvatar(rs.getString("AvatarUrl"));
                    comments.add(c);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return comments;
    }

    public List<Post> getAllPostsAdmin() {
        List<Post> list = new ArrayList<>();
        String sql = "SELECT p.*, u.Username, u.FullName, u.AvatarUrl, " +
                "(SELECT COUNT(*) FROM Likes WHERE PostID = p.PostID) AS LikeCount, " +
                "(SELECT COUNT(*) FROM Comments WHERE PostID = p.PostID) AS CommentCount, " +
                "0 AS IsLiked " +
                "FROM Posts p JOIN Users u ON p.UserID = u.UserID " +
                "ORDER BY p.CreatedAt DESC";

        try (Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql);
                ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(mapResultSetToPost(rs, conn));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public boolean deletePost(int postId) {
        String sql = "DELETE FROM Posts WHERE PostID = ?";
        try (Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, postId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public int getTotalPosts() {
        String sql = "SELECT COUNT(*) FROM Posts";
        try (Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql);
                ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }

    private Post mapResultSetToPost(ResultSet rs, Connection conn) throws SQLException {
        Post post = new Post();
        post.setPostId(rs.getInt("PostID"));
        post.setUserId(rs.getInt("UserID"));
        post.setContent(rs.getString("Content"));
        int oriId = rs.getInt("OriginalPostID");
        post.setOriginalPostId(oriId);
        post.setCreatedAt(rs.getTimestamp("CreatedAt"));

        post.setAuthorName(rs.getString("FullName"));
        post.setAuthorUsername(rs.getString("Username"));
        post.setAuthorAvatar(rs.getString("AvatarUrl"));

        post.setLikeCount(rs.getInt("LikeCount"));
        post.setCommentCount(rs.getInt("CommentCount"));
        post.setRepostCount(rs.getInt("RepostCount"));
        post.setLikedByCurrentUser(rs.getInt("IsLiked") == 1);

        // Nếu đây là bài repost, ta đệ quy lấy bài gốc (Tránh đệ quy vô hạn vì bài gốc
        // hiếm khi là bảng ảo)
        if (oriId > 0) {
            Post oriPost = getPostById(oriId, 0, conn);
            post.setOriginalPost(oriPost);
        }

        return post;
    }
}
