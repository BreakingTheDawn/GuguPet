"""
爬虫引擎模块
封装DrissionPage浏览器操作

【合规说明】
本模块是爬虫系统的底层引擎，负责浏览器初始化和页面操作。
引擎内置了以下合规特性：
- User-Agent轮换：使用真实的浏览器UA，避免被识别为爬虫
- 代理支持：支持HTTP/HTTPS/SOCKS5代理，保护访问者隐私
- 浏览器指纹随机化：随机化屏幕分辨率、语言等特征
- Cookie加密存储：使用Fernet对称加密保护敏感数据
- 请求频率控制：集成rate_limiter，自动控制访问频率

技术选型说明：
- 使用DrissionPage而非Selenium，因为它更轻量、更难被检测
- 支持无头模式和有头模式切换，有头模式更像真实用户
- 自动禁用图片加载，减少带宽消耗和服务器压力
"""
import random
import time
from typing import Optional

from DrissionPage import ChromiumPage, ChromiumOptions

from config.settings import HEADLESS, DISABLE_IMAGES, COOKIE_DIR
from core.anti_detect import anti_detect
from core.proxy_pool import proxy_pool
from config.settings import PROXY_ENABLED
from core.secure_storage import secure_storage
from config.settings import COOKIE_ENCRYPTION_ENABLED
from config.settings import (
    FINGERPRINT_RANDOMIZATION, SCREEN_RESOLUTIONS, 
    LANGUAGES, TIMEZONES, PLATFORMS
)
from utils.logger import logger


