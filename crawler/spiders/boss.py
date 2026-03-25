"""
Boss直聘爬虫
实现Boss直聘网站的职位爬取

【合规声明】
本爬虫仅用于个人学习和研究目的，使用前请确保：
1. 已阅读并理解Boss直聘的服务条款和robots.txt规则
2. 仅爬取公开的职位信息，不涉及用户隐私数据
3. 设置合理的请求频率，避免对服务器造成压力
4. 采集的数据仅用于个人求职辅助，不用于商业用途

robots.txt参考：https://www.zhipin.com/robots.txt
建议爬取时间：非高峰时段（如凌晨或深夜）
建议请求间隔：≥5秒
"""
import re
import time
from typing import List
from urllib.parse import quote

from spiders.base import BaseSpider
from storage.models import Job
from config.cities import get_city_code
from utils.logger import logger


# Boss直聘字体反爬解码映射
# 这些PUA字符是Boss直聘用来混淆薪资显示的
BOSS_FONT_MAP = {
    '\ue000': '0', '\ue001': '1', '\ue002': '2', '\ue003': '3', '\ue004': '4',
    '\ue005': '5', '\ue006': '6', '\ue007': '7', '\ue008': '8', '\ue009': '9',
    '\ue00a': '0', '\ue00b': '1', '\ue00c': '2', '\ue00d': '3', '\ue00e': '4',
    '\ue00f': '5', '\ue010': '6', '\ue011': '7', '\ue012': '8', '\ue013': '9',
    '\ue014': '0', '\ue015': '1', '\ue016': '2', '\ue017': '3', '\ue018': '4',
    '\ue019': '5', '\ue01a': '6', '\ue01b': '7', '\ue01c': '8', '\ue01d': '9',
    '\ue01e': '0', '\ue01f': '1', '\ue020': '2', '\ue021': '3', '\ue022': '4',
    '\ue023': '5', '\ue024': '6', '\ue025': '7', '\ue026': '8', '\ue027': '9',
    '\ue028': '0', '\ue029': '1', '\ue02a': '2', '\ue02b': '3', '\ue02c': '4',
    '\ue02d': '5', '\ue02e': '6', '\ue02f': '7', '\ue030': '8', '\ue031': '9',
    '\ue032': '0', '\ue033': '1', '\ue034': '2', '\ue035': '3', '\ue036': '4',
    '\ue037': '5', '\ue038': '6', '\ue039': '7', '\ue03a': '8', '\ue03b': '9',
    '\ue03c': '0', '\ue03d': '1', '\ue03e': '2', '\ue03f': '3', '\ue040': '4',
    '\ue041': '5', '\ue042': '6', '\ue043': '7', '\ue044': '8', '\ue045': '9',
    '\ue046': '0', '\ue047': '1', '\ue048': '2', '\ue049': '3', '\ue04a': '4',
    '\ue04b': '5', '\ue04c': '6', '\ue04d': '7', '\ue04e': '8', '\ue04f': '9',
    '\ue050': '0', '\ue051': '1', '\ue052': '2', '\ue053': '3', '\ue054': '4',
    '\ue055': '5', '\ue056': '6', '\ue057': '7', '\ue058': '8', '\ue059': '9',
    '\ue05a': '0', '\ue05b': '1', '\ue05c': '2', '\ue05d': '3', '\ue05e': '4',
    '\ue05f': '5', '\ue060': '6', '\ue061': '7', '\ue062': '8', '\ue063': '9',
    '\ue064': '0', '\ue065': '1', '\ue066': '2', '\ue067': '3', '\ue068': '4',
    '\ue069': '5', '\ue06a': '6', '\ue06b': '7', '\ue06c': '8', '\ue06d': '9',
    '\ue06e': '0', '\ue06f': '1', '\ue070': '2', '\ue071': '3', '\ue072': '4',
    '\ue073': '5', '\ue074': '6', '\ue075': '7', '\ue076': '8', '\ue077': '9',
    '\ue078': '0', '\ue079': '1', '\ue07a': '2', '\ue07b': '3', '\ue07c': '4',
    '\ue07d': '5', '\ue07e': '6', '\ue07f': '7', '\ue080': '8', '\ue081': '9',
    '\ue082': '0', '\ue083': '1', '\ue084': '2', '\ue085': '3', '\ue086': '4',
    '\ue087': '5', '\ue088': '6', '\ue089': '7', '\ue08a': '8', '\ue08b': '9',
    '\ue08c': '0', '\ue08d': '1', '\ue08e': '2', '\ue08f': '3', '\ue090': '4',
    '\ue091': '5', '\ue092': '6', '\ue093': '7', '\ue094': '8', '\ue095': '9',
    '\ue096': '0', '\ue097': '1', '\ue098': '2', '\ue099': '3', '\ue09a': '4',
    '\ue09b': '5', '\ue09c': '6', '\ue09d': '7', '\ue09e': '8', '\ue09f': '9',
    '\ue0a0': '0', '\ue0a1': '1', '\ue0a2': '2', '\ue0a3': '3', '\ue0a4': '4',
    '\ue0a5': '5', '\ue0a6': '6', '\ue0a7': '7', '\ue0a8': '8', '\ue0a9': '9',
    '\ue0aa': '0', '\ue0ab': '1', '\ue0ac': '2', '\ue0ad': '3', '\ue0ae': '4',
    '\ue0af': '5', '\ue0b0': '6', '\ue0b1': '7', '\ue0b2': '8', '\ue0b3': '9',
    '\ue0b4': '0', '\ue0b5': '1', '\ue0b6': '2', '\ue0b7': '3', '\ue0b8': '4',
    '\ue0b9': '5', '\ue0ba': '6', '\ue0bb': '7', '\ue0bc': '8', '\ue0bd': '9',
    '\ue0be': '0', '\ue0bf': '1', '\ue0c0': '2', '\ue0c1': '3', '\ue0c2': '4',
    '\ue0c3': '5', '\ue0c4': '6', '\ue0c5': '7', '\ue0c6': '8', '\ue0c7': '9',
    '\ue0c8': '0', '\ue0c9': '1', '\ue0ca': '2', '\ue0cb': '3', '\ue0cc': '4',
    '\ue0cd': '5', '\ue0ce': '6', '\ue0cf': '7', '\ue0d0': '8', '\ue0d1': '9',
    '\ue0d2': '0', '\ue0d3': '1', '\ue0d4': '2', '\ue0d5': '3', '\ue0d6': '4',
    '\ue0d7': '5', '\ue0d8': '6', '\ue0d9': '7', '\ue0da': '8', '\ue0db': '9',
    '\ue0dc': '0', '\ue0dd': '1', '\ue0de': '2', '\ue0df': '3', '\ue0e0': '4',
    '\ue0e1': '5', '\ue0e2': '6', '\ue0e3': '7', '\ue0e4': '8', '\ue0e5': '9',
    '\ue0e6': '0', '\ue0e7': '1', '\ue0e8': '2', '\ue0e9': '3', '\ue0ea': '4',
    '\ue0eb': '5', '\ue0ec': '6', '\ue0ed': '7', '\ue0ee': '8', '\ue0ef': '9',
    '\ue0f0': '0', '\ue0f1': '1', '\ue0f2': '2', '\ue0f3': '3', '\ue0f4': '4',
    '\ue0f5': '5', '\ue0f6': '6', '\ue0f7': '7', '\ue0f8': '8', '\ue0f9': '9',
}


