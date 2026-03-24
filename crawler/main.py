"""
职位爬虫主入口
协调各爬虫执行爬取任务

================================================================================
【合规声明】
================================================================================
本爬虫系统仅用于个人学习和研究目的，严格遵守以下原则：

1. 合规性原则
   - 自动检查并遵守目标网站的 robots.txt 规则
   - 设置合理的请求频率限制（默认每分钟≤10次，每小时≤500次）
   - 使用自适应延迟机制，避免对目标服务器造成过大压力

2. 数据使用原则
   - 仅采集公开的职位信息，不涉及用户隐私数据
   - 采集的数据仅用于个人求职辅助，不用于商业用途
   - 不对采集的数据进行二次分发或出售

3. 技术规范
   - 使用合法的浏览器自动化工具（DrissionPage）
   - 不绕过网站的安全验证机制
   - 遇到验证码时暂停爬取，等待人工处理

4. 法律依据
   - 《中华人民共和国网络安全法》
   - 《中华人民共和国数据安全法》
   - 《互联网信息服务管理办法》

5. 免责声明
   - 使用者应自行确保爬取行为符合目标网站的服务条款
   - 因不当使用造成的法律责任由使用者自行承担
   - 本系统开发者不对任何滥用行为承担责任

================================================================================
使用前请确保：
- 已阅读并理解目标网站的服务条款
- 已配置合理的爬取频率和延迟参数
- 仅用于个人学习和研究目的
================================================================================
"""
import sys
from datetime import datetime

from config.settings import LOG_DIR
from config.cities import HOT_CITIES
from config.categories import get_all_keywords
from spiders.boss import BossSpider
from spiders.zhilian import ZhilianSpider
from spiders.qiancheng import QianchengSpider
from storage.database import db
from utils.logger import logger


def run_all_spiders():
    """
    运行所有爬虫
    """
    logger.info("="*60)
    logger.info(f"职位爬虫系统启动 | 时间: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    logger.info("="*60)
    
    # 获取配置
    cities = HOT_CITIES
    keywords = get_all_keywords()
    
    logger.info(f"目标城市: {', '.join(cities)}")
    logger.info(f"搜索关键词: {len(keywords)}个")
    logger.info("-"*60)
    
    # 爬虫列表
    spiders = [
        BossSpider(),
        ZhilianSpider(),
        QianchengSpider(),
    ]
    
    # 运行统计
    total_jobs = 0
    total_new = 0
    total_errors = 0
    
    # 依次运行爬虫
    for spider in spiders:
        try:
            logger.info(f"开始运行爬虫: {spider.name}")
            log = spider.run(keywords, cities)
            total_jobs += log.total_count
            total_new += log.new_count
            total_errors += log.error_count
        except Exception as e:
            logger.error(f"爬虫运行失败: {spider.name}, 错误: {e}")
            continue
    
    # 输出总结
    logger.info("="*60)
    logger.info("爬取任务全部完成")
    logger.info(f"总计爬取: {total_jobs}条 | 新增: {total_new}条 | 错误: {total_errors}个")
    logger.info(f"数据库职位总数: {db.get_job_count()}条")
    logger.info("="*60)


def run_single_spider(spider_name: str):
    """
    运行单个爬虫
    
    Args:
        spider_name: 爬虫名称（boss/zhilian/qiancheng）
    """
    spider_map = {
        'boss': BossSpider,
        'zhilian': ZhilianSpider,
        'qiancheng': QianchengSpider,
    }
    
    if spider_name not in spider_map:
        logger.error(f"未知的爬虫名称: {spider_name}")
        return
    
    cities = HOT_CITIES
    keywords = get_all_keywords()
    
    spider = spider_map[spider_name]()
    spider.run(keywords, cities)


def main():
    """
    主函数
    支持命令行参数指定运行特定爬虫
    """
    # 确保日志目录存在
    LOG_DIR.mkdir(parents=True, exist_ok=True)
    
    # 解析命令行参数
    if len(sys.argv) > 1:
        spider_name = sys.argv[1].lower()
        run_single_spider(spider_name)
    else:
        run_all_spiders()


if __name__ == "__main__":
    main()
