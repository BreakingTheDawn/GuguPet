# 职位爬虫系统

## ⚠️ 重要声明

**本爬虫系统仅用于个人学习和研究目的！**

使用前请务必阅读并遵守以下合规要求：

### 合规原则

1. **遵守 robots.txt** - 自动检查并遵守目标网站的爬取规则
2. **合理频率** - 默认每分钟≤10次请求，每小时≤500次请求
3. **人性化访问** - 使用随机延迟和真实浏览器UA
4. **数据安全** - 仅采集公开信息，数据本地存储

### 法律依据

- 《中华人民共和国网络安全法》
- 《中华人民共和国数据安全法》
- 《中华人民共和国个人信息保护法》
- 《互联网信息服务管理办法》

---

## 功能特性

### 核心功能

- ✅ 多平台支持：Boss直聘、智联招聘、前程无忧
- ✅ 自动化爬取：基于DrissionPage的浏览器自动化
- ✅ 数据存储：SQLite本地数据库
- ✅ 日志记录：完整的运行日志

### 安全特性

- ✅ robots.txt合规检查
- ✅ 流量限制与自适应延迟
- ✅ IP代理池支持
- ✅ Cookie加密存储
- ✅ 验证码检测与通知
- ✅ 浏览器指纹随机化
- ✅ 异常告警系统

---

## 目录结构

```
crawler/
├── config/                 # 配置模块
│   ├── settings.py        # 全局配置
│   ├── cities.py          # 城市编码配置
│   └── categories.py      # 职位分类配置
├── core/                   # 核心模块
│   ├── engine.py          # 爬虫引擎（浏览器操作）
│   ├── robots_checker.py  # robots.txt检查器
│   ├── rate_limiter.py    # 流量限制器
│   ├── anti_detect.py     # 反检测策略
│   ├── captcha_handler.py # 验证码处理器
│   ├── proxy_pool.py      # 代理池管理
│   ├── secure_storage.py  # 安全存储（Cookie加密）
│   └── alerter.py         # 异常告警
├── spiders/                # 爬虫实现
│   ├── base.py            # 爬虫基类
│   ├── boss.py            # Boss直聘爬虫
│   ├── zhilian.py         # 智联招聘爬虫
│   └── qiancheng.py       # 前程无忧爬虫
├── storage/                # 数据存储
│   ├── database.py        # 数据库操作
│   └── models.py          # 数据模型
├── utils/                  # 工具模块
│   └── logger.py          # 日志工具
├── output/                 # 输出目录
│   └── jobs.db            # SQLite数据库
├── main.py                 # 主入口
└── requirements.txt        # 依赖列表
```

---

## 安装与配置

### 1. 环境要求

- Python 3.10+
- Chrome/Edge 浏览器
- Windows/macOS/Linux

### 2. 安装依赖

```bash
cd crawler
pip install -r requirements.txt
```

### 3. 配置参数

编辑 `config/settings.py`，配置以下参数：

```python
# 爬取频率配置（重要！）
DELAY_MIN = 3              # 最小延迟（秒）
DELAY_MAX = 8              # 最大延迟（秒）
MAX_REQUESTS_PER_MINUTE = 10   # 每分钟最大请求数
MAX_REQUESTS_PER_HOUR = 500    # 每小时最大请求数

# 合规配置（默认启用）
ROBOTS_TXT_CHECK_ENABLED = True   # robots.txt检查
RESPECT_ROBOTS_TXT = True         # 遵守robots.txt规则
RATE_LIMIT_ENABLED = True         # 流量限制

# 代理配置（可选）
PROXY_ENABLED = False             # 是否启用代理
PROXY_POOL = []                   # 代理列表

# Cookie加密（可选）
COOKIE_ENCRYPTION_ENABLED = False # 是否启用加密
COOKIE_ENCRYPTION_KEY = "YOUR_KEY" # 加密密钥
```

---

## 使用方法

### 基本使用

```bash
# 运行所有爬虫
python main.py

# 运行单个爬虫
python main.py boss        # 仅爬取Boss直聘
python main.py zhilian     # 仅爬取智联招聘
python main.py qiancheng   # 仅爬取前程无忧
```

### 定时任务

使用Windows任务计划程序或Linux crontab设置定时任务：

**Windows (PowerShell):**
```powershell
# 每天凌晨2点运行
.\setup_schedule.ps1
```

