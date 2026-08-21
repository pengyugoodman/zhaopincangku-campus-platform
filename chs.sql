/*
SQLyog Community v13.1.6 (64 bit)
MySQL - 8.0.46 : Database - campus_second_hand
*********************************************************************
*/

/*!40101 SET NAMES utf8 */;

/*!40101 SET SQL_MODE=''*/;

/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;
CREATE DATABASE /*!32312 IF NOT EXISTS*/`campus_second_hand` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci */ /*!80016 DEFAULT ENCRYPTION='N' */;

USE `campus_second_hand`;

/*Table structure for table `activities` */

DROP TABLE IF EXISTS `activities`;

CREATE TABLE `activities` (
  `activityId` int unsigned NOT NULL AUTO_INCREMENT COMMENT '活动ID',
  `title` varchar(200) NOT NULL COMMENT '活动标题',
  `coverImage` varchar(500) DEFAULT NULL COMMENT '封面图URL',
  `description` text COMMENT '活动描述',
  `pointsReward` int unsigned NOT NULL COMMENT '完成奖励积分',
  `maxParticipants` int unsigned DEFAULT NULL COMMENT '最大参与人数（NULL不限）',
  `currentParticipants` int unsigned DEFAULT '0' COMMENT '当前参与人数',
  `startTime` datetime NOT NULL COMMENT '开始时间',
  `endTime` datetime NOT NULL COMMENT '结束时间',
  `status` tinyint unsigned DEFAULT '1' COMMENT '状态:0-草稿,1-进行中,2-已结束,3-已取消',
  `createTime` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updateTime` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`activityId`),
  KEY `idx_status_time` (`status`,`startTime`,`endTime`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='公益活动表';

/*Data for the table `activities` */

insert  into `activities`(`activityId`,`title`,`coverImage`,`description`,`pointsReward`,`maxParticipants`,`currentParticipants`,`startTime`,`endTime`,`status`,`createTime`,`updateTime`) values
(1,'旧书回收计划','https://example.com/activity/1.jpg','将闲置教材捐赠至图书馆，回收后统一处理',20,100,45,'2026-07-01 08:00:00','2026-07-15 20:00:00',1,'2026-07-08 10:52:34','2026-07-08 10:52:34'),
(2,'毕业季“薪火接力”','https://example.com/activity/2.jpg','毕业生捐赠学习资料，帮助学弟学妹',30,NULL,120,'2026-06-20 09:00:00','2026-07-10 18:00:00',1,'2026-07-08 10:52:34','2026-07-08 10:52:34'),
(3,'校园清洁志愿活动','https://example.com/activity/3.jpg','清理操场、宿舍区周边垃圾',25,30,12,'2026-07-05 14:00:00','2026-07-05 17:00:00',1,'2026-07-08 10:52:34','2026-07-08 10:52:34'),
(4,'衣物回收公益行动','https://example.com/activity/4.jpg','回收旧衣物，捐赠给贫困地区',15,50,8,'2026-07-08 10:00:00','2026-07-20 16:00:00',0,'2026-07-08 10:52:34','2026-07-08 10:52:34'),
(5,'线上低碳打卡','https://example.com/activity/5.jpg','每天步行8000步以上打卡，连续7天',10,200,88,'2026-07-01 00:00:00','2026-07-31 23:59:59',1,'2026-07-08 10:52:34','2026-07-08 10:52:34');

/*Table structure for table `activity_participation` */

DROP TABLE IF EXISTS `activity_participation`;

CREATE TABLE `activity_participation` (
  `participationId` int unsigned NOT NULL AUTO_INCREMENT COMMENT '参与记录ID',
  `userId` int unsigned NOT NULL COMMENT '用户ID',
  `activityId` int unsigned NOT NULL COMMENT '活动ID',
  `pointsEarned` int unsigned DEFAULT '0' COMMENT '获得的积分（实际发放时记录）',
  `status` tinyint unsigned DEFAULT '0' COMMENT '状态:0-报名,1-参与中,2-已完成,3-已取消',
  `joinTime` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '报名时间',
  `completeTime` datetime DEFAULT NULL COMMENT '完成时间',
  `remark` varchar(255) DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`participationId`),
  UNIQUE KEY `uk_user_activity` (`userId`,`activityId`),
  KEY `idx_userId` (`userId`),
  KEY `idx_activityId` (`activityId`),
  KEY `idx_status` (`status`),
  CONSTRAINT `fk_participation_activity` FOREIGN KEY (`activityId`) REFERENCES `activities` (`activityId`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_participation_user` FOREIGN KEY (`userId`) REFERENCES `users` (`userId`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='活动参与记录表';

/*Data for the table `activity_participation` */

insert  into `activity_participation`(`participationId`,`userId`,`activityId`,`pointsEarned`,`status`,`joinTime`,`completeTime`,`remark`) values 
(1,1,1,20,2,'2026-07-01 09:00:00','2026-07-02 16:00:00','捐赠了5本书'),
(2,2,1,20,2,'2026-07-01 10:00:00','2026-07-02 14:30:00','捐赠了3本教材'),
(3,3,2,30,2,'2026-06-20 10:00:00','2026-06-25 12:00:00','捐赠考研资料'),
(4,4,2,30,2,'2026-06-21 15:00:00','2026-06-27 09:00:00','捐赠了笔记本电脑包等'),
(5,5,3,25,2,'2026-07-05 13:30:00','2026-07-05 17:00:00','参加校园清洁'),
(6,8,1,20,2,'2026-07-01 11:00:00','2026-07-03 10:00:00','捐赠了10本书'),
(7,9,5,10,1,'2026-07-01 07:00:00',NULL,'打卡第一天'),
(8,10,5,10,1,'2026-07-01 08:00:00',NULL,'已完成第一天'),
(9,1,5,10,1,'2026-07-01 06:30:00',NULL,''),
(10,2,5,0,0,'2026-07-02 09:00:00',NULL,'');

/*Table structure for table `cart_items` */

DROP TABLE IF EXISTS `cart_items`;

CREATE TABLE `cart_items` (
  `cartId` int unsigned NOT NULL AUTO_INCREMENT COMMENT '璐?墿杞﹁?褰旾D',
  `userId` int unsigned NOT NULL COMMENT '鐢ㄦ埛ID',
  `goodsId` int unsigned NOT NULL COMMENT '鍟嗗搧ID',
  `createTime` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '鍔犲叆鏃堕棿',
  PRIMARY KEY (`cartId`),
  UNIQUE KEY `uk_user_goods` (`userId`,`goodsId`),
  KEY `idx_userId` (`userId`),
  KEY `idx_goodsId` (`goodsId`),
  CONSTRAINT `fk_cart_goods` FOREIGN KEY (`goodsId`) REFERENCES `goods` (`goodsId`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_cart_user` FOREIGN KEY (`userId`) REFERENCES `users` (`userId`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='璐?墿杞';

/*Data for the table `cart_items` */

/*Table structure for table `categories` */

DROP TABLE IF EXISTS `categories`;

CREATE TABLE `categories` (
  `categoryId` tinyint unsigned NOT NULL AUTO_INCREMENT COMMENT '分类ID',
  `parentId` tinyint unsigned DEFAULT '0' COMMENT '父分类ID',
  `categoryName` varchar(50) NOT NULL COMMENT '分类名称',
  `sortOrder` tinyint unsigned DEFAULT '0' COMMENT '排序',
  `icon` varchar(255) DEFAULT NULL COMMENT '图标',
  PRIMARY KEY (`categoryId`),
  KEY `idx_parentId` (`parentId`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='商品分类表';

/*Data for the table `categories` */

insert  into `categories`(`categoryId`,`parentId`,`categoryName`,`sortOrder`,`icon`) values 
(1,0,'教材教辅',1,NULL),
(2,0,'电子数码',2,NULL),
(3,0,'生活用品',3,NULL),
(4,0,'体育器材',4,NULL),
(5,0,'服饰鞋包',5,NULL),
(6,0,'其他',6,NULL);

/*Table structure for table `favorites` */

DROP TABLE IF EXISTS `favorites`;

CREATE TABLE `favorites` (
  `favoriteId` int unsigned NOT NULL AUTO_INCREMENT COMMENT '鏀惰棌ID',
  `userId` int unsigned NOT NULL COMMENT '鐢ㄦ埛ID',
  `goodsId` int unsigned NOT NULL COMMENT '鍟嗗搧ID',
  `createTime` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '鏀惰棌鏃堕棿',
  PRIMARY KEY (`favoriteId`),
  UNIQUE KEY `uk_user_goods` (`userId`,`goodsId`),
  KEY `idx_userId` (`userId`),
  KEY `idx_goodsId` (`goodsId`),
  CONSTRAINT `fk_fav_goods` FOREIGN KEY (`goodsId`) REFERENCES `goods` (`goodsId`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_fav_user` FOREIGN KEY (`userId`) REFERENCES `users` (`userId`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='鏀惰棌琛';

/*Data for the table `favorites` */

/*Table structure for table `goods` */

DROP TABLE IF EXISTS `goods`;

CREATE TABLE `goods` (
  `goodsId` int unsigned NOT NULL AUTO_INCREMENT COMMENT '商品ID',
  `sellerId` int unsigned NOT NULL COMMENT '卖家用户ID',
  `categoryId` tinyint unsigned NOT NULL COMMENT '商品分类ID',
  `title` varchar(200) NOT NULL COMMENT '商品标题',
  `description` text COMMENT '商品描述',
  `images` text COMMENT '图片URL列表（JSON数组）',
  `conditionLevel` tinyint unsigned DEFAULT '0' COMMENT '新旧程度:0-全新,1-几乎全新,2-有轻微使用痕迹,3-有明显磨损,4-已损坏',
  `flawDesc` varchar(500) DEFAULT NULL COMMENT '瑕疵说明',
  `pricePoints` int unsigned NOT NULL COMMENT '积分价格',
  `status` tinyint unsigned DEFAULT '0' COMMENT '状态:0-待审核,1-已上架,2-已下架,3-已售出',
  `auditRemark` varchar(255) DEFAULT NULL COMMENT '审核备注（驳回原因）',
  `viewCount` int unsigned DEFAULT '0' COMMENT '浏览次数',
  `createTime` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '发布时间',
  `updateTime` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `onTime` datetime DEFAULT NULL COMMENT '上架时间',
  `offTime` datetime DEFAULT NULL COMMENT '下架时间',
  PRIMARY KEY (`goodsId`),
  KEY `idx_sellerId` (`sellerId`),
  KEY `idx_categoryId` (`categoryId`),
  KEY `idx_status` (`status`),
  KEY `idx_pricePoints` (`pricePoints`),
  KEY `idx_createTime` (`createTime`),
  CONSTRAINT `fk_goods_category` FOREIGN KEY (`categoryId`) REFERENCES `categories` (`categoryId`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_goods_seller` FOREIGN KEY (`sellerId`) REFERENCES `users` (`userId`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=21 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='商品表';

/*Data for the table `goods` */

insert  into `goods`(`goodsId`,`sellerId`,`categoryId`,`title`,`description`,`images`,`conditionLevel`,`flawDesc`,`pricePoints`,`status`,`auditRemark`,`viewCount`,`createTime`,`updateTime`,`onTime`,`offTime`) values 
(1,1,1,'高等数学(第七版) 上下册','同济大学数学系编，全新未使用，买多了','[\"https://example.com/goods/1_1.jpg\",\"https://example.com/goods/1_2.jpg\"]',0,NULL,30,3,NULL,45,'2026-06-20 10:00:00','2026-07-08 10:52:34','2026-06-21 08:00:00','2026-07-08 10:52:34'),
(2,2,1,'大学英语四级真题精讲','含最近3年真题，几乎全新，有少量笔记','[\"https://example.com/goods/2_1.jpg\"]',1,'第3页有几行铅笔笔记',15,1,NULL,30,'2026-06-18 15:30:00','2026-07-08 10:52:34','2026-06-19 09:00:00',NULL),
(3,3,2,'苹果 AirPods Pro 二代','正品，使用1个月，保修期内','[\"https://example.com/goods/3_1.jpg\",\"https://example.com/goods/3_2.jpg\"]',1,'充电盒轻微划痕',280,3,NULL,120,'2026-06-15 20:00:00','2026-07-08 10:52:34','2026-06-16 10:00:00','2026-07-08 10:52:34'),
(4,4,2,'小米手环7 Pro','功能正常，屏幕有细小划痕','[\"https://example.com/goods/4_1.jpg\"]',2,'屏幕右下角有1mm划痕',50,3,NULL,22,'2026-06-22 09:00:00','2026-07-08 10:52:34','2026-06-23 08:00:00','2026-07-08 10:52:34'),
(5,5,3,'宿舍用折叠桌','床上桌，可折叠，实用','[\"https://example.com/goods/5_1.jpg\",\"https://example.com/goods/5_2.jpg\"]',2,'桌面有少量划痕',25,1,NULL,18,'2026-06-19 11:00:00','2026-07-08 10:52:34','2026-06-20 12:00:00',NULL),
(6,1,3,'全新台灯 USB充电','LED护眼灯，三档调光','[\"https://example.com/goods/6_1.jpg\"]',0,NULL,20,3,NULL,9,'2026-06-25 16:00:00','2026-07-08 10:52:34','2026-06-26 14:00:00','2026-07-08 10:52:34'),
(7,6,4,'篮球 斯伯丁','七号球，打气筒配套，使用过几次','[\"https://example.com/goods/7_1.jpg\"]',2,'表面轻微磨损',40,0,NULL,5,'2026-06-27 09:00:00','2026-07-08 10:52:34',NULL,NULL),
(8,7,5,'二手耐克运动鞋','42码，仅穿过一次，几乎全新','[\"https://example.com/goods/8_1.jpg\",\"https://example.com/goods/8_2.jpg\"]',1,NULL,60,2,'价格偏高，建议调整',12,'2026-06-20 14:00:00','2026-07-08 10:52:34',NULL,NULL),
(9,8,1,'考研数学复习全书','2025年版，全新，未使用','[\"https://example.com/goods/9_1.jpg\"]',0,NULL,45,3,NULL,60,'2026-06-17 08:00:00','2026-07-08 10:52:34','2026-06-18 10:00:00','2026-07-08 10:52:34'),
(10,9,2,'罗技M590无线鼠标','静音，双模连接，使用1年','[\"https://example.com/goods/10_1.jpg\"]',3,'左键微动有点软',35,3,NULL,28,'2026-06-21 10:00:00','2026-07-08 10:52:34','2026-06-22 09:00:00','2026-07-08 10:52:34'),
(11,10,3,'便携折叠水桶','宿舍洗衣服用，容量10L','[\"https://example.com/goods/11_1.jpg\"]',1,NULL,10,3,NULL,8,'2026-06-23 17:00:00','2026-07-08 10:52:34','2026-06-24 11:00:00','2026-07-08 10:52:34'),
(12,2,4,'羽毛球拍一对','铝合金材质，送球网','[\"https://example.com/goods/12_1.jpg\"]',2,'手胶有磨损',55,0,NULL,3,'2026-06-26 08:00:00','2026-07-08 10:52:34',NULL,NULL),
(13,3,5,'优衣库羽绒服','灰色，L码，冬季保暖','[\"https://example.com/goods/13_1.jpg\"]',2,'袖口轻微起毛',80,1,NULL,15,'2026-06-20 12:00:00','2026-07-08 10:52:34','2026-06-21 14:00:00',NULL),
(14,4,6,'吉他 雅马哈F310','入门琴，带包，琴弦有锈','[\"https://example.com/goods/14_1.jpg\",\"https://example.com/goods/14_2.jpg\"]',3,'琴弦需更换',120,1,NULL,35,'2026-06-18 16:00:00','2026-07-08 10:52:34','2026-06-19 10:00:00',NULL),
(15,5,1,'数据结构与算法 教材','清华大学出版社，有少量笔记','[\"https://example.com/goods/15_1.jpg\"]',2,'第5章有铅笔标注',20,1,NULL,16,'2026-06-24 13:00:00','2026-07-08 10:52:34','2026-06-25 10:00:00',NULL),
(16,6,3,'储物箱 中号','塑料，带盖，尺寸40*30*25','[\"https://example.com/goods/16_1.jpg\"]',1,NULL,15,1,NULL,7,'2026-06-22 18:00:00','2026-07-08 10:52:34','2026-06-23 09:00:00',NULL),
(17,7,2,'充电宝 10000mAh','小米移动电源，使用正常','[\"https://example.com/goods/17_1.jpg\"]',2,'外壳有划痕',30,3,NULL,20,'2026-06-19 09:00:00','2026-07-08 10:52:34','2026-06-20 08:00:00','2026-07-08 10:52:34'),
(18,8,4,'瑜伽垫 TPE材质','6mm厚，使用几次','[\"https://example.com/goods/18_1.jpg\"]',1,NULL,45,1,NULL,11,'2026-06-25 14:00:00','2026-07-08 10:52:34','2026-06-26 15:00:00',NULL),
(19,9,6,'自行车 折叠车','7成新，代步用','[\"https://example.com/goods/19_1.jpg\"]',3,'刹车需要调整',150,1,NULL,40,'2026-06-16 11:00:00','2026-07-08 10:52:34','2026-06-17 09:00:00',NULL),
(20,10,5,'女士单肩包','黑色，PU皮，时尚款','[\"https://example.com/goods/20_1.jpg\"]',1,NULL,55,1,NULL,14,'2026-06-23 10:00:00','2026-07-08 10:52:34','2026-06-24 08:00:00',NULL);

/*Table structure for table `orders` */

DROP TABLE IF EXISTS `orders`;

CREATE TABLE `orders` (
  `orderId` int unsigned NOT NULL AUTO_INCREMENT COMMENT '订单ID',
  `orderSn` varchar(32) NOT NULL COMMENT '订单编号（唯一）',
  `buyerId` int unsigned NOT NULL COMMENT '买家用户ID',
  `goodsId` int unsigned NOT NULL COMMENT '商品ID',
  `pointsCost` int unsigned NOT NULL COMMENT '消耗积分',
  `status` tinyint unsigned DEFAULT '0' COMMENT '订单状态:0-待确认,1-待取货,2-已完成,3-已取消',
  `pickupCode` varchar(10) DEFAULT NULL COMMENT '取货码',
  `deliveryMethod` tinyint unsigned DEFAULT '1' COMMENT '交付方式:1-校园自提,2-校内配送',
  `address` varchar(200) DEFAULT NULL COMMENT '配送地址（校内）',
  `buyerRemark` varchar(255) DEFAULT NULL COMMENT '买家备注',
  `confirmTime` datetime DEFAULT NULL COMMENT '确认收货时间',
  `cancelTime` datetime DEFAULT NULL COMMENT '取消时间',
  `createTime` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '下单时间',
  `updateTime` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`orderId`),
  UNIQUE KEY `uk_orderSn` (`orderSn`),
  UNIQUE KEY `uk_pickupCode` (`pickupCode`),
  KEY `idx_buyerId` (`buyerId`),
  KEY `idx_goodsId` (`goodsId`),
  KEY `idx_status` (`status`),
  KEY `idx_createTime` (`createTime`),
  CONSTRAINT `fk_orders_buyer` FOREIGN KEY (`buyerId`) REFERENCES `users` (`userId`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_orders_goods` FOREIGN KEY (`goodsId`) REFERENCES `goods` (`goodsId`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='订单表';

/*Data for the table `orders` */

insert  into `orders`(`orderId`,`orderSn`,`buyerId`,`goodsId`,`pointsCost`,`status`,`pickupCode`,`deliveryMethod`,`address`,`buyerRemark`,`confirmTime`,`cancelTime`,`createTime`,`updateTime`) values 
(1,'ORD202606210001',2,1,30,2,'A1B2C3',1,NULL,'书不错，希望保存好','2026-06-22 10:00:00',NULL,'2026-06-21 09:00:00','2026-07-08 10:52:34'),
(2,'ORD202606220002',3,3,280,2,'D4E5F6',1,NULL,'耳机正品吗？','2026-06-23 14:30:00',NULL,'2026-06-22 11:00:00','2026-07-08 10:52:34'),
(3,'ORD202606230003',4,4,50,1,'G7H8I9',1,NULL,'约在图书馆取',NULL,NULL,'2026-06-23 15:00:00','2026-07-08 10:52:34'),
(4,'ORD202606240004',5,6,20,0,'J0K1L2',1,NULL,'请尽快发货',NULL,NULL,'2026-06-24 08:00:00','2026-07-08 10:52:34'),
(5,'ORD202606250005',1,10,35,2,'M3N4O5',2,'5栋302','鼠标要试一下','2026-06-26 09:00:00',NULL,'2026-06-25 13:00:00','2026-07-08 10:52:34'),
(6,'ORD202606260006',8,9,45,1,'P6Q7R8',1,NULL,'考研用书',NULL,NULL,'2026-06-26 10:00:00','2026-07-08 10:52:34'),
(7,'ORD202606270007',9,14,120,3,NULL,1,NULL,'突然不想买了',NULL,NULL,'2026-06-27 08:00:00','2026-07-08 10:52:34'),
(8,'ORD202606280008',10,19,150,0,'S9T0U1',2,'6栋203','能帮忙调试刹车吗？',NULL,NULL,'2026-06-28 14:00:00','2026-07-08 10:52:34'),
(9,'ORD202606290009',2,11,10,2,'V2W3X4',1,NULL,'水桶好用','2026-06-30 11:00:00',NULL,'2026-06-29 09:00:00','2026-07-08 10:52:34'),
(10,'ORD202606300010',4,17,30,1,'Y5Z6A7',2,'4栋101','充电宝容量怎么样',NULL,NULL,'2026-06-30 16:00:00','2026-07-08 10:52:34');

/*Table structure for table `points_log` */

DROP TABLE IF EXISTS `points_log`;

CREATE TABLE `points_log` (
  `logId` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '日志ID',
  `userId` int unsigned NOT NULL COMMENT '用户ID',
  `type` tinyint unsigned NOT NULL COMMENT '类型:1-收入,2-支出',
  `amount` int unsigned NOT NULL COMMENT '积分数量',
  `source` tinyint unsigned NOT NULL COMMENT '来源:1-发布商品,2-完成交易,3-公益活动,4-连续登录,5-邀请好友,6-兑换商品,7-管理员调整',
  `sourceId` int unsigned DEFAULT NULL COMMENT '关联ID（如活动ID、订单ID等）',
  `description` varchar(255) DEFAULT NULL COMMENT '描述',
  `balanceAfter` int unsigned NOT NULL COMMENT '操作后余额',
  `createTime` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '记录时间',
  PRIMARY KEY (`logId`),
  KEY `idx_userId` (`userId`),
  KEY `idx_type` (`type`),
  KEY `idx_source` (`source`),
  KEY `idx_createTime` (`createTime`),
  CONSTRAINT `fk_points_user` FOREIGN KEY (`userId`) REFERENCES `users` (`userId`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=21 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='积分流水表';

/*Data for the table `points_log` */

insert  into `points_log`(`logId`,`userId`,`type`,`amount`,`source`,`sourceId`,`description`,`balanceAfter`,`createTime`) values 
(1,1,1,5,1,1,'发布商品 高等数学',5,'2026-06-20 10:00:00'),
(2,1,1,20,3,1,'参加旧书回收计划',25,'2026-07-02 16:00:00'),
(3,1,2,35,2,5,'购买商品 罗技鼠标',270,'2026-06-25 13:00:00'),
(4,2,1,5,1,2,'发布商品 英语四级真题',155,'2026-06-18 15:30:00'),
(5,2,1,20,3,1,'参加旧书回收计划',175,'2026-07-02 14:30:00'),
(6,2,2,30,2,1,'购买商品 高等数学',145,'2026-06-21 09:00:00'),
(7,2,2,10,2,9,'购买商品 便携折叠水桶',135,'2026-06-29 09:00:00'),
(8,3,1,5,1,3,'发布商品 AirPods',505,'2026-06-15 20:00:00'),
(9,3,1,30,3,2,'参加薪火接力',535,'2026-06-25 12:00:00'),
(10,3,2,280,2,2,'购买商品 AirPods',255,'2026-06-22 11:00:00'),
(11,4,1,5,1,4,'发布商品 小米手环',215,'2026-06-22 09:00:00'),
(12,4,1,30,3,2,'参加薪火接力',245,'2026-06-27 09:00:00'),
(13,4,2,50,2,3,'购买商品 小米手环',195,'2026-06-23 15:00:00'),
(14,4,2,30,2,10,'购买商品 充电宝',165,'2026-06-30 16:00:00'),
(15,5,1,5,1,5,'发布商品 折叠桌',85,'2026-06-19 11:00:00'),
(16,5,1,25,3,3,'参加校园清洁',110,'2026-07-05 17:00:00'),
(17,8,1,5,1,9,'发布商品 考研数学',605,'2026-06-17 08:00:00'),
(18,8,1,20,3,1,'参加旧书回收计划',625,'2026-07-03 10:00:00'),
(19,9,1,5,1,10,'发布商品 罗技鼠标',405,'2026-06-21 10:00:00'),
(20,10,1,5,1,11,'发布商品 折叠水桶',275,'2026-06-23 17:00:00');

/*Table structure for table `reviews` */

DROP TABLE IF EXISTS `reviews`;

CREATE TABLE `reviews` (
  `reviewId` int unsigned NOT NULL AUTO_INCREMENT COMMENT '评价ID',
  `orderId` int unsigned NOT NULL COMMENT '订单ID',
  `fromUserId` int unsigned NOT NULL COMMENT '评价人（买家）',
  `toUserId` int unsigned NOT NULL COMMENT '被评价人（卖家）',
  `rating` tinyint unsigned NOT NULL COMMENT '评分:1-5分',
  `content` varchar(500) DEFAULT NULL COMMENT '评价内容',
  `createTime` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '评价时间',
  PRIMARY KEY (`reviewId`),
  UNIQUE KEY `uk_orderId` (`orderId`),
  KEY `idx_fromUserId` (`fromUserId`),
  KEY `idx_toUserId` (`toUserId`),
  KEY `idx_rating` (`rating`),
  CONSTRAINT `fk_reviews_from` FOREIGN KEY (`fromUserId`) REFERENCES `users` (`userId`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_reviews_order` FOREIGN KEY (`orderId`) REFERENCES `orders` (`orderId`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_reviews_to` FOREIGN KEY (`toUserId`) REFERENCES `users` (`userId`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='交易评价表';

/*Data for the table `reviews` */

insert  into `reviews`(`reviewId`,`orderId`,`fromUserId`,`toUserId`,`rating`,`content`,`createTime`) values 
(1,1,2,1,5,'书很新，卖家信用好','2026-06-22 10:30:00'),
(2,2,3,4,4,'耳机不错，就是价格略高','2026-06-23 15:00:00'),
(3,5,1,9,5,'鼠标很好用，谢谢卖家','2026-06-26 09:30:00'),
(4,9,2,10,4,'水桶便宜实用','2026-06-30 11:30:00');

/*Table structure for table `sign_in_records` */

DROP TABLE IF EXISTS `sign_in_records`;

CREATE TABLE `sign_in_records` (
  `recordId` int unsigned NOT NULL AUTO_INCREMENT COMMENT '绛惧埌璁板綍ID',
  `userId` int unsigned NOT NULL COMMENT '鐢ㄦ埛ID',
  `signDate` date NOT NULL COMMENT '绛惧埌鏃ユ湡',
  `pointsEarned` int unsigned NOT NULL DEFAULT '0' COMMENT '鑾峰緱绉?垎',
  `streakDays` int unsigned NOT NULL DEFAULT '1' COMMENT '杩炵画绛惧埌澶╂暟',
  `createTime` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '绛惧埌鏃堕棿',
  PRIMARY KEY (`recordId`),
  UNIQUE KEY `uk_user_date` (`userId`,`signDate`),
  KEY `idx_userId` (`userId`),
  KEY `idx_signDate` (`signDate`),
  CONSTRAINT `fk_sign_user` FOREIGN KEY (`userId`) REFERENCES `users` (`userId`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='绛惧埌璁板綍琛';

/*Data for the table `sign_in_records` */

/*Table structure for table `system_config` */

DROP TABLE IF EXISTS `system_config`;

CREATE TABLE `system_config` (
  `configId` int unsigned NOT NULL AUTO_INCREMENT COMMENT '閰嶇疆ID',
  `configKey` varchar(50) NOT NULL COMMENT '閰嶇疆閿',
  `configValue` varchar(255) NOT NULL COMMENT '閰嶇疆鍊',
  `description` varchar(255) DEFAULT NULL COMMENT '閰嶇疆璇存槑',
  `createTime` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '鍒涘缓鏃堕棿',
  `updateTime` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '鏇存柊鏃堕棿',
  PRIMARY KEY (`configId`),
  UNIQUE KEY `uk_configKey` (`configKey`),
  KEY `idx_configKey` (`configKey`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='绯荤粺閰嶇疆琛';

/*Data for the table `system_config` */

insert  into `system_config`(`configKey`,`configValue`,`description`) values
('sign_base_points','2','每日签到基础积分'),
('sign_streak_bonus','5','连续签到7天额外奖励积分'),
('publish_reward_points','10','发布商品奖励积分'),
('publish_daily_limit','3','每日发布奖励上限'),
('order_cancel_hours','48','订单自动取消时限(小时)');

/*Table structure for table `user_verify_materials` */

DROP TABLE IF EXISTS `user_verify_materials`;

CREATE TABLE `user_verify_materials` (
  `verifyId` int unsigned NOT NULL AUTO_INCREMENT COMMENT '璁よ瘉璁板綍ID',
  `userId` int unsigned NOT NULL COMMENT '鐢ㄦ埛ID',
  `studentId` varchar(20) NOT NULL COMMENT '瀛﹀彿',
  `realName` varchar(50) NOT NULL COMMENT '鐪熷疄濮撳悕',
  `cardPhoto` varchar(255) NOT NULL COMMENT '瀛︾敓璇佺収鐗嘦RL',
  `status` tinyint unsigned NOT NULL DEFAULT '1' COMMENT '鐘舵?:1-寰呭?鏍?2-宸查?杩?3-宸查┏鍥',
  `rejectReason` varchar(255) DEFAULT NULL COMMENT '椹冲洖鍘熷洜',
  `submitTime` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '鎻愪氦鏃堕棿',
  `auditTime` datetime DEFAULT NULL COMMENT '瀹℃牳鏃堕棿',
  PRIMARY KEY (`verifyId`),
  UNIQUE KEY `uk_userId` (`userId`),
  KEY `idx_status` (`status`),
  CONSTRAINT `fk_verify_user` FOREIGN KEY (`userId`) REFERENCES `users` (`userId`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='鐢ㄦ埛璁よ瘉鏉愭枡琛';

/*Data for the table `user_verify_materials` */

/*Table structure for table `users` */

DROP TABLE IF EXISTS `users`;

CREATE TABLE `users` (
  `userId` int unsigned NOT NULL AUTO_INCREMENT COMMENT '用户ID',
  `studentId` varchar(20) NOT NULL COMMENT '学号',
  `realName` varchar(50) NOT NULL COMMENT '真实姓名',
  `nickname` varchar(50) DEFAULT NULL COMMENT '昵称',
  `phone` varchar(15) NOT NULL COMMENT '手机号',
  `password` varchar(255) NOT NULL COMMENT '登录密码（加密）',
  `avatar` varchar(255) DEFAULT NULL COMMENT '头像URL',
  `creditScore` tinyint unsigned DEFAULT '100' COMMENT '信用分(0-100)',
  `pointsBalance` int unsigned DEFAULT '0' COMMENT '当前积分余额',
  `verifyStatus` tinyint unsigned DEFAULT '0' COMMENT '认证状态:0-未认证,1-待审核,2-已认证,3-驳回',
  `role` tinyint unsigned DEFAULT '0' COMMENT '角色:0-普通用户,1-管理员',
  `status` tinyint unsigned DEFAULT '1' COMMENT '状态:0-禁用,1-正常',
  `createTime` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '注册时间',
  `updateTime` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`userId`),
  UNIQUE KEY `uk_studentId` (`studentId`),
  UNIQUE KEY `uk_phone` (`phone`),
  KEY `idx_creditScore` (`creditScore`)
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='用户表';

/*Data for the table `users` */

insert  into `users`(`userId`,`studentId`,`realName`,`nickname`,`phone`,`password`,`avatar`,`creditScore`,`pointsBalance`,`verifyStatus`,`role`,`status`,`createTime`,`updateTime`) values
(1,'202101001','ABC','小明同学','13800000001','123456','https://example.com/avatar/1.jpg',96,340,2,0,1,'2026-07-08 10:52:34','2026-07-09 23:26:38'),
(2,'202101002','李红','红红','13800000002','123456','https://example.com/avatar/2.jpg',88,170,2,0,1,'2026-07-08 10:52:34','2026-07-08 10:52:34'),
(3,'202101003','王强','强哥','13800000003','123456','https://example.com/avatar/3.jpg',76,530,2,0,1,'2026-07-08 10:52:34','2026-07-08 10:52:35'),
(4,'202101004','赵丽','丽丽','13800000004','123456','https://example.com/avatar/4.jpg',93,240,2,0,1,'2026-07-08 10:52:34','2026-07-08 10:52:35'),
(5,'202101005','陈浩','浩子','13800000005','123456','https://example.com/avatar/5.jpg',80,105,2,0,1,'2026-07-08 10:52:34','2026-07-08 10:52:35'),
(6,'202101006','周芳','芳芳','13800000006','123456','https://example.com/avatar/6.jpg',70,30,1,0,1,'2026-07-08 10:52:34','2026-07-08 10:52:34'),
(7,'202101007','吴刚','刚子','13800000007','123456','https://example.com/avatar/7.jpg',65,5,0,0,1,'2026-07-08 10:52:34','2026-07-08 10:52:34'),
(8,'202101008','郑丽','小郑','13800000008','123456','https://example.com/avatar/8.jpg',100,620,2,0,1,'2026-07-08 10:52:34','2026-07-08 10:52:34'),
(9,'202101009','孙鹏','大鹏','13800000009','123456','https://example.com/avatar/9.jpg',86,400,2,0,1,'2026-07-08 10:52:34','2026-07-08 10:52:35'),
(10,'202101010','刘洋','洋洋','13800000010','123456','https://example.com/avatar/10.jpg',91,270,2,0,1,'2026-07-08 10:52:34','2026-07-08 10:52:35'),
(11,'admin001','管理员','管理员','13800000000','123456','https://example.com/avatar/admin.jpg',0,0,2,1,1,'2026-07-08 10:52:34','2026-07-08 10:52:34');

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;
