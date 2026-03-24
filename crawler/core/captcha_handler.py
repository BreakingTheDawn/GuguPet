"""
验证码处理模块
提供验证码检测、通知、自动处理功能

【合规说明】
本模块是爬虫合规性的重要保障，遇到验证码时的处理策略：

1. 检测到验证码时的行为：
   - 立即暂停爬取任务
   - 发送通知给使用者（支持Webhook）
   - 等待人工处理，不尝试自动绕过

2. 合规原则：
   - 不使用第三方验证码识别服务
   - 不尝试暴力破解或绕过验证码
   - 尊重网站的安全验证机制
   - 验证码是网站保护自身的重要手段

3. 法律依据：
   - 绕过验证码可能违反《中华人民共和国网络安全法》
   - 绕过验证码可能构成非法侵入计算机信息系统罪

4. 使用建议：
   - 配置Webhook通知，及时处理验证码
   - 合理设置请求频率，减少触发验证码的概率
   - 遇到频繁验证码时，考虑降低爬取频率或暂停爬取
"""
import time
import random
from typing import Optional, Tuple
from enum import Enum

try:
    import requests
    REQUESTS_AVAILABLE = True
except ImportError:
    REQUESTS_AVAILABLE = False

from config.settings import (
    CAPTCHA_AUTO_RETRY, CAPTCHA_MAX_WAIT, CAPTCHA_KEYWORDS,
    CAPTCHA_NOTIFY_ENABLED, CAPTCHA_NOTIFY_WEBHOOK
)
from utils.logger import logger


class CaptchaType(Enum):
    """验证码类型枚举"""
    UNKNOWN = "unknown"
    SLIDER = "slider"       # 滑块验证
    IMAGE = "image"         # 图形验证码
    CLICK = "click"         # 点击验证
    SMS = "sms"             # 短信验证


