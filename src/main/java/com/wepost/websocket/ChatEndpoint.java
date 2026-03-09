package com.wepost.websocket;

import java.io.IOException;
import java.util.Collections;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;
import com.google.gson.Gson;
import com.google.gson.JsonObject;
import com.google.gson.JsonSyntaxException;

// APIs WebSockets jakarta.websocket.
import jakarta.websocket.OnClose;
import jakarta.websocket.OnError;
import jakarta.websocket.OnMessage;
import jakarta.websocket.OnOpen;
import jakarta.websocket.Session;
import jakarta.websocket.server.PathParam;
import jakarta.websocket.server.ServerEndpoint;

/**
 * Socket Server Point-to-Point (1-1 Private Chat)
 * Lắng nghe tại ws://localhost:{port}/WePost/chat/{username}
 */
@ServerEndpoint("/chat/{username}")
public class ChatEndpoint {

    // Map chứa Danh sách { Username -> Session của họ }
    // Khắc phục hoàn toàn tình trạng Broadcast bừa bãi
    private static final Map<String, Session> clients = new ConcurrentHashMap<>();

    // RAM History lưu theo RoomKey (Ví dụ: "alexdev-sarah")
    private static final Map<String, List<String>> messageHistory = new ConcurrentHashMap<>();
    private static final int MAX_HISTORY = 50;

    private static final Gson gson = new Gson();

    @OnOpen
    public void onOpen(Session session, @PathParam("username") String username) {
        if (username != null && !username.isEmpty()) {
            clients.put(username, session);
            System.out.println("User connect: " + username + " (WebSocket: " + session.getId() + ")");
        } else {
            try {
                session.close();
            } catch (IOException e) {
                e.printStackTrace();
            }
        }
    }

    @OnMessage
    public void onMessage(String message, Session session, @PathParam("username") String senderUsername) {
        System.out.println("Nhận Private JSON từ " + senderUsername + ": " + message);

        try {
            JsonObject jsonMsg = gson.fromJson(message, JsonObject.class);

            // Nếu Client bắn lệnh "LOAD_HISTORY", gửi ngược lịch sử về mà k gửi đi
            if (jsonMsg.has("type") && jsonMsg.get("type").getAsString().equals("LOAD_HISTORY")) {
                String receiverUsername = jsonMsg.get("targetUser").getAsString();
                String roomKey = getRoomKey(senderUsername, receiverUsername);

                List<String> history = messageHistory.getOrDefault(roomKey, new LinkedList<>());
                synchronized (history) {
                    for (String pastMsg : history) {
                        try {
                            session.getBasicRemote().sendText(pastMsg);
                        } catch (IOException e) {
                            e.printStackTrace();
                        }
                    }
                }
                return;
            }

            // Xử lý gửi tin nhắn Chat mới
            String receiverUsername = jsonMsg.get("receiverName").getAsString();
            String roomKey = getRoomKey(senderUsername, receiverUsername);

            // Lưu lịch sử tĩnh bộ nhớ Server (Cập nhật HashMap)
            messageHistory.putIfAbsent(roomKey, Collections.synchronizedList(new LinkedList<>()));
            List<String> history = messageHistory.get(roomKey);
            synchronized (history) {
                history.add(message);
                if (history.size() > MAX_HISTORY) {
                    history.remove(0);
                }
            }

            // Gửi Point-to-Point cho BÊN NHẬN (chỉ đích danh Session của họ)
            Session receiverSession = clients.get(receiverUsername);
            if (receiverSession != null && receiverSession.isOpen()) {
                receiverSession.getBasicRemote().sendText(message);
            }

            // Ghi chú: Không cần gửi ngược cho BÊN GỬI vì Front-end JS đã tự render bong
            // bóng xanh rồi

        } catch (JsonSyntaxException | IOException e) {
            e.printStackTrace();
            System.err.println("Gói tin xấu bị từ chối");
        }
    }

    @OnClose
    public void onClose(Session session, @PathParam("username") String username) {
        if (username != null) {
            clients.remove(username);
            System.out.println("Kết nối đóng - (Client Disconnect): " + username);
        }
    }

    @OnError
    public void onError(Throwable exception, Session session) {
        System.err.println("Lỗi WebSocket Client: " + exception.getMessage());
    }

    /**
     * Thuật toán đảm bảo ID phòng Chat của A và B lúc nào cũng quy về 1 chuỗi không
     * đổi
     */
    private String getRoomKey(String user1, String user2) {
        if (user1.compareTo(user2) < 0) {
            return user1 + "-" + user2;
        } else {
            return user2 + "-" + user1;
        }
    }
}
