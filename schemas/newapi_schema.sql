-- MySQL dump 10.13  Distrib 8.3.0, for Linux (x86_64)
--
-- Host: localhost    Database: new-api
-- ------------------------------------------------------
-- Server version	8.3.0

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `abilities`
--

DROP TABLE IF EXISTS `abilities`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `abilities` (
  `group` varchar(64) NOT NULL,
  `model` varchar(255) NOT NULL,
  `channel_id` bigint NOT NULL,
  `enabled` tinyint(1) DEFAULT NULL,
  `priority` bigint DEFAULT '0',
  `weight` bigint unsigned DEFAULT '0',
  `tag` varchar(191) DEFAULT NULL,
  PRIMARY KEY (`group`,`model`,`channel_id`),
  KEY `idx_abilities_channel_id` (`channel_id`),
  KEY `idx_abilities_priority` (`priority`),
  KEY `idx_abilities_weight` (`weight`),
  KEY `idx_abilities_tag` (`tag`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `channels`
--

DROP TABLE IF EXISTS `channels`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `channels` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `type` bigint DEFAULT '0',
  `key` longtext NOT NULL,
  `open_ai_organization` longtext,
  `test_model` longtext,
  `status` bigint DEFAULT '1',
  `name` varchar(191) DEFAULT NULL,
  `weight` bigint unsigned DEFAULT '0',
  `created_time` bigint DEFAULT NULL,
  `test_time` bigint DEFAULT NULL,
  `response_time` bigint DEFAULT NULL,
  `base_url` varchar(191) DEFAULT '',
  `other` longtext,
  `balance` double DEFAULT NULL,
  `balance_updated_time` bigint DEFAULT NULL,
  `models` longtext,
  `group` varchar(64) DEFAULT 'default',
  `used_quota` bigint DEFAULT '0',
  `model_mapping` text,
  `status_code_mapping` varchar(1024) DEFAULT '',
  `priority` bigint DEFAULT '0',
  `auto_ban` bigint DEFAULT '1',
  `other_info` longtext,
  `tag` varchar(191) DEFAULT NULL,
  `setting` text,
  `param_override` text,
  PRIMARY KEY (`id`),
  KEY `idx_channels_name` (`name`),
  KEY `idx_channels_tag` (`tag`)
) ENGINE=InnoDB AUTO_INCREMENT=159 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `logs`
--

DROP TABLE IF EXISTS `logs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `logs` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `user_id` bigint DEFAULT NULL,
  `created_at` bigint DEFAULT NULL,
  `type` bigint DEFAULT NULL,
  `content` longtext,
  `username` varchar(191) DEFAULT '',
  `token_name` varchar(191) DEFAULT '',
  `model_name` varchar(191) DEFAULT '',
  `quota` bigint DEFAULT '0',
  `prompt_tokens` bigint DEFAULT '0',
  `completion_tokens` bigint DEFAULT '0',
  `use_time` bigint DEFAULT '0',
  `is_stream` tinyint(1) DEFAULT '0',
  `channel_id` bigint DEFAULT NULL,
  `channel_name` longtext,
  `token_id` bigint DEFAULT '0',
  `group` varchar(191) DEFAULT NULL,
  `other` longtext,
  `ip` varchar(191) DEFAULT '',
  PRIMARY KEY (`id`),
  KEY `idx_logs_user_id` (`user_id`),
  KEY `idx_logs_token_name` (`token_name`),
  KEY `idx_logs_model_name` (`model_name`),
  KEY `idx_logs_channel_id` (`channel_id`),
  KEY `idx_logs_token_id` (`token_id`),
  KEY `idx_logs_group` (`group`),
  KEY `idx_created_at_id` (`id`,`created_at`),
  KEY `idx_created_at_type` (`created_at`,`type`),
  KEY `idx_logs_username` (`username`),
  KEY `index_username_model_name` (`model_name`,`username`),
  KEY `idx_logs_ip` (`ip`)
) ENGINE=InnoDB AUTO_INCREMENT=9623 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `midjourneys`
--

DROP TABLE IF EXISTS `midjourneys`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `midjourneys` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `code` bigint DEFAULT NULL,
  `user_id` bigint DEFAULT NULL,
  `action` varchar(40) DEFAULT NULL,
  `mj_id` varchar(191) DEFAULT NULL,
  `prompt` longtext,
  `prompt_en` longtext,
  `description` longtext,
  `state` longtext,
  `submit_time` bigint DEFAULT NULL,
  `start_time` bigint DEFAULT NULL,
  `finish_time` bigint DEFAULT NULL,
  `image_url` longtext,
  `status` varchar(20) DEFAULT NULL,
  `progress` varchar(30) DEFAULT NULL,
  `fail_reason` longtext,
  `channel_id` bigint DEFAULT NULL,
  `quota` bigint DEFAULT NULL,
  `buttons` longtext,
  `properties` longtext,
  PRIMARY KEY (`id`),
  KEY `idx_midjourneys_user_id` (`user_id`),
  KEY `idx_midjourneys_action` (`action`),
  KEY `idx_midjourneys_mj_id` (`mj_id`),
  KEY `idx_midjourneys_submit_time` (`submit_time`),
  KEY `idx_midjourneys_start_time` (`start_time`),
  KEY `idx_midjourneys_finish_time` (`finish_time`),
  KEY `idx_midjourneys_status` (`status`),
  KEY `idx_midjourneys_progress` (`progress`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `options`
--

DROP TABLE IF EXISTS `options`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `options` (
  `key` varchar(191) NOT NULL,
  `value` longtext,
  PRIMARY KEY (`key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `quota_data`
--

DROP TABLE IF EXISTS `quota_data`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `quota_data` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `user_id` bigint DEFAULT NULL,
  `username` varchar(64) DEFAULT '',
  `model_name` varchar(64) DEFAULT '',
  `created_at` bigint DEFAULT NULL,
  `token_used` bigint DEFAULT '0',
  `count` bigint DEFAULT '0',
  `quota` bigint DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `idx_quota_data_user_id` (`user_id`),
  KEY `idx_qdt_model_user_name` (`model_name`,`username`),
  KEY `idx_qdt_created_at` (`created_at`)
) ENGINE=InnoDB AUTO_INCREMENT=759 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `redemptions`
--

