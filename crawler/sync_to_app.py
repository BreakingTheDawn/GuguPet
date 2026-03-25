"""
数据同步脚本
将爬虫数据库中的职位数据同步到前端App数据库

使用方法:
1. 直接运行: python sync_to_app.py
2. 同步特定平台: python sync_to_app.py boss
3. 同步并清空旧数据: python sync_to_app.py --clear
"""
import sqlite3
import json
import shutil
from pathlib import Path
from datetime import datetime
from typing import Optional

from utils.logger import logger


# 路径配置
CRAWLER_DB = Path(__file__).parent / "output" / "jobs.db"
APP_DB_DIR = Path(__file__).parent.parent / "app" / "assets" / "data"
APP_DB = APP_DB_DIR / "jobs.db"


def ensure_app_db_dir():
    """确保App数据库目录存在"""
    APP_DB_DIR.mkdir(parents=True, exist_ok=True)


def get_crawler_jobs(platform: Optional[str] = None, limit: int = 1000):
    """
    从爬虫数据库获取职位数据
    
    Args:
        platform: 平台筛选（boss/zhilian/qiancheng）
        limit: 最大返回数量
    
    Returns:
        职位数据列表
    """
    if not CRAWLER_DB.exists():
        logger.error(f"爬虫数据库不存在: {CRAWLER_DB}")
        return []
    
    conn = sqlite3.connect(CRAWLER_DB)
    conn.row_factory = sqlite3.Row
    cursor = conn.cursor()
    
    try:
        if platform:
            cursor.execute("""
                SELECT * FROM jobs 
                WHERE source = ? 
                ORDER BY created_at DESC 
                LIMIT ?
            """, (platform, limit))
        else:
            cursor.execute("""
                SELECT * FROM jobs 
                ORDER BY created_at DESC 
                LIMIT ?
            """, (limit,))
        
        rows = cursor.fetchall()
        jobs = [dict(row) for row in rows]
        logger.info(f"从爬虫数据库读取 {len(jobs)} 条职位数据")
        return jobs
        
    except Exception as e:
        logger.error(f"读取爬虫数据库失败: {e}")
        return []
    finally:
        conn.close()


def transform_job(crawler_job: dict) -> dict:
    """
    将爬虫数据格式转换为App数据格式
    
    Args:
        crawler_job: 爬虫数据库中的职位数据
    
    Returns:
        App格式的职位数据
    """
    # 解析tags
    tags = []
    if crawler_job.get('tags'):
        try:
            # 尝试解析JSON数组
            tags = json.loads(crawler_job['tags'])
        except json.JSONDecodeError:
            # 如果不是JSON，按逗号分割
            tags = [t.strip() for t in crawler_job['tags'].split(',') if t.strip()]
    
    # 转换数据格式
    app_job = {
        'id': crawler_job['id'],
        'title': crawler_job['title'],
        'company': crawler_job['company'],
        'salary': crawler_job['salary'] or '',
        'location': crawler_job['location'] or '',
        'category': crawler_job['category'],
        'experience': crawler_job['experience'],
        'education': crawler_job['education'],
        'tags': ','.join(tags) if tags else None,
        'description': crawler_job['description'],
        'is_new': 1 if crawler_job.get('is_new') else 0,
        'is_urgent': 0,  # 爬虫数据中没有这个字段
        'posted_at': crawler_job['created_at'],  # 使用创建时间作为发布时间
        'posted_text': None,
        'company_size': None,  # 爬虫数据中没有这个字段
        'funding_stage': None,  # 爬虫数据中没有这个字段
        'industry_tag': None,  # 爬虫数据中没有这个字段
        'source_url': crawler_job['source_url'],
        'source': crawler_job['source'],
    }
    
    return app_job


def init_app_database():
    """初始化App数据库"""
    conn = sqlite3.connect(APP_DB)
    cursor = conn.cursor()
    
    try:
        # 创建jobs表（与App模型对应）
        cursor.execute("""
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
                source_url TEXT,
                source TEXT,
                synced_at TEXT DEFAULT CURRENT_TIMESTAMP
            )
        """)
        
        conn.commit()
        logger.info("App数据库初始化完成")
        
    except Exception as e:
        logger.error(f"初始化App数据库失败: {e}")
    finally:
        conn.close()