**Linux (crontab):**
```bash
# 每天凌晨2点运行
0 2 * * * cd /path/to/crawler && python main.py
```

---

## 合规配置说明

### robots.txt 检查

系统会自动检查目标网站的 robots.txt 文件：

```python
# 启用robots.txt检查
ROBOTS_TXT_CHECK_ENABLED = True

# 遵守robots.txt规则
RESPECT_ROBOTS_TXT = True

# 爬虫标识（用于robots.txt检查）
CRAWLER_USER_AGENT = "GuguPetCrawler"
```

### 流量限制

系统内置多层流量限制：

```python
# 分钟级限制
MAX_REQUESTS_PER_MINUTE = 10

# 小时级限制
MAX_REQUESTS_PER_HOUR = 500

# 自适应延迟
ADAPTIVE_DELAY_ENABLED = True
ADAPTIVE_DELAY_MIN = 3
ADAPTIVE_DELAY_MAX = 30
```

### 验证码处理

遇到验证码时的处理策略：

```python
# 自动重试
CAPTCHA_AUTO_RETRY = True

# 最大等待时间（秒）
CAPTCHA_MAX_WAIT = 300

# Webhook通知（可选）
CAPTCHA_NOTIFY_ENABLED = True
CAPTCHA_NOTIFY_WEBHOOK = "your_webhook_url"
```

---

## 数据说明

### 数据字段

爬取的职位信息包含以下字段：

| 字段 | 说明 | 是否公开 |
|------|------|---------|
| job_id | 职位唯一ID | ✅ |
| title | 职位名称 | ✅ |
| company | 公司名称 | ✅ |
| salary | 薪资范围 | ✅ |
| location | 工作地点 | ✅ |
| experience | 经验要求 | ✅ |
| education | 学历要求 | ✅ |
| description | 职位描述 | ✅ |
| url | 职位链接 | ✅ |

### 数据使用原则

- ✅ 仅用于个人求职参考
- ✅ 数据存储在本地，不上传服务器
- ❌ 不用于商业用途
- ❌ 不进行数据倒卖或分发

---

## 安全建议

### 1. 代理使用

```python
# 配置代理池
PROXY_ENABLED = True
PROXY_POOL = [
    "http://user:pass@proxy1.example.com:8080",
    "socks5://user:pass@proxy2.example.com:1080",
]
```

### 2. Cookie加密

```python
# 生成加密密钥
python -c "from cryptography.fernet import Fernet; print(Fernet.generate_key().decode())"

# 启用加密
COOKIE_ENCRYPTION_ENABLED = True
COOKIE_ENCRYPTION_KEY = "your_generated_key"
```

### 3. 告警配置

```python
# Webhook告警
ALERT_ENABLED = True
ALERT_WEBHOOK_URL = "your_webhook_url"

# 告警触发条件
ALERT_ON_CAPTCHA = True      # 验证码时告警
ALERT_ON_BLOCKED = True      # 被封时告警
ALERT_ON_ERROR_RATE = 0.3    # 错误率>30%时告警
```

---

## 常见问题

### Q1: 如何降低被封风险？

- 设置合理的请求延迟（≥5秒）
- 在非高峰时段爬取
- 使用代理池
- 遵守robots.txt规则

### Q2: 遇到验证码怎么办？

系统会自动暂停并通知，等待人工处理后继续。

### Q3: 数据存储在哪里？

数据存储在 `output/jobs.db` SQLite数据库中。

### Q4: 如何修改爬取频率？

编辑 `config/settings.py` 中的延迟参数。

---

## 免责声明

- ⚠️ 使用者应自行确保爬取行为符合目标网站的服务条款
- ⚠️ 因不当使用造成的法律责任由使用者自行承担
- ⚠️ 本系统开发者不对任何滥用行为承担责任
- ⚠️ 使用本系统即表示您已阅读并同意以上条款

---

## 更新日志

### v1.2.0 (2026-03-24)

- ✅ 安全增强：代理池、Cookie加密、验证码处理
- ✅ 合规增强：robots.txt检查、流量限制
- ✅ 新增告警系统

### v1.0.0 (2026-03-19)

- 初始版本发布
- 支持Boss直聘、智联招聘、前程无忧

---

**请合法合规使用本系统！**
