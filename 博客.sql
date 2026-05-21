-- 创建数据库
CREATE DATABASE IF NOT EXISTS blog_db DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE blog_db;

-- 1. 用户表
DROP TABLE IF EXISTS `user`;
CREATE TABLE `user` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '用户ID',
  `username` varchar(50) NOT NULL COMMENT '用户名',
  `password` varchar(255) NOT NULL COMMENT '密码（加密）',
  `nickname` varchar(50) DEFAULT NULL COMMENT '昵称',
  `avatar` varchar(500) DEFAULT NULL COMMENT '头像URL',
  `role` varchar(20) DEFAULT 'user' COMMENT '角色：admin-管理员，user-普通用户',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` tinyint DEFAULT 0 COMMENT '逻辑删除标识：0-未删除，1-已删除',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_username` (`username`),
  INDEX `idx_username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='用户表';

-- 初始管理员账号：admin 密码：admin123（需要在应用中加密后使用）
INSERT INTO `user` VALUES (1,'admin','$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVKIUi','管理员','', 'admin',now(),now(),0);

-- 2. 分类表
DROP TABLE IF EXISTS `category`;
CREATE TABLE `category` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '分类ID',
  `name` varchar(50) NOT NULL COMMENT '分类名称',
  `sort` int DEFAULT 0 COMMENT '排序号（数字越小越靠前）',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` tinyint DEFAULT 0 COMMENT '逻辑删除标识：0-未删除，1-已删除',
  PRIMARY KEY (`id`),
  INDEX `idx_sort` (`sort`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='文章分类表';

INSERT INTO `category` VALUES 
(1,'技术分享',1,now(),now(),0),
(2,'生活随笔',2,now(),now(),0),
(3,'学习笔记',3,now(),now(),0),
(4,'项目实战',4,now(),now(),0);

-- 3. 标签表
DROP TABLE IF EXISTS `tag`;
CREATE TABLE `tag` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '标签ID',
  `name` varchar(30) NOT NULL COMMENT '标签名称',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` tinyint DEFAULT 0 COMMENT '逻辑删除标识：0-未删除，1-已删除',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_name` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='文章标签表';

INSERT INTO `tag` VALUES 
(1,'Java',now(),now(),0),
(2,'Spring Boot',now(),now(),0),
(3,'MySQL',now(),now(),0),
(4,'前端',now(),now(),0),
(5,'Vue',now(),now(),0),
(6,'Python',now(),now(),0),
(7,'Linux',now(),now(),0),
(8,'Docker',now(),now(),0);

-- 4. 文章表
DROP TABLE IF EXISTS `article`;
CREATE TABLE `article` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '文章ID',
  `title` varchar(255) NOT NULL COMMENT '文章标题',
  `cover` varchar(500) DEFAULT NULL COMMENT '封面图片URL',
  `content` longtext COMMENT '文章内容',
  `category_id` bigint DEFAULT NULL COMMENT '分类ID',
  `view_count` int DEFAULT 0 COMMENT '浏览量',
  `publish_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '发布时间',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` tinyint DEFAULT 0 COMMENT '逻辑删除标识：0-未删除，1-已删除',
  PRIMARY KEY (`id`),
  INDEX `idx_category_id` (`category_id`),
  INDEX `idx_publish_time` (`publish_time`),
  INDEX `idx_title` (`title`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='文章表';

-- 插入测试文章数据
INSERT INTO `article` (`title`, `cover`, `content`, `category_id`, `view_count`, `publish_time`, `create_time`, `update_time`, `deleted`) VALUES 
('Spring Boot 入门教程', '', '这里是 Spring Boot 入门教程的详细内容...', 1, 100, NOW(), NOW(), NOW(), 0),
('MySQL 优化技巧', '', '这里是 MySQL 优化技巧的详细内容...', 1, 80, NOW(), NOW(), NOW(), 0),
('我的2024年总结', '', '这里是年度总结的详细内容...', 2, 150, NOW(), NOW(), NOW(), 0);

-- 5. 文章-标签 中间表（多对多）
DROP TABLE IF EXISTS `article_tag`;
CREATE TABLE `article_tag` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `article_id` bigint NOT NULL COMMENT '文章ID',
  `tag_id` bigint NOT NULL COMMENT '标签ID',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_article_tag` (`article_id`, `tag_id`),
  INDEX `idx_article_id` (`article_id`),
  INDEX `idx_tag_id` (`tag_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='文章标签关联表';

-- 插入文章标签关联数据
INSERT INTO `article_tag` (`article_id`, `tag_id`) VALUES 
(1, 1), (1, 2),
(2, 3),
(3, 1);

-- 6. 评论表
DROP TABLE IF EXISTS `comment`;
CREATE TABLE `comment` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '评论ID',
  `article_id` bigint NOT NULL COMMENT '文章ID',
  `user_id` bigint NOT NULL COMMENT '评论用户ID',
  `content` text NOT NULL COMMENT '评论内容',
  `parent_id` bigint DEFAULT 0 COMMENT '父评论ID（0表示顶级评论）',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` tinyint DEFAULT 0 COMMENT '逻辑删除标识：0-未删除，1-已删除',
  PRIMARY KEY (`id`),
  INDEX `idx_article_id` (`article_id`),
  INDEX `idx_user_id` (`user_id`),
  INDEX `idx_parent_id` (`parent_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='评论表';

-- 插入测试评论数据
INSERT INTO `comment` (`article_id`, `user_id`, `content`, `parent_id`, `create_time`, `update_time`, `deleted`) VALUES 
(1, 1, '写得很好，受益匪浅！', 0, NOW(), NOW(), 0),
(1, 1, '谢谢分享', 1, NOW(), NOW(), 0),
(2, 1, '非常实用的优化技巧', 0, NOW(), NOW(), 0);

-- =============================================
-- 完成提示
-- =============================================
SELECT '数据库创建完成！' AS message;