DROP TABLE IF EXISTS `redemptions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `redemptions` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `user_id` bigint DEFAULT NULL,
  `key` char(32) DEFAULT NULL,
  `status` bigint DEFAULT '1',
  `name` varchar(191) DEFAULT NULL,
  `quota` bigint DEFAULT '100',
  `created_time` bigint DEFAULT NULL,
  `redeemed_time` bigint DEFAULT NULL,
  `used_user_id` bigint DEFAULT NULL,
  `deleted_at` datetime(3) DEFAULT NULL,
  `expired_time` bigint DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_redemptions_key` (`key`),
  KEY `idx_redemptions_name` (`name`),
  KEY `idx_redemptions_deleted_at` (`deleted_at`)
) ENGINE=InnoDB AUTO_INCREMENT=431 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `setups`
--

DROP TABLE IF EXISTS `setups`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `setups` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `version` varchar(50) NOT NULL,
  `initialized_at` bigint NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tasks`
--

DROP TABLE IF EXISTS `tasks`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tasks` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `created_at` bigint DEFAULT NULL,
  `updated_at` bigint DEFAULT NULL,
  `task_id` varchar(50) DEFAULT NULL,
  `platform` varchar(30) DEFAULT NULL,
  `user_id` bigint DEFAULT NULL,
  `channel_id` bigint DEFAULT NULL,
  `quota` bigint DEFAULT NULL,
  `action` varchar(40) DEFAULT NULL,
  `status` varchar(20) DEFAULT NULL,
  `fail_reason` longtext,
  `submit_time` bigint DEFAULT NULL,
  `start_time` bigint DEFAULT NULL,
  `finish_time` bigint DEFAULT NULL,
  `progress` varchar(20) DEFAULT NULL,
  `properties` json DEFAULT NULL,
  `data` json DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_tasks_start_time` (`start_time`),
  KEY `idx_tasks_platform` (`platform`),
  KEY `idx_tasks_user_id` (`user_id`),
  KEY `idx_tasks_action` (`action`),
  KEY `idx_tasks_submit_time` (`submit_time`),
  KEY `idx_tasks_finish_time` (`finish_time`),
  KEY `idx_tasks_progress` (`progress`),
  KEY `idx_tasks_created_at` (`created_at`),
  KEY `idx_tasks_task_id` (`task_id`),
  KEY `idx_tasks_channel_id` (`channel_id`),
  KEY `idx_tasks_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tokens`
--

DROP TABLE IF EXISTS `tokens`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tokens` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `user_id` bigint DEFAULT NULL,
  `key` char(48) DEFAULT NULL,
  `status` bigint DEFAULT '1',
  `name` varchar(191) DEFAULT NULL,
  `created_time` bigint DEFAULT NULL,
  `accessed_time` bigint DEFAULT NULL,
  `expired_time` bigint DEFAULT '-1',
  `remain_quota` bigint DEFAULT '0',
  `unlimited_quota` tinyint(1) DEFAULT '0',
  `model_limits_enabled` tinyint(1) DEFAULT '0',
  `model_limits` varchar(1024) DEFAULT '',
  `allow_ips` varchar(191) DEFAULT '',
  `used_quota` bigint DEFAULT '0',
  `group` varchar(191) DEFAULT '',
  `deleted_at` datetime(3) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_tokens_key` (`key`),
  KEY `idx_tokens_user_id` (`user_id`),
  KEY `idx_tokens_name` (`name`),
  KEY `idx_tokens_deleted_at` (`deleted_at`)
) ENGINE=InnoDB AUTO_INCREMENT=33 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `top_ups`
--

DROP TABLE IF EXISTS `top_ups`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `top_ups` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `user_id` bigint DEFAULT NULL,
  `amount` bigint DEFAULT NULL,
  `money` double DEFAULT NULL,
  `trade_no` longtext,
  `create_time` bigint DEFAULT NULL,
  `status` longtext,
  PRIMARY KEY (`id`),
  KEY `idx_top_ups_user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `users` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `username` varchar(191) DEFAULT NULL,
  `password` longtext NOT NULL,
  `display_name` varchar(191) DEFAULT NULL,
  `role` bigint DEFAULT '1',
  `status` bigint DEFAULT '1',
  `email` varchar(191) DEFAULT NULL,
  `github_id` varchar(191) DEFAULT NULL,
  `oidc_id` varchar(191) DEFAULT NULL,
  `wechat_id` varchar(191) DEFAULT NULL,
  `telegram_id` varchar(191) DEFAULT NULL,
  `access_token` char(32) DEFAULT NULL,
  `quota` bigint DEFAULT '0',
  `used_quota` bigint DEFAULT '0',
  `request_count` bigint DEFAULT '0',
  `group` varchar(64) DEFAULT 'default',
  `aff_code` varchar(32) DEFAULT NULL,
  `aff_count` bigint DEFAULT '0',
  `aff_quota` bigint DEFAULT '0',
  `aff_history` bigint DEFAULT '0',
  `inviter_id` bigint DEFAULT NULL,
  `deleted_at` datetime(3) DEFAULT NULL,
  `linux_do_id` varchar(191) DEFAULT NULL,
  `setting` text,
  `remark` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `username` (`username`),
  UNIQUE KEY `idx_users_aff_code` (`aff_code`),
  UNIQUE KEY `idx_users_access_token` (`access_token`),
  KEY `idx_users_display_name` (`display_name`),
  KEY `idx_users_email` (`email`),
  KEY `idx_users_git_hub_id` (`github_id`),
  KEY `idx_users_oidc_id` (`oidc_id`),
  KEY `idx_users_we_chat_id` (`wechat_id`),
  KEY `idx_users_telegram_id` (`telegram_id`),
  KEY `idx_users_inviter_id` (`inviter_id`),
  KEY `idx_users_username` (`username`),
  KEY `idx_users_deleted_at` (`deleted_at`),
  KEY `idx_users_linux_do_id` (`linux_do_id`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2025-06-19 14:22:53
