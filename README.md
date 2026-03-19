# 职宠小窝 (GuguPet)

## 项目简介

职宠小窝是一款轻拟人的电子宠物求职陪伴APP，旨在为求职者提供情感支持和求职辅助。通过与虚拟宠物的互动，缓解求职压力，提供求职建议和激励。

## 项目结构

```
GuguPet/
├── app/                 # Flutter应用端代码
├── docs/                # 项目文档
├── miniprogram/         # 微信小程序代码
└── suchAs/              # 设计资源和参考代码
```

### 核心目录说明

- **app/**：基于Flutter开发的移动端应用，包含完整的宠物陪伴、求职辅助等功能
- **miniprogram/**：基于Taro + React开发的微信小程序，提供基础的宠物互动功能
- **docs/**：包含项目需求文档、设计文档、API文档等
- **suchAs/**：包含UI设计参考、组件库等资源

## 技术栈

### Flutter应用端

| 技术/框架 | 版本 | 用途 |
|----------|------|------|
| Flutter | ^3.10.4 | 跨平台移动应用开发框架 |
| Provider | ^6.1.1 | 状态管理 |
| Sqflite | ^2.3.2 | 本地数据库 |
| Dio | ^5.4.0 | 网络请求 |
| Lottie | ^3.1.0 | 动画效果 |
| SharedPreferences | ^2.2.2 | 本地存储 |
| FL Chart | ^0.66.0 | 数据可视化 |
| Flutter SVG | ^2.0.9 | SVG图标支持 |

### 微信小程序端

| 技术/框架 | 版本 | 用途 |
|----------|------|------|
| Taro | ^4.1.11 | 跨端开发框架 |
| React | ^18.3.1 | UI框架 |
| Zustand | ^5.0.3 | 状态管理 |
| Dayjs | ^1.11.13 | 日期处理 |
| TypeScript | ^5.7.3 | 类型安全 |

## 环境要求

### Flutter应用端

- Flutter SDK 3.10.4+
- Dart SDK 3.10.0+
- Android Studio 2022.3+
- Xcode 14.0+ (macOS)

### 微信小程序端

- Node.js 18.0.0+
- npm 9.0.0+
- 微信开发者工具 Stable 1.06+

## 安装与运行

### Flutter应用端

1. 克隆项目
   ```bash
   git clone <repository-url>
   cd GuguPet/app
   ```

2. 获取依赖
   ```bash
   flutter pub get
   ```

3. 运行应用
   - Android: `flutter run`
   - iOS: `flutter run` (需要macOS环境)
   - Web: `flutter run -d chrome`

### 微信小程序端

1. 进入小程序目录
   ```bash
   cd GuguPet/miniprogram
   ```

2. 安装依赖
   ```bash
   npm install
   ```

3. 开发模式运行
   ```bash
   npm run dev:weapp
   ```

4. 构建生产版本
   ```bash
   npm run build:weapp
   ```

5. 在微信开发者工具中打开 `GuguPet/miniprogram` 目录预览效果

## 功能模块

### 1. 宠物陪伴
- 宠物互动（喂食、玩耍、清洁）
- 宠物成长系统
- 情感状态反馈
- 3D宠物动画展示

### 2. 求职辅助
- 求职进度追踪
- 简历优化建议
- 面试模拟练习
- 职位推荐

### 3. 情感支持
- 心情倾诉功能
- 智能回复系统
- 激励语录推送
- 成就系统

### 4. 社交功能
- 宠物乐园互动
- 求职经验分享
- 互助社区

### 5. 数据统计
- 求职数据可视化
- 情绪变化分析
- 互动频率统计

## 开发规范

### 代码规范

1. **Flutter应用端**
   - 遵循官方Flutter代码风格指南
   - 使用Dart格式化工具 `dart format .`
   - 代码注释覆盖率不低于30%

2. **微信小程序端**
   - 遵循React和TypeScript最佳实践
   - 使用ESLint和Prettier进行代码检查和格式化
   - 组件命名采用大驼峰式，文件命名采用短横线分隔

### 文档规范

1. 所有新功能开发前必须编写需求文档
2. 系统设计变更必须同步更新相关文档
3. API接口必须有详细的文档说明
4. 文档格式统一使用Markdown

### Git提交规范

```
<type>(<scope>): <subject>

<body>

<footer>
```

- **type**：feat(新功能)、fix(修复bug)、docs(文档更新)、style(代码格式)、refactor(重构)、test(测试)、chore(构建/工具)
- **scope**：模块名称或功能点
- **subject**：简明的提交描述
- **body**：详细的提交说明
- **footer**：关联的Issue或PR

## 贡献指南

1. Fork本仓库
2. 创建特性分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'feat: Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 打开Pull Request

## 许可证

本项目采用MIT许可证，详情请查看LICENSE文件。

## 联系方式

- 项目负责人：XXX
- 技术支持：XXX
- 反馈邮箱：XXX@example.com

## 更新日志

### v1.0.0 (2026-03-19)
- 初始版本发布
- 完成Flutter应用端核心功能
- 完成微信小程序基础功能
- 编写项目文档

## 致谢

感谢所有为项目贡献代码和建议的开发者们！