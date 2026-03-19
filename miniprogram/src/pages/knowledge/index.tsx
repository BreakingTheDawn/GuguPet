import { View, Text } from '@tarojs/components'
import { useState } from 'react'
import './index.scss'

// 专栏数据
const columns = [
  {
    id: 1,
    category: '补贴·领取',
    catBg: '#C8F0D4',
    catColor: '#1E6640',
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
  },
  {
    id: 2,
    category: '考公·入门',
    catBg: '#C2D9FF',
    catColor: '#1A3E7A',
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
  },
  {
    id: 3,
    category: '简历·优化',
    catBg: '#FFE2CC',
    catColor: '#7A3A10',
    title: '《简历从0到1写作攻略》',
    benefits: '包含：模板×8+HR点评+AI提示词',
    price: '¥14.9',
    emoji: '📝',
    previewContent: [
      'HR 平均看一份简历只用 6 秒，你的简历能通过吗？',
      '✏️ 常见致命错误 #1：工作描述写「负责XXX」——HR 看到这 3 个字直接翻页。',
      '✏️ 正确写法：用「动词 + 数字 + 结果」结构。例：「主导设计 XX 功能，用户转化率提升 23%」。',
      '✏️ 常见致命错误 #2：一份简历投所有岗位——职位描述关键词不匹配，ATS 系统直接过滤。',
      '…… 后续章节包含 8 套分行业模板和 20 条 AI 优化提示词，可直接套用。',
    ],
  },
  {
    id: 4,
    category: '面试·技巧',
    catBg: '#E8D4FF',
    catColor: '#4A1A7A',
    title: '《高频面试题答题框架》',
    benefits: '包含：50题+STAR模板+反问清单',
    price: '¥19.9',
    emoji: '🎯',
    previewContent: [
      '「你能介绍一下自己吗？」这题99%的人都没答好。',
      '🔑 黄金公式：30秒背景 + 30秒亮点经历 + 10秒与岗位的连接。',
      '🔑 背景：「我是XX大学XX专业的应届毕业生，主要学习方向是……」',
      '🔑 亮点经历：「在校期间，我做了一个让我印象最深的项目……（用数字证明价值）」',
      '…… 后续包含「为什么跳槽」「你的缺点是什么」等 50 道高频题完整答题示范。',
    ],
  },
  {
    id: 5,
    category: '职场·避坑',
    catBg: '#FFF0C0',
    catColor: '#6A4A00',
    title: '《职场新人第一年避坑手册》',
    benefits: '包含：20个坑+话术模板+晋升地图',
    price: '¥14.9',
    emoji: '🗺️',
    previewContent: [
      '90% 的职场新人都踩过这些坑，你中了几个？',
      '⚠️ 坑 #1：把「努力工作」等同于「表现好」。努力不等于价值可见，你需要主动汇报进度。',
      '⚠️ 坑 #2：不懂「向上管理」。让领导知道你在做什么，比做了什么更重要。',
      '⚠️ 坑 #3：第一个月就提涨薪。试用期内提薪会让你的职业生涯直接终结于这家公司。',
      '…… 本手册共 20 个实战避坑经验，附带每个场景的话术模板，可直接复用。',
    ],
  },
  {
    id: 6,
    category: '选城·落户',
    catBg: '#C8F0F8',
    catColor: '#0A4A5A',
    title: '《新一线城市落户完全攻略》',
    benefits: '包含：12城对比+积分模拟+时间轴',
    price: '¥12.9',
    emoji: '🏙️',
    previewContent: [
      '留北上广还是去新一线？这份数据对比或许能帮你决定。',
      '📊 落户门槛对比（应届生专项）：',
      '成都：本科直接落户，无需积分，到场办理一天完成。',
      '杭州：本科落户限额制，每年约 3 万名额，先到先得。',
      '…… 本手册覆盖成都、杭州、武汉、南京等 12 座城市，附带落户积分模拟计算器。',
    ],
  },
  {
    id: 7,
    category: '薪资·谈判',
    catBg: '#FFD4E4',
    catColor: '#7A1A3A',
    title: '《薪资谈判完全指南》',
    benefits: '包含：话术脚本+常见陷阱+期望报价公式',
    price: '¥9.9',
    emoji: '💼',
    previewContent: [
      '「你期望薪资是多少？」这一句话，可能值几万元。',
      '💡 核心策略：永远不要第一个报数。先反问「这个岗位的薪资范围是多少？」',
      '💡 如果对方坚持让你先报：用「期望区间」代替「精确数字」，给自己留余地。',
      '💡 公式：目标薪资 = 当前市场水平 × 1.15 ~ 1.25（跳槽溢价）',
      '…… 本指南包含完整对话脚本、7 种常见谈判陷阱识别，以及如何利用 Offer 竞价拉高薪资。',
    ],
  },
  {
    id: 8,
    category: '实习·转正',
    catBg: '#D4F0C0',
    catColor: '#1A5A2A',
    title: '《实习生转正成功率提升手册》',
    benefits: '包含：转正评估表+关键节点清单+案例库',
    price: '¥12.9',
    emoji: '🌱',
    previewContent: [
      '从实习到转正，决定结果的往往是这 3 件事——',
      '🌱 关键因素 #1：第 3 天的「期望对齐会」。主动找导师 1v1，搞清楚「转正的评判标准是什么」。',
      '🌱 关键因素 #2：第 30 天的「成果可视化」。整理一份自己的阶段成果文档，主动发给导师。',
      '🌱 关键因素 #3：第 60 天的「人际网络建立」。在组内至少与 5 位核心成员建立实质性合作关系。',
      '…… 本手册包含完整转正评估模板、每周关键节点 Checklist，以及 10 个真实转正/未转正案例分析。',
    ],
  },
]

