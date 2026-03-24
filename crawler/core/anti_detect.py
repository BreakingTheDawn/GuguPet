"""
反检测策略模块
提供多种反爬虫检测规避策略

【合规说明】
本模块提供人性化的访问行为模拟，目的是：
1. 模拟真实用户行为，避免被误判为恶意爬虫
2. 减少对目标服务器的压力，通过随机延迟实现人性化访问
3. 使用真实浏览器的User-Agent，避免使用明显的爬虫标识

重要提示：
- 本模块的反检测策略仅用于模拟正常用户访问行为
- 不应用于绕过网站的安全机制或访问限制
- 不应使用本模块进行任何违法或违规的数据采集活动

功能说明：
- User-Agent轮换：使用真实浏览器的UA标识
- 随机延迟：模拟人类浏览页面的时间间隔
- 鼠标行为模拟：模拟人类的鼠标移动轨迹
- 请求头伪装：使用完整的浏览器请求头
"""
import random
import time
from typing import Tuple, Dict

from config.settings import (
    USER_AGENTS, 
    DELAY_MIN, DELAY_MAX, 
    DELAY_PAGE_MIN, DELAY_PAGE_MAX,
    RETRY_DELAY_BASE,
    REQUEST_HEADERS_TEMPLATES
)


class AntiDetect:
    """
    反检测策略类
    封装各种反爬虫检测规避方法
    """
    
    def __init__(self):
        """初始化反检测策略"""
        self.current_ua = None
    
    def get_random_ua(self) -> str:
        """
        获取随机User-Agent
        
        Returns:
            随机选择的User-Agent字符串
        """
        self.current_ua = random.choice(USER_AGENTS)
        return self.current_ua
    
    def get_random_delay(self, is_page: bool = False) -> float:
        """
        获取随机延迟时间
        
        Args:
            is_page: 是否为翻页请求
        
        Returns:
            延迟秒数
        """
        if is_page:
            return random.uniform(DELAY_PAGE_MIN, DELAY_PAGE_MAX)
        return random.uniform(DELAY_MIN, DELAY_MAX)
    
    def get_retry_delay(self, retry_count: int) -> float:
        """
        获取重试延迟时间（指数退避）
        
        Args:
            retry_count: 当前重试次数
        
        Returns:
            延迟秒数
        """
        return RETRY_DELAY_BASE * (2 ** retry_count) + random.uniform(0, 5)
    
    def sleep(self, is_page: bool = False):
        """
        执行随机延迟
        
        Args:
            is_page: 是否为翻页请求
        """
        delay = self.get_random_delay(is_page)
        time.sleep(delay)
    
    def sleep_retry(self, retry_count: int):
        """
        执行重试延迟
        
        Args:
            retry_count: 当前重试次数
        """
        delay = self.get_retry_delay(retry_count)
        time.sleep(delay)
    
    @staticmethod
    def get_random_scroll_position() -> Tuple[int, int]:
        """
        获取随机滚动位置
        
        Returns:
            (起始位置, 结束位置)
        """
        start = random.randint(0, 300)
        end = start + random.randint(500, 1000)
        return start, end
    
    @staticmethod
    def get_random_mouse_offset() -> Tuple[int, int]:
        """
        获取随机鼠标偏移量
        
        Returns:
            (x偏移, y偏移)
        """
        return (
            random.randint(-50, 50),
            random.randint(-30, 30)
        )
    
    def get_random_headers(self) -> Dict:
        """
        获取随机请求头
        
        Returns:
            请求头字典
        """
        headers = random.choice(REQUEST_HEADERS_TEMPLATES).copy()
        return headers
    
    def get_full_identity(self) -> Tuple[str, Dict]:
        """
        获取完整身份信息（UA + Headers）
        
        Returns:
            (User-Agent, Headers字典)
        """
        ua = self.get_random_ua()
        headers = self.get_random_headers()
        return ua, headers


# 全局反检测策略实例
anti_detect = AntiDetect()
