# 职宠小窝 (JobPet)

一款帮助求职者管理求职进度的宠物养成应用。

## 🤖 AI对话功能配置

### 快速开始

本项目使用智谱AI的GLM-4模型提供智能对话功能。使用前需要配置您的API密钥。

### 获取API密钥

1. **访问智谱AI开放平台**
   - 网址：https://open.bigmodel.cn/
   - 点击注册/登录

2. **创建应用**
   - 进入控制台
   - 创建新应用
   - 选择GLM-4-Flash模型（免费）

3. **获取API密钥**
   - 在应用详情页找到API密钥
   - 复制密钥

### 配置API密钥

**方式1：应用内配置（推荐）**
1. 运行应用后，进入 **设置 > AI对话设置**
2. 在API密钥输入框中粘贴您的密钥
3. 点击"保存配置"

**方式2：环境变量配置**
```bash
# 编译时注入
flutter run --dart-define=GLM_API_KEY=your_api_key_here
```

### 免费额度说明

智谱AI为新用户提供免费额度：
- ✅ GLM-4-Flash模型完全免费
- ✅ 每月赠送免费tokens
- ✅ 无需绑定银行卡

### 安全提示

⚠️ **重要安全事项**：
- 🔐 API密钥会加密存储在本地
- ❌ 不要将API密钥提交到Git仓库
- ❌ 不要在公开场合分享您的API密钥
- ✅ 定期更换API密钥以确保安全

## 功能特性

- 🐾 **宠物养成系统** - 通过完成求职任务来养成虚拟宠物
- 📊 **求职进度管理** - 追踪和管理求职进度
- 🎨 **主题定制** - 支持亮色和暗色主题
- 🔐 **安全保护** - 多层安全防护机制
- 🤖 **AI智能对话** - 与宠物进行智能对话互动

## 🔒 安全特性

职宠小窝应用实现了多层安全防护机制，保护用户数据和付费功能：

### 数据安全
- **VIP状态保护** - 使用HMAC签名验证VIP状态完整性，防止篡改
- **API密钥加密** - 敏感API密钥使用flutter_secure_storage加密存储
- **数据签名** - 关键数据添加数字签名，防止数据被恶意修改

### 设备安全
- **Root/越狱检测** - 检测设备是否Root或越狱，提示安全风险
- **设备指纹** - 生成设备唯一标识，防止数据跨设备滥用

### 运行时保护
- **完整性校验** - 应用启动时验证关键数据完整性
- **异常检测** - 监控异常行为模式，记录安全事件
- **安全日志** - 记录所有安全相关事件，生成安全报告

### 安全建议
1. 不要在Root/越狱设备上使用VIP等付费功能
2. 定期检查安全设置页面的安全评分
3. 发现异常及时联系客服

### 技术实现
- HMAC-SHA256签名验证
- flutter_secure_storage安全存储
- 设备指纹生成
- 安全事件监控和报告

## 📊 安全架构

```
┌─────────────────────────────────────────┐
│          应用层（业务逻辑）               │
├─────────────────────────────────────────┤
│       安全服务层（签名、加密、验证）       │
├─────────────────────────────────────────┤
│    数据保护层（VIP保护、API密钥保护）      │
├─────────────────────────────────────────┤
│  安全存储层（flutter_secure_storage）    │
└─────────────────────────────────────────┘
```

## 开始使用

本项目是一个Flutter应用的起点。

如果你是第一次接触Flutter项目，以下资源可以帮助你开始：

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

关于Flutter开发的帮助，可以查看
[在线文档](https://docs.flutter.dev/)，其中包含教程、示例、移动开发指南和完整的API参考。

## 安装依赖

```bash
flutter pub get
```

## 运行应用

```bash
flutter run
```

## 运行测试

```bash
flutter test
```

## 项目结构

```
lib/
├── core/                    # 核心功能
│   ├── services/           # 服务层
│   │   ├── security_service.dart          # 安全服务
│   │   ├── vip_protection_service.dart    # VIP保护服务
│   │   └── security_monitor_service.dart  # 安全监控服务
│   ├── theme/              # 主题配置
│   └── di/                 # 依赖注入
├── features/               # 功能模块
│   ├── auth/              # 认证功能
│   ├── pet/               # 宠物系统
│   ├── profile/           # 用户资料
│   └── settings/          # 设置页面
│       └── pages/
│           └── security_settings_page.dart # 安全设置页面
├── data/                   # 数据层
│   ├── models/            # 数据模型
│   ├── repositories/      # 数据仓库
│   └── datasources/       # 数据源
└── routes/                 # 路由配置
```

## 安全功能使用指南

### 1. 查看安全状态
进入 **设置 > 安全设置** 页面，可以查看：
- 设备安全状态（是否Root/越狱）
- 安全评分（0-100分）
- 最近安全事件

### 2. VIP状态保护
VIP状态受到自动保护：
- 数据库中的VIP状态会被签名验证
- 篡改的VIP状态会被自动检测并重置
- VIP过期时间合理性会被自动检查

### 3. API密钥安全
AI配置中的API密钥受到保护：
- 自动加密存储到安全存储区
- 不再以明文形式保存
- 应用启动时自动加载

## 开发指南

### 添加新的安全事件

```dart
import 'package:jobpet/core/services/security_monitor_service.dart';

// 记录安全事件
await SecurityMonitorService().logSecurityEvent(
  eventType: SecurityEventType.suspiciousActivity,
  severity: SecuritySeverity.warning,
  details: '检测到可疑活动',
  userId: 'user_123',
);
```

### 验证VIP状态

```dart
import 'package:jobpet/core/services/vip_protection_service.dart';

// 验证VIP状态
final isTrusted = await VipProtectionService().isVipStatusTrusted(
  userId,
  vipStatus,
  vipExpireTime,
);
```

## 许可证

本项目采用 MIT 许可证。

## 贡献

欢迎提交Issue和Pull Request！

## 联系方式

如有问题或建议，请通过Issue联系。