// 分类筛选
const categories = ['全部', '求职技能', '政策补贴', '职场成长', '考公备考']

type ColumnItem = typeof columns[0]

export default function KnowledgePage() {
  const [previewColumn, setPreviewColumn] = useState<ColumnItem | null>(null)
  const [activeCategory, setActiveCategory] = useState(0)

  return (
    <View className="knowledge-page">
      {/* Hero Banner */}
      <View className="hero-banner">
        {/* 装饰点 */}
        {[...Array(12)].map((_, i) => (
          <View
            key={i}
            className="deco-dot"
            style={{
              width: `${4 + (i % 3) * 2}px`,
              height: `${4 + (i % 3) * 2}px`,
              left: `${8 + (i * 27) % 82}%`,
              top: `${10 + (i * 19) % 70}%`,
            }}
          />
        ))}

        {/* 文字内容 */}
        <View className="banner-content">
          <View className="banner-tag">
            <Text className="banner-tag-emoji">🎓</Text>
            <Text className="banner-tag-text">咕咕精选 · 毕业特辑</Text>
          </View>
          <Text className="banner-title">毕业不迷茫：{'\n'}咕咕的避坑档案馆</Text>
          <Text className="banner-subtitle">8 份干货手册 · 陪你迈过每道坎</Text>
        </View>

        {/* 背景鸟图 */}
        <View className="banner-bird">
          <Text className="banner-bird-emoji">🐧</Text>
        </View>
      </View>

      {/* 区块标题 */}
      <View className="section-header">
        <View className="section-title-group">
          <Text className="section-title">全套档案馆</Text>
          <Text className="section-subtitle">共 {columns.length} 份专栏 · 持续更新中</Text>
        </View>
        <View className="archive-tag">
          <Text>🗂️ 档案馆</Text>
        </View>
      </View>

      {/* 分类筛选 */}
      <View className="category-pills">
        {categories.map((cat, i) => (
          <View
            key={cat}
            className={`category-pill ${activeCategory === i ? 'active' : ''}`}
            onClick={() => setActiveCategory(i)}
          >
            <Text>{cat}</Text>
          </View>
        ))}
      </View>

      {/* 专栏卡片网格 */}
      <View className="columns-grid">
        {columns.map((col, i) => (
          <View
            key={col.id}
            className="column-card"
            onClick={() => setPreviewColumn(col)}
          >
            {/* 左侧牛皮纸纹理条 */}
            <View className="card-texture" />

            {/* 右上角折角 */}
            <View className="card-fold" />
            <View className="card-fold-inner" />

            {/* 卡片内容 */}
            <View className="card-content">
              {/* 分类标签 */}
              <View className="card-header">
                <View
                  className="card-category"
                  style={{ background: col.catBg, color: col.catColor }}
                >
                  <Text>{col.category}</Text>
                </View>
                <Text className="card-emoji">{col.emoji}</Text>
              </View>

              {/* 标题 */}
              <Text className="card-title">{col.title}</Text>

              {/* 收益描述 */}
              <Text className="card-benefits">{col.benefits}</Text>
            </View>

            {/* 底部栏 */}
            <View className="card-footer">
              {/* 试读按钮 */}
              <View className="try-read-btn">
                <Text className="try-read-icon">👁</Text>
                <Text className="try-read-text">试读</Text>
              </View>

              {/* 价格 */}
              <Text className="card-price">{col.price}</Text>
            </View>
          </View>
        ))}
      </View>

      {/* 底部 CTA 按钮 */}
      <View className="bottom-cta">
        <View className="cta-btn">
          <View className="cta-shimmer" />
          <View className="cta-content">
            <Text className="cta-emoji">📦</Text>
            <View className="cta-text-group">
              <Text className="cta-title">一键带走全套档案馆</Text>
              <Text className="cta-subtitle">8册合集 · 原价 ¥123.2 · 现仅 ¥49.9</Text>
            </View>
            <Text className="cta-sparkle">✨</Text>
          </View>
        </View>
      </View>

      {/* 预览弹窗 */}
      {previewColumn && (
        <View className="preview-overlay" onClick={() => setPreviewColumn(null)}>
          <View className="preview-modal" onClick={(e) => e.stopPropagation()}>
            <View className="modal-handle" />

            {/* 弹窗头部 */}
            <View className="preview-header">
              <View className="preview-header-left">
                <View
                  className="preview-category"
                  style={{ background: previewColumn.catBg, color: previewColumn.catColor }}
                >
                  <Text>{previewColumn.category}</Text>
                </View>
                <Text className="preview-title">{previewColumn.title}</Text>
                <Text className="preview-hint">前 20% 内容免费预览</Text>
              </View>
              <View className="preview-close" onClick={() => setPreviewColumn(null)}>
                <Text>×</Text>
              </View>
            </View>

            {/* 预览内容 */}
            <View className="preview-content">
              {previewColumn.previewContent.map((line, i) => (
                <Text key={i} className="preview-line">{line}</Text>
              ))}
              <View className="preview-fade" />
            </View>

            {/* 解锁按钮 */}
            <View className="unlock-btn">
              <View className="unlock-shimmer" />
              <Text className="unlock-text">解锁完整内容 · {previewColumn.price}</Text>
            </View>
          </View>
        </View>
      )}
    </View>
  )
}
