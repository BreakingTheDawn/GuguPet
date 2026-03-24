"""
前程无忧爬虫
实现前程无忧网站的职位爬取

【合规声明】
本爬虫仅用于个人学习和研究目的，使用前请确保：
1. 已阅读并理解前程无忧的服务条款和robots.txt规则
2. 仅爬取公开的职位信息，不涉及用户隐私数据
3. 设置合理的请求频率，避免对服务器造成压力
4. 采集的数据仅用于个人求职辅助，不用于商业用途

robots.txt参考：https://www.51job.com/robots.txt
建议爬取时间：非高峰时段（如凌晨或深夜）
建议请求间隔：≥5秒
"""
import re
from typing import List
from urllib.parse import quote

from spiders.base import BaseSpider
from storage.models import Job
from config.cities import get_city_code
from utils.logger import logger


class QianchengSpider(BaseSpider):
    """
    前程无忧爬虫类
    """
    
    name = "qiancheng"
    base_url = "https://www.51job.com"
    
    def search(self, keyword: str, city: str) -> bool:
        """
        搜索职位
        
        Args:
            keyword: 搜索关键词
            city: 城市
        
        Returns:
            是否成功进入搜索结果页
        """
        city_code = get_city_code("qiancheng", city)
        if not city_code:
            logger.warning(f"未找到城市编码: {city}")
            city_code = "010000"  # 默认北京
        
        # 构建搜索URL
        search_url = f"{self.base_url}/sc/{city_code}_000000_000000_0_{quote(keyword)}_1_1.html"
        
        # 导航到搜索页面
        self.engine.navigate(search_url)
        
        # 等待职位列表加载
        return self.engine.wait_for_element('.j_joblist', timeout=10)
    
    def parse_job_list(self) -> List[Job]:
        """
        解析职位列表页
        
        Returns:
            职位列表
        """
        jobs = []
        
        # 获取职位卡片列表
        job_cards = self.engine.get_elements('.j_joblist .e')
        
        for card in job_cards:
            try:
                job = self._parse_job_card(card)
                if job:
                    jobs.append(job)
            except Exception as e:
                logger.debug(f"解析职位卡片失败: {e}")
                continue
        
        return jobs
    
    def _parse_job_card(self, card) -> Job:
        """
        解析单个职位卡片
        
        Args:
            card: 职位卡片元素
        
        Returns:
            职位数据
        """
        # 获取职位链接
        job_link = card.ele('css:.t a')
        if not job_link:
            return None
        
        href = job_link.attr('href') or ''
        
        # 从URL中提取职位ID
        job_id_match = re.search(r'/(\d+)\.html', href)
        if not job_id_match:
            return None
        
        source_id = job_id_match.group(1)
        job_id = self.generate_job_id(source_id)
        
        # 获取职位标题
        title = job_link.attr('title') or job_link.text.strip()
        
        # 获取薪资
        salary_elem = card.ele('css:.sal')
        salary = salary_elem.text.strip() if salary_elem else None
        
        # 获取公司名称
        company_elem = card.ele('css:.er a')
        company = company_elem.text.strip() if company_elem else "未知公司"
        
        # 获取工作地点
        location_elem = card.ele('css:.d')
        location = location_elem.text.strip() if location_elem else None
        
        # 获取标签信息
        tag_elems = card.eles('css:.ttag span')
        experience = None
        education = None
        tags = []
        
        for i, tag in enumerate(tag_elems):
            tag_text = tag.text.strip()
            tags.append(tag_text)
            
            # 尝试识别经验和学历
            if '经验' in tag_text or '-' in tag_text and '年' in tag_text:
                experience = tag_text
            elif any(edu in tag_text for edu in ['本科', '硕士', '博士', '大专', '学历']):
                education = tag_text
        
        # 获取福利标签
        welfare_elems = card.eles('css:.tag span')
        welfare_tags = [elem.text.strip() for elem in welfare_elems if elem.text.strip()]
        tags.extend(welfare_tags)
        
        # 构建完整URL
        source_url = href if href.startswith('http') else f"{self.base_url}{href}"
        
        return Job(
            id=job_id,
            title=title,
            company=company,
            salary=salary,
            location=location,
            category=self.current_keyword,
            experience=experience,
            education=education,
            tags=tags if tags else None,
            source=self.name,
            source_url=source_url,
        )
    
    def get_next_page(self) -> bool:
        """
        获取下一页
        
        Returns:
            是否成功翻页
        """
        # 查找下一页按钮
        next_btn = self.engine.page.ele('css:.next')
        
        if next_btn and 'disabled' not in (next_btn.attr('class') or ''):
            self.engine._simulate_human_click(next_btn)
            self.engine.page.wait.doc_loaded()
            return True
        
        return False
