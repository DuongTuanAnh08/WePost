package com.wepost.listener;

import jakarta.servlet.ServletContext;
import jakarta.servlet.http.HttpSessionEvent;
import jakarta.servlet.http.HttpSessionListener;
import java.util.concurrent.atomic.AtomicInteger;

public class VisitCounterListener implements HttpSessionListener {

    @Override
    public void sessionCreated(HttpSessionEvent se) {
        ServletContext context = se.getSession().getServletContext();
        AtomicInteger activeSessions = (AtomicInteger) context.getAttribute("activeSessions");
        AtomicInteger totalVisits = (AtomicInteger) context.getAttribute("totalVisits");

        if (activeSessions == null) {
            activeSessions = new AtomicInteger(0);
        }
        if (totalVisits == null) {
            totalVisits = new AtomicInteger(0);
        }

        activeSessions.incrementAndGet();
        totalVisits.incrementAndGet();

        context.setAttribute("activeSessions", activeSessions);
        context.setAttribute("totalVisits", totalVisits);
    }

    @Override
    public void sessionDestroyed(HttpSessionEvent se) {
        ServletContext context = se.getSession().getServletContext();
        AtomicInteger activeSessions = (AtomicInteger) context.getAttribute("activeSessions");

        if (activeSessions != null && activeSessions.get() > 0) {
            activeSessions.decrementAndGet();
            context.setAttribute("activeSessions", activeSessions);
        }
    }
}
