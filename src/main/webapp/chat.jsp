<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
    <%@ taglib uri="jakarta.tags.core" prefix="c" %>
        <%@ taglib uri="jakarta.tags.functions" prefix="fn" %>
            <!DOCTYPE html>
            <html lang="vi">

            <head>
                <meta charset="UTF-8">
                <meta name="viewport" content="width=device-width, initial-scale=1.0">
                <title>Tin nhắn (WebSockets Real-time) / WePost</title>
                <base href="${pageContext.request.contextPath}/">
                <link rel="stylesheet" href="css/style.css">
                <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap"
                    rel="stylesheet">
                <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
                <style>
                    .chat-user-item {
                        padding: 10px;
                        display: flex;
                        align-items: center;
                        gap: 10px;
                        cursor: pointer;
                        border-radius: var(--radius-md);
                        margin: 0 10px 5px;
                    }

                    .chat-user-item:hover {
                        background: rgba(255, 255, 255, 0.05);
                    }

                    .chat-user-item.active {
                        background: rgba(59, 130, 246, 0.1);
                        border-left: 3px solid var(--primary-color);
                    }

                    .chat-room {
                        display: flex;
                        flex-direction: column;
                        height: 100%;
                        flex: 1;
                    }
                </style>
            </head>

            <body>
                <div class="app-container">
                    <!-- Sidebar Navigation -->
                    <nav class="sidebar">
                        <h1 class="logo">WePost</h1>
                        <ul class="nav-menu">
                            <li class="nav-item" onclick="window.location.href='home'">
                                <i class="fas fa-home"></i><span class="nav-label">Trang chủ</span>
                            </li>
                            <li class="nav-item" onclick="window.location.href='explore'">
                                <i class="fas fa-hashtag"></i><span class="nav-label">Khám phá</span>
                            </li>
                            <li class="nav-item active" onclick="window.location.href='messages'">
                                <i class="fas fa-envelope"></i><span class="nav-label">Tin nhắn</span>
                            </li>
                            <li class="nav-item" onclick="window.location.href='profile'">
                                <i class="far fa-user"></i><span class="nav-label">Hồ sơ</span>
                            </li>
                            <!-- Nút Admin (Chỉ hiện cho Role ADMIN) -->
                            <c:if test="${currentUser != null && currentUser.role == 'ADMIN'}">
                                <li class="nav-item" onclick="window.location.href='admin/dashboard'"
                                    style="color: var(--primary-color);">
                                    <i class="fas fa-shield-alt"></i>
                                    <span class="nav-label">Quản trị</span>
                                </li>
                            </c:if>
                            <!-- Nút Đăng xuất -->
                        </ul>
                    </nav>

                    <!-- Main Content -->
                    <main class="main-content"
                        style="max-width: 900px; padding:0; display:flex; flex-direction:column;">
                        <header class="top-header"
                            style="border-bottom: 1px solid var(--border-color); padding: 16px 20px;">
                            <h2 class="page-title">Tin nhắn Cá nhân 1-1</h2>
                            <div
                                style="font-size: 13px; color: var(--text-muted); padding: 5px 15px; background: rgba(34, 197, 94, 0.1); border-radius: 20px; color: #22c55e;">
                                <i class="fas fa-circle" style="font-size: 8px;"></i> Secure Point-to-Point Socket
                            </div>
                        </header>

                        <!-- Chat Application Area -->
                        <div class="chat-container">
                            <!-- User List Sidebar -->
                            <aside class="chat-users">
                                <div class="search-container" style="width:100%; padding: 10px;">
                                    <input type="text" class="search-input" placeholder="Tìm kiếm tin nhắn">
                                </div>

                                <div
                                    style="padding: 0 15px; font-size: 13px; font-weight: 600; color: var(--text-muted); margin-bottom: 10px;">
                                    BẠN BÈ TƯƠNG TÁC
                                </div>

                                <!-- Hiển thị Danh sách Bạn Bè từ Java Attribute -->
                                <c:if test="${empty friendList}">
                                    <div style="padding: 10px 15px; font-size: 13px; color: var(--text-muted);">
                                        Bạn chưa theo dõi chéo ai. Hãy vào phần Hồ sơ để kết nối nhé!
                                    </div>
                                </c:if>

                                <c:forEach var="friend" items="${friendList}">
                                    <!-- Nạp Avatar Logic -->
                                    <c:set var="friendAva" value="images/avatars/${friend.avatarUrl}" />
                                    <c:if test="${empty friend.avatarUrl || friend.avatarUrl == 'default-avatar.png'}">
                                        <c:set var="friendAva"
                                            value="https://ui-avatars.com/api/?name=${fn:escapeXml(friend.fullName)}&background=10b981&color=fff" />
                                    </c:if>

                                    <div class="chat-user-item"
                                        onclick="openChatRoom('${friend.username}', '${fn:escapeXml(friend.fullName)}', '${friendAva}')">
                                        <img src="${friendAva}" alt="" class="avatar" style="width:40px; height:40px;">
                                        <div>
                                            <div style="font-weight:600; font-size:15px; color:var(--text-main);">
                                                <c:out value="${friend.fullName}" />
                                            </div>
                                            <div style="font-size:13px; color:var(--text-muted);">@
                                                <c:out value="${friend.username}" />
                                            </div>
                                        </div>
                                    </div>
                                </c:forEach>
                            </aside>

                            <!-- Real-time Chat Room Pane -->
                            <section class="chat-room" id="chatRoomArea" style="display: none;">
                                <div
                                    style="padding: 12px 20px; border-bottom: 1px solid var(--border-color); display:flex; align-items:center; gap: 12px; font-weight:700;">
                                    <img id="activeRoomAvatar" src="" alt="" class="avatar"
                                        style="width:36px; height:36px;">
                                    <span id="activeRoomName">Đang tải...</span>
                                    <div style="margin-left:auto; color:var(--primary-color);">
                                        <i class="fas fa-circle" style="font-size:10px;"></i> Đang kết nối
                                    </div>
                                </div>

                                <!-- Khu vực tự động render tin nhắn JSON (Cuộn Scroll riêng) -->
                                <div class="chat-messages" id="messageContainer" style="flex: 1; overflow-y: auto;">
                                    <div
                                        style="text-align: center; color: var(--text-muted); font-size: 13px; margin-bottom: 20px;">
                                        Đây là khởi đầu tin nhắn bí mật của bạn với <span id="introRoomName"></span>.
                                    </div>
                                </div>

                                <div class="chat-input-area"
                                    style="border-top: 1px solid var(--border-color); padding: 15px 20px; flex-direction: column;">

                                    <div id="chatWarning"
                                        style="color: var(--danger-color); font-size: 13px; font-weight: 500; display: none; margin-bottom: 4px;">
                                        Bạn đã nhập tối đa 256 ký tự!
                                    </div>

                                    <div style="display: flex; gap: 12px; width: 100%; align-items: flex-end;">
                                        <textarea id="chatInput" class="chat-input message-box-area"
                                            placeholder="Bắt đầu nhập tin nhắn bí mật... (tối đa 256 ký tự)"
                                            rows="1"></textarea>
                                        <button id="sendBtn" class="btn-primary"
                                            style="padding: 8px 16px; border-radius:50%; width: 44px; height: 44px; flex-shrink: 0;">
                                            <i class="fas fa-paper-plane" style="font-size: 15px;"></i>
                                        </button>
                                    </div>
                                </div>
                            </section>

                            <section class="chat-room" id="noRoomArea"
                                style="display: flex; align-items: center; justify-content: center;">
                                <div style="text-align: center; color: var(--text-muted);">
                                    <i class="fas fa-comments"
                                        style="font-size: 48px; margin-bottom: 16px; opacity: 0.5;"></i>
                                    <h3>Tin nhắn của bạn</h3>
                                    <p style="font-size: 14px; margin-top: 8px;">Chọn một người bạn bên trái để bắt đầu
                                        nhắn tin.</p>
                                </div>
                            </section>
                        </div>
                    </main>
                </div>

                <!-- Thông tin Current User ẩn -->
                <input type="hidden" id="myUsername" value="<c:out value='${currentUser.username}'/>">
                <input type="hidden" id="myFullName" value="<c:out value='${currentUser.fullName}'/>">
                <c:choose>
                    <c:when test="${not empty currentUser.avatarUrl && currentUser.avatarUrl != 'default-avatar.png'}">
                        <input type="hidden" id="myAvatar"
                            value="images/avatars/<c:out value='${currentUser.avatarUrl}'/>">
                    </c:when>
                    <c:otherwise>
                        <input type="hidden" id="myAvatar"
                            value="https://ui-avatars.com/api/?name=${fn:escapeXml(currentUser.fullName)}&background=3b82f6&color=fff">
                    </c:otherwise>
                </c:choose>

                <!-- Kịch bản kết nối WebSockets -->
                <script>
                    const chatInput = document.getElementById('chatInput');
                    const sendBtn = document.getElementById('sendBtn');
                    const messageContainer = document.getElementById('messageContainer');
                    const chatRoomArea = document.getElementById('chatRoomArea');
                    const noRoomArea = document.getElementById('noRoomArea');

                    const myUsername = document.getElementById('myUsername').value;
                    const myFullName = document.getElementById('myFullName').value;
                    const myAvatar = document.getElementById('myAvatar').value;

                    // Quản lý trạng thái đang chat với ai
                    let currentTargetUsername = null;
                    let currentTargetAvatar = null;

                    // Xây dựng URL động kết nối WebSocket riêng cho mình theo Username
                    const protocol = window.location.protocol === "https:" ? "wss://" : "ws://";
                    const wsUrl = protocol + window.location.host + "${pageContext.request.contextPath}/chat/" + myUsername;

                    let socket = null;
                    try {
                        socket = new WebSocket(wsUrl);
                        console.log("Kết nối bảo mật 1-1 tới:", wsUrl);
                    } catch (e) {
                        console.error("Không thể kết nối WS", e);
                    }

                    socket.onopen = function (e) {
                        console.log("Private WebSocket Connection Established.");
                    };

                    // Lắng nghe Message
                    socket.onmessage = function (event) {
                        try {
                            const data = JSON.parse(event.data);

                            // Validation 1: Có phải đang chat đúng với luồng này không? Mở phòng sai thì không load bong bóng lên.
                            const involvedUsers = [data.senderUsername, data.receiverName];
                            if (currentTargetUsername && involvedUsers.includes(currentTargetUsername) && involvedUsers.includes(myUsername)) {

                                const isMine = (data.senderUsername === myUsername);
                                const displayAvatar = isMine ? myAvatar : data.avatar;
                                const displayName = isMine ? "Tôi" : data.senderFullName;

                                renderMessage(displayName, displayAvatar, data.content, isMine);
                            }
                        } catch (err) {
                            console.error("Lỗi khi parse tin nhắn JSON:", err);
                        }
                    };

                    // Kỹ thuật mở phòng chat Point-toPoint
                    function openChatRoom(targetUser, targetFullName, targetAvatar) {
                        // Xóa CSS Active của thẻ cũ
                        document.querySelectorAll('.chat-user-item').forEach(el => el.classList.remove('active'));
                        // Gắn CSS vào thẻ mới bấm (Dùng event.currentTarget trong thực tế, nhưng demo ta bỏ qua bằng cách đơn giản)

                        currentTargetUsername = targetUser;
                        currentTargetAvatar = targetAvatar;

                        document.getElementById('activeRoomName').textContent = targetFullName;
                        document.getElementById('introRoomName').textContent = targetFullName;
                        document.getElementById('activeRoomAvatar').src = targetAvatar;

                        noRoomArea.style.display = 'none';
                        chatRoomArea.style.display = 'flex';

                        // Xóa sạch bộ nhớ Tin nhắn trên UI HTML
                        messageContainer.innerHTML = '';

                        // Gửi lệnh LOAD_HISTORY lên RAM của máy chủ Java
                        if (socket.readyState === WebSocket.OPEN) {
                            socket.send(JSON.stringify({
                                type: "LOAD_HISTORY",
                                targetUser: currentTargetUsername // Java sẽ biết đang truy vấn Lịch sử của (Tao - Mày)
                            }));
                        }
                    }

                    // Xử lý gửi Event
                    function sendMessage() {
                        if (!currentTargetUsername) return; // Không có phòng thì chặn
                        const rawText = chatInput.value.trim();
                        if (rawText !== '' && socket && socket.readyState === WebSocket.OPEN) {

                            // Chuẩn bị Data
                            const msgObj = {
                                senderUsername: myUsername,
                                senderFullName: myFullName,
                                avatar: myAvatar,
                                receiverName: currentTargetUsername,
                                content: rawText
                            };

                            // Đẩy lên Server
                            socket.send(JSON.stringify(msgObj));

                            // Vẽ tin nhắn lên giao diện local để mượt mà không chớp lác
                            renderMessage("Tôi", myAvatar, rawText, true);

                            chatInput.value = '';
                        }
                    }

                    // Xử lý auto resize khi gõ và Enter để gửi
                    const chatWarning = document.getElementById('chatWarning');

                    chatInput.addEventListener('input', function () {
                        // Khắc phục lỗi gõ tiếng Việt có dấu ở cuối dòng khi dùng max-length HTML
                        if (this.value.length > 256) {
                            this.value = this.value.substring(0, 256);
                        }

                        // Hiện cảnh báo nếu full
                        if (this.value.length >= 256) {
                            chatWarning.style.display = 'block';
                        } else {
                            chatWarning.style.display = 'none';
                        }

                        this.style.height = 'auto'; // Reset chiều cao
                        // Giới hạn max-height (70% viewport theo yêu cầu) để scroll
                        let currentHeight = this.scrollHeight;
                        let maxHeight = window.innerHeight * 0.7;
                        if (currentHeight > maxHeight) {
                            this.style.height = maxHeight + 'px';
                            this.style.overflowY = 'auto';
                        } else {
                            this.style.height = currentHeight + 'px';
                            this.style.overflowY = 'hidden';
                        }
                    });

                    chatInput.addEventListener('keypress', function (e) {
                        if (e.key === 'Enter' && !e.shiftKey) {
                            e.preventDefault(); // Không tạo dòng mới
                            sendMessage();
                            this.style.height = 'auto'; // Trả về mặc định sau khi gửi
                            chatWarning.style.display = 'none';
                        }
                    });

                    sendBtn.addEventListener('click', sendMessage);

                    function renderMessage(name, avatar, content, isMine) {
                        const wrapper = document.createElement('div');
                        wrapper.style.display = 'flex';
                        wrapper.style.alignItems = 'flex-end';
                        wrapper.style.gap = '10px';
                        wrapper.style.marginBottom = '20px';
                        if (isMine) wrapper.style.flexDirection = 'row-reverse';

                        const img = document.createElement('img');
                        img.src = avatar;
                        img.className = 'avatar';
                        img.style.width = '30px';
                        img.style.height = '30px';

                        const msgDiv = document.createElement('div');
                        msgDiv.className = isMine ? 'message sent' : 'message received';

                        // XSS Security (Rule 13 - Security First)
                        msgDiv.textContent = content;

                        if (isMine) msgDiv.style.marginRight = '0';
                        else msgDiv.style.marginLeft = '0';

                        wrapper.appendChild(img);
                        wrapper.appendChild(msgDiv);

                        if (!isMine) {
                            const nameLabel = document.createElement('div');
                            nameLabel.textContent = name;
                            nameLabel.style.fontSize = '12px';
                            nameLabel.style.color = 'var(--text-muted)';
                            nameLabel.style.marginBottom = '4px';
                            nameLabel.style.marginLeft = '40px';

                            const containerNode = document.createElement('div');
                            containerNode.style.display = 'flex';
                            containerNode.style.flexDirection = 'column';
                            containerNode.appendChild(nameLabel);
                            containerNode.appendChild(wrapper);

                            messageContainer.appendChild(containerNode);
                        } else {
                            messageContainer.appendChild(wrapper);
                        }

                        // Scroll bottom
                        messageContainer.scrollTop = messageContainer.scrollHeight;
                    }
                </script>
            </body>

            </html>