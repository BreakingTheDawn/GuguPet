"""
异常告警模块
支持Webhook和邮件通知
"""
try:
    import requests
    REQUESTS_AVAILABLE = True
except ImportError:
    REQUESTS_AVAILABLE = False

from typing import Optional

from config.settings import (
    ALERT_ENABLED, ALERT_WEBHOOK_URL, ALERT_EMAIL,
    ALERT_ON_CAPTCHA, ALERT_ON_BLOCKED, ALERT_ON_ERROR_RATE
)
from utils.logger import logger


class Alerter:
    """
    告警器
    支持Webhook和邮件通知
    """
    
    def __init__(self):
        """初始化告警器"""
        self._error_count = 0
        self._total_count = 0
    
    def send_alert(self, title: str, message: str, level: str = "warning"):
        """
        发送告警
        
        Args:
            title: 告警标题
            message: 告警内容
            level: 告警级别（info/warning/error）
        """
        if not ALERT_ENABLED:
            return
        
        full_message = f"[{level.upper()}] {title}\n{message}"
        logger.warning(f"[告警] {full_message}")
        
        # Webhook通知
        if ALERT_WEBHOOK_URL and REQUESTS_AVAILABLE:
            self._send_webhook(title, message, level)
        
        # 邮件通知
        if ALERT_EMAIL:
            self._send_email(title, message)
    
    def _send_webhook(self, title: str, message: str, level: str):
        """发送Webhook通知"""
        try:
            payload = {
                "msgtype": "text",
                "text": {
                    "content": f"[爬虫告警] {title}\n{message}"
                }
            }
            requests.post(ALERT_WEBHOOK_URL, json=payload, timeout=5)
            logger.debug(f"[告警] Webhook通知已发送")
        except Exception as e:
            logger.error(f"[告警] 发送Webhook失败: {e}")
    
    def _send_email(self, title: str, message: str):
        """发送邮件通知（预留接口）"""
        # 实现邮件发送逻辑
        pass
    
    def report_request(self, is_error: bool = False):
        """
        报告请求结果
        
        Args:
            is_error: 是否为错误请求
        """
        self._total_count += 1
        if is_error:
            self._error_count += 1
        
        # 检查错误率
        if self._total_count > 10:
            error_rate = self._error_count / self._total_count
            if error_rate > ALERT_ON_ERROR_RATE:
                self.send_alert(
                    "错误率过高",
                    f"当前错误率: {error_rate:.1%}",
                    "error"
                )
    
    def alert_captcha(self, site: str):
        """
        验证码告警
        
        Args:
            site: 网站名称
        """
        if ALERT_ON_CAPTCHA:
            self.send_alert(
                "检测到验证码",
                f"网站: {site}\n请及时处理",
                "warning"
            )
    
    def alert_blocked(self, site: str, reason: str = ""):
        """
        被封告警
        
        Args:
            site: 网站名称
            reason: 被封原因
        """
        if ALERT_ON_BLOCKED:
            self.send_alert(
                "IP可能被封",
                f"网站: {site}\n原因: {reason}",
                "error"
            )
    
    def get_stats(self) -> dict:
        """
        获取统计信息
        
        Returns:
            统计信息字典
        """
        return {
            "total_requests": self._total_count,
            "error_count": self._error_count,
            "error_rate": self._error_count / self._total_count if self._total_count > 0 else 0
        }
    
    def reset(self):
        """重置统计"""
        self._error_count = 0
        self._total_count = 0


# 全局告警器实例
alerter = Alerter()