def decode_boss_text(text: str) -> str:
    """
    解码Boss直聘的字体反爬文本
    
    Boss直聘使用PUA字符来混淆薪资等敏感信息
    这个函数将PUA字符映射回正常数字
    
    Args:
        text: 可能包含PUA字符的文本
    
    Returns:
        解码后的正常文本
    """
    if not text:
        return text
    
    result = text
    for pua_char, real_char in BOSS_FONT_MAP.items():
        result = result.replace(pua_char, real_char)
    
    return result


class BossSpider(BaseSpider):
    """
    Boss直聘爬虫类
    """
    
    name = "boss"
    base_url = "https://www.zhipin.com"
    
    def search(self, keyword: str, city: str) -> bool:
        """
        搜索职位
        
        Args:
            keyword: 搜索关键词
            city: 城市
        
        Returns:
            是否成功进入搜索结果页
        """
        city_code = get_city_code("boss", city)
        if not city_code:
            logger.warning(f"未找到城市编码: {city}")
            city_code = "101010100"  # 默认北京
        
        # 构建搜索URL（Boss直聘URL已更新为 /web/geek/jobs）
        search_url = f"{self.base_url}/web/geek/jobs?query={quote(keyword)}&city={city_code}"
        
        logger.info(f"正在访问: {search_url}")
        
        # 导航到搜索页面（增加等待时间确保页面完全加载）
        self.engine.navigate(search_url, wait_time=5)
        
        # 额外等待页面加载
        time.sleep(3)
        
        # 检查当前URL
        current_url = self.engine.page.url
        logger.info(f"当前页面URL: {current_url}")
        
        # 检查是否跳转到了详情页或其他页面
        if '/job_detail/' in current_url:
            logger.warning("[Boss] 页面跳转到了职位详情页，返回搜索页...")
            self.engine.navigate(search_url)
            time.sleep(3)
        
        # 尝试多个选择器等待职位列表（根据实际页面结构调整）
        # Boss直聘页面结构：左侧职位列表，右侧职位详情
        selectors = [
            '.job-list-container',     # 职位列表容器（实际结构）
            '.job-card-wrap',          # 职位卡片（实际结构）
            '.job-list-box',           # 原选择器
            '.search-job-result',      # 搜索结果容器
            '[class*="job-list"]',     # 包含job-list的类
            '[class*="job-card"]',     # 包含job-card的类
        ]
        
        for selector in selectors:
            try:
                result = self.engine.wait_for_element(selector, 5, 'css')
                if result:
                    logger.info(f"[Boss] 找到职位列表容器: {selector}")
                    return True
            except Exception as e:
                logger.debug(f"选择器 {selector} 等待失败: {e}")
                continue
        
        # 打印页面HTML片段用于调试
        try:
            page_html = self.engine.page.html[:2000]
            logger.debug(f"页面HTML片段: {page_html}")
        except Exception:
            pass
        
        logger.warning("[Boss] 未找到职位列表容器")
        return False
    
    def parse_job_list(self) -> List[Job]:
        """
        解析职位列表页（Boss直聘使用无限滚动加载）
        
        Returns:
            职位列表
        """
        jobs = []
        last_count = 0
        no_change_count = 0
        max_scroll_attempts = 20  # 最大滚动次数（增加到20次）
        
        for attempt in range(max_scroll_attempts):
            # 获取当前职位卡片列表
            job_cards = self.engine.get_elements('.job-card-wrap')
            
            if not job_cards:
                job_cards = self.engine.get_elements('.job-list-container .job-card-wrap')
            
            if not job_cards:
                job_cards = self.engine.get_elements('[class*="job-card-wrap"]')
            
            current_count = len(job_cards)
            logger.info(f"[Boss] 第{attempt + 1}次滚动，找到 {current_count} 个职位卡片")
            
            # 解析新加载的卡片（从上次解析的位置开始）
            new_jobs_count = 0
            for i, card in enumerate(job_cards[last_count:], start=last_count):
                try:
                    job = self._parse_job_card(card)
                    if job:
                        jobs.append(job)
                        new_jobs_count += 1
                except Exception as e:
                    logger.debug(f"解析第{i+1}个职位卡片失败: {e}")
                    continue
            
            logger.info(f"[Boss] 本次解析成功 {new_jobs_count} 个职位")
            
            # 检查是否达到目标数量
            if len(jobs) >= 50:  # JOBS_PER_KEYWORD
                logger.info(f"[Boss] 已达到目标数量50个")
                break
            
            # 检查是否有新卡片加载
            if current_count == last_count:
                no_change_count += 1
                if no_change_count >= 3:  # 连续3次没有新卡片，停止滚动
                    logger.info(f"[Boss] 连续{no_change_count}次没有新卡片加载，停止滚动")
                    break
            else:
                no_change_count = 0
            
            last_count = current_count
            
            # 滚动左侧职位列表区域加载更多
            try:
                # Boss直聘的职位列表在 .job-list-container 内部滚动
                # 需要找到该容器并在其内部滚动
                list_container = self.engine.page.ele('css:.job-list-container')
                if list_container:
                    # 在容器内部滚动 - 使用JavaScript滚动
                    self.engine.page.run_js('document.querySelector(".job-list-container").scrollTop += 1500')
                    logger.info(f"[Boss] 滚动加载更多职位...")
                    import time
                    time.sleep(1.5)  # 缩短等待时间到1.5秒
                else:
                    # 如果找不到容器，尝试滚动整个页面
                    self.engine.page.scroll.down(800)
                    logger.info(f"[Boss] 页面滚动加载更多职位...")
                    import time
                    time.sleep(1.5)
            except Exception as e:
                logger.warning(f"[Boss] 滚动失败: {e}")
                break
        
        logger.info(f"[Boss] 总共解析成功 {len(jobs)} 个职位")
        return jobs
    
    def _parse_job_card(self, card) -> Job:
        """
        解析单个职位卡片
        
        Args:
            card: 职位卡片元素
        
        Returns:
            职位数据
        """
        try:
            # 获取职位链接
            job_link = card.ele('css:.job-name')
            if not job_link:
                logger.debug("[Boss] 解析失败: 未找到 .job-name")
                return None
            
            href = job_link.attr('href') or ''
            
            # 提取职位ID（Boss直聘链接格式：/job_detail/IDxxx.html）
            # 支持新旧两种格式：ID.html 或 IDxxx.html
            job_id_match = re.search(r'/job_detail/([a-zA-Z0-9]+)', href)
            if not job_id_match:
                logger.debug(f"[Boss] 解析失败: 无法从链接提取ID: {href}")
                return None
            
            source_id = job_id_match.group(1)
            job_id = self.generate_job_id(source_id)
            
            # 获取职位标题
            title = job_link.text.strip()
            if not title:
                logger.debug("[Boss] 解析失败: 职位标题为空")
                return None
            
            # 获取薪资（Boss直聘实际使用 .job-salary）
            # Boss直聘使用动态字体反爬，需要通过JavaScript获取渲染后的文本
            salary_elem = card.ele('css:.job-salary')
            if salary_elem:
                # 使用JavaScript获取渲染后的文本（绕过字体反爬）
                try:
                    salary = self.engine.page.run_js('''
                        var elem = arguments[0];
                        return elem.innerText;
                    ''', salary_elem)
                    salary = salary.strip() if salary else None
                except:
                    # 如果JavaScript失败，尝试直接获取文本
                    salary = salary_elem.text.strip() if salary_elem else None
            else:
                salary = None
            
            # 获取公司名称（Boss直聘实际使用 .boss-name）
            company_elem = card.ele('css:.boss-name')
            company = company_elem.text.strip() if company_elem else "未知公司"
            
            # 获取工作地点（Boss直聘实际使用 .company-location）
            location_elem = card.ele('css:.company-location')
            location = location_elem.text.strip() if location_elem else None
            
            # 获取标签
            tags = card.eles('css:.tag-list li')
            experience = None
            education = None
            tag_list = []
            
            for i, tag in enumerate(tags):
                tag_text = tag.text.strip()
                tag_list.append(tag_text)
                
                if i == 0:
                    experience = tag_text
                elif i == 1:
                    education = tag_text
            
            # 获取职位详情链接
            source_url = f"{self.base_url}{href}" if href.startswith('/') else href
            
            # 获取福利标签（Boss直聘可能在详情页）
            welfare_elems = card.eles('css:.info-desc')
            welfare_tags = [elem.text.strip() for elem in welfare_elems if elem.text.strip()]
            
            # 合并标签
            all_tags = tag_list + welfare_tags
            
            logger.debug(f"[Boss] 解析成功: {title} @ {company}")
            
            return Job(
                id=job_id,
                title=title,
                company=company,
                salary=salary,
                location=location,
                category=self.current_keyword,
                experience=experience,
                education=education,
                tags=all_tags if all_tags else None,
                source=self.name,
                source_url=source_url,
            )
        except Exception as e:
            logger.debug(f"[Boss] 解析职位卡片异常: {e}")
            return None
    
    def get_next_page(self) -> bool:
        """
        获取下一页
        
        Returns:
            是否成功翻页
        """
        # 查找下一页按钮
        next_btn = self.engine.page.ele('css:.options-pages .next')
        
        if next_btn and 'disabled' not in (next_btn.attr('class') or ''):
            self.engine._simulate_human_click(next_btn)
            self.engine.page.wait.doc_loaded()
            return True
        
        return False
