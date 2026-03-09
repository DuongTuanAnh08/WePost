package com.wepost.dao;

import com.wepost.db.DBConnection;
import com.wepost.model.User;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class FriendDAO {

    /**
     * Kiểm tra xem UserA đã ấn Theo Dõi (Following) UserB chưa?
     */
    public boolean isFollowing(int followerId, int followedId) {
        String sql = "SELECT 1 FROM Friends WHERE User1_ID = ? AND User2_ID = ?";
        try (Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, followerId);
            ps.setInt(2, followedId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next())
                    return true;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     * Thực hiện ấn Nút "Theo dõi"
     * 
     * @return true nếu ghi vào SQL Server thành công
     */
    public boolean followUser(int followerId, int followedId) {
        // Validation: Không cho theo dõi chính mình
        if (followerId == followedId)
            return false;

        // Validation 2: Cấm Insert trùng lặp nếu đã Follow rồi
        if (isFollowing(followerId, followedId))
            return true;

        String sql = "INSERT INTO Friends (User1_ID, User2_ID, Status) VALUES (?, ?, 'FOLLOWING')";
        try (Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, followerId);
            ps.setInt(2, followedId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     * Thực hiện ấn nút "Hủy Theo dõi"
     */
    public boolean unfollowUser(int followerId, int followedId) {
        String sql = "DELETE FROM Friends WHERE User1_ID = ? AND User2_ID = ?";
        try (Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, followerId);
            ps.setInt(2, followedId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     * Lấy danh sách bạn bè (Bạn bè = 2 người CùNG Follow chéo lẫn nhau)
     * Đây là điều kiện tiên quyết để được mở khóa tính năng Chat 1-1
     */
    public List<User> getMutualFriends(int myUserId) {
        List<User> listFriends = new ArrayList<>();
        // Query SQL Join tự đọ Follow 2 chiều:
        // Lấy tất cả thông tin từ bảng Users (u) với điều kiện:
        // Đã tồn tại dòng (Me -> Them) TRONG BẢNG Friends
        // VÀ đã tồn tại dòng (Them -> Me) TRONG BẢNG Friends
        String sql = "SELECT u.* "
                + "FROM Users u "
                + "JOIN Friends f1 ON u.UserID = f1.User2_ID AND f1.User1_ID = ? "
                + "JOIN Friends f2 ON u.UserID = f2.User1_ID AND f2.User2_ID = ?";

        try (Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, myUserId);
            ps.setInt(2, myUserId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    listFriends.add(mapResultSetToUser(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return listFriends;
    }

    public List<User> getPendingFollowers(int myUserId) {
        List<User> list = new ArrayList<>();
        // Lấy User (u) ĐÃ Follow Mình (User2 = My) VÀ Mình chưa Follow Lại (User1 = My,
        // User2 = u)
        String sql = "SELECT TOP 10 u.* FROM Users u "
                + "JOIN Friends f ON u.UserID = f.User1_ID "
                + "WHERE f.User2_ID = ? "
                + "AND NOT EXISTS ("
                + "   SELECT 1 FROM Friends f2 WHERE f2.User1_ID = ? AND f2.User2_ID = u.UserID"
                + ") ORDER BY f.CreatedAt DESC";

        try (Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, myUserId);
            ps.setInt(2, myUserId);
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

    private User mapResultSetToUser(ResultSet rs) throws SQLException {
        User user = new User();
        user.setUserId(rs.getInt("UserID"));
        user.setUsername(rs.getString("Username"));
        user.setFullName(rs.getString("FullName"));
        user.setAvatarUrl(rs.getString("AvatarUrl"));
        // Ẩn mật khẩu khi lấy list user
        user.setPasswordHash(null);
        user.setBio(rs.getString("Bio"));
        user.setRole(rs.getString("Role"));
        user.setCreatedAt(rs.getTimestamp("CreatedAt"));
        return user;
    }

    /**
     * Lấy số lượng người dùng mà user đang theo dõi (Following)
     */
    public int countFollowing(int userId) {
        String sql = "SELECT COUNT(*) FROM Friends WHERE User1_ID = ?";
        try (Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next())
                    return rs.getInt(1);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }

    /**
     * Lấy số lượng người dùng đang theo dõi user (Followers)
     */
    public int countFollowers(int userId) {
        String sql = "SELECT COUNT(*) FROM Friends WHERE User2_ID = ?";
        try (Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next())
                    return rs.getInt(1);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }
}
