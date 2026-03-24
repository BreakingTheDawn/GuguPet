"""
日志工具模块
提供统一的日志记录功能

【合规说明】
本模块提供爬虫运行日志的记录功能：
1. 日志记录爬虫运行状态，便于调试和监控
2. 日志文件存储在本地，不上传到服务器
3. 日志中不应包含敏感信息（如Cookie、密码等）
4. 定期清理过期日志，避免占用过多磁盘空间

日志安全建议：
- 不要在日志中记录敏感信息
- 日志文件应设置适当的访问权限
- 定期归档和清理日志文件
"""
import logging
import sys
from pathlib import Path
from datetime import datetime

from config.settings import LOG_DIR, LOG_FILE, LOG_LEVEL, LOG_FORMAT, LOG_DATE_FORMAT


def setup_logger(name: str = "crawler") -> logging.Logger:
    """
    设置并返回日志记录器
    
    Args:
        name: 日志记录器名称
    
    Returns:
        配置好的日志记录器
    """
    # 确保日志目录存在
    LOG_DIR.mkdir(parents=True, exist_ok=True)
    
    # 创建日志记录器
    logger = logging.getLogger(name)
    logger.setLevel(getattr(logging, LOG_LEVEL))
    
    # 避免重复添加handler
    if logger.handlers:
        return logger
    
    # 文件处理器
    file_handler = logging.FileHandler(
        LOG_FILE,
        encoding="utf-8",
        mode="a"
    )
    file_handler.setLevel(logging.DEBUG)
    file_handler.setFormatter(logging.Formatter(LOG_FORMAT, LOG_DATE_FORMAT))
    
    # 控制台处理器
    console_handler = logging.StreamHandler(sys.stdout)
    console_handler.setLevel(logging.INFO)
    console_handler.setFormatter(logging.Formatter(LOG_FORMAT, LOG_DATE_FORMAT))
    
    # 添加处理器
    logger.addHandler(file_handler)
    logger.addHandler(console_handler)
    
    return logger


# 全局日志记录器
logger = setup_logger()


class CrawlLogger:
    """
    爬取日志记录器
    用于记录爬取过程中的详细信息
    """
    
    def __init__(self, spider_name: str):
        """
        初始化爬取日志记录器
        
        Args:
            spider_name: 爬虫名称
        """
        self.spider_name = spider_name
        self.start_time = None
        self.end_time = None
        self.total_count = 0
        self.new_count = 0
        self.error_count = 0
        self.current_keyword = None
        self.current_city = None
    
    def start(self):
        """记录爬取开始"""
        self.start_time = datetime.now()
        logger.info(f"{'='*60}")
        logger.info(f"开始爬取任务 | 爬虫: {self.spider_name}")
        logger.info(f"{'='*60}")
    
    def end(self):
        """记录爬取结束"""
        self.end_time = datetime.now()
        duration = (self.end_time - self.start_time).total_seconds()
        
        logger.info(f"{'='*60}")
        logger.info(f"爬取任务完成 | 爬虫: {self.spider_name}")
        logger.info(f"总计: {self.total_count}条 | 新增: {self.new_count}条 | 错误: {self.error_count}条")
        logger.info(f"耗时: {duration:.1f}秒")
        logger.info(f"{'='*60}")
    
    def start_keyword(self, keyword: str, city: str):
        """记录开始爬取某个关键词"""
        self.current_keyword = keyword
        self.current_city = city
        logger.info(f"{self.spider_name} | {city} | {keyword} | 开始爬取")
    
    def end_keyword(self, count: int, new_count: int):
        """记录完成爬取某个关键词"""
        self.total_count += count
        self.new_count += new_count
        logger.info(f"{self.spider_name} | {self.current_city} | {self.current_keyword} | 爬取完成，共{count}条，新增{new_count}条")
    
    def error(self, message: str):
        """记录错误"""
        self.error_count += 1
        logger.error(f"{self.spider_name} | {self.current_city} | {self.current_keyword} | {message}")
    
    def warning(self, message: str):
        """记录警告"""
        logger.warning(f"{self.spider_name} | {self.current_city} | {self.current_keyword} | {message}")
    
    def info(self, message: str):
        """记录信息"""
        logger.info(f"{self.spider_name} | {message}")
