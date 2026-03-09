package com.wepost.controller;

import com.wepost.dao.UserDAO;
import com.wepost.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.Part;

import java.io.File;
import java.io.IOException;
import java.util.UUID;

// MultipartConfig để có thể bắt được file Ảnh gửi lên từ Form (Enctype multipart)
@WebServlet("/edit-profile")
@MultipartConfig(fileSizeThreshold = 1024 * 1024 * 1, // 1 MB
        maxFileSize = 1024 * 1024 * 10, // 10 MB tối đa 1 file ảnh
        maxRequestSize = 1024 * 1024 * 15 // 15 MB toàn request
)
public class EditProfileServlet extends HttpServlet {

    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("currentUser") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        // Lấy thông tin user hiện tại truyền ra Edit View
        User currUser = (User) session.getAttribute("currentUser");
        request.setAttribute("user", currUser);
        request.getRequestDispatcher("/edit-profile.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("currentUser") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        User currUser = (User) session.getAttribute("currentUser");

        // Đọc dữ liệu nhập từ Form
        String fullName = request.getParameter("fullName");
        String bio = request.getParameter("bio");

        if (fullName == null || fullName.trim().isEmpty()) {
            request.setAttribute("error", "Tên hiển thị không được để trống!");
            request.setAttribute("user", currUser);
            request.getRequestDispatcher("/edit-profile.jsp").forward(request, response);
            return;
        }

        // --- Xử lý Upload Ảnh Đại Diện ---
        String finalAvatarUrl = currUser.getAvatarUrl(); // Mặc định giữ ảnh cũ
        Part filePart = request.getPart("avatarFile");

        if (filePart != null && filePart.getSize() > 0) {
            String mimeType = filePart.getContentType();
            // Chỉ chấp nhận định dạng ảnh
            if (mimeType.startsWith("image/")) {
                // Lấy đường dẫn thực tế của ứng dụng chứa ảnh Avatar
                String applicationPath = request.getServletContext().getRealPath("");
                String uploadFilePath = applicationPath + File.separator + "images" + File.separator + "avatars";

                File uploadDir = new File(uploadFilePath);
                if (!uploadDir.exists())
                    uploadDir.mkdirs();

                // Sinh tên file ngẫu nhiên (UUID) tránh trùng lặp đè ảnh người khác
                String originalFileName = extractFileName(filePart);
                String extension = originalFileName.substring(originalFileName.lastIndexOf("."));
                String newFileName = UUID.randomUUID().toString() + extension;

                filePart.write(uploadFilePath + File.separator + newFileName);

                // Lưu thành công, đổi biến để Update DB
                finalAvatarUrl = newFileName;
            } else {
                request.setAttribute("error", "Vui lòng chỉ tải lên file hình ảnh (JPG, PNG)!");
                request.setAttribute("user", currUser);
                request.getRequestDispatcher("/edit-profile.jsp").forward(request, response);
                return;
            }
        }

        // --- Xử lý Upload Ảnh Bìa ---
        String finalCoverUrl = currUser.getCoverUrl(); // Mặc định giữ ảnh cũ
        Part coverPart = request.getPart("coverFile");

        if (coverPart != null && coverPart.getSize() > 0) {
            String mimeType = coverPart.getContentType();
            // Chỉ chấp nhận định dạng ảnh
            if (mimeType != null && mimeType.startsWith("image/")) {
                // Lấy đường dẫn thực tế của ứng dụng
                String applicationPath = request.getServletContext().getRealPath("");
                String uploadFilePath = applicationPath + File.separator + "images" + File.separator + "covers";

                File uploadDir = new File(uploadFilePath);
                if (!uploadDir.exists())
                    uploadDir.mkdirs();

                // Sinh tên file ngẫu nhiên (UUID)
                String originalFileName = extractFileName(coverPart);
                String extension = "";
                if (originalFileName.contains(".")) {
                    extension = originalFileName.substring(originalFileName.lastIndexOf("."));
                } else {
                    extension = ".jpg"; // fallback
                }
                String newFileName = UUID.randomUUID().toString() + extension;

                coverPart.write(uploadFilePath + File.separator + newFileName);

                // Lưu thành công, đổi biến
                finalCoverUrl = newFileName;
            } else {
                request.setAttribute("error", "Vui lòng chỉ tải lên file hình ảnh (JPG, PNG) cho bìa!");
                request.setAttribute("user", currUser);
                request.getRequestDispatcher("/edit-profile.jsp").forward(request, response);
                return;
            }
        }

        // Cập nhật Database
        boolean success = userDAO.updateProfile(currUser.getUserId(), fullName.trim(), bio.trim(), finalAvatarUrl,
                finalCoverUrl);

        if (success) {
            // Cập nhật lại đối tượng User trong Session để các trang khác load ngay lập tức
            currUser.setFullName(fullName.trim());
            currUser.setBio(bio.trim());
            currUser.setAvatarUrl(finalAvatarUrl);
            currUser.setCoverUrl(finalCoverUrl);
            session.setAttribute("currentUser", currUser);

            // Redirect về profile để xem thành quả
            response.sendRedirect(request.getContextPath() + "/profile");
        } else {
            request.setAttribute("error", "Đã có lỗi hệ thống xảy ra khi lưu! Hãy thử lại.");
            request.setAttribute("user", currUser);
            request.getRequestDispatcher("/edit-profile.jsp").forward(request, response);
        }
    }

    // Tiện ích bóc tách lấy cái đuôi mở rộng file (.jpg, .png)
    private String extractFileName(Part part) {
        String contentDisp = part.getHeader("content-disposition");
        String[] items = contentDisp.split(";");
        for (String s : items) {
            if (s.trim().startsWith("filename")) {
                return s.substring(s.indexOf("=") + 2, s.length() - 1);
            }
        }
        return "";
    }
}
