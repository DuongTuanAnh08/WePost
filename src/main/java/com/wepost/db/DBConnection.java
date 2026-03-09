package com.wepost.db;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DBConnection {

    // IMPORTANT: Thay thế Cấu hình dưới đây bằng Server Name của SQL Server Studio trên máy Local.
    private static final String URL = "jdbc:sqlserver://localhost:1433;databaseName=WePostDB;encrypt=false;trustServerCertificate=true;";
    // Thông tin tài khoản đăng nhập SQL Server (Tùy chỉnh tuỳ môi trường):
    private static final String USER = "sa"; 
    private static final String PASS = "123456";

    // Mẫu chuẩn kiểm soát (JDBC Type 4)
    public static Connection getConnection() {
        Connection conn = null;
        try {
            // Tải thư viện Driver MSSQL Server
            Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
            conn = DriverManager.getConnection(URL, USER, PASS);
            System.out.println("Kết nối SQL Server (WePostDB) Thành Công!");
        } catch (ClassNotFoundException e) {
            System.err.println("Database Driver không tìm thấy: " + e.getMessage());
        } catch (SQLException e) {
            System.err.println("Lỗi cấu hình CSDL: " + e.getMessage());
        }
        return conn;
    }
}