def sync_jobs_to_app(jobs: list, clear_existing: bool = False):
    """
    同步职位数据到App数据库
    
    Args:
        jobs: 职位数据列表
        clear_existing: 是否清空现有数据
    """
    if not jobs:
        logger.warning("没有数据需要同步")
        return 0
    
    ensure_app_db_dir()
    init_app_database()
    
    conn = sqlite3.connect(APP_DB)
    cursor = conn.cursor()
    
    try:
        # 如果需要，清空现有数据
        if clear_existing:
            cursor.execute("DELETE FROM jobs")
            logger.info("已清空App数据库中的现有数据")
        
        # 插入或更新数据
        inserted = 0
        updated = 0
        
        for crawler_job in jobs:
            try:
                app_job = transform_job(crawler_job)
                
                # 检查是否已存在
                cursor.execute("SELECT id FROM jobs WHERE id = ?", (app_job['id'],))
                existing = cursor.fetchone()
                
                if existing:
                    # 更新现有记录
                    cursor.execute("""
                        UPDATE jobs SET
                            title = ?,
                            company = ?,
                            salary = ?,
                            location = ?,
                            category = ?,
                            experience = ?,
                            education = ?,
                            tags = ?,
                            description = ?,
                            is_new = ?,
                            source_url = ?,
                            source = ?,
                            synced_at = CURRENT_TIMESTAMP
                        WHERE id = ?
                    """, (
                        app_job['title'],
                        app_job['company'],
                        app_job['salary'],
                        app_job['location'],
                        app_job['category'],
                        app_job['experience'],
                        app_job['education'],
                        app_job['tags'],
                        app_job['description'],
                        app_job['is_new'],
                        app_job['source_url'],
                        app_job['source'],
                        app_job['id'],
                    ))
                    updated += 1
                else:
                    # 插入新记录
                    cursor.execute("""
                        INSERT INTO jobs (
                            id, title, company, salary, location,
                            category, experience, education, tags, description,
                            is_new, is_urgent, posted_at, posted_text,
                            company_size, funding_stage, industry_tag,
                            source_url, source
                        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
                    """, (
                        app_job['id'],
                        app_job['title'],
                        app_job['company'],
                        app_job['salary'],
                        app_job['location'],
                        app_job['category'],
                        app_job['experience'],
                        app_job['education'],
                        app_job['tags'],
                        app_job['description'],
                        app_job['is_new'],
                        app_job['is_urgent'],
                        app_job['posted_at'],
                        app_job['posted_text'],
                        app_job['company_size'],
                        app_job['funding_stage'],
                        app_job['industry_tag'],
                        app_job['source_url'],
                        app_job['source'],
                    ))
                    inserted += 1
                    
            except Exception as e:
                logger.error(f"同步职位 {crawler_job.get('id')} 失败: {e}")
                continue
        
        conn.commit()
        logger.info(f"同步完成: 新增 {inserted} 条, 更新 {updated} 条")
        return inserted + updated
        
    except Exception as e:
        logger.error(f"同步数据到App数据库失败: {e}")
        conn.rollback()
        return 0
    finally:
        conn.close()


def main():
    """主函数"""
    import sys
    
    # 解析参数
    platform = None
    clear_existing = False
    
    for arg in sys.argv[1:]:
        if arg == '--clear':
            clear_existing = True
        elif arg in ['boss', 'zhilian', 'qiancheng']:
            platform = arg
    
    logger.info("=" * 60)
    logger.info("开始同步爬虫数据到App数据库")
    logger.info(f"平台筛选: {platform or '全部'}")
    logger.info(f"清空现有数据: {clear_existing}")
    logger.info("=" * 60)
    
    # 1. 从爬虫数据库读取数据
    jobs = get_crawler_jobs(platform=platform)
    
    if not jobs:
        logger.warning("没有数据需要同步")
        return
    
    # 2. 同步到App数据库
    synced_count = sync_jobs_to_app(jobs, clear_existing=clear_existing)
    
    logger.info("=" * 60)
    logger.info(f"同步完成! 共处理 {synced_count} 条数据")
    logger.info(f"App数据库位置: {APP_DB}")
    logger.info("=" * 60)


if __name__ == "__main__":
    main()
