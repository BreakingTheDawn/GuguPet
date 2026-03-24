"""
数据模型定义
定义职位数据结构和爬取日志结构

【合规说明】
本模块定义的数据模型仅包含公开的职位信息：
- 职位名称、薪资、地点等公开信息
- 公司信息（公开的企业信息）
- 不包含任何用户个人隐私数据

数据使用原则：
- 仅用于个人求职参考
- 不用于商业用途
- 不进行数据倒卖或分发
"""
from dataclasses import dataclass, field, asdict
from datetime import datetime
from typing import Optional, List
import json


@dataclass
class Job:
    """
    职位数据模型
    与APP端的Job模型保持一致
    """
    # 必填字段
    id: str                           # 职位唯一标识（网站+职位ID组合）
    title: str                        # 职位标题
    company: str                      # 公司名称
    source: str                       # 数据来源（boss/zhilian/qiancheng）
    
    # 可选字段
    salary: Optional[str] = None      # 薪资范围
    location: Optional[str] = None    # 工作地点
    category: Optional[str] = None    # 职位类型
    experience: Optional[str] = None  # 经验要求
    education: Optional[str] = None   # 学历要求
    tags: Optional[List[str]] = None  # 职位标签
    description: Optional[str] = None # 职位描述
    is_new: bool = False              # 是否新职位
    is_urgent: bool = False           # 是否急招
    posted_at: Optional[str] = None   # 发布时间
    posted_text: Optional[str] = None # 发布时间描述
    company_size: Optional[str] = None    # 公司规模
    funding_stage: Optional[str] = None   # 融资阶段
    industry_tag: Optional[str] = None    # 行业标签
    source_url: Optional[str] = None      # 原始链接
    created_at: Optional[str] = None # 入库时间
    updated_at: Optional[str] = None # 更新时间
    
    def __post_init__(self):
        """初始化后处理"""
        now = datetime.now().isoformat()
        if self.created_at is None:
            self.created_at = now
        self.updated_at = now
    
    def to_dict(self) -> dict:
        """转换为字典"""
        data = asdict(self)
        # 处理tags列表
        if self.tags:
            data['tags'] = ','.join(self.tags)
        return data
    
    @classmethod
    def from_dict(cls, data: dict) -> 'Job':
        """从字典创建实例"""
        # 处理tags字符串
        if 'tags' in data and isinstance(data['tags'], str):
            data['tags'] = [t.strip() for t in data['tags'].split(',') if t.strip()]
        return cls(**data)


@dataclass
class CrawlLog:
    """
    爬取日志数据模型
    记录每次爬取的统计信息
    """
    id: str                           # 日志ID
    spider_name: str                  # 爬虫名称
    keyword: Optional[str] = None     # 搜索关键词
    city: Optional[str] = None        # 城市
    total_count: int = 0              # 爬取总数
    new_count: int = 0                # 新增数量
    error_count: int = 0              # 错误数量
    start_time: Optional[str] = None  # 开始时间
    end_time: Optional[str] = None    # 结束时间
    duration_seconds: int = 0         # 耗时（秒）
    
    def to_dict(self) -> dict:
        """转换为字典"""
        return asdict(self)