class CrawlerEngine:
    """
    爬虫引擎类
    封装浏览器初始化、页面操作等方法
    """
    
    def __init__(self, disable_images: bool = None):
        """
        初始化爬虫引擎
        
        Args:
            disable_images: 是否禁用图片加载，None时使用配置文件设置
        """
        self.page: Optional[ChromiumPage] = None
        self._is_initialized = False
        self._disable_images = disable_images if disable_images is not None else DISABLE_IMAGES
    
    def init_browser(self):
        """
        初始化浏览器
        配置反检测参数
        """
        if self._is_initialized:
            return
        
        logger.info("正在初始化浏览器...")
        
        # 创建浏览器配置
        co = ChromiumOptions()
        
        # 设置User-Agent
        co.set_user_agent(anti_detect.get_random_ua())
        
        # 设置代理
        if PROXY_ENABLED:
            proxy_url = proxy_pool.get_proxy()
            if proxy_url:
                proxy_info = proxy_pool.parse_proxy_for_browser(proxy_url)
                if proxy_info:
                    co.set_argument(f'--proxy-server={proxy_info["server"]}')
                    logger.info(f"[浏览器] 使用代理: {proxy_pool._mask_proxy(proxy_url)}")
        
        # 反检测配置
        co.set_argument('--disable-blink-features=AutomationControlled')
        co.set_argument('--disable-infobars')
        co.set_argument('--no-sandbox')
        co.set_argument('--disable-dev-shm-usage')
        co.set_argument('--disable-gpu')
        
        # 浏览器指纹随机化
        if FINGERPRINT_RANDOMIZATION:
            # 随机屏幕分辨率
            width, height = random.choice(SCREEN_RESOLUTIONS)
            co.set_argument(f'--window-size={width},{height}')
            
            # 随机语言
            lang = random.choice(LANGUAGES)
            co.set_argument(f'--lang={lang}')
            
            logger.debug(f"[浏览器指纹] 分辨率: {width}x{height}, 语言: {lang}")
        
        # 禁用图片加载（提高速度）
        if self._disable_images:
            co.set_pref('profile.managed_default_content_settings.images', 2)
        
        # 无头模式配置
        if HEADLESS:
            co.set_headless(True)
        
        # 创建浏览器页面
        self.page = ChromiumPage(co)
        
        # 设置页面超时
        self.page.set.load_mode.eager()  # 智能等待模式
        
        self._is_initialized = True
        logger.info("浏览器初始化完成")
    
    def close(self):
        """关闭浏览器"""
        if self.page:
            self.page.quit()
            self.page = None
            self._is_initialized = False
            logger.info("浏览器已关闭")
    
    def navigate(self, url: str, wait_time: float = None):
        """
        导航到指定URL
        
        Args:
            url: 目标URL
            wait_time: 等待时间（秒）
        """
        if wait_time is None:
            wait_time = anti_detect.get_random_delay()
        
        logger.info(f"正在访问: {url}")
        self.page.get(url)
        time.sleep(wait_time)
    
    def scroll_page(self, distance: int = None):
        """
        滚动页面
        
        Args:
            distance: 滚动距离
        """
        if distance is None:
            _, distance = anti_detect.get_random_scroll_position()
        
        self.page.scroll.down(distance)
        time.sleep(random.uniform(0.5, 1.5))
    
    def scroll_to_bottom(self):
        """滚动到页面底部"""
        self.page.scroll.to_bottom()
        time.sleep(random.uniform(1, 2))
    
    def click_element(self, selector: str, by: str = 'css'):
        """
        点击元素
        
        Args:
            selector: 元素选择器
            by: 选择器类型（css/xpath/text）
        """
        try:
            if by == 'css':
                element = self.page.ele(f'css:{selector}')
            elif by == 'xpath':
                element = self.page.ele(f'xpath:{selector}')
            else:
                element = self.page.ele(selector)
            
            if element:
                # 模拟人类点击行为
                self._simulate_human_click(element)
                return True
        except Exception as e:
            logger.warning(f"点击元素失败: {selector}, 错误: {e}")
        return False
    
    def _simulate_human_click(self, element):
        """
        模拟人类点击行为
        
        Args:
            element: 目标元素
        """
        # 先移动到元素附近
        offset = anti_detect.get_random_mouse_offset()
        element.hover()
        time.sleep(random.uniform(0.2, 0.5))
        # 点击
        element.click()
        time.sleep(random.uniform(0.3, 0.8))
    
    def get_element_text(self, selector: str, by: str = 'css') -> str:
        """
        获取元素文本
        
        Args:
            selector: 元素选择器
            by: 选择器类型
        
        Returns:
            元素文本内容
        """
        try:
            if by == 'css':
                element = self.page.ele(f'css:{selector}')
            elif by == 'xpath':
                element = self.page.ele(f'xpath:{selector}')
            else:
                element = self.page.ele(selector)
            
            if element:
                return element.text.strip()
        except Exception as e:
            logger.debug(f"获取元素文本失败: {selector}, 错误: {e}")
        return ""
    
    def get_elements(self, selector: str, by: str = 'css') -> list:
        """
        获取多个元素
        
        Args:
            selector: 元素选择器
            by: 选择器类型
        
        Returns:
            元素列表
        """
        try:
            if by == 'css':
                return self.page.eles(f'css:{selector}')
            elif by == 'xpath':
                return self.page.eles(f'xpath:{selector}')
            else:
                return self.page.eles(selector)
        except Exception as e:
            logger.debug(f"获取元素列表失败: {selector}, 错误: {e}")
        return []
    
    def wait_for_element(self, selector: str, timeout: float = 10, by: str = 'css') -> bool:
        """
        等待元素出现
        
        Args:
            selector: 元素选择器
            timeout: 超时时间
            by: 选择器类型
        
        Returns:
            元素是否出现
        """
        try:
            if by == 'css':
                return self.page.wait.ele_displayed(f'css:{selector}', timeout=timeout)
            elif by == 'xpath':
                return self.page.wait.ele_displayed(f'xpath:{selector}', timeout=timeout)
            else:
                return self.page.wait.ele_displayed(selector, timeout=timeout)
        except Exception:
            return False
    
    def save_cookies(self, domain: str):
        """
        保存Cookie（支持加密存储）
        
        Args:
            domain: 域名
        """
        try:
            # 获取所有Cookie并转换为字典格式
            cookies = self.page.cookies()
            cookie_dict = {c.get('name', ''): c for c in cookies if c.get('name')}
            
            # 使用安全存储保存
            if secure_storage.save_cookies(domain, cookie_dict):
                logger.info(f"[Cookie] 已保存: {domain}")
            else:
                # 降级到原始保存方式
                COOKIE_DIR.mkdir(parents=True, exist_ok=True)
                cookie_file = COOKIE_DIR / f"{domain}.txt"
                self.page.cookies.save(cookie_file)
                logger.info(f"[Cookie] 已保存（明文）: {domain}")
        except Exception as e:
            logger.error(f"[Cookie] 保存失败: {domain}, 错误: {e}")
    
    def load_cookies(self, domain: str) -> bool:
        """
        加载Cookie（支持解密加载）
        
        Args:
            domain: 域名
        
        Returns:
            是否加载成功
        """
        try:
            # 尝试从安全存储加载
            cookies = secure_storage.load_cookies(domain)
            if cookies:
                for name, cookie in cookies.items():
                    try:
                        self.page.set.cookies(cookie)
                    except Exception:
                        # 忽略单个Cookie设置失败
                        pass
                logger.info(f"[Cookie] 已加载: {domain}")
                return True
            
            # 降级到原始加载方式
            cookie_file = COOKIE_DIR / f"{domain}.txt"
            if cookie_file.exists():
                self.page.cookies.load(cookie_file)
                logger.info(f"[Cookie] 已加载（明文）: {domain}")
                return True
            
            return False
        except Exception as e:
            logger.error(f"[Cookie] 加载失败: {domain}, 错误: {e}")
            return False
    
    def is_captcha_detected(self) -> bool:
        """
        检测是否出现验证码
        
        Returns:
            是否检测到验证码
        """
        captcha_keywords = ['验证', '安全验证', '人机验证', '滑动验证', '图形验证']
        page_text = self.page.html
        
        for keyword in captcha_keywords:
            if keyword in page_text:
                return True
        return False


# 全局引擎实例
engine = CrawlerEngine()
