import 'package:flutter/material.dart';

/// 专栏数据模型
/// 用于存储付费专栏的基本信息
class ColumnItem {
  final int id;
  final String category;
  final Color catBg;
  final Color catColor;
  final String title;
  final String benefits;
  final String price;
  final String emoji;
  final List<String> previewContent;

  const ColumnItem({
    required this.id,
    required this.category,
    required this.catBg,
    required this.catColor,
    required this.title,
    required this.benefits,
    required this.price,
    required this.emoji,
    required this.previewContent,
  });
}

/// 专栏数据列表
/// 根据职宠小窝付费专栏内容清单配置
class ColumnData {
  ColumnData._();

  static const List<ColumnItem> columns = [
    ColumnItem(
      id: 1,
      category: '补贴·领取',
      catBg: Color(0xFFC8F0D4),
      catColor: Color(0xFF1E6640),
      title: '《毕业补贴完整领取手册》',
      benefits: '包含：7大补贴+申请模板+避坑清单',
      price: '¥9.9',
      emoji: '💰',
      previewContent: [
        '你知道吗？作为应届毕业生，你可能正在错过这些：',
        '📌 求职补贴：大部分省市提供 500-2000 元一次性求职补贴，需在毕业 6 个月内申请。',
        '📌 租房补贴：一线城市及新一线城市对应届生有 1-3 年的租房补贴，每月可领 300-800 元。',
        '📌 技能培训补贴：参加政府认可的职业技能培训，可全额报销或补贴 80%。',
        '…… 本手册还包含社保补贴、创业补贴等共 7 项，附完整申请链接与流程。',
      ],
    ),
    ColumnItem(
      id: 2,
      category: '考公·入门',
      catBg: Color(0xFFC2D9FF),
      catColor: Color(0xFF1A3E7A),
      title: '《考公小白完全入门手册》',
      benefits: '包含：全流程图解+报名模板+备考计划',
      price: '¥19.9',
      emoji: '📋',
      previewContent: [
        '考公的流程看起来复杂，分步骤来其实并不难——',
        '🗺️ 第一步：搞清楚你要考哪类岗位（国考 / 省考 / 事业单位 / 三支一扶）',
        '🗺️ 第二步：查询报名时间。国考每年 10 月公告，省考多集中在 3-4 月。',
        '🗺️ 第三步：对照职位表筛选适合自己的岗位，重点看「专业」「学历」「政治面貌」三个门槛。',
        '…… 后续章节包含行测备考框架、申论高分模板及 30 天备考计划表。',
      ],
    ),
    ColumnItem(
      id: 3,
      category: '五险·一金',
      catBg: Color(0xFFE8D4FF),
      catColor: Color(0xFF4A1A7A),
      title: '《五险一金避坑手册》',
      benefits: '包含：速查表+计算器+避坑清单',
      price: '¥19.9',
      emoji: '🛡️',
      previewContent: [
        '五险一金是职场人的基本保障，但很多人并不真正了解——',
        '🏥 医疗保险：报销比例因地而异，门诊和住院报销规则不同。',
        '🏠 公积金：可用于购房、租房提取，离职时如何处理？',
        '⚠️ 断缴影响：医保断缴次月失效，公积金断缴影响贷款额度。',
        '…… 本手册包含全国主要城市缴费比例速查表和在线计算器。',
      ],
    ),
    ColumnItem(
      id: 4,
      category: '毕业·手续',
      catBg: Color(0xFFC8F0F8),
      catColor: Color(0xFF0A4A5A),
      title: '《毕业手续办理指南》',
      benefits: '包含：流程清单+材料模板+办理指南',
      price: '¥19.9',
      emoji: '📄',
      previewContent: [
        '毕业手续繁杂，错过时间可能影响一生——',
        '📜 报到证：2023年起已取消，但档案转移仍需注意。',
        '📁 档案存放：人才市场 vs 单位，各有利弊。',
        '⏰ 关键节点：毕业证领取、户口迁移、党团关系转接。',
        '…… 本手册提供完整时间轴和各类材料模板。',
      ],
    ),
    ColumnItem(
      id: 5,
      category: '劳动·合同',
      catBg: Color(0xFFFFE2CC),
      catColor: Color(0xFF7A3A10),
      title: '《劳动合同避坑指南》',
      benefits: '包含：避坑清单+合同模板+维权指南',
      price: '¥14.9',
      emoji: '📝',
      previewContent: [
        '签合同前，这些坑你必须知道——',
        '⚠️ 试用期陷阱：试用期工资不得低于转正工资的80%。',
        '⚠️ 竞业协议：离职后可能限制你2年内不得从事同类工作。',
        '⚠️ 社保缴纳：入职30天内必须缴纳，不缴是违法的。',
        '…… 本手册包含劳动合同自查清单和维权流程。',
      ],
    ),
    ColumnItem(
      id: 6,
      category: '情绪·陪伴',
      catBg: Color(0xFFFFD4E4),
      catColor: Color(0xFF7A1A3A),
      title: '《情绪陪伴成长计划》',
      benefits: '包含：音频课+打卡计划+调适技巧',
      price: '¥9.9',
      emoji: '🌸',
      previewContent: [
        '毕业季焦虑？你不是一个人——',
        '🧘 焦虑缓解：5分钟呼吸冥想，快速平复情绪。',
        '💪 压力管理：将大目标拆解为小任务，逐一击破。',
        '🌱 心态调整：接纳不确定性，把焦虑转化为行动力。',
        '…… 本计划包含10节音频课和21天情绪打卡。',
      ],
    ),
    ColumnItem(
      id: 7,
      category: '简历·优化',
      catBg: Color(0xFFD4F0C0),
      catColor: Color(0xFF1A5A2A),
      title: '《简历从0到1写作攻略》',
      benefits: '包含：模板×8+HR点评+AI提示词',
      price: '¥14.9',
      emoji: '✏️',
      previewContent: [
        'HR 平均看一份简历只用 6 秒，你的简历能通过吗？',
        '✏️ 常见致命错误 #1：工作描述写「负责XXX」——HR 看到这 3 个字直接翻页。',
        '✏️ 正确写法：用「动词 + 数字 + 结果」结构。',
        '✏️ 常见致命错误 #2：一份简历投所有岗位——ATS 系统直接过滤。',
        '…… 后续章节包含 8 套分行业模板和 20 条 AI 优化提示词。',
      ],
    ),
    ColumnItem(
      id: 8,
      category: '面试·技巧',
      catBg: Color(0xFFE8D4FF),
      catColor: Color(0xFF4A1A7A),
      title: '《高频面试题答题框架》',
      benefits: '包含：50题+STAR模板+反问清单',
      price: '¥19.9',
      emoji: '🎯',
      previewContent: [
        '「你能介绍一下自己吗？」这题99%的人都没答好。',
        '🔑 黄金公式：30秒背景 + 30秒亮点经历 + 10秒与岗位的连接。',
        '🔑 背景：「我是XX大学XX专业的应届毕业生，主要学习方向是……」',
        '🔑 亮点经历：「在校期间，我做了一个让我印象最深的项目……」',
        '…… 后续包含「为什么跳槽」「你的缺点是什么」等 50 道高频题完整答题示范。',
      ],
    ),
  ];

  /// 分类筛选标签
  static const List<String> categories = ['全部', '求职技能', '政策补贴', '职场成长', '考公备考'];

  /// 套餐价格
  static const String bundlePrice = '¥49.9';
  static const String originalPrice = '¥123.2';
}
