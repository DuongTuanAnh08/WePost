package com.wepost.dao;

import com.wepost.db.DBConnection;
import com.wepost.model.User;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

public class UserDAO {

    /**
     * Xác thực đăng nhập tránh SQL Injection cho dự án WePost.
     */
    public User authenticate(String username, String passwordHash) {
        String sql = "SELECT * FROM Users WHERE Username = ? AND PasswordHash = ?";
        try (Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, username);
            ps.setString(2, passwordHash);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToUser(rs);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    /**
     * Lấy thông tin User theo Username (Xây dựng trang cá nhân)
     */
    public User getUserByUsername(String username) {
        String sql = "SELECT * FROM Users WHERE Username = ?";
        try (Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, username);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToUser(rs);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public boolean checkUsernameExists(String username) {
        String sql = "SELECT 1 FROM Users WHERE Username = ?";
        try (Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, username);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return true;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean updateProfile(int userId, String fullName, String bio, String avatarUrl, String coverUrl) {
        String sql = "UPDATE Users SET FullName = ?, Bio = ?, AvatarUrl = ?, CoverUrl = ? WHERE UserID = ?";
        try (Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, fullName);

            // Theo như Database schema Bio là NVARCHAR(500)
            if (bio != null && bio.length() > 500) {
                bio = bio.substring(0, 500);
            }
            ps.setString(2, bio);

            // Xử lý avatarUrl rỗng thì giữ nguyên hoặc đưa về default
            if (avatarUrl == null || avatarUrl.trim().isEmpty()) {
                avatarUrl = "default-avatar.png";
            } else if (avatarUrl.length() > 255) {
                avatarUrl = avatarUrl.substring(0, 255);
            }
            ps.setString(3, avatarUrl);

            // Xử lý coverUrl
            if (coverUrl == null || coverUrl.trim().isEmpty()) {
                coverUrl = "default-cover.jpg";
            } else if (coverUrl.length() > 255) {
                coverUrl = coverUrl.substring(0, 255);
            }
            ps.setString(4, coverUrl);

            ps.setInt(5, userId);

            int rowsAffected = ps.executeUpdate();
            return rowsAffected > 0;

        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean registerUser(String username, String passwordHash, String fullName) {
        String sql = "INSERT INTO Users (Username, PasswordHash, FullName, AvatarUrl, Bio, Role) VALUES (?, ?, ?, 'default-avatar.png', 'Xin chào, tôi là thành viên WePost!', 'user')";
        try (Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, username);
            ps.setString(2, passwordHash);
            ps.setString(3, fullName);
            int rowsAffected = ps.executeUpdate();
            return rowsAffected > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public java.util.List<User> searchUsers(String keyword, int currentUserId) {
        java.util.List<User> list = new java.util.ArrayList<>();
        String sql = "SELECT TOP 50 * FROM Users WHERE (Username LIKE ? OR FullName LIKE ?) AND UserID != ?";
        try (Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {

            String searchPattern = "%" + keyword + "%";
            ps.setString(1, searchPattern);
            ps.setString(2, searchPattern);
            ps.setInt(3, currentUserId);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapResultSetToUser(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public java.util.List<User> getRecommendedUsers(int currentUserId) {
        java.util.List<User> list = new java.util.ArrayList<>();
        // Lấy 50 user mới hoặc ngẫu nhiên (trừ bản thân)
        String sql = "SELECT TOP 50 * FROM Users WHERE UserID != ? ORDER BY CreatedAt DESC";
        try (Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, currentUserId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapResultSetToUser(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public java.util.List<User> getAllUsers() {
        java.util.List<User> list = new java.util.ArrayList<>();
        String sql = "SELECT * FROM Users ORDER BY CreatedAt DESC";
        try (Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql);
                ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(mapResultSetToUser(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public boolean updateUserStatus(int userId, boolean isBanned) {
        String sql = "UPDATE Users SET IsBanned = ? WHERE UserID = ?";
        try (Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setBoolean(1, isBanned);
            ps.setInt(2, userId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public int getTotalUsers() {
        String sql = "SELECT COUNT(*) FROM Users";
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

    private User mapResultSetToUser(ResultSet rs) throws SQLException {
        User user = new User();
        user.setUserId(rs.getInt("UserID"));
        user.setUsername(rs.getString("Username"));
        user.setPasswordHash(rs.getString("PasswordHash"));
        user.setFullName(rs.getString("FullName"));
        user.setAvatarUrl(rs.getString("AvatarUrl"));
        try {
            user.setCoverUrl(rs.getString("CoverUrl"));
        } catch (SQLException ignore) {
            user.setCoverUrl("default-cover.jpg");
        }
        user.setBio(rs.getString("Bio"));
        user.setRole(rs.getString("Role"));
        user.setCreatedAt(rs.getTimestamp("CreatedAt"));
        try {
            user.setBanned(rs.getBoolean("IsBanned"));
        } catch (SQLException ignore) {
        }
        return user;
    }
}
