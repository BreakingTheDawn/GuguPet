# 《职宠小窝》微信小程序 API接口文档

**文档编号：** API-JOBPET-MP-001  
**版本号：** v1.0  
**编写日期：** 2026-03-17  
**文档状态：** 正式发布  
**基础URL：** `https://api.leancloud.cn/1.1`

---

## 修订历史

| 版本 | 日期 | 修订人 | 修订内容 |
|------|------|--------|----------|
| v1.0 | 2026-03-17 | 架构师 | 初始版本 |

---

## 目录

1. [接口概述](#1-接口概述)
2. [通用规范](#2-通用规范)
3. [用户认证接口](#3-用户认证接口)
4. [专栏购买接口](#4-专栏购买接口)
5. [内容更新接口](#5-内容更新接口)
6. [错误码定义](#6-错误码定义)

---

## 1. 接口概述

### 1.1 接口架构

小程序采用**简化API架构**，主要支持：
- 用户认证（微信登录）
- 专栏购买管理
- 内容版本更新检测

专栏内容本身打包在小程序内，减少网络依赖，提升用户体验。

### 1.2 接口列表总览

| 模块 | 接口数量 | 说明 |
|------|----------|------|
| 用户认证 | 2 | 微信登录、获取用户信息 |
| 专栏购买 | 4 | 创建订单、支付、验证、查询 |
| 内容更新 | 1 | 检测专栏版本更新 |

### 1.3 与APP API的差异

| 功能 | 小程序API | APP API |
|------|-----------|---------|
| 用户认证 | 微信登录 | 手机号/微信/Apple登录 |
| 倾诉交互 | ❌ 本地处理 | ✅ 云端意图识别 |
| 求职事件 | ❌ 本地存储 | ✅ 云端同步 |
| 岗位聚合 | ❌ 无此功能 | ✅ 云端数据 |
| 专栏购买 | ✅ 简化版 | ❌ 无此功能 |
| 彼岸公园 | ❌ 无此功能 | ✅ 社交功能 |

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

### 2.3 时间格式

- 时间戳：毫秒级Unix时间戳
- ISO 8601：`2026-03-17T10:30:00.000Z`

---

## 3. 用户认证接口

### 3.1 微信登录

**接口描述**：通过微信授权登录，获取用户信息和SessionToken

**请求方式**：`POST`

**请求路径**：`/functions/wechatLogin`

**请求参数：**

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| code | string | 是 | wx.login获取的code |
| userInfo | object | 否 | 用户信息（头像、昵称） |

**请求示例：**

```json
{
  "code": "071Abc2D3efG4H1I0jk5lM6nO7pQ8rS9",
  "userInfo": {
    "nickName": "咕咕用户",
    "avatarUrl": "https://wx.qlogo.cn/..."
  }
}
```

**响应示例：**

```json
{
  "code": 200,
  "data": {
    "objectId": "user_abc123",
    "sessionToken": "session_token_xxx",
    "openid": "oXXXX_xxxxxxxx",
    "nickName": "咕咕用户",
    "avatarUrl": "https://wx.qlogo.cn/...",
    "createdAt": "2026-03-17T10:30:00.000Z"
  }
}
```

---

### 3.2 获取用户信息

**接口描述**：获取当前登录用户的详细信息

**请求方式**：`GET`

**请求路径：** `/users/{objectId}`

**请求头：**

```http
X-LC-Session: {SessionToken}
```

**响应示例：**

```json
{
  "objectId": "user_abc123",
  "nickName": "咕咕用户",
  "avatarUrl": "https://wx.qlogo.cn/...",
  "purchasedColumns": ["column_001", "column_002"],
  "createdAt": "2026-03-17T10:30:00.000Z",
  "updatedAt": "2026-03-17T12:00:00.000Z"
}
```

---

## 4. 专栏购买接口

### 4.1 创建订单

**接口描述**：创建专栏购买订单，获取微信支付参数

**请求方式**：`POST`

**请求路径**：`/functions/createColumnOrder`

**请求参数：**

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| userId | string | 是 | 用户ID |
| columnId | string | 是 | 专栏ID |
| columnTitle | string | 是 | 专栏标题 |
| amount | number | 是 | 金额（分） |

**请求示例：**

```json
{
  "userId": "user_abc123",
  "columnId": "column_001",
  "columnTitle": "毕业补贴领取指南",
  "amount": 990
}
```

**响应示例：**

```json
{
  "code": 200,
  "data": {
    "orderId": "order_xxx",
    "timeStamp": "1710662400",
    "nonceStr": "abc123def456",
    "package": "prepay_id=wx20260317103000xxxx",
    "signType": "RSA",
    "paySign": "xxxxxxxxxxxx"
  }
}
```

---

### 4.2 支付回调验证

**接口描述**：微信支付成功后的回调验证

**请求方式**：`POST`

**请求路径**：`/functions/verifyWechatPay`

**请求参数：**

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| orderId | string | 是 | 订单ID |
| userId | string | 是 | 用户ID |
| columnId | string | 是 | 专栏ID |

**请求示例：**

```json
{
  "orderId": "order_xxx",
  "userId": "user_abc123",
  "columnId": "column_001"
}
```

**响应示例：**

```json
{
  "code": 200,
  "data": {
    "verified": true,
    "columnId": "column_001",
    "unlockedAt": "2026-03-17T10:35:00.000Z"
  }
}
```

---

### 4.3 查询购买记录

**接口描述**：查询用户的专栏购买记录

**请求方式**：`POST`

**请求路径**：`/functions/getPurchaseRecords`

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
    "records": [
      {
        "orderId": "order_001",
        "columnId": "column_001",
        "columnTitle": "毕业补贴领取指南",
        "amount": 990,
        "status": "paid",
        "paidAt": "2026-03-17T10:35:00.000Z"
      },
      {
        "orderId": "order_002",
        "columnId": "column_002",
        "columnTitle": "五险一金避坑手册",
        "amount": 1990,
        "status": "paid",
        "paidAt": "2026-03-17T11:00:00.000Z"
      }
    ],
    "total": 2
  }
}
```

---

### 4.4 检查专栏购买状态

**接口描述**：检查指定专栏是否已购买

**请求方式**：`POST`

**请求路径**：`/functions/checkColumnPurchase`

**请求参数：**

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| userId | string | 是 | 用户ID |
| columnId | string | 是 | 专栏ID |

**请求示例：**

```json
{
  "userId": "user_abc123",
  "columnId": "column_001"
}
```

**响应示例：**

```json
{
  "code": 200,
  "data": {
    "purchased": true,
    "unlockedAt": "2026-03-17T10:35:00.000Z"
  }
}
```

---

## 5. 内容更新接口

### 5.1 检测专栏版本

**接口描述**：检测专栏内容是否有更新版本

**请求方式**：`POST`

**请求路径**：`/functions/checkColumnVersion`

**请求参数：**

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| currentVersions | object | 是 | 当前本地版本映射 |

**请求示例：**

```json
{
  "currentVersions": {
    "column_001": "1.0.0",
    "column_002": "1.0.0",
    "column_003": "1.0.0"
  }
}
```

**响应示例：**

```json
{
  "code": 200,
  "data": {
    "hasUpdate": true,
    "updates": [
      {
        "columnId": "column_001",
        "currentVersion": "1.0.0",
        "latestVersion": "1.1.0",
        "updateLog": "更新了2026年最新补贴政策",
        "forceUpdate": false
      }
    ]
  }
}
```

---

## 6. 错误码定义

### 6.1 HTTP状态码

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

### 6.2 业务错误码

| 错误码 | 错误信息 | 说明 |
|--------|----------|------|
| 1001 | 用户不存在 | 用户ID无效 |
| 1002 | 微信登录失败 | code无效或已过期 |
| 1003 | Session过期 | 需要重新登录 |
| 2001 | 专栏不存在 | 专栏ID无效 |
| 2002 | 专栏已购买 | 无需重复购买 |
| 2003 | 订单不存在 | 订单ID无效 |
| 3001 | 支付失败 | 微信支付失败 |
| 3002 | 支付取消 | 用户取消支付 |
| 3003 | 支付超时 | 支付超时 |
| 4001 | 版本检查失败 | 版本格式错误 |

### 6.3 错误响应示例

```json
{
  "code": 2002,
  "error": "该专栏已购买",
  "detail": {
    "columnId": "column_001",
    "purchasedAt": "2026-03-17T10:35:00.000Z"
  }
}
```

---

## 附录

### A. 本地数据存储说明

小程序大部分数据存储在本地，无需云端API：

| 数据类型 | 存储位置 | 说明 |
|----------|----------|------|
| 用户基本信息 | 微信Storage | 通过Zustand持久化 |
| 对话记录 | 微信Storage | 最多保存100条 |
| 倒计时数据 | 微信Storage | 用户自定义 |
| 专栏内容 | 小程序包内 | 静态打包 |
| 购买状态 | 云端+本地缓存 | 需要同步 |

### B. 离线可用性

| 功能 | 离线可用 | 说明 |
|------|----------|------|
| 宠物倾诉室 | ✅ | 完全本地化 |
| 求职看板 | ✅ | 完全本地化 |
| 专栏阅读（已购买） | ✅ | 内容已打包 |
| 专栏购买 | ❌ | 需要网络 |
| 登录 | ❌ | 需要网络 |

### C. 云函数列表

| 函数名 | 说明 | 权限 |
|--------|------|------|
| wechatLogin | 微信登录 | 公开 |
| createColumnOrder | 创建订单 | 登录用户 |
| verifyWechatPay | 验证支付 | 登录用户 |
| getPurchaseRecords | 查询购买记录 | 登录用户 |
| checkColumnPurchase | 检查购买状态 | 登录用户 |
| checkColumnVersion | 检测版本更新 | 公开 |

---

**文档结束**

*本文档为《职宠小窝》微信小程序API接口文档v1.0版，如有变更请及时更新版本号。*