class CaptchaHandler:
    """
    验证码处理类
    支持检测、通知、自动处理
    """
    
    def __init__(self, engine):
        """
        初始化验证码处理器
        
        Args:
            engine: 爬虫引擎实例
        """
        self.engine = engine
        self._captcha_detected = False
        self._captcha_type = CaptchaType.UNKNOWN
    
    def detect_captcha(self) -> Tuple[bool, CaptchaType]:
        """
        检测页面是否出现验证码
        
        Returns:
            (是否检测到验证码, 验证码类型)
        """
        try:
            page_html = self.engine.page.html
            
            # 检测验证码关键词
            for keyword in CAPTCHA_KEYWORDS:
                if keyword in page_html:
                    self._captcha_detected = True
                    self._captcha_type = self._identify_captcha_type(page_html)
                    logger.warning(f"[验证码] 检测到验证码: {keyword}, 类型: {self._captcha_type.value}")
                    return True, self._captcha_type
            
            return False, CaptchaType.UNKNOWN
        except Exception as e:
            logger.error(f"[验证码] 检测失败: {e}")
            return False, CaptchaType.UNKNOWN
    
    def _identify_captcha_type(self, html: str) -> CaptchaType:
        """
        识别验证码类型
        
        Args:
            html: 页面HTML
        
        Returns:
            验证码类型
        """
        html_lower = html.lower()
        
        if '滑动' in html or 'slider' in html_lower:
            return CaptchaType.SLIDER
        elif '图形验证' in html or '输入验证码' in html:
            return CaptchaType.IMAGE
        elif '点击' in html and '验证' in html:
            return CaptchaType.CLICK
        elif '短信' in html or '手机' in html:
            return CaptchaType.SMS
        
        return CaptchaType.UNKNOWN
    
    def handle_captcha(self) -> bool:
        """
        处理验证码
        
        Returns:
            是否处理成功
        """
        if not self._captcha_detected:
            return True
        
        # 发送通知
        self._send_notification()
        
        # 根据类型处理
        if self._captcha_type == CaptchaType.SLIDER:
            return self._handle_slider_captcha()
        elif self._captcha_type == CaptchaType.IMAGE:
            return self._handle_image_captcha()
        else:
            return self._handle_manual()
    
    def _handle_slider_captcha(self) -> bool:
        """
        处理滑块验证码
        
        Returns:
            是否处理成功
        """
        logger.info("[验证码] 尝试自动处理滑块验证码...")
        
        try:
            # 查找滑块元素（需要根据具体网站调整）
            slider_selectors = [
                '.slide-verify-slider',
                '.slider-btn',
                '[class*="slider"]',
                '.secsdk-captcha-drag-icon',
                '.tc-slider-normal',
            ]
            
            for selector in slider_selectors:
                try:
                    slider = self.engine.page.ele(f'css:{selector}')
                    if slider:
                        # 模拟人类拖动
                        return self._simulate_slider_drag(slider)
                except Exception:
                    continue
            
            # 自动处理失败，等待人工
            return self._handle_manual()
            
        except Exception as e:
            logger.error(f"[验证码] 滑块验证码处理失败: {e}")
            return self._handle_manual()
    
    def _simulate_slider_drag(self, slider_element) -> bool:
        """
        模拟滑块拖动
        
        Args:
            slider_element: 滑块元素
        
        Returns:
            是否成功
        """
        try:
            # 计算拖动距离（通常需要根据验证码背景图计算）
            drag_distance = random.randint(200, 300)
            
            # 模拟人类拖动轨迹
            actions = self.engine.page.actions
            
            # 按住滑块
            actions.move_to(slider_element).hold()
            
            # 分段移动（模拟人类行为）
            steps = random.randint(10, 20)
            for i in range(steps):
                move_x = drag_distance // steps + random.randint(-5, 5)
                actions.move(move_x, random.randint(-2, 2))
                time.sleep(random.uniform(0.01, 0.05))
            
            # 释放滑块
            actions.release()
            
            logger.info("[验证码] 滑块验证码已尝试自动处理")
            time.sleep(2)  # 等待验证结果
            
            # 检查是否通过
            detected, _ = self.detect_captcha()
            return not detected
            
        except Exception as e:
            logger.error(f"[验证码] 模拟滑块拖动失败: {e}")
            return False
    
    def _handle_image_captcha(self) -> bool:
        """
        处理图形验证码
        
        Returns:
            是否处理成功
        """
        logger.info("[验证码] 图形验证码需要人工处理")
        return self._handle_manual()
    
    def _handle_manual(self) -> bool:
        """
        等待人工处理验证码
        
        Returns:
            是否处理成功
        """
        logger.warning(f"[验证码] 等待人工处理验证码，最长等待 {CAPTCHA_MAX_WAIT} 秒...")
        
        start_time = time.time()
        
        while time.time() - start_time < CAPTCHA_MAX_WAIT:
            # 检查验证码是否消失
            detected, _ = self.detect_captcha()
            if not detected:
                logger.info("[验证码] 验证码已通过")
                return True
            
            # 每秒检查一次
            time.sleep(1)
            remaining = int(CAPTCHA_MAX_WAIT - (time.time() - start_time))
            if remaining % 30 == 0:  # 每30秒提示一次
                logger.info(f"[验证码] 等待中，剩余 {remaining} 秒...")
        
        logger.error("[验证码] 验证码处理超时")
        return False
    
    def _send_notification(self):
        """发送验证码通知"""
        if not CAPTCHA_NOTIFY_ENABLED:
            return
        
        message = f"[爬虫告警] 检测到验证码\n类型: {self._captcha_type.value}\n请及时处理"
        
        # Webhook通知
        if CAPTCHA_NOTIFY_WEBHOOK and REQUESTS_AVAILABLE:
            try:
                requests.post(CAPTCHA_NOTIFY_WEBHOOK, json={"text": message}, timeout=5)
                logger.info("[验证码] 通知已发送")
            except Exception as e:
                logger.error(f"[验证码] 发送通知失败: {e}")
        
        logger.warning(message)
    
    def reset(self):
        """重置验证码状态"""
        self._captcha_detected = False
        self._captcha_type = CaptchaType.UNKNOWN


def create_captcha_handler(engine):
    """
    创建验证码处理器
    
    Args:
        engine: 爬虫引擎实例
    
    Returns:
        CaptchaHandler实例
    """
    return CaptchaHandler(engine)
