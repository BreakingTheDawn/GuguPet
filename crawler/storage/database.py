"""
数据库操作模块
提供SQLite数据库的CRUD操作

【合规说明】
本模块负责爬取数据的本地存储，使用SQLite数据库：
1. 数据仅存储在本地，不上传到任何服务器
2. 仅存储公开的职位信息，不涉及用户隐私数据
3. 数据库文件应妥善保管，避免泄露
4. 使用完毕后建议清理敏感数据

数据安全建议：
- 定期备份数据库文件
- 不要将数据库文件提交到代码仓库
- 清理过期的职位数据
"""
import sqlite3
from pathlib import Path
from datetime import datetime
from typing import List, Optional
import uuid

from config.settings import DATABASE_PATH
from storage.models import Job, CrawlLog


class Database:
    """
    SQLite数据库操作类
    """
    
    def __init__(self, db_path: Path = None):
        """
        初始化数据库连接
        
        Args:
            db_path: 数据库文件路径
        """
        self.db_path = db_path or DATABASE_PATH
        self._ensure_db_dir()
        self._init_tables()
    
    def _ensure_db_dir(self):
        """确保数据库目录存在"""
        self.db_path.parent.mkdir(parents=True, exist_ok=True)
    
    def _get_connection(self) -> sqlite3.Connection:
        """获取数据库连接"""
        conn = sqlite3.connect(self.db_path)
        conn.row_factory = sqlite3.Row
        return conn
    
    def _init_tables(self):
        """初始化数据库表"""
        conn = self._get_connection()
        cursor = conn.cursor()
        
        # 创建职位表
        cursor.execute('''
            CREATE TABLE IF NOT EXISTS jobs (
                id TEXT PRIMARY KEY,
                title TEXT NOT NULL,
                company TEXT NOT NULL,
                salary TEXT,
                location TEXT,
                category TEXT,
                experience TEXT,
                education TEXT,
                tags TEXT,
                description TEXT,
                is_new INTEGER DEFAULT 0,
                is_urgent INTEGER DEFAULT 0,
                posted_at TEXT,
                posted_text TEXT,
                company_size TEXT,
                funding_stage TEXT,
                industry_tag TEXT,
                source TEXT NOT NULL,
                source_url TEXT,
                created_at TEXT,
                updated_at TEXT
            )
        ''')
        
        # 创建爬取日志表
        cursor.execute('''
            CREATE TABLE IF NOT EXISTS crawl_logs (
                id TEXT PRIMARY KEY,
                spider_name TEXT NOT NULL,
                keyword TEXT,
                city TEXT,
                total_count INTEGER,
                new_count INTEGER,
                error_count INTEGER,
                start_time TEXT,
                end_time TEXT,
                duration_seconds INTEGER
            )
        ''')
        
        # 创建索引
        cursor.execute('CREATE INDEX IF NOT EXISTS idx_jobs_category ON jobs(category)')
        cursor.execute('CREATE INDEX IF NOT EXISTS idx_jobs_location ON jobs(location)')
        cursor.execute('CREATE INDEX IF NOT EXISTS idx_jobs_source ON jobs(source)')
        cursor.execute('CREATE INDEX IF NOT EXISTS idx_jobs_created_at ON jobs(created_at)')
        cursor.execute('CREATE INDEX IF NOT EXISTS idx_crawl_logs_spider ON crawl_logs(spider_name)')
        
        conn.commit()
        conn.close()
    
    # ==================== 职位操作 ====================
    
    def job_exists(self, job_id: str) -> bool:
        """
        检查职位是否存在
        
        Args:
            job_id: 职位ID
        
        Returns:
            是否存在
        """
        conn = self._get_connection()
        cursor = conn.cursor()
        cursor.execute('SELECT 1 FROM jobs WHERE id = ?', (job_id,))
        exists = cursor.fetchone() is not None
        conn.close()
        return exists
    
    def save_job(self, job: Job) -> bool:
        """
        保存职位（增量更新）
        
        Args:
            job: 职位数据
        
        Returns:
            是否为新职位
        """
        if self.job_exists(job.id):
            # 已存在，更新updated_at
            conn = self._get_connection()
            cursor = conn.cursor()
            cursor.execute(
                'UPDATE jobs SET updated_at = ? WHERE id = ?',
                (datetime.now().isoformat(), job.id)
            )
            conn.commit()
            conn.close()
            return False
        else:
            # 新职位，插入
            conn = self._get_connection()
            cursor = conn.cursor()
            data = job.to_dict()
            placeholders = ', '.join(['?' for _ in data])
            columns = ', '.join(data.keys())
            cursor.execute(
                f'INSERT INTO jobs ({columns}) VALUES ({placeholders})',
                list(data.values())
            )
            conn.commit()
            conn.close()
            return True
    
    def save_jobs_batch(self, jobs: List[Job]) -> int:
        """
        批量保存职位
        
        Args:
            jobs: 职位列表
        
        Returns:
            新增数量
        """
        new_count = 0
        for job in jobs:
            if self.save_job(job):
                new_count += 1
        return new_count
    
    def get_jobs(self, 
                 category: str = None, 
                 location: str = None, 
                 source: str = None,
                 limit: int = 100) -> List[Job]:
        """
        查询职位列表
        
        Args:
            category: 职位类型
            location: 工作地点
            source: 数据来源
            limit: 返回数量限制
        
        Returns:
            职位列表
        """
        conn = self._get_connection()
        cursor = conn.cursor()
        
        sql = 'SELECT * FROM jobs WHERE 1=1'
        params = []
        
        if category:
            sql += ' AND category = ?'
            params.append(category)
        if location:
            sql += ' AND location LIKE ?'
            params.append(f'%{location}%')
        if source:
            sql += ' AND source = ?'
            params.append(source)
        
        sql += ' ORDER BY created_at DESC LIMIT ?'
        params.append(limit)
        
        cursor.execute(sql, params)
        rows = cursor.fetchall()
        conn.close()
        
        return [Job.from_dict(dict(row)) for row in rows]
    
    def get_job_count(self) -> int:
        """获取职位总数"""
        conn = self._get_connection()
        cursor = conn.cursor()
        cursor.execute('SELECT COUNT(*) FROM jobs')
        count = cursor.fetchone()[0]
        conn.close()
        return count
    
    def get_job_count_by_category(self, category: str) -> int:
        """
        获取某个类别的职位数量
        
        Args:
            category: 职位类别
        
        Returns:
            该类别的职位数量
        """
        conn = self._get_connection()
        cursor = conn.cursor()
        cursor.execute('SELECT COUNT(*) FROM jobs WHERE category = ?', (category,))
        count = cursor.fetchone()[0]
        conn.close()
        return count
    
    def get_today_job_count_by_category(self, category: str) -> int:
        """
        获取某个类别今天新增的职位数量
        
        Args:
            category: 职位类别
        
        Returns:
            今天该类别新增的职位数量
        """
        today = datetime.now().strftime('%Y-%m-%d')
        conn = self._get_connection()
        cursor = conn.cursor()
        cursor.execute(
            'SELECT COUNT(*) FROM jobs WHERE category = ? AND DATE(created_at) = ?',
            (category, today)
        )
        count = cursor.fetchone()[0]
        conn.close()
        return count
    
    def get_category_stats(self) -> dict:
        """
        获取所有类别的统计信息
        
        Returns:
            类别统计字典 {category: count}
        """
        conn = self._get_connection()
        cursor = conn.cursor()
        cursor.execute('SELECT category, COUNT(*) as count FROM jobs GROUP BY category')
        rows = cursor.fetchall()
        conn.close()
        return {row['category']: row['count'] for row in rows}
    
    # ==================== 爬取日志操作 ====================
    
    def save_crawl_log(self, log: CrawlLog):
        """
        保存爬取日志
        
        Args:
            log: 爬取日志数据
        """
        conn = self._get_connection()
        cursor = conn.cursor()
        data = log.to_dict()
        placeholders = ', '.join(['?' for _ in data])
        columns = ', '.join(data.keys())
        cursor.execute(
            f'INSERT INTO crawl_logs ({columns}) VALUES ({placeholders})',
            list(data.values())
        )
        conn.commit()
        conn.close()
    
    def get_latest_crawl_log(self, spider_name: str) -> Optional[CrawlLog]:
        """
        获取指定爬虫的最新日志
        
        Args:
            spider_name: 爬虫名称
        
        Returns:
            最新的爬取日志
        """
        conn = self._get_connection()
        cursor = conn.cursor()
        cursor.execute(
            'SELECT * FROM crawl_logs WHERE spider_name = ? ORDER BY start_time DESC LIMIT 1',
            (spider_name,)
        )
        row = cursor.fetchone()
        conn.close()
        
        if row:
            return CrawlLog(**dict(row))
        return None


# 全局数据库实例
db = Database()
