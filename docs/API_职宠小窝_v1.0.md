# 《职宠小窝》APP API接口文档

**文档编号：** API-JOBPET-001  
**版本号：** v1.0  
**编写日期：** 2026-03-16  
**文档状态：** 正式发布  
**基础URL：** `https://api.leancloud.cn/1.1`

---

## 修订历史

| 版本 | 日期 | 修订人 | 修订内容 |
|------|------|--------|----------|
| v1.0 | 2026-03-16 | 架构师 | 初始版本 |

---

## 目录

1. [接口概述](#1-接口概述)
2. [通用规范](#2-通用规范)
3. [用户认证接口](#3-用户认证接口)
4. [倾诉交互接口](#4-倾诉交互接口)
5. [求职事件接口](#5-求职事件接口)
6. [求职看板接口](#6-求职看板接口)
7. [彼岸公园接口](#7-彼岸公园接口)
8. [岗位聚合接口](#8-岗位聚合接口)
9. [宠物皮肤接口](#9-宠物皮肤接口)
10. [会员服务接口](#10-会员服务接口)
11. [数据同步接口](#11-数据同步接口)
12. [推送服务接口](#12-推送服务接口)
13. [错误码定义](#13-错误码定义)

---

## 1. 接口概述

### 1.1 接口架构

本APP采用LeanCloud BaaS平台，API分为两类：

| 类型 | 说明 | 示例 |
|------|------|------|
| REST API | LeanCloud标准REST接口 | 用户注册、数据CRUD |
| 云函数 | 自定义业务逻辑 | 意图识别、回忆录生成 |

### 1.2 接口列表总览

| 模块 | 接口数量 | 说明 |
|------|----------|------|
| 用户认证 | 5 | 注册、登录、注销等 |
| 倾诉交互 | 4 | 倾诉提交、历史查询等 |
| 求职事件 | 4 | 事件CRUD |
| 求职看板 | 3 | 统计、趋势、成就 |
| 彼岸公园 | 6 | 公园相关功能 |
| 岗位聚合 | 2 | 岗位列表、详情 |
| 宠物皮肤 | 4 | 皮肤列表、装备等 |
| 会员服务 | 3 | 订阅、权益查询 |
| 数据同步 | 2 | 同步上传、下载 |
| 推送服务 | 2 | 注册、配置 |

---

## 2. 通用规范

### 2.1 请求头

**必需请求头：**

```http
X-LC-Id: {AppId}
X-LC-Key: {AppKey}
Content-Type: application/json
```

**认证请求头（登录后）：**

```http
X-LC-Session: {SessionToken}
```

### 2.2 响应格式

**成功响应：**

```json
{
  "code": 200,
  "message": "success",
  "data": { ... }
}
```

**错误响应：**

```json
{
  "code": 400,
  "error": "错误描述信息"
}
```

### 2.3 分页参数

| 参数名 | 类型 | 必填 | 默认值 | 说明 |
|--------|------|------|--------|------|
| limit | int | 否 | 20 | 每页数量（最大100） |
| skip | int | 否 | 0 | 跳过数量 |
| order | string | 否 | -createdAt | 排序字段（-表示降序） |

**分页响应：**

```json
{
  "results": [...],
  "count": 100
}
```

### 2.4 时间格式

- 时间戳：毫秒级Unix时间戳
- ISO 8601：`2026-03-16T10:30:00.000Z`

---

## 3. 用户认证接口

### 3.1 用户注册

**接口描述：** 注册新用户账号

**请求方式：** `POST`

**请求路径：** `/users`

**请求参数：**

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| username | string | 是 | 用户名（手机号） |
| password | string | 是 | 密码（6-20位） |
| phone | string | 否 | 手机号 |
| authData | object | 否 | 第三方登录数据 |

**请求示例：**

```json
{
  "username": "13800138000",
  "password": "password123",
  "phone": "13800138000"
}
```

**响应示例：**

```json
{
  "objectId": "user_abc123",
  "sessionToken": "session_token_xxx",
  "createdAt": "2026-03-16T10:30:00.000Z",
  "username": "13800138000"
}
```

---

### 3.2 用户登录

**接口描述：** 用户登录获取SessionToken

**请求方式：** `POST`

**请求路径：** `/login`

**请求参数：**

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| username | string | 是 | 用户名 |
| password | string | 是 | 密码 |

**请求示例：**

```json
{
  "username": "13800138000",
  "password": "password123"
}
```

**响应示例：**

```json
{
  "objectId": "user_abc123",
  "sessionToken": "session_token_xxx",
  "username": "13800138000",
  "createdAt": "2026-03-16T10:30:00.000Z",
  "updatedAt": "2026-03-16T10:30:00.000Z"
}
```

---

### 3.3 短信验证码登录

**接口描述：** 通过短信验证码登录

**请求方式：** `POST`

**请求路径：** `/loginByPhone`

**请求参数：**

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| mobilePhoneNumber | string | 是 | 手机号 |
| smsCode | string | 是 | 短信验证码 |

**请求示例：**

```json
{
  "mobilePhoneNumber": "13800138000",
  "smsCode": "123456"
}
```

**响应示例：**

```json
{
  "objectId": "user_abc123",
  "sessionToken": "session_token_xxx",
  "mobilePhoneNumber": "13800138000"
}
```

---

### 3.4 发送短信验证码

**接口描述：** 发送短信验证码

**请求方式：** `POST`

**请求路径：** `/requestSmsCode`

**请求参数：**

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| mobilePhoneNumber | string | 是 | 手机号 |

**请求示例：**

```json
{
  "mobilePhoneNumber": "13800138000"
}
```

**响应示例：**

```json
{
  "code": 200,
  "message": "success"
}
```

---

### 3.5 用户注销

**接口描述：** 用户退出登录

**请求方式：** `POST`

**请求路径：** `/logout`

**请求头：**

```http
X-LC-Session: {SessionToken}
```

**响应示例：**

```json
{
  "code": 200,
  "message": "success"
}
```

---

## 4. 倾诉交互接口

### 4.1 提交倾诉内容

**接口描述：** 提交用户倾诉内容，返回宠物响应

**请求方式：** `POST`

**请求路径：** `/functions/submitConfide`

**请求参数：**

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| userId | string | 是 | 用户ID |
| content | string | 是 | 倾诉内容 |
| inputType | string | 否 | 输入类型（text/voice），默认text |
| localId | string | 否 | 本地记录ID |

**请求示例：**

```json
{
  "userId": "user_abc123",
  "content": "今天投了3份简历",
  "inputType": "text",
  "localId": "local_001"
}
```

**响应示例：**

```json
{
  "code": 200,
  "data": {
    "interactionId": "inter_xxx",
    "actionType": "resume_submit",
    "emotionType": "positive",
    "petAction": "wing_flap_nod",
    "petBubble": "嗯！",
    "keywordsMatched": ["投了", "简历"],
    "confidenceScore": 0.95,
    "recordedEvent": {
      "eventId": "event_xxx",
      "eventType": "submit",
      "eventContent": "投递简历"
    }
  }
}
```

---

### 4.2 获取对话历史

**接口描述：** 获取用户与宠物的对话历史

**请求方式：** `GET`

**请求路径：** `/classes/interactions`

**请求参数：**

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| where | string | 是 | 查询条件（JSON字符串） |
| limit | int | 否 | 每页数量 |
| skip | int | 否 | 跳过数量 |
| order | string | 否 | 排序 |

**请求示例：**

```
GET /classes/interactions?where={"user_id":"user_abc123"}&limit=20&order=-create_time
```

**响应示例：**

```json
{
  "results": [
    {
      "objectId": "inter_001",
      "user_id": "user_abc123",
      "user_content": "今天投了3份简历",
      "action_type": "resume_submit",
      "emotion_type": "positive",
      "pet_action": "wing_flap_nod",
      "pet_bubble": "嗯！",
      "create_time": {
        "__type": "Date",
        "iso": "2026-03-16T10:30:00.000Z"
      }
    }
  ],
  "count": 50
}
```

---

### 4.3 获取宠物记忆

**接口描述：** 获取宠物的短期记忆（Pro版功能）

**请求方式：** `GET`

**请求路径：** `/functions/getPetMemory`

**请求参数：**

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| userId | string | 是 | 用户ID |

**请求示例：**

```json
{
  "userId": "user_abc123"
}
```

**响应示例：**

```json
{
  "code": 200,
  "data": {
    "memories": [
      {
        "type": "interview",
        "key": "面试时间",
        "value": "2026-03-20 14:00",
        "company": "XX科技"
      },
      {
        "type": "preference",
        "key": "求职方向",
        "value": "前端开发"
      }
    ],
    "memoryCount": 15,
    "maxCapacity": 20
  }
}
```

---

### 4.4 更新宠物记忆

**接口描述：** 更新宠物记忆内容

**请求方式：** `POST`

**请求路径：** `/functions/updatePetMemory`

**请求参数：**

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| userId | string | 是 | 用户ID |
| memoryType | string | 是 | 记忆类型 |
| memoryKey | string | 是 | 记忆键 |
| memoryValue | string | 是 | 记忆值 |

**请求示例：**

```json
{
  "userId": "user_abc123",
  "memoryType": "interview",
  "memoryKey": "面试时间",
  "memoryValue": "2026-03-20 14:00"
}
```

**响应示例：**

```json
{
  "code": 200,
  "data": {
    "success": true,
    "memoryCount": 16
  }
}
```

---

## 5. 求职事件接口

### 5.1 创建求职事件

**接口描述：** 创建新的求职事件

**请求方式：** `POST`

**请求路径：** `/classes/job_applications`

**请求参数：**

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| user_id | string | 是 | 用户ID |
| event_type | string | 是 | 事件类型 |
| event_content | string | 否 | 事件内容 |
| company_name | string | 否 | 公司名称 |
| position_name | string | 否 | 职位名称 |
| event_time | object | 是 | 事件时间（Date类型） |

**请求示例：**

```json
{
  "user_id": "user_abc123",
  "event_type": "interview",
  "event_content": "收到XX科技面试邀请",
  "company_name": "XX科技",
  "position_name": "前端开发工程师",
  "event_time": {
    "__type": "Date",
    "iso": "2026-03-20T06:00:00.000Z"
  }
}
```

**响应示例：**

```json
{
  "objectId": "event_xxx",
  "createdAt": "2026-03-16T10:30:00.000Z"
}
```

---

### 5.2 获取求职事件列表

**接口描述：** 获取用户的求职事件列表

**请求方式：** `GET`

**请求路径：** `/classes/job_applications`

**请求参数：**

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| where | string | 是 | 查询条件 |
| limit | int | 否 | 每页数量 |
| skip | int | 否 | 跳过数量 |
| order | string | 否 | 排序 |

**请求示例：**

```
GET /classes/job_applications?where={"user_id":"user_abc123"}&limit=20&order=-event_time
```

**响应示例：**

```json
{
  "results": [
    {
      "objectId": "event_001",
      "user_id": "user_abc123",
      "event_type": "interview",
      "event_content": "收到XX科技面试邀请",
      "company_name": "XX科技",
      "position_name": "前端开发工程师",
      "event_time": {
        "__type": "Date",
        "iso": "2026-03-20T06:00:00.000Z"
      }
    }
  ],
  "count": 25
}
```

---

### 5.3 更新求职事件

**接口描述：** 更新求职事件信息

**请求方式：** `PUT`

**请求路径：** `/classes/job_applications/{objectId}`

**请求参数：**

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| event_type | string | 否 | 事件类型 |
| event_content | string | 否 | 事件内容 |
| company_name | string | 否 | 公司名称 |

**请求示例：**

```json
{
  "event_content": "XX科技二面通过",
  "company_name": "XX科技"
}
```

**响应示例：**

```json
{
  "objectId": "event_001",
  "updatedAt": "2026-03-16T10:30:00.000Z"
}
```

---

### 5.4 删除求职事件

**接口描述：** 删除求职事件

**请求方式：** `DELETE`

**请求路径：** `/classes/job_applications/{objectId}`

**响应示例：**

```json
{}
```

---

## 6. 求职看板接口

### 6.1 获取统计数据

**接口描述：** 获取求职行为统计数据

**请求方式：** `POST`

**请求路径：** `/functions/getJobStatistics`

**请求参数：**

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| userId | string | 是 | 用户ID |
| period | string | 否 | 统计周期（today/week/month），默认today |

**请求示例：**

```json
{
  "userId": "user_abc123",
  "period": "week"
}
```

**响应示例：**

```json
{
  "code": 200,
  "data": {
    "period": "week",
    "submitCount": 15,
    "interviewCount": 3,
    "rejectCount": 5,
    "offerCount": 0,
    "slackCount": 2,
    "totalDays": 7,
    "activeDays": 5
  }
}
```

---

### 6.2 获取趋势数据

**接口描述：** 获取求职行为趋势数据

**请求方式：** `POST`

**请求路径：** `/functions/getJobTrend`

**请求参数：**

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| userId | string | 是 | 用户ID |
| startDate | string | 是 | 开始日期（YYYY-MM-DD） |
| endDate | string | 是 | 结束日期（YYYY-MM-DD） |

**请求示例：**

```json
{
  "userId": "user_abc123",
  "startDate": "2026-03-01",
  "endDate": "2026-03-15"
}
```

**响应示例：**

```json
{
  "code": 200,
  "data": {
    "trend": [
      {
        "date": "2026-03-01",
        "submit": 3,
        "interview": 0,
        "reject": 1,
        "offer": 0
      },
      {
        "date": "2026-03-02",
        "submit": 2,
        "interview": 1,
        "reject": 0,
        "offer": 0
      }
    ]
  }
}
```

---

### 6.3 获取成就列表

**接口描述：** 获取用户成就徽章列表

**请求方式：** `POST`

**请求路径：** `/functions/getAchievements`

**请求参数：**

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| userId | string | 是 | 用户ID |

**请求示例：**

```json
{
  "userId": "user_abc123"
}
```

**响应示例：**

```json
{
  "code": 200,
  "data": {
    "achievements": [
      {
        "id": "persist_submit",
        "name": "坚持投递",
        "description": "连续7天投递",
        "icon": "🎯",
        "unlocked": true,
        "unlockedAt": "2026-03-10T10:00:00.000Z",
        "progress": 100
      },
      {
        "id": "interview_master",
        "name": "面试达人",
        "description": "累计5次面试",
        "icon": "💼",
        "unlocked": false,
        "progress": 60
      }
    ]
  }
}
```

---

## 7. 彼岸公园接口

### 7.1 解锁彼岸公园

**接口描述：** 用户获得Offer后解锁彼岸公园

**请求方式：** `POST`

**请求路径：** `/functions/unlockVictoryPark`

**请求参数：**

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| userId | string | 是 | 用户ID |
| offerData | object | 否 | Offer相关信息 |

**请求示例：**

```json
{
  "userId": "user_abc123",
  "offerData": {
    "company": "XX科技",
    "position": "前端开发",
    "industry": "internet"
  }
}
```

**响应示例：**

```json
{
  "code": 200,
  "data": {
    "unlocked": true,
    "parkProfileId": "park_xxx",
    "industryZone": "码农森林",
    "petEvolutionStage": 2
  }
}
```

---

### 7.2 获取公园档案列表

**接口描述：** 获取公园内展示的用户档案列表

**请求方式：** `POST`

**请求路径：** `/functions/getParkProfiles`

**请求参数：**

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| industryZone | string | 否 | 行业分区（不传则获取全部） |
| limit | int | 否 | 每页数量，默认20 |
| skip | int | 否 | 跳过数量 |

**请求示例：**

```json
{
  "industryZone": "internet",
  "limit": 20
}
```

**响应示例：**

```json
{
  "code": 200,
  "data": {
    "profiles": [
      {
        "id": "park_001",
        "petAvatarUrl": "https://cdn.example.com/pet/001.png",
        "petStage": 2,
        "industryZone": "码农森林",
        "onboardingDate": "2026-02-15",
        "jobCompany": "某大厂",
        "jobPosition": "高级前端",
        "battleReport": "历时45天，投递120份简历...",
        "lastVisitTime": "2026-03-15T10:00:00.000Z"
      }
    ],
    "total": 156
  }
}
```

---

### 7.3 发起公园交互

**接口描述：** 在公园内发起宠物交互

**请求方式：** `POST`

**请求路径：** `/functions/createParkInteraction`

**请求参数：**

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| fromUserId | string | 是 | 发起者用户ID |
| toUserId | string | 是 | 接收者用户ID |
| interactionType | string | 是 | 交互类型（touch/flower/report） |

**请求示例：**

```json
{
  "fromUserId": "user_abc123",
  "toUserId": "user_xyz789",
  "interactionType": "flower"
}
```

**响应示例：**

```json
{
  "code": 200,
  "data": {
    "interactionId": "inter_xxx",
    "success": true
  }
}
```

---

### 7.4 获取公园交互消息

**接口描述：** 获取用户收到的公园交互消息

**请求方式：** `POST`

**请求路径：** `/functions/getParkInteractions`

**请求参数：**

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| userId | string | 是 | 用户ID |
| isRead | boolean | 否 | 是否已读（不传获取全部） |
| limit | int | 否 | 每页数量 |

**请求示例：**

```json
{
  "userId": "user_abc123",
  "isRead": false,
  "limit": 20
}
```

**响应示例：**

```json
{
  "code": 200,
  "data": {
    "interactions": [
      {
        "id": "inter_001",
        "fromUserId": "user_xyz789",
        "fromUserName": "咕咕达人",
        "interactionType": "flower",
        "createTime": "2026-03-15T10:00:00.000Z",
        "isRead": false
      }
    ],
    "unreadCount": 5
  }
}
```

---

### 7.5 创建许愿信封

**接口描述：** 上岸用户创建鼓励信封

**请求方式：** `POST`

**请求路径：** `/functions/createWishLetter`

**请求参数：**

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| fromUserId | string | 是 | 发送者用户ID |
| letterContent | string | 是 | 鼓励内容（需审核） |
| industryTag | string | 否 | 目标行业标签 |

**请求示例：**

```json
{
  "fromUserId": "user_abc123",
  "letterContent": "加油！坚持就是胜利！",
  "industryTag": "internet"
}
```

**响应示例：**

```json
{
  "code": 200,
  "data": {
    "letterId": "letter_xxx",
    "status": "pending_review",
    "message": "信封已提交审核，审核通过后将随机送给求职中的咕咕"
  }
}
```

---

### 7.6 接收许愿信封

**接口描述：** 焦虑状态用户接收鼓励信封

**请求方式：** `POST`

**请求路径：** `/functions/receiveWishLetter`

**请求参数：**

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| userId | string | 是 | 接收者用户ID |

**请求示例：**

```json
{
  "userId": "user_abc123"
}
```

**响应示例：**

```json
{
  "code": 200,
  "data": {
    "hasLetter": true,
    "letter": {
      "id": "letter_xxx",
      "content": "加油！坚持就是胜利！",
      "fromIndustry": "互联网",
      "receiveTime": "2026-03-16T10:00:00.000Z"
    }
  }
}
```

---

## 8. 岗位聚合接口

### 8.1 获取岗位列表

**接口描述：** 获取推荐岗位列表

**请求方式：** `GET`

**请求路径：** `/classes/jobs`

**请求参数：**

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| where | string | 否 | 查询条件 |
| limit | int | 否 | 每页数量（免费版最大5，Pro版最大20） |
| skip | int | 否 | 跳过数量 |
| order | string | 否 | 排序 |

**请求示例：**

```
GET /classes/jobs?where={"industry_tag":"internet","city":"北京"}&limit=5&order=-publish_time
```

**响应示例：**

```json
{
  "results": [
    {
      "objectId": "job_001",
      "job_title": "高级前端开发工程师",
      "company_name": "XX科技",
      "salary_range": "25k-40k",
      "requirements": "3年以上前端开发经验，熟悉Vue/React",
      "source_url": "https://example.com/job/001",
      "source_platform": "boss",
      "city": "北京",
      "publish_time": {
        "__type": "Date",
        "iso": "2026-03-15T00:00:00.000Z"
      }
    }
  ],
  "count": 156
}
```

---

### 8.2 获取岗位详情

**接口描述：** 获取单个岗位详细信息

**请求方式：** `GET`

**请求路径：** `/classes/jobs/{objectId}`

**响应示例：**

```json
{
  "objectId": "job_001",
  "job_title": "高级前端开发工程师",
  "company_name": "XX科技",
  "salary_range": "25k-40k",
  "salary_min": 25000,
  "salary_max": 40000,
  "requirements": "3年以上前端开发经验，熟悉Vue/React...",
  "experience_require": "3-5年",
  "education_require": "本科及以上",
  "source_url": "https://example.com/job/001",
  "source_platform": "boss",
  "city": "北京",
  "industry_tag": "internet",
  "publish_time": {
    "__type": "Date",
    "iso": "2026-03-15T00:00:00.000Z"
  }
}
```

---

## 9. 宠物皮肤接口

### 9.1 获取皮肤列表

**接口描述：** 获取所有可用皮肤列表

**请求方式：** `GET`

**请求路径：** `/classes/pet_skins`

**请求参数：**

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| where | string | 否 | 查询条件 |
| order | string | 否 | 排序 |

**请求示例：**

```
GET /classes/pet_skins?where={"is_active":true}&order=sort_order
```

**响应示例：**

```json
{
  "results": [
    {
      "objectId": "skin_001",
      "skin_id": "basic_gugu",
      "skin_name": "基础咕咕鸟",
      "skin_type": "basic",
      "skin_assets_url": "https://cdn.example.com/skin/basic.zip",
      "skin_preview_url": "https://cdn.example.com/skin/basic_preview.png",
      "is_pro_only": false,
      "price": null
    },
    {
      "objectId": "skin_002",
      "skin_id": "workplace_gugu",
      "skin_name": "职场精英咕咕",
      "skin_type": "workplace",
      "skin_assets_url": "https://cdn.example.com/skin/workplace.zip",
      "skin_preview_url": "https://cdn.example.com/skin/workplace_preview.png",
      "is_pro_only": true,
      "price": null
    }
  ]
}
```

---

### 9.2 获取用户皮肤

**接口描述：** 获取用户拥有的皮肤列表

**请求方式：** `POST`

**请求路径：** `/functions/getUserSkins`

**请求参数：**

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| userId | string | 是 | 用户ID |

**请求示例：**

```json
{
  "userId": "user_abc123"
}
```

**响应示例：**

```json
{
  "code": 200,
  "data": {
    "ownedSkins": [
      {
        "skinId": "basic_gugu",
        "skinName": "基础咕咕鸟",
        "isEquipped": true,
        "unlockTime": "2026-03-01T00:00:00.000Z"
      },
      {
        "skinId": "workplace_gugu",
        "skinName": "职场精英咕咕",
        "isEquipped": false,
        "unlockTime": "2026-03-15T00:00:00.000Z"
      }
    ],
    "currentSkinId": "basic_gugu"
  }
}
```

---

### 9.3 装备皮肤

**接口描述：** 装备指定皮肤

**请求方式：** `POST`

**请求路径：** `/functions/equipSkin`

**请求参数：**

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| userId | string | 是 | 用户ID |
| skinId | string | 是 | 皮肤ID |

**请求示例：**

```json
{
  "userId": "user_abc123",
  "skinId": "workplace_gugu"
}
```

**响应示例：**

```json
{
  "code": 200,
  "data": {
    "success": true,
    "currentSkinId": "workplace_gugu"
  }
}
```

---

### 9.4 购买皮肤

**接口描述：** 单独购买皮肤

**请求方式：** `POST`

**请求路径：** `/functions/purchaseSkin`

**请求参数：**

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| userId | string | 是 | 用户ID |
| skinId | string | 是 | 皮肤ID |
| paymentMethod | string | 是 | 支付方式（apple_iap/wechat/alipay） |

**请求示例：**

```json
{
  "userId": "user_abc123",
  "skinId": "seasonal_spring",
  "paymentMethod": "wechat"
}
```

**响应示例：**

```json
{
  "code": 200,
  "data": {
    "orderId": "order_xxx",
    "paymentParams": {
      "appId": "wx1234567890",
      "timeStamp": "1710585600",
      "nonceStr": "abc123",
      "package": "prepay_id=xxx",
      "signType": "RSA",
      "paySign": "xxx"
    }
  }
}
```

---

## 10. 会员服务接口

### 10.1 获取会员权益

**接口描述：** 获取用户会员状态和权益信息

**请求方式：** `POST`

**请求路径：** `/functions/getVipStatus`

**请求参数：**

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| userId | string | 是 | 用户ID |

**请求示例：**

```json
{
  "userId": "user_abc123"
}
```

**响应示例：**

```json
{
  "code": 200,
  "data": {
    "isVip": true,
    "vipExpireTime": "2027-03-16T00:00:00.000Z",
    "vipType": "yearly",
    "daysRemaining": 365,
    "benefits": {
      "dailyJobLimit": 20,
      "petMemoryEnabled": true,
      "parkVisitorMode": true,
      "resumeCheckEnabled": true,
      "interviewReminderEnabled": true,
      "memoryBookEnabled": true
    }
  }
}
```

---

### 10.2 订阅会员

**接口描述：** 订阅Pro版会员

**请求方式：** `POST`

**请求路径：** `/functions/subscribeVip`

**请求参数：**

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| userId | string | 是 | 用户ID |
| planType | string | 是 | 套餐类型（monthly/yearly/lifetime） |
| paymentMethod | string | 是 | 支付方式 |

**请求示例：**

```json
{
  "userId": "user_abc123",
  "planType": "yearly",
  "paymentMethod": "apple_iap"
}
```

**响应示例：**

```json
{
  "code": 200,
  "data": {
    "orderId": "order_xxx",
    "productId": "jobpet_pro_yearly",
    "amount": 6800,
    "currency": "CNY",
    "iapParams": {
      "productIdentifier": "jobpet_pro_yearly",
      "quantity": 1
    }
  }
}
```

---

### 10.3 验证支付

**接口描述：** 验证支付结果并激活会员

**请求方式：** `POST`

**请求路径：** `/functions/verifyPayment`

**请求参数：**

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| userId | string | 是 | 用户ID |
| orderId | string | 是 | 订单ID |
| paymentMethod | string | 是 | 支付方式 |
| receiptData | string | 否 | iOS收据数据（IAP必传） |
| transactionId | string | 否 | 第三方交易ID |

**请求示例：**

```json
{
  "userId": "user_abc123",
  "orderId": "order_xxx",
  "paymentMethod": "apple_iap",
  "receiptData": "base64_encoded_receipt"
}
```

**响应示例：**

```json
{
  "code": 200,
  "data": {
    "verified": true,
    "vipExpireTime": "2027-03-16T00:00:00.000Z",
    "message": "会员激活成功"
  }
}
```

---

## 11. 数据同步接口

### 11.1 上传本地数据

**接口描述：** 上传本地数据到云端

**请求方式：** `POST`

**请求路径：** `/functions/syncUpload`

**请求参数：**

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| userId | string | 是 | 用户ID |
| dataType | string | 是 | 数据类型（interactions/events/memory） |
| data | array | 是 | 数据数组 |
| lastSyncTime | string | 否 | 最后同步时间 |

**请求示例：**

```json
{
  "userId": "user_abc123",
  "dataType": "interactions",
  "data": [
    {
      "localId": "local_001",
      "userContent": "今天投了3份简历",
      "actionType": "resume_submit",
      "emotionType": "positive",
      "petAction": "wing_flap_nod",
      "petBubble": "嗯！",
      "createTime": 1710585600000
    }
  ],
  "lastSyncTime": "2026-03-15T00:00:00.000Z"
}
```

**响应示例：**

```json
{
  "code": 200,
  "data": {
    "uploaded": 1,
    "failed": 0,
    "mapping": [
      {
        "localId": "local_001",
        "cloudId": "inter_xxx"
      }
    ]
  }
}
```

---

### 11.2 下载云端数据

**接口描述：** 下载云端数据到本地

**请求方式：** `POST`

**请求路径：** `/functions/syncDownload`

**请求参数：**

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| userId | string | 是 | 用户ID |
| dataType | string | 是 | 数据类型 |
| lastSyncTime | string | 是 | 最后同步时间 |

**请求示例：**

```json
{
  "userId": "user_abc123",
  "dataType": "events",
  "lastSyncTime": "2026-03-15T00:00:00.000Z"
}
```

**响应示例：**

```json
{
  "code": 200,
  "data": {
    "dataType": "events",
    "data": [
      {
        "objectId": "event_001",
        "event_type": "interview",
        "event_content": "收到XX科技面试邀请",
        "company_name": "XX科技",
        "event_time": "2026-03-16T06:00:00.000Z",
        "updatedAt": "2026-03-16T10:00:00.000Z"
      }
    ],
    "hasMore": false,
    "serverTime": "2026-03-16T10:30:00.000Z"
  }
}
```

---

## 12. 推送服务接口

### 12.1 注册推送设备

**接口描述：** 注册设备推送Token

**请求方式：** `POST`

**请求路径：** `/installations`

**请求参数：**

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| deviceType | string | 是 | 设备类型（ios/android） |
| deviceToken | string | 是 | 推送Token |
| userId | string | 否 | 用户ID |
| channels | array | 否 | 订阅频道 |

**请求示例：**

```json
{
  "deviceType": "ios",
  "deviceToken": "abc123def456...",
  "userId": "user_abc123",
  "channels": ["interview_reminder", "job_push"]
}
```

**响应示例：**

```json
{
  "objectId": "install_xxx",
  "createdAt": "2026-03-16T10:30:00.000Z"
}
```

---

### 12.2 更新推送配置

**接口描述：** 更新用户推送配置

**请求方式：** `PUT`

**请求路径：** `/installations/{objectId}`

**请求参数：**

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| channels | array | 否 | 订阅频道 |
| pushEnabled | boolean | 否 | 是否启用推送 |

**请求示例：**

```json
{
  "channels": ["interview_reminder", "job_push", "wish_letter"],
  "pushEnabled": true
}
```

**响应示例：**

```json
{
  "objectId": "install_xxx",
  "updatedAt": "2026-03-16T10:30:00.000Z"
}
```

---

## 13. 错误码定义

### 13.1 HTTP状态码

| 状态码 | 说明 |
|--------|------|
| 200 | 成功 |
| 201 | 创建成功 |
| 400 | 请求参数错误 |
| 401 | 未授权（未登录或Token过期） |
| 403 | 禁止访问（权限不足） |
| 404 | 资源不存在 |
| 429 | 请求过于频繁 |
| 500 | 服务器内部错误 |
| 503 | 服务不可用 |

### 13.2 业务错误码

| 错误码 | 错误信息 | 说明 |
|--------|----------|------|
| 1001 | 用户不存在 | 用户ID无效 |
| 1002 | 密码错误 | 登录密码错误 |
| 1003 | 用户已存在 | 注册时用户名重复 |
| 1004 | 验证码错误 | 短信验证码错误 |
| 1005 | 验证码过期 | 短信验证码已过期 |
| 1006 | Token过期 | SessionToken已过期 |
| 2001 | 非Pro用户 | 需要Pro权限 |
| 2002 | 功能未解锁 | 如公园未解锁 |
| 2003 | 次数已达上限 | 如每日岗位推送上限 |
| 3001 | 内容审核中 | 信封审核中 |
| 3002 | 内容审核失败 | 信封内容不合规 |
| 4001 | 支付失败 | 支付处理失败 |
| 4002 | 订单不存在 | 订单ID无效 |
| 4003 | 订单已支付 | 订单重复支付 |
| 5001 | 同步冲突 | 数据同步冲突 |
| 5002 | 网络错误 | 网络连接失败 |

### 13.3 错误响应示例

```json
{
  "code": 2001,
  "error": "该功能需要Pro版会员",
  "detail": {
    "feature": "pet_memory",
    "requiredVip": true,
    "currentVip": false
  }
}
```

---

## 附录

### A. 云函数列表

| 函数名 | 说明 | 权限 |
|--------|------|------|
| submitConfide | 提交倾诉 | 登录用户 |
| getPetMemory | 获取宠物记忆 | Pro用户 |
| updatePetMemory | 更新宠物记忆 | Pro用户 |
| getJobStatistics | 获取统计数据 | 登录用户 |
| getJobTrend | 获取趋势数据 | 登录用户 |
| getAchievements | 获取成就列表 | 登录用户 |
| unlockVictoryPark | 解锁彼岸公园 | 登录用户 |
| getParkProfiles | 获取公园档案 | 登录用户 |
| createParkInteraction | 发起公园交互 | 上岸用户 |
| getParkInteractions | 获取公园消息 | 登录用户 |
| createWishLetter | 创建许愿信封 | 上岸用户 |
| receiveWishLetter | 接收许愿信封 | 登录用户 |
| getUserSkins | 获取用户皮肤 | 登录用户 |
| equipSkin | 装备皮肤 | 登录用户 |
| purchaseSkin | 购买皮肤 | 登录用户 |
| getVipStatus | 获取会员状态 | 登录用户 |
| subscribeVip | 订阅会员 | 登录用户 |
| verifyPayment | 验证支付 | 登录用户 |
| syncUpload | 上传本地数据 | 登录用户 |
| syncDownload | 下载云端数据 | 登录用户 |

### B. 数据类型说明

| 类型 | 说明 | 示例 |
|------|------|------|
| String | 字符串 | "hello" |
| Number | 数字 | 123 |
| Boolean | 布尔值 | true |
| Date | 日期时间 | {"__type":"Date","iso":"2026-03-16T10:30:00.000Z"} |
| Pointer | 指针（关联） | {"__type":"Pointer","className":"User","objectId":"xxx"} |
| File | 文件 | {"__type":"File","id":"xxx","name":"a.png","url":"http://..."} |
| GeoPoint | 地理位置 | {"__type":"GeoPoint","latitude":39.9,"longitude":116.4} |

---

**文档结束**

*本文档为《职宠小窝》APP API接口文档v1.0版，如有变更请及时更新版本号。*
