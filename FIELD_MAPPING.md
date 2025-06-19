# VoAPI至NewAPI字段映射文档 (FIELD_MAPPING.md)

**版本:** 2.0 (详尽版)
**日期:** 2025年06月19日

本文档基于对两个数据库 schema 的完整对比，提供一份详尽的、逐表的字段映射关系、转换规则和取舍策略。根据指示，`redemptions` 表已被排除在此次分析之外。

## 1. 总体迁移策略

- **用户数据为核心**: `users`, `tokens`, `logs` 是迁移的重中之重。
- **配置数据采用目标库**: `channels`, `abilities`, `options` 等配置类数据，以 `newapi` 基准库为准，仅做引用，不进行数据迁移。
- **新增功能表忽略**: `newapi` 中新增的 `midjourneys`, `setups` 等表，在本次迁移中不涉及。
- **废弃功能表舍弃**: `voapi` 中特有的、在新版中已不存在的表或字段将被舍弃。

## 2. 逐表字段映射详情

---

### **`users` (用户表)**
**策略:** 核心用户信息迁移。`voapi` 特有的第三方登录信息和附加功能字段将被舍弃。

| VoAPI 字段 (`voapi.users`) | NewAPI 字段 (`newapi.users`) | 转换规则 / 备注 |
| :--- | :--- | :--- |
| `id` | `id` | 直接迁移 (主键) |
| `username` | `username` | 直接迁移 |
| `password` | `password` | **不迁移**。所有用户需在新系统重置密码。 |
| `display_name` | `display_name` | 直接迁移 |
| `role` | `role` | 直接迁移 |
| `status` | `status` | 直接迁移 |
| `email` | `email` | 直接迁移 |
| `quota` | `quota` | 直接迁移 |
| `used_quota` | `used_quota` | 直接迁移 |
| `request_count` | `request_count` | 直接迁移 |
| `group` | `group` | 直接迁移 |
| `aff_code` | `aff_code` | 直接迁移 |
| `aff_count` | `aff_count` | 直接迁移 |
| `aff_quota` | `aff_quota` | 直接迁移 |
| `aff_history_quota` | `aff_history` | **字段更名**，直接迁移值。 |
| `inviter_id` | `inviter_id` | 直接迁移 |
| `github_id`, `github_info` | (无) | **舍弃**。`newapi` 废弃了此登录方式。 |
| `linuxdo_id` | `linux_do_id` | **字段更名**，直接迁移值。 |
| `linuxdo_id_level` | (无) | **舍弃**。 |
| `wechat_id` | `wechat_id` | 直接迁移 |
| `telegram_id` | `telegram_id` | 直接迁移 |
| `access_token` | `access_token` | 直接迁移 |
| `last_clock_in` | (无) | **舍弃** (`voapi` 特有功能)。 |
| `register_ip`, `last_login_ip` | (无) | **舍弃** (隐私与安全考虑)。 |
| `created_at` | (无) | **舍弃**。`newapi` 会自动处理时间。 |
| `deleted_at` | `deleted_at` | 直接迁移。 |
| (无) | `oidc_id` | **新增字段**，迁移时留空 (`NULL`)。 |
| (无) | `setting`, `remark` | **新增字段**，迁移时留空 (`NULL`)。 |

---

### **`tokens` (令牌表)**
**策略:** 结构几乎完全一致，可以直接进行全量迁移。

| VoAPI 字段 (`voapi.tokens`) | NewAPI 字段 (`newapi.tokens`) | 转换规则 / 备注 |
| :--- | :--- | :--- |
| `id` | `id` | 直接迁移 |
| `user_id` | `user_id` | 直接迁移 |
| `key` | `key` | 直接迁移 |
| `status` | `status` | 直接迁移 |
| `name` | `name` | 直接迁移 |
| `created_time` | `created_time` | 直接迁移 |
| `accessed_time` | `accessed_time` | 直接迁移 |
| `expired_time` | `expired_time` | 直接迁移 |
| `remain_quota` | `remain_quota` | 直接迁移 |
| `unlimited_quota` | `unlimited_quota` | 直接迁移 |
| `model_limits_enabled`| `model_limits_enabled`| 直接迁移 |
| `model_limits` | `model_limits` | 直接迁移 |
| `allow_ips` | `allow_ips` | 直接迁移 |
| `used_quota` | `used_quota` | 直接迁移 |
| `group` | `group` | 直接迁移 |
| `deleted_at` | `deleted_at` | 直接迁移 |

---

### **`logs` (日志表)**
**策略:** 迁移核心日志信息，`newapi` 的新增字段需根据“引用与融合”原则，通过关联查询填充。

