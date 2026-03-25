"""
爬虫基类模块
定义所有爬虫的通用接口和公共方法

【合规说明】
本模块是爬虫系统的核心基类，所有具体爬虫实现都应继承此类。
基类内置了以下合规机制：
- robots.txt检查：通过robots_checker模块自动检查目标网站是否允许爬取
- 流量控制：通过rate_limiter模块限制请求频率
- 反检测机制：通过anti_detect模块实现人性化的访问行为
- 验证码处理：遇到验证码时暂停，等待人工处理

使用本模块开发的爬虫应遵守：
1. 仅爬取公开数据，不涉及用户隐私
2. 遵守目标网站的robots.txt规则
3. 设置合理的请求延迟，避免对服务器造成压力
"""
from abc import ABC, abstractmethod
from typing import List, Optional
import uuid
from datetime import datetime

from core.engine import CrawlerEngine
from core.anti_detect import anti_detect
from core.captcha_handler import create_captcha_handler
from storage.database import db
from storage.models import Job, CrawlLog
from utils.logger import CrawlLogger, logger
from config.settings import JOBS_PER_KEYWORD, MAX_PAGES, MAX_RETRIES


class BaseSpider(ABC):
    """
    爬虫基类
    定义爬虫的通用接口
    """
    
    # 子类需要覆盖的属性
    name: str = "base"
    base_url: str = ""
    
    def __init__(self, engine: CrawlerEngine = None):
        """
        初始化爬虫
        
        Args:
            engine: 爬虫引擎实例
        """
        self.engine = engine or CrawlerEngine()
        self.crawl_logger = CrawlLogger(self.name)
        self.current_keyword = None
        self.current_city = None
    
    @abstractmethod
    def search(self, keyword: str, city: str) -> bool:
        """
        搜索职位
        
        Args:
            keyword: 搜索关键词
            city: 城市
        
        Returns:
            是否成功进入搜索结果页
        """
        pass
    
    @abstractmethod
    def parse_job_list(self) -> List[Job]:
        """
        解析职位列表页
        
        Returns:
            职位列表
        """
        pass
    
    @abstractmethod
    def get_next_page(self) -> bool:
        """
        获取下一页
        
        Returns:
            是否成功翻页
        """
        pass
    
    def generate_job_id(self, source_id: str) -> str:
        """
        生成职位唯一ID
        
        Args:
            source_id: 来源网站的职位ID
        
        Returns:
            唯一ID（格式：{spider_name}_{source_id}）
        """
        return f"{self.name}_{source_id}"
    
    def crawl_keyword(self, keyword: str, city: str) -> tuple:
        """
        爬取单个关键词的职位
        
        Args:
            keyword: 搜索关键词
            city: 城市
        
        Returns:
            (总数量, 新增数量)
        """
        self.current_keyword = keyword
        self.current_city = city
        self.crawl_logger.start_keyword(keyword, city)
        
        all_jobs = []
        page = 1
        
        # 尝试搜索
        for retry in range(MAX_RETRIES):
            try:
                if self.search(keyword, city):
                    break
            except Exception as e:
                self.crawl_logger.warning(f"搜索失败，重试 {retry + 1}/{MAX_RETRIES}: {e}")
                anti_detect.sleep_retry(retry)
        else:
            self.crawl_logger.error("搜索失败，已达到最大重试次数")
            return 0, 0
        
        # 检测验证码（使用新的处理器）
        captcha_handler = create_captcha_handler(self.engine)
        detected, captcha_type = captcha_handler.detect_captcha()
        
        if detected:
            self.crawl_logger.warning(f"检测到验证码: {captcha_type.value}")
            
            # 尝试处理验证码
            if not captcha_handler.handle_captcha():
                self.crawl_logger.error("验证码处理失败，跳过当前关键词")
                return 0, 0
            
            # 处理成功后继续
        
        # 爬取职位（支持翻页或无限滚动）
        try:
            # 解析职位列表（Boss直聘使用无限滚动，在parse_job_list中处理）
            jobs = self.parse_job_list()
            all_jobs.extend(jobs)
            
            # 对于需要翻页的网站，继续翻页
            page = 1
            while page <= MAX_PAGES and len(all_jobs) < JOBS_PER_KEYWORD:
                # 尝试翻页
                anti_detect.sleep(is_page=True)
                
                if not self.get_next_page():
                    break
                
                # 解析下一页
                jobs = self.parse_job_list()
                all_jobs.extend(jobs)
                
                page += 1
                
        except Exception as e:
            self.crawl_logger.error(f"解析职位失败: {e}")
        
        # 保存数据（限制数量）
        jobs_to_save = all_jobs[:JOBS_PER_KEYWORD]
        new_count = db.save_jobs_batch(jobs_to_save)
        self.crawl_logger.end_keyword(len(all_jobs), new_count)
        
        return len(all_jobs), new_count
    
    def run(self, keywords: List[str], cities: List[str]) -> CrawlLog:
        """
        运行爬虫
        
        Args:
            keywords: 搜索关键词列表
            cities: 城市列表
        
        Returns:
            爬取日志
        """
        from config.categories import get_category_by_keyword, CATEGORIES
        from config.settings import JOBS_PER_KEYWORD
        
        self.crawl_logger.start()
        
        # 初始化浏览器
        self.engine.init_browser()
        
        # 加载已保存的Cookie
        from urllib.parse import urlparse
        domain = urlparse(self.base_url).netloc
        if self.engine.load_cookies(domain):
            logger.info(f"[Cookie] 已加载: {domain}")
        
        try:
            # 按类别遍历，每个类别爬取一定数量后跳到下一个类别
            for category, category_keywords in CATEGORIES.items():
                # 检查该类别是否已经有足够的职位
                current_count = db.get_job_count_by_category(category)
                today_new = db.get_today_job_count_by_category(category)
                
                logger.info(f"[类别] {category}: 当前总数 {current_count}, 今日新增 {today_new}")
                
                # 如果该类别已经有足够的职位，跳过
                if current_count >= JOBS_PER_KEYWORD:
                    logger.info(f"[类别] {category} 已有 {current_count} 个职位，跳过")
                    continue
                
                # 如果今天已经新增了一些，也跳过（避免重复爬取）
                if today_new >= 10:
                    logger.info(f"[类别] {category} 今日已新增 {today_new} 个职位，跳过")
                    continue
                
                # 需要爬取的数量
                need_count = JOBS_PER_KEYWORD - current_count
                logger.info(f"[类别] {category} 还需要爬取 {need_count} 个职位")
                
                # 遍历该类别下的关键词
                for keyword in category_keywords:
                    for city in cities:
                        try:
                            total, new = self.crawl_keyword(keyword, city)
                            
                            # 检查是否已经爬取足够
                            current_count = db.get_job_count_by_category(category)
                            if current_count >= JOBS_PER_KEYWORD:
                                logger.info(f"[类别] {category} 已达到目标数量 {JOBS_PER_KEYWORD}，跳到下一个类别")
                                break
                            
                            # 关键词之间的延迟
                            anti_detect.sleep()
                        except Exception as e:
                            self.crawl_logger.error(f"爬取失败: {keyword} @ {city}: {e}")
                            continue
                    
                    # 检查类别是否已达到目标
                    current_count = db.get_job_count_by_category(category)
                    if current_count >= JOBS_PER_KEYWORD:
                        break
        finally:
            self.engine.close()
        
        self.crawl_logger.end()
        
        # 保存爬取日志
        log = CrawlLog(
            id=str(uuid.uuid4()),
            spider_name=self.name,
            total_count=self.crawl_logger.total_count,
            new_count=self.crawl_logger.new_count,
            error_count=self.crawl_logger.error_count,
            start_time=self.crawl_logger.start_time.isoformat() if self.crawl_logger.start_time else None,
            end_time=self.crawl_logger.end_time.isoformat() if self.crawl_logger.end_time else None,
            duration_seconds=int((self.crawl_logger.end_time - self.crawl_logger.start_time).total_seconds()) if self.crawl_logger.start_time and self.crawl_logger.end_time else 0
        )
        db.save_crawl_log(log)
        
        return log
