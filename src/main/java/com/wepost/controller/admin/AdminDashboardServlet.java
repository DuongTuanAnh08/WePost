package com.wepost.controller.admin;

import com.wepost.dao.PostDAO;
import com.wepost.dao.UserDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.concurrent.atomic.AtomicInteger;

@WebServlet("/admin/dashboard")
public class AdminDashboardServlet extends HttpServlet {
    private final UserDAO userDAO = new UserDAO();
    private final PostDAO postDAO = new PostDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        int totalUsers = userDAO.getTotalUsers();
        int totalPosts = postDAO.getTotalPosts();

        AtomicInteger totalVisits = (AtomicInteger) getServletContext().getAttribute("totalVisits");
        int visitsCount = (totalVisits != null) ? totalVisits.get() : 0;

        request.setAttribute("totalUsers", totalUsers);
        request.setAttribute("totalPosts", totalPosts);
        request.setAttribute("totalVisits", visitsCount);

        request.getRequestDispatcher("/admin/dashboard.jsp").forward(request, response);
    }
}
