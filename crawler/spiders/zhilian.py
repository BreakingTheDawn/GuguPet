"""
智联招聘爬虫
实现智联招聘网站的职位爬取

【合规声明】
本爬虫仅用于个人学习和研究目的，使用前请确保：
1. 已阅读并理解智联招聘的服务条款和robots.txt规则
2. 仅爬取公开的职位信息，不涉及用户隐私数据
3. 设置合理的请求频率，避免对服务器造成压力
4. 采集的数据仅用于个人求职辅助，不用于商业用途

robots.txt参考：https://www.zhaopin.com/robots.txt
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


class ZhilianSpider(BaseSpider):
    """
    智联招聘爬虫类
    """
    
    name = "zhilian"
    base_url = "https://www.zhaopin.com"
    
    def search(self, keyword: str, city: str) -> bool:
        """
        搜索职位
        
        Args:
            keyword: 搜索关键词
            city: 城市
        
        Returns:
            是否成功进入搜索结果页
        """
        city_code = get_city_code("zhilian", city)
        if not city_code:
            logger.warning(f"未找到城市编码: {city}")
            city_code = "530"  # 默认北京
        
        # 构建搜索URL
        search_url = f"{self.base_url}/sou?jl={city_code}&kw={quote(keyword)}"
        
        # 导航到搜索页面
        self.engine.navigate(search_url)
        
        # 等待职位列表加载
        return self.engine.wait_for_element('.joblist-box__item', timeout=10)
    
    def parse_job_list(self) -> List[Job]:
        """
        解析职位列表页
        
        Returns:
            职位列表
        """
        jobs = []
        
        # 获取职位卡片列表
        job_cards = self.engine.get_elements('.joblist-box__item')
        
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
        job_link = card.ele('css:.jobinfo__top a')
        if not job_link:
            return None
        
        href = job_link.attr('href') or ''
        
        # 从URL中提取职位ID
        job_id_match = re.search(r'/jobs/(\d+)\.html', href)
        if not job_id_match:
            # 尝试另一种URL格式
            job_id_match = re.search(r'jobid=(\d+)', href)
        
        if not job_id_match:
            return None
        
        source_id = job_id_match.group(1)
        job_id = self.generate_job_id(source_id)
        
        # 获取职位标题
        title = job_link.text.strip()
        
        # 获取薪资
        salary_elem = card.ele('css:.jobinfo__salary')
        salary = salary_elem.text.strip() if salary_elem else None
        
        # 获取公司名称
        company_elem = card.ele('css:.companyinfo__top a')
        company = company_elem.text.strip() if company_elem else "未知公司"
        
        # 获取工作地点
        location_elem = card.ele('css:.jobinfo__other .iteminfo__line--city')
        location = location_elem.text.strip() if location_elem else None
        
        # 获取经验和学历要求
        exp_elem = card.ele('css:.jobinfo__other .iteminfo__line--exp')
        experience = exp_elem.text.strip() if exp_elem else None
        
        edu_elem = card.ele('css:.jobinfo__other .iteminfo__line--edu')
        education = edu_elem.text.strip() if edu_elem else None
        
        # 获取福利标签
        welfare_elems = card.eles('css:.jobinfo__tag .jobinfo__tag-item')
        tags = [elem.text.strip() for elem in welfare_elems if elem.text.strip()]
        
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
        next_btn = self.engine.page.ele('css:.soupager__next')
        
        if next_btn and 'soupager__next--disabled' not in (next_btn.attr('class') or ''):
            self.engine._simulate_human_click(next_btn)
            self.engine.page.wait.doc_loaded()
            return True
        
        return False
