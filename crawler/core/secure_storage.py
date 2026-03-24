"""
安全存储模块
提供Cookie加密存储功能
使用Fernet对称加密保护Cookie数据

【合规说明】
本模块提供Cookie的安全存储功能，保护用户隐私：

1. 安全特性：
   - 使用Fernet对称加密算法
   - Cookie数据加密后存储在本地
   - 防止Cookie被恶意程序窃取

2. 隐私保护：
   - Cookie包含敏感的会话信息
   - 加密存储防止信息泄露
   - 符合《个人信息保护法》的要求

3. 使用说明：
   - 首次使用需生成加密密钥
   - 密钥应妥善保管，不要提交到代码仓库
   - 密钥丢失将无法解密已存储的Cookie

4. 安全建议：
   - 定期更换加密密钥
   - 不要在公共计算机上存储Cookie
   - 使用完毕后及时清理Cookie数据
"""
import json
from pathlib import Path
from typing import Optional, Dict

try:
    from cryptography.fernet import Fernet
    CRYPTO_AVAILABLE = True
except ImportError:
    CRYPTO_AVAILABLE = False

from config.settings import (
    COOKIE_DIR, COOKIE_ENCRYPTION_KEY, COOKIE_ENCRYPTION_ENABLED
)
from utils.logger import logger


class SecureCookieStorage:
    """
    安全Cookie存储类
    使用Fernet对称加密保护Cookie数据
    """
    
    def __init__(self):
        """初始化加密存储"""
        self._cipher = None
        self._init_cipher()
    
    def _init_cipher(self):
        """初始化加密器"""
        if not COOKIE_ENCRYPTION_ENABLED:
            logger.info("[安全存储] Cookie加密功能已禁用")
            return
        
        if not CRYPTO_AVAILABLE:
            logger.warning("[安全存储] cryptography库未安装，将使用明文存储")
            return
        
        try:
            # 使用配置的密钥
            key = COOKIE_ENCRYPTION_KEY.encode()
            # 确保密钥格式正确（Fernet key base64编码后长度为44）
            if len(key) == 44:
                self._cipher = Fernet(key)
                logger.info("[安全存储] Cookie加密器初始化成功")
            else:
                logger.warning("[安全存储] Cookie加密密钥格式错误，将使用明文存储")
                self._cipher = None
        except Exception as e:
            logger.error(f"[安全存储] Cookie加密器初始化失败: {e}")
            self._cipher = None
    
    def save_cookies(self, domain: str, cookies: Dict) -> bool:
        """
        安全保存Cookie
        
        Args:
            domain: 域名
            cookies: Cookie字典
        
        Returns:
            是否保存成功
        """
        try:
            COOKIE_DIR.mkdir(parents=True, exist_ok=True)
            
            data = json.dumps(cookies, ensure_ascii=False)
            
            if self._cipher and COOKIE_ENCRYPTION_ENABLED:
                # 加密存储
                cookie_file = COOKIE_DIR / f"{domain}.enc"
                encrypted = self._cipher.encrypt(data.encode())
                cookie_file.write_bytes(encrypted)
                logger.debug(f"[安全存储] Cookie已加密保存: {domain}")
            else:
                # 明文存储（降级方案）
                cookie_file = COOKIE_DIR / f"{domain}.txt"
                cookie_file.write_text(data, encoding='utf-8')
                logger.debug(f"[安全存储] Cookie已保存（明文）: {domain}")
            
            return True
        except Exception as e:
            logger.error(f"[安全存储] 保存Cookie失败: {domain}, 错误: {e}")
            return False
    
    def load_cookies(self, domain: str) -> Optional[Dict]:
        """
        安全加载Cookie
        
        Args:
            domain: 域名
        
        Returns:
            Cookie字典，失败返回None
        """
        try:
            # 优先尝试加密文件
            cookie_file_enc = COOKIE_DIR / f"{domain}.enc"
            cookie_file_txt = COOKIE_DIR / f"{domain}.txt"
            
            if cookie_file_enc.exists() and self._cipher:
                # 加载加密文件
                encrypted = cookie_file_enc.read_bytes()
                decrypted = self._cipher.decrypt(encrypted)
                cookies = json.loads(decrypted.decode())
                logger.debug(f"[安全存储] Cookie已解密加载: {domain}")
                return cookies
            elif cookie_file_txt.exists():
                # 加载明文文件（兼容旧数据）
                data = cookie_file_txt.read_text(encoding='utf-8')
                cookies = json.loads(data)
                logger.debug(f"[安全存储] Cookie已加载（明文）: {domain}")
                return cookies
            else:
                return None
        except Exception as e:
            logger.error(f"[安全存储] 加载Cookie失败: {domain}, 错误: {e}")
            return None
    
    def delete_cookies(self, domain: str) -> bool:
        """
        删除Cookie文件
        
        Args:
            domain: 域名
        
        Returns:
            是否删除成功
        """
        try:
            for ext in ['.enc', '.txt']:
                cookie_file = COOKIE_DIR / f"{domain}{ext}"
                if cookie_file.exists():
                    cookie_file.unlink()
            logger.debug(f"[安全存储] Cookie已删除: {domain}")
            return True
        except Exception as e:
            logger.error(f"[安全存储] 删除Cookie失败: {domain}, 错误: {e}")
            return False
    
    def migrate_to_encrypted(self):
        """
        将明文Cookie迁移到加密存储
        需要在加密器初始化成功后调用
        """
        if not self._cipher:
            logger.warning("[安全存储] 加密器未初始化，无法迁移")
            return
        
        migrated = 0
        for cookie_file in COOKIE_DIR.glob("*.txt"):
            domain = cookie_file.stem
            cookies = self.load_cookies(domain)
            if cookies:
                self.save_cookies(domain, cookies)
                cookie_file.unlink()  # 删除明文文件
                migrated += 1
        
        logger.info(f"[安全存储] Cookie迁移完成，共迁移 {migrated} 个文件")
    
    def is_encryption_available(self) -> bool:
        """
        检查加密功能是否可用
        
        Returns:
            加密功能是否可用
        """
        return self._cipher is not None


# 全局安全存储实例
secure_storage = SecureCookieStorage()
