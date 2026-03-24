"""
robots.txt合规检查模块
检查目标网站是否允许爬取

【合规说明】
本模块是爬虫合规性的核心组件，负责检查和遵守目标网站的robots.txt规则。

功能说明：
1. 自动获取并解析目标网站的robots.txt文件
2. 检查指定URL是否允许被爬取
3. 获取网站要求的爬取延迟（Crawl-Delay）
4. 获取网站提供的sitemap列表

合规原则：
- 默认启用robots.txt检查（ROBOTS_TXT_CHECK_ENABLED = True）
- 默认遵守robots.txt规则（RESPECT_ROBOTS_TXT = True）
- 使用专用的爬虫标识（CRAWLER_USER_AGENT = "GuguPetCrawler"）
- 缓存robots.txt解析结果，减少重复请求

法律依据：
- robots.txt是国际通用的网络爬虫规范
- 遵守robots.txt是网络爬虫的基本道德准则
- 《中华人民共和国网络安全法》要求网络爬虫不得干扰网络正常服务
"""
import urllib.robotparser
from urllib.parse import urlparse
from pathlib import Path
from typing import Optional, List

from config.settings import (
    ROBOTS_TXT_CHECK_ENABLED, ROBOTS_TXT_CACHE_DIR,
    CRAWLER_USER_AGENT, RESPECT_ROBOTS_TXT
)
from utils.logger import logger


class RobotsChecker:
    """
    robots.txt检查器
    检查目标网站是否允许爬取
    """
    
    def __init__(self):
        """初始化检查器"""
        self._cache = {}  # URL -> RobotFileParser
        ROBOTS_TXT_CACHE_DIR.mkdir(parents=True, exist_ok=True)
    
    def can_fetch(self, url: str) -> bool:
        """
        检查是否允许爬取指定URL
        
        Args:
            url: 目标URL
        
        Returns:
            是否允许爬取
        """
        if not ROBOTS_TXT_CHECK_ENABLED:
            return True
        
        parsed = urlparse(url)
        base_url = f"{parsed.scheme}://{parsed.netloc}"
        
        # 检查缓存
        if base_url in self._cache:
            rp = self._cache[base_url]
        else:
            rp = self._fetch_robots_txt(base_url)
            self._cache[base_url] = rp
        
        if rp is None:
            # 无法获取robots.txt，默认允许
            return True
        
        allowed = rp.can_fetch(CRAWLER_USER_AGENT, url)
        
        if not allowed and RESPECT_ROBOTS_TXT:
            logger.warning(f"[robots.txt] 禁止爬取: {url}")
        
        return allowed or not RESPECT_ROBOTS_TXT
    
    def _fetch_robots_txt(self, base_url: str) -> Optional[urllib.robotparser.RobotFileParser]:
        """
        获取并解析robots.txt
        
        Args:
            base_url: 网站基础URL
        
        Returns:
            RobotFileParser实例，失败返回None
        """
        rp = urllib.robotparser.RobotFileParser()
        robots_url = f"{base_url}/robots.txt"
        
        try:
            rp.set_url(robots_url)
            rp.read()
            
            # 获取爬取延迟
            crawl_delay = rp.crawl_delay(CRAWLER_USER_AGENT)
            if crawl_delay:
                logger.info(f"[robots.txt] {base_url} 要求爬取延迟: {crawl_delay}秒")
            
            logger.debug(f"[robots.txt] 成功获取: {robots_url}")
            return rp
            
        except Exception as e:
            logger.debug(f"[robots.txt] 获取失败: {robots_url}, 错误: {e}")
            return None
    
    def get_crawl_delay(self, url: str) -> Optional[float]:
        """
        获取网站要求的爬取延迟
        
        Args:
            url: 目标URL
        
        Returns:
            延迟秒数，无要求返回None
        """
        if not ROBOTS_TXT_CHECK_ENABLED:
            return None
        
        parsed = urlparse(url)
        base_url = f"{parsed.scheme}://{parsed.netloc}"
        
        if base_url in self._cache:
            rp = self._cache[base_url]
        else:
            rp = self._fetch_robots_txt(base_url)
            self._cache[base_url] = rp
        
        if rp is None:
            return None
        
        return rp.crawl_delay(CRAWLER_USER_AGENT)
    
    def get_sitemaps(self, url: str) -> List[str]:
        """
        获取网站的sitemap列表
        
        Args:
            url: 目标URL
        
        Returns:
            sitemap URL列表
        """
        parsed = urlparse(url)
        base_url = f"{parsed.scheme}://{parsed.netloc}"
        
        if base_url in self._cache:
            rp = self._cache[base_url]
        else:
            rp = self._fetch_robots_txt(base_url)
            self._cache[base_url] = rp
        
        if rp is None:
            return []
        
        return rp.site_maps() or []


# 全局检查器实例
robots_checker = RobotsChecker()
