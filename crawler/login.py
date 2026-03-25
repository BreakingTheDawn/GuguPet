"""
手动登录脚本
用于在浏览器中手动登录各招聘网站，并保存Cookie

使用方法：
1. 运行此脚本：python login.py boss
2. 在打开的浏览器中手动完成登录
3. 登录成功后，按回车键保存Cookie
4. Cookie会加密保存到 cookies/ 目录

支持的平台：
- boss: Boss直聘
- zhilian: 智联招聘
- qiancheng: 前程无忧
"""
import sys
from pathlib import Path

from DrissionPage import ChromiumPage, ChromiumOptions
from core.secure_storage import secure_storage
from utils.logger import logger


# 平台登录URL配置
LOGIN_URLS = {
    "boss": "https://www.zhipin.com/web/user/?ka=header-login",
    "zhilian": "https://passport.zhaopin.com/login",
    "qiancheng": "https://login.51job.com/login.php",
}


def manual_login(platform: str):
    """
    手动登录指定平台
    
    Args:
        platform: 平台名称（boss/zhilian/qiancheng）
    """
    if platform not in LOGIN_URLS:
        logger.error(f"不支持的平台: {platform}")
        logger.info(f"支持的平台: {', '.join(LOGIN_URLS.keys())}")
        return False
    
    login_url = LOGIN_URLS[platform]
    domain = login_url.split("/")[2]
    
    logger.info("=" * 60)
    logger.info(f"手动登录脚本 | 平台: {platform}")
    logger.info("=" * 60)
    
    # 创建浏览器配置（完全启用图片）
    logger.info("正在启动浏览器（已启用图片加载）...")
    co = ChromiumOptions()
    
    # 基本配置
    co.set_argument('--disable-blink-features=AutomationControlled')
    co.set_argument('--no-sandbox')
    co.set_argument('--disable-dev-shm-usage')
    
    # 确保图片加载启用（设置为1表示允许图片）
    co.set_pref('profile.managed_default_content_settings.images', 1)
    
    # 创建浏览器页面
    page = ChromiumPage(co)
    
    try:
        # 访问登录页面
        logger.info(f"正在访问登录页面: {login_url}")
        page.get(login_url)
        
        # 提示用户手动登录
        logger.info("-" * 60)
        logger.info("请在浏览器中完成以下操作：")
        logger.info("1. 使用手机扫码或账号密码登录")
        logger.info("2. 如需验证码，请完成图片验证")
        logger.info("3. 确保登录成功后页面显示正常")
        logger.info("4. 登录成功后，回到此终端按回车键继续")
        logger.info("-" * 60)
        
        # 等待用户确认
        input("\n按回车键保存Cookie并退出...")
        
        # 保存Cookie
        cookies = page.cookies()
        cookie_dict = {c.get('name', ''): c for c in cookies if c.get('name')}
        
        if secure_storage.save_cookies(domain, cookie_dict):
            logger.info(f"[Cookie] 已加密保存: {domain}")
        else:
            # 降级保存
            COOKIE_DIR = Path(__file__).parent / "cookies"
            COOKIE_DIR.mkdir(parents=True, exist_ok=True)
            cookie_file = COOKIE_DIR / f"{domain}.txt"
            page.cookies.save(cookie_file)
            logger.info(f"[Cookie] 已保存: {domain}")
        
        logger.info("=" * 60)
        logger.info("Cookie保存成功！")
        logger.info(f"现在可以运行: python main.py {platform}")
        logger.info("=" * 60)
        
        return True
        
    except Exception as e:
        logger.error(f"登录过程出错: {e}")
        return False
    finally:
        page.quit()
        logger.info("浏览器已关闭")


def main():
    """主函数"""
    if len(sys.argv) < 2:
        print("用法: python login.py <platform>")
        print(f"支持的平台: {', '.join(LOGIN_URLS.keys())}")
        return
    
    platform = sys.argv[1].lower()
    manual_login(platform)


if __name__ == "__main__":
    main()
