USE campus_second_hand;
SET NAMES utf8mb4;

-- 签到记录表
CREATE TABLE IF NOT EXISTS sign_in_records (
    recordId INT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '签到记录ID',
    userId INT UNSIGNED NOT NULL COMMENT '用户ID',
    signDate DATE NOT NULL COMMENT '签到日期',
    pointsEarned INT UNSIGNED NOT NULL DEFAULT 0 COMMENT '获得积分',
    streakDays INT UNSIGNED NOT NULL DEFAULT 1 COMMENT '连续签到天数',
    createTime DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '签到时间',
    PRIMARY KEY (recordId),
    UNIQUE KEY uk_user_date (userId, signDate),
    KEY idx_userId (userId),
    KEY idx_signDate (signDate),
    CONSTRAINT fk_sign_user FOREIGN KEY (userId) REFERENCES users(userId) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='签到记录表';

-- 购物车表
CREATE TABLE IF NOT EXISTS cart_items (
    cartId INT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '购物车记录ID',
    userId INT UNSIGNED NOT NULL COMMENT '用户ID',
    goodsId INT UNSIGNED NOT NULL COMMENT '商品ID',
    createTime DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '加入时间',
    PRIMARY KEY (cartId),
    UNIQUE KEY uk_user_goods (userId, goodsId),
    KEY idx_userId (userId),
    KEY idx_goodsId (goodsId),
    CONSTRAINT fk_cart_user FOREIGN KEY (userId) REFERENCES users(userId) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_cart_goods FOREIGN KEY (goodsId) REFERENCES goods(goodsId) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='购物车';

-- 收藏表
CREATE TABLE IF NOT EXISTS favorites (
    favoriteId INT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '收藏ID',
    userId INT UNSIGNED NOT NULL COMMENT '用户ID',
    goodsId INT UNSIGNED NOT NULL COMMENT '商品ID',
    createTime DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '收藏时间',
    PRIMARY KEY (favoriteId),
    UNIQUE KEY uk_user_goods (userId, goodsId),
    KEY idx_userId (userId),
    KEY idx_goodsId (goodsId),
    CONSTRAINT fk_fav_user FOREIGN KEY (userId) REFERENCES users(userId) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_fav_goods FOREIGN KEY (goodsId) REFERENCES goods(goodsId) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='收藏表';

-- 用户认证材料表
CREATE TABLE IF NOT EXISTS user_verify_materials (
    verifyId INT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '认证记录ID',
    userId INT UNSIGNED NOT NULL COMMENT '用户ID',
    studentId VARCHAR(20) NOT NULL COMMENT '学号',
    realName VARCHAR(50) NOT NULL COMMENT '真实姓名',
    cardPhoto VARCHAR(255) NOT NULL COMMENT '学生证照片URL',
    status TINYINT UNSIGNED NOT NULL DEFAULT 1 COMMENT '状态:1-待审核,2-已通过,3-已驳回',
    rejectReason VARCHAR(255) DEFAULT NULL COMMENT '驳回原因',
    submitTime DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '提交时间',
    auditTime DATETIME DEFAULT NULL COMMENT '审核时间',
    PRIMARY KEY (verifyId),
    UNIQUE KEY uk_userId (userId),
    KEY idx_status (status),
    CONSTRAINT fk_verify_user FOREIGN KEY (userId) REFERENCES users(userId) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='用户认证材料表';

-- 系统配置表
CREATE TABLE IF NOT EXISTS system_config (
    configId INT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '配置ID',
    configKey VARCHAR(50) NOT NULL COMMENT '配置键',
    configValue VARCHAR(255) NOT NULL COMMENT '配置值',
    description VARCHAR(255) DEFAULT NULL COMMENT '配置说明',
    createTime DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updateTime DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    PRIMARY KEY (configId),
    UNIQUE KEY uk_configKey (configKey),
    KEY idx_configKey (configKey)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='系统配置表';

-- 插入默认签到配置
INSERT INTO system_config (configKey, configValue, description) VALUES
('sign_base_points', '2', '每日签到基础积分'),
('sign_streak_bonus', '5', '连续签到7天额外奖励积分'),
('publish_reward_points', '10', '发布商品奖励积分'),
('publish_daily_limit', '3', '每日发布奖励上限'),
('order_cancel_hours', '48', '订单自动取消时限(小时)')
ON DUPLICATE KEY UPDATE configValue = VALUES(configValue);

-- 为 activities 表添加 coverImage 列（如果不存在）
SET @col_exists = (SELECT COUNT(*) FROM information_schema.COLUMNS WHERE TABLE_SCHEMA='campus_second_hand' AND TABLE_NAME='activities' AND COLUMN_NAME='coverImage');
SET @sql = IF(@col_exists = 0, 'ALTER TABLE activities ADD COLUMN coverImage VARCHAR(500) DEFAULT NULL COMMENT ''封面图URL'' AFTER title', 'SELECT 1');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;
