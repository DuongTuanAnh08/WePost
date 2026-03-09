-- Cấu trúc Database cho WePost (SQL Server)
-- Khuyên dùng công cụ SSMS (SQL Server Management Studio) để chạy script.

CREATE DATABASE WePostDB;
GO

USE WePostDB;
GO

-- 1. Bảng lưu trữ Thông tin Người Dùng
CREATE TABLE Users (
    UserID INT IDENTITY(1,1) PRIMARY KEY,
    Username NVARCHAR(50) NOT NULL UNIQUE,
    PasswordHash NVARCHAR(255) NOT NULL,
    FullName NVARCHAR(100),
    AvatarUrl NVARCHAR(255) DEFAULT 'default-avatar.png',
    CoverUrl NVARCHAR(255) DEFAULT 'default-cover.jpg',
    Bio NVARCHAR(500),
    Role VARCHAR(20) DEFAULT 'USER', -- ADMIN hoặc USER
    IsBanned BIT DEFAULT 0, -- 0: Hoạt động bình thường, 1: Bị cấm
    CreatedAt DATETIME DEFAULT GETDATE()
);
GO

-- 2. Bảng lưu trữ Bài Đăng (Post)
CREATE TABLE Posts (
    PostID INT IDENTITY(1,1) PRIMARY KEY,
    UserID INT NOT NULL,
    Content NVARCHAR(MAX) NOT NULL,
    OriginalPostID INT NULL, -- Cho tính năng Đăng Lại (Repost)
    CreatedAt DATETIME DEFAULT GETDATE(),
    -- Khóa ngoại liên kết với bảng Users
    CONSTRAINT FK_Posts_Users FOREIGN KEY (UserID) REFERENCES Users(UserID) ON DELETE CASCADE,
    -- Khóa ngoại liên kết chéo với chính Posts (Repost)
    CONSTRAINT FK_Posts_Original FOREIGN KEY (OriginalPostID) REFERENCES Posts(PostID)
);
GO

-- 2.1 Bảng Lượt Thích (Likes)
CREATE TABLE Likes (
    LikeID INT IDENTITY(1,1) PRIMARY KEY,
    UserID INT NOT NULL,
    PostID INT NOT NULL,
    CreatedAt DATETIME DEFAULT GETDATE(),
    CONSTRAINT FK_Likes_User FOREIGN KEY (UserID) REFERENCES Users(UserID),
    CONSTRAINT FK_Likes_Post FOREIGN KEY (PostID) REFERENCES Posts(PostID) ON DELETE CASCADE,
    -- Mỗi người chỉ like 1 bài 1 lần
    CONSTRAINT UQ_Likes_UserPost UNIQUE (UserID, PostID)
);
GO

-- 2.2 Bảng Bình Luận (Comments)
CREATE TABLE Comments (
    CommentID INT IDENTITY(1,1) PRIMARY KEY,
    PostID INT NOT NULL,
    UserID INT NOT NULL,
    Content NVARCHAR(MAX) NOT NULL,
    CreatedAt DATETIME DEFAULT GETDATE(),
    CONSTRAINT FK_Comments_User FOREIGN KEY (UserID) REFERENCES Users(UserID),
    CONSTRAINT FK_Comments_Post FOREIGN KEY (PostID) REFERENCES Posts(PostID) ON DELETE CASCADE
);
GO

-- 3. Bảng Kết bạn / Theo dõi (Friends)
CREATE TABLE Friends (
    FriendshipID INT IDENTITY(1,1) PRIMARY KEY,
    User1_ID INT NOT NULL,
    User2_ID INT NOT NULL,
    Status VARCHAR(20) DEFAULT 'FOLLOWING', -- FOLLOWING, FRIENDS, BLOCKED
    CreatedAt DATETIME DEFAULT GETDATE(),
    -- Ràng buộc khóa ngoại
    CONSTRAINT FK_Friends_User1 FOREIGN KEY (User1_ID) REFERENCES Users(UserID),
    CONSTRAINT FK_Friends_User2 FOREIGN KEY (User2_ID) REFERENCES Users(UserID),
    -- Đảm bảo không trùng lặp cặp User liên tiếp
    CONSTRAINT UQ_Friends_Pair UNIQUE (User1_ID, User2_ID)
);
GO

-- 4. Bảng Tin nhắn (Tin nhắn Real-time WebSockets)
CREATE TABLE Messages (
    MessageID INT IDENTITY(1,1) PRIMARY KEY,
    SenderID INT NOT NULL,
    ReceiverID INT NOT NULL,
    Content NVARCHAR(MAX) NOT NULL,
    SentAt DATETIME DEFAULT GETDATE(),
    IsRead BIT DEFAULT 0, -- Trạng thái tin rác / đã đọc
    -- Ràng buộc khóa ngoại
    CONSTRAINT FK_Messages_Sender FOREIGN KEY (SenderID) REFERENCES Users(UserID),
    CONSTRAINT FK_Messages_Receiver FOREIGN KEY (ReceiverID) REFERENCES Users(UserID)
);
GO

-- Tạo Index để tăng tốc truy vấn (Cải thiện hiệu năng - Performance Testing Constraint)
-- 1. Tìm tin nhắn nhanh qua ID người gửi/nhận
CREATE NONCLUSTERED INDEX IX_Messages_SenderReceiver ON Messages(SenderID, ReceiverID);
-- 2. Tìm danh sách User theo Username cho phần Đăng nhập
CREATE NONCLUSTERED INDEX IX_Users_Username ON Users(Username);
-- 3. Lọc danh sách bài đăng Feed nhanh theo Thời gian
CREATE NONCLUSTERED INDEX IX_Posts_CreatedAt ON Posts(CreatedAt DESC);
GO

-- Ảo hóa dữ liệu mẫu (Dummy Data)
INSERT INTO Users (Username, PasswordHash, FullName, AvatarUrl, Bio) 
VALUES 
('duongnguyen', 'hash_123', 'Duong Nguyen', 'duong.jpg', 'Yêu lập trình Web'),
('alexdev', 'hash_123', 'Alex Developer', 'alex.jpg', 'Chuyên gia Java Servlet'),
('sarah', 'hash_123', 'Sarah Designer', 'sarah.jpg', 'UI/UX Master');

INSERT INTO Posts (UserID, Content) 
VALUES 
(2, N'Lần đầu tiên trải nghiệm WePost, hệ thống chat realtime thực sự rất mượt mà!'),
(3, N'Giao diện này nhìn khá giống một mạng xã hội chim xanh nổi tiếng nhỉ? Dark mode rất đẹp và dịu mắt.');

INSERT INTO Friends (User1_ID, User2_ID) 
VALUES 
(1, 2), -- Duong Nguyen theo dõi Alex
(1, 3); -- Duong Nguyen theo dõi Sarah

INSERT INTO Messages (SenderID, ReceiverID, Content) 
VALUES 
(2, 1, N'Chào bạn, code chạy khá ổn trên local. Bạn đã test WebSocket bao giờ chưa?'),
(1, 2, N'Mình vừa test thử rồi. Chat thời gian thực rất nhanh không hề trễ mạng.'),
(2, 1, N'Okay lát nữa tôi kiểm tra nhé');
GO