| VoAPI 字段 (`voapi.logs`) | NewAPI 字段 (`newapi.logs`) | 转换规则 / 备注 |
| :--- | :--- | :--- |
| `id` | `id` | 直接迁移 |
| `user_id` | `user_id` | 直接迁移 |
| `created_at` | `created_at` | 直接迁移 |
| `type` | `type` | 直接迁移 |
| `content` | `content` | 直接迁移 |
| `username` | `username` | 直接迁移 |
| `token_name` | `token_name` | 直接迁移 |
| `model_name` | `model_name` | 直接迁移 |
| `quota` | `quota` | 直接迁移 |
| `prompt_tokens` | `prompt_tokens` | 直接迁移 |
| `completion_tokens` | `completion_tokens`| 直接迁移 |
| `use_time` | `use_time` | 直接迁移 |
| `is_stream` | `is_stream` | 直接迁移 |
| `channel` | `channel_id` | **字段更名**，直接迁移值。 |
| `token_id` | `token_id` | 直接迁移 |
| `ip` | `ip` | 直接迁移。注意 `voapi` 为 `longtext`，`newapi` 为 `varchar(191)`，可能需要截断或验证。 |
| `root_content` | (无) | **舍弃**。 |
| (无) | `channel_name` | **引用与融合**：脚本需根据 `channel_id` 查询 `newapi.channels` 表来填充。 |
| (无) | `group` | **引用与融合**：脚本需根据 `user_id` 查询 `newapi.users` 表来填充。 |

---

### **`abilities` (模型权限表)**
**策略:** 结构几乎完全一致，可以直接进行全量迁移。这是实现模型路由和访问控制的核心数据。

| VoAPI 字段 (`voapi.abilities`) | NewAPI 字段 (`newapi.abilities`) | 转换规则 / 备注 |
| :--- | :--- | :--- |
| `group` | `group` | 直接迁移 |
| `model` | `model` | 直接迁移。`newapi` 中字段长度更长 (`varchar(255)` vs `varchar(64)`)，兼容。|
| `channel_id` | `channel_id` | 直接迁移 |
| `enabled` | `enabled` | 直接迁移 |
| `priority` | `priority` | 直接迁移 |
| `weight` | `weight` | 直接迁移 |
| `tag` | `tag` | 直接迁移 |

### **`options` (系统配置表)**
**策略:** **选择性迁移（最终版）**。经过测试，直接迁移部分UI配置（如 `HomePageContent`, `Notice`, `Footer`, `About`, `SiteName`）会导致新版后台显示异常。因此，最终决定仅迁移少数安全且兼容的配置项。

- **迁移方式:** 采用 `INSERT ... ON DUPLICATE KEY UPDATE` 语句，逐条更新白名单内的配置。
- **最终白名单 (Final Whitelist):** `Logo`, `ModelRatio`, `GroupRatio`, `TopUpLink`, `ChatLink`, `QuotaPerUnit`, `DisplayInCurrency`。
- **已放弃的配置:** 所有与UI显示、个性化内容相关的配置项均**不进行迁移**，建议在新系统中手动配置。

---

### **`quota_data` & `top_ups` (额度与充值表)**
**策略:** 结构几乎完全一致，可以考虑直接迁移。

- **`quota_data`**: 所有字段 (`id`, `user_id`, `username`, `model_name`, `created_at`, `token_used`, `count`, `quota`) 均可直接映射。
- **`top_ups`**: 所有字段 (`id`, `user_id`, `amount`, `money`, `trade_no`, `create_time`, `status`) 均可直接映射。

---

### **`tasks` (任务表)**
**策略:** 此表关联异步任务（如 Midjourney），数据时效性强且结构有差异。建议**不进行迁移**，以避免潜在的状态不一致问题。

| VoAPI 字段 (`voapi.tasks`) | NewAPI 字段 (`newapi.tasks`) | 转换规则 / 备注 |
| :--- | :--- | :--- |
| `remote_task_id` | (无) | **舍弃**。 |
| (其他字段) | (其他字段) | 结构基本一致，但鉴于业务逻辑，**建议不迁移此表**。 |

---

### **`redemptions` (兑换码表)**
**策略:** 结构基本一致，直接全量迁移。`new-api` 中新增的 `expired_time` 字段在迁移后将留空 (`NULL`)。

| VoAPI 字段 (`voapi.redemptions`) | NewAPI 字段 (`newapi.redemptions`) | 转换规则 / 备注 |
| :--- | :--- | :--- |
| `id` | `id` | 直接迁移 |
| `user_id` | `user_id` | 直接迁移 |
| `key` | `key` | 直接迁移 |
| `status` | `status` | 直接迁移 |
| `name` | `name` | 直接迁移 |
| `quota` | `quota` | 直接迁移 |
| `created_time` | `created_time` | 直接迁移 |
| `redeemed_time` | `redeemed_time` | 直接迁移 |
| `used_user_id` | `used_user_id` | 直接迁移 |
| `deleted_at` | `deleted_at` | 直接迁移 |
| (无) | `expired_time` | **新增字段**，迁移时留空 (`NULL`)。 |

---

### **`midjourneys` & `setups` (新功能表)**
**策略:** 这些是 `newapi` 新增的表，`voapi` 中不存在。**无需任何操作**。