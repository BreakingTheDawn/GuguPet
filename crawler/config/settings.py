"""
全局配置文件
定义爬虫的各项参数配置

【合规说明】
本配置文件包含爬虫系统的所有参数配置，请根据实际需求合理设置：

1. 频率控制（重要！）
   - DELAY_MIN/DELAY_MAX: 请求延迟范围，建议≥3秒
   - MAX_REQUESTS_PER_MINUTE: 每分钟最大请求数，建议≤10次
   - MAX_REQUESTS_PER_HOUR: 每小时最大请求数，建议≤500次

2. 合规配置
   - ROBOTS_TXT_CHECK_ENABLED: 是否检查robots.txt（建议保持True）
   - RESPECT_ROBOTS_TXT: 是否遵守robots.txt规则（建议保持True）
   - RATE_LIMIT_ENABLED: 是否启用流量限制（建议保持True）

3. 安全配置
   - PROXY_ENABLED: 是否启用代理（可选）
   - COOKIE_ENCRYPTION_ENABLED: 是否加密Cookie（建议启用）

4. 使用前请确保：
   - 已阅读目标网站的服务条款
   - 已根据目标网站负载能力调整参数
   - 仅用于个人学习和研究目的
"""
import os
from pathlib import Path

# 项目根目录
BASE_DIR = Path(__file__).parent.parent.absolute()

# 数据库配置
DATABASE_PATH = BASE_DIR / "output" / "jobs.db"

# 日志配置
LOG_DIR = BASE_DIR / "logs"
LOG_FILE = LOG_DIR / "crawler.log"
LOG_LEVEL = "INFO"
LOG_FORMAT = "[%(asctime)s] %(levelname)-8s | %(message)s"
LOG_DATE_FORMAT = "%Y-%m-%d %H:%M:%S"

# 爬虫配置
# 每个关键词爬取数量
JOBS_PER_KEYWORD = 50

# 最大翻页数
MAX_PAGES = 5

# 请求延迟配置（秒）
DELAY_MIN = 3
DELAY_MAX = 8
DELAY_PAGE_MIN = 5
DELAY_PAGE_MAX = 10

# 重试配置
MAX_RETRIES = 3
RETRY_DELAY_BASE = 10

# User-Agent池（扩展到20+）
USER_AGENTS = [
    # Chrome Windows
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36",
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36",
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/118.0.0.0 Safari/537.36",
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/117.0.0.0 Safari/537.36",
    # Chrome Mac
    "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36",
    "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36",
    # Edge
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36 Edg/120.0.0.0",
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36 Edg/119.0.0.0",
    # Firefox
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:121.0) Gecko/20100101 Firefox/121.0",
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:120.0) Gecko/20100101 Firefox/120.0",
    "Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:121.0) Gecko/20100101 Firefox/121.0",
    # Safari
    "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.2 Safari/605.1.15",
    "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.1 Safari/605.1.15",
    # Chrome Linux
    "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36",
    "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36",
    # 更多Chrome版本
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/116.0.0.0 Safari/537.36",
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/115.0.0.0 Safari/537.36",
    "Mozilla/5.0 (Windows NT 11.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36",
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.6099.109 Safari/537.36",
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.6045.159 Safari/537.36",
]

# ==================== 请求头配置 ====================
# 完整请求头模板
REQUEST_HEADERS_TEMPLATES = [
    {
        "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8",
        "Accept-Language": "zh-CN,zh;q=0.9,en;q=0.8",
        "Accept-Encoding": "gzip, deflate, br",
        "Connection": "keep-alive",
        "Upgrade-Insecure-Requests": "1",
        "Sec-Fetch-Dest": "document",
        "Sec-Fetch-Mode": "navigate",
        "Sec-Fetch-Site": "none",
        "Sec-Fetch-User": "?1",
        "Cache-Control": "max-age=0",
    },
    {
        "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8",
        "Accept-Language": "zh-CN,zh;q=0.9",
        "Accept-Encoding": "gzip, deflate, br",
        "Connection": "keep-alive",
        "Sec-Fetch-Dest": "document",
        "Sec-Fetch-Mode": "navigate",
        "Sec-Fetch-Site": "same-origin",
        "Sec-Fetch-User": "?1",
    },
]

# 浏览器配置
HEADLESS = False  # 不使用无头模式，更像真实用户
DISABLE_IMAGES = True  # 禁用图片加载，提高速度

# Cookie存储路径
COOKIE_DIR = BASE_DIR / "cookies"

# ==================== 代理配置 ====================
# 代理池配置（支持HTTP/HTTPS/SOCKS5）
PROXY_ENABLED = False  # 是否启用代理（默认关闭，需要时开启）
PROXY_POOL = [
    # 格式：协议://用户名:密码@地址:端口
    # 示例（请替换为实际代理）：
    # "http://user:pass@proxy1.example.com:8080",
    # "http://user:pass@proxy2.example.com:8080",
    # "socks5://user:pass@proxy3.example.com:1080",
]
PROXY_TEST_URL = "https://httpbin.org/ip"  # 代理测试URL
PROXY_TIMEOUT = 10  # 代理连接超时（秒）
PROXY_MAX_FAILS = 3  # 代理最大失败次数，超过则移除

# ==================== 安全配置 ====================
# Cookie加密密钥（32字节base64编码，请修改为自己的密钥）
# 生成方式：python -c "from cryptography.fernet import Fernet; print(Fernet.generate_key().decode())"
COOKIE_ENCRYPTION_KEY = "YOUR_ENCRYPTION_KEY_HERE"  # 请替换为实际密钥
COOKIE_ENCRYPTION_ENABLED = False  # 是否启用Cookie加密（默认关闭，配置密钥后开启）

# ==================== 验证码配置 ====================
CAPTCHA_AUTO_RETRY = True  # 是否自动重试
CAPTCHA_MAX_WAIT = 300     # 验证码最大等待时间（秒）
CAPTCHA_NOTIFY_ENABLED = True  # 是否启用通知
CAPTCHA_NOTIFY_WEBHOOK = ""  # Webhook通知地址（可选）

# 验证码检测关键词
CAPTCHA_KEYWORDS = [
    '验证', '安全验证', '人机验证', '滑动验证', 
    '图形验证', '请完成安全验证', '检测到异常'
]

# ==================== 合规配置 ====================
ROBOTS_TXT_CHECK_ENABLED = True  # 是否检查robots.txt
ROBOTS_TXT_CACHE_DIR = BASE_DIR / "cache" / "robots"
CRAWLER_USER_AGENT = "GuguPetCrawler"  # 爬虫标识（用于robots.txt检查）
RESPECT_ROBOTS_TXT = True  # 是否遵守robots.txt规则

# ==================== 流量控制配置 ====================
MAX_CONCURRENT_REQUESTS = 1      # 最大并发请求数（建议保持1）
MAX_REQUESTS_PER_MINUTE = 10     # 每分钟最大请求数
MAX_REQUESTS_PER_HOUR = 500      # 每小时最大请求数
RATE_LIMIT_ENABLED = True        # 是否启用流量限制

# 自适应延迟配置
ADAPTIVE_DELAY_ENABLED = True    # 是否启用自适应延迟
ADAPTIVE_DELAY_MIN = 3           # 自适应延迟最小值
ADAPTIVE_DELAY_MAX = 30          # 自适应延迟最大值

# ==================== 浏览器指纹配置 ====================
FINGERPRINT_RANDOMIZATION = True  # 是否启用指纹随机化

# 屏幕分辨率池
SCREEN_RESOLUTIONS = [
    (1920, 1080),
    (1366, 768),
    (1536, 864),
    (1440, 900),
    (2560, 1440),
]

# 语言配置
LANGUAGES = ["zh-CN", "zh-CN,zh", "zh-CN,zh;q=0.9,en;q=0.8"]

# 时区配置
TIMEZONES = ["Asia/Shanghai", "Asia/Chongqing", "Asia/Hong_Kong"]

# 平台配置
PLATFORMS = ["Win32", "Linux x86_64", "MacIntel"]

# ==================== 告警配置 ====================
ALERT_ENABLED = True  # 是否启用告警
ALERT_WEBHOOK_URL = ""  # Webhook URL（支持钉钉/企业微信/Slack等）
ALERT_EMAIL = ""  # 告警邮箱

# 告警触发条件
ALERT_ON_CAPTCHA = True      # 验证码时告警
ALERT_ON_BLOCKED = True      # 被封时告警
ALERT_ON_ERROR_RATE = 0.3    # 错误率超过30%时告警
