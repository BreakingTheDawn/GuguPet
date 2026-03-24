"""
流量限制模块
控制请求频率，防止被封
支持分钟级和小时级限制，以及自适应延迟

【合规说明】
本模块是爬虫合规性的重要组件，负责控制请求频率，避免对目标服务器造成过大压力。

功能说明：
1. 分钟级限制：默认每分钟最多10次请求（MAX_REQUESTS_PER_MINUTE = 10）
2. 小时级限制：默认每小时最多500次请求（MAX_REQUESTS_PER_HOUR = 500）
3. 自适应延迟：根据请求成功率自动调整延迟时间（3-30秒）
4. 错误率监控：记录错误次数，失败时自动增加延迟

合规原则：
- 限制请求频率，避免对目标服务器造成拒绝服务攻击
- 使用人性化的访问间隔，模拟真实用户行为
- 遇到错误时自动降速，给目标服务器缓冲时间
- 遵循《中华人民共和国网络安全法》关于不得干扰网络正常服务的要求

使用建议：
- 根据目标网站的负载能力调整限制参数
- 高峰期适当降低请求频率
- 监控错误率，及时调整爬取策略
"""
import time
import random
import threading
from collections import deque
from typing import Optional

from config.settings import (
    RATE_LIMIT_ENABLED, MAX_REQUESTS_PER_MINUTE, 
    MAX_REQUESTS_PER_HOUR, ADAPTIVE_DELAY_ENABLED,
    ADAPTIVE_DELAY_MIN, ADAPTIVE_DELAY_MAX
)
from utils.logger import logger


class RateLimiter:
    """
    流量限制器
    支持分钟级和小时级限制
    支持自适应延迟调整
    """
    
    def __init__(self):
        """初始化限制器"""
        self._minute_requests = deque()  # 分钟请求时间戳
        self._hour_requests = deque()    # 小时请求时间戳
        self._lock = threading.Lock()
        self._adaptive_delay = ADAPTIVE_DELAY_MIN
        self._error_count = 0
    
    def acquire(self) -> bool:
        """
        获取请求许可
        如果超过限制会阻塞等待
        
        Returns:
            是否获得许可
        """
        if not RATE_LIMIT_ENABLED:
            return True
        
        with self._lock:
            now = time.time()
            
            # 清理过期记录
            self._cleanup(now)
            
            # 检查分钟限制
            if len(self._minute_requests) >= MAX_REQUESTS_PER_MINUTE:
                wait_time = 60 - (now - self._minute_requests[0])
                if wait_time > 0:
                    logger.debug(f"[限流器] 达到分钟限制，等待 {wait_time:.1f} 秒")
                    time.sleep(wait_time)
            
            # 检查小时限制
            if len(self._hour_requests) >= MAX_REQUESTS_PER_HOUR:
                wait_time = 3600 - (now - self._hour_requests[0])
                if wait_time > 0:
                    logger.warning(f"[限流器] 达到小时限制，等待 {wait_time:.1f} 秒")
                    time.sleep(wait_time)
            
            # 记录请求
            self._minute_requests.append(now)
            self._hour_requests.append(now)
            
            return True
    
    def _cleanup(self, now: float):
        """清理过期记录"""
        # 清理分钟记录
        while self._minute_requests and now - self._minute_requests[0] > 60:
            self._minute_requests.popleft()
        
        # 清理小时记录
        while self._hour_requests and now - self._hour_requests[0] > 3600:
            self._hour_requests.popleft()
    
    def get_adaptive_delay(self) -> float:
        """
        获取自适应延迟时间
        
        Returns:
            延迟秒数
        """
        if not ADAPTIVE_DELAY_ENABLED:
            return ADAPTIVE_DELAY_MIN
        
        # 根据错误率调整延迟
        delay = min(self._adaptive_delay, ADAPTIVE_DELAY_MAX)
        return delay + random.uniform(0, 2)
    
    def report_success(self):
        """报告请求成功，降低延迟"""
        with self._lock:
            self._error_count = max(0, self._error_count - 1)
            # 成功时逐渐降低延迟
            self._adaptive_delay = max(
                ADAPTIVE_DELAY_MIN,
                self._adaptive_delay * 0.9
            )
    
    def report_error(self):
        """报告请求失败，增加延迟"""
        with self._lock:
            self._error_count += 1
            # 失败时增加延迟
            self._adaptive_delay = min(
                ADAPTIVE_DELAY_MAX,
                self._adaptive_delay * 1.5
            )
            logger.warning(f"[限流器] 请求失败，自适应延迟调整为 {self._adaptive_delay:.1f} 秒")
    
    def get_stats(self) -> dict:
        """
        获取统计信息
        
        Returns:
            统计信息字典
        """
        now = time.time()
        self._cleanup(now)
        
        return {
            "requests_last_minute": len(self._minute_requests),
            "requests_last_hour": len(self._hour_requests),
            "adaptive_delay": round(self._adaptive_delay, 1),
            "error_count": self._error_count
        }
    
    def reset(self):
        """重置限流器状态"""
        with self._lock:
            self._minute_requests.clear()
            self._hour_requests.clear()
            self._adaptive_delay = ADAPTIVE_DELAY_MIN
            self._error_count = 0


# 全局限流器实例
rate_limiter = RateLimiter()
