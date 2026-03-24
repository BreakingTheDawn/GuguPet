"""
职位类型配置
定义爬取的职位类型和搜索关键词
"""

# 职位类型及其搜索关键词
CATEGORIES = {
    "设计": [
        "UI设计师",
        "视觉设计师",
        "交互设计师",
        "平面设计",
    ],
    "技术": [
        "前端工程师",
        "后端工程师",
        "Java开发",
        "Python开发",
    ],
    "产品": [
        "产品经理",
        "产品助理",
    ],
    "运营": [
        "运营专员",
        "用户运营",
        "内容运营",
    ],
    "数据": [
        "数据分析师",
        "数据工程师",
    ],
}

def get_all_keywords() -> list:
    """
    获取所有搜索关键词
    
    Returns:
        所有关键词列表
    """
    keywords = []
    for category_keywords in CATEGORIES.values():
        keywords.extend(category_keywords)
    return keywords

def get_category_by_keyword(keyword: str) -> str:
    """
    根据关键词获取职位类型
    
    Args:
        keyword: 搜索关键词
    
    Returns:
        职位类型，未找到返回"其他"
    """
    for category, keywords in CATEGORIES.items():
        if keyword in keywords:
            return category
    return "其他"
