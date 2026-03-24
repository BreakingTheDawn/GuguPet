"""
IP代理池模块
提供代理获取、验证、切换功能

【合规说明】
本模块提供代理池管理功能，用于：
1. 保护爬虫运行者的隐私和安全
2. 避免因单一IP频繁访问而被封禁
3. 分散请求来源，减轻目标服务器压力

重要提示：
- 代理仅用于合法的数据采集活动
- 使用代理不改变爬虫应遵守的合规原则
- 仍需遵守目标网站的robots.txt规则
- 仍需控制请求频率，避免对服务器造成压力

功能说明：
- 支持HTTP/HTTPS/SOCKS5代理协议
- 自动验证代理可用性
- 失败自动切换代理
- 代理失效自动移除

使用建议：
- 使用合法的代理服务
- 配置合理的代理轮换策略
- 监控代理成功率，及时调整
"""
import random
import time
import re
from typing import Optional, List, Dict
from dataclasses import dataclass
from threading import Lock

try:
    import requests
    REQUESTS_AVAILABLE = True
except ImportError:
    REQUESTS_AVAILABLE = False

from config.settings import (
    PROXY_ENABLED, PROXY_POOL, PROXY_TEST_URL, 
    PROXY_TIMEOUT, PROXY_MAX_FAILS
)
from utils.logger import logger


@dataclass
class ProxyInfo:
    """代理信息数据类"""
    url: str              # 代理URL
    fail_count: int = 0   # 失败次数
    last_used: float = 0  # 最后使用时间
    is_alive: bool = True # 是否存活


class ProxyPool:
    """
    IP代理池管理类
    支持代理获取、验证、自动切换
    """
    
    def __init__(self):
        """初始化代理池"""
        self._proxies: List[ProxyInfo] = []
        self._current_proxy: Optional[ProxyInfo] = None
        self._lock = Lock()
        self._init_pool()
    
    def _init_pool(self):
        """初始化代理池，加载配置中的代理"""
        if not PROXY_ENABLED:
            logger.info("[代理池] 代理功能已禁用")
            return
        
        for proxy_url in PROXY_POOL:
            proxy = ProxyInfo(url=proxy_url)
            self._proxies.append(proxy)
        
        logger.info(f"[代理池] 初始化完成，共 {len(self._proxies)} 个代理")
    
    def get_proxy(self) -> Optional[str]:
        """
        获取一个可用代理
        
        Returns:
            代理URL，无可用代理返回None
        """
        if not PROXY_ENABLED or not self._proxies:
            return None
        
        with self._lock:
            # 过滤存活代理
            alive_proxies = [p for p in self._proxies if p.is_alive]
            
            if not alive_proxies:
                logger.warning("[代理池] 无可用代理，将使用直连")
                return None
            
            # 随机选择代理
            proxy = random.choice(alive_proxies)
            proxy.last_used = time.time()
            self._current_proxy = proxy
            
            logger.debug(f"[代理池] 使用代理: {self._mask_proxy(proxy.url)}")
            return proxy.url
    
    def report_success(self, proxy_url: str):
        """
        报告代理使用成功，重置失败计数
        
        Args:
            proxy_url: 代理URL
        """
        with self._lock:
            for proxy in self._proxies:
                if proxy.url == proxy_url:
                    proxy.fail_count = 0
                    break
    
    def report_failure(self, proxy_url: str):
        """
        报告代理使用失败，增加失败计数
        
        Args:
            proxy_url: 代理URL
        """
        with self._lock:
            for proxy in self._proxies:
                if proxy.url == proxy_url:
                    proxy.fail_count += 1
                    if proxy.fail_count >= PROXY_MAX_FAILS:
                        proxy.is_alive = False
                        logger.warning(f"[代理池] 代理已失效: {self._mask_proxy(proxy.url)}")
                    break
    
    def test_proxy(self, proxy_url: str) -> bool:
        """
        测试代理是否可用
        
        Args:
            proxy_url: 代理URL
        
        Returns:
            是否可用
        """
        if not REQUESTS_AVAILABLE:
            logger.warning("[代理池] requests库未安装，无法测试代理")
            return False
        
        try:
            proxies = {
                "http": proxy_url,
                "https": proxy_url
            }
            response = requests.get(
                PROXY_TEST_URL, 
                proxies=proxies, 
                timeout=PROXY_TIMEOUT
            )
            return response.status_code == 200
        except Exception as e:
            logger.debug(f"[代理池] 代理测试失败: {self._mask_proxy(proxy_url)}, 错误: {e}")
            return False
    
    def test_all_proxies(self):
        """测试所有代理，更新存活状态"""
        if not REQUESTS_AVAILABLE:
            logger.warning("[代理池] requests库未安装，无法测试代理")
            return
        
        logger.info("[代理池] 开始测试所有代理...")
        for proxy in self._proxies:
            is_alive = self.test_proxy(proxy.url)
            proxy.is_alive = is_alive
            status = "可用" if is_alive else "不可用"
            logger.info(f"[代理池] 代理 {self._mask_proxy(proxy.url)}: {status}")
        
        alive_count = sum(1 for p in self._proxies if p.is_alive)
        logger.info(f"[代理池] 代理测试完成，可用: {alive_count}/{len(self._proxies)}")
    
    def rotate_proxy(self) -> Optional[str]:
        """
        切换到下一个可用代理
        
        Returns:
            新代理URL
        """
        if self._current_proxy:
            self.report_failure(self._current_proxy.url)
        return self.get_proxy()
    
    @staticmethod
    def _mask_proxy(proxy_url: str) -> str:
        """
        遮蔽代理URL中的敏感信息（用户名密码）
        
        Args:
            proxy_url: 原始URL
        
        Returns:
            遮蔽后的URL
        """
        # 遮蔽用户名密码
        return re.sub(r'(://[^:]+:)[^@]+(@)', r'\1****\2', proxy_url)
    
    def get_stats(self) -> Dict:
        """
        获取代理池统计信息
        
        Returns:
            统计信息字典
        """
        return {
            "total": len(self._proxies),
            "alive": sum(1 for p in self._proxies if p.is_alive),
            "dead": sum(1 for p in self._proxies if not p.is_alive),
            "enabled": PROXY_ENABLED
        }
    
    def parse_proxy_for_browser(self, proxy_url: str) -> Optional[Dict[str, str]]:
        """
        解析代理URL为浏览器可用的格式
        
        Args:
            proxy_url: 代理URL（格式：protocol://user:pass@host:port）
        
        Returns:
            包含server、username、password的字典，或仅server的字典
        """
        try:
            from urllib.parse import urlparse
            parsed = urlparse(proxy_url)
            
            result = {
                "server": f"{parsed.hostname}:{parsed.port}"
            }
            
            # 如果有认证信息
            if parsed.username and parsed.password:
                result["username"] = parsed.username
                result["password"] = parsed.password
            
            return result
        except Exception as e:
            logger.error(f"[代理池] 解析代理URL失败: {proxy_url}, 错误: {e}")
            return None


# 全局代理池实例
proxy_pool = ProxyPool()
