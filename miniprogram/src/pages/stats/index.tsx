import { View, Text } from '@tarojs/components'
import { useState, useEffect } from 'react'
import { useStore } from '../../store'
import './index.scss'

// 倒计时数据类型
interface Countdown {
  id: number
  label: string
  date: string
  emoji: string
  catBg: string
  textColor: string
}

// 计算距离日期的天数
function getDaysUntil(dateStr: string): number {
  const target = new Date(dateStr)
  const now = new Date()
  now.setHours(0, 0, 0, 0)
  return Math.max(0, Math.ceil((target.getTime() - now.getTime()) / 86400000))
}

// 默认倒计时数据
const defaultCountdowns: Countdown[] = [
  { id: 1, label: '距毕业', date: '2026-06-20', emoji: '🎓', catBg: '#FFE2EE', textColor: '#C05A78' },
  { id: 2, label: '入职报到', date: '2026-07-15', emoji: '💼', catBg: '#E2EEFF', textColor: '#4A68C8' },
  { id: 3, label: '三方截止', date: '2026-04-30', emoji: '📋', catBg: '#E2FFE8', textColor: '#3A8A50' },
]

// 高频待办数据
const quickActions = [
  { id: 1, emoji: '📄', title: '论文查重', sub: '知网 / 维普', bg: '#FFF3E8', color: '#C06020' },
  { id: 2, emoji: '📋', title: '三方协议', sub: '查看状态', bg: '#E8F0FF', color: '#4060C8' },
  { id: 3, emoji: '🏦', title: '社保查询', sub: '参保记录', bg: '#E8FFF0', color: '#208050' },
  { id: 4, emoji: '🏠', title: '公积金', sub: '开户进度', bg: '#F5E8FF', color: '#8040C0' },
]

// 智能推荐数据
const recommendations = [
  { id: 1, emoji: '📋', title: '毕业手续\n办理指南', reason: '距答辩仅7天', urgency: 'high', bg: '#FFE8F0', accentColor: '#E05080' },
  { id: 2, emoji: '🏦', title: '社保缴纳\n完整攻略', reason: '入职前必看', urgency: 'medium', bg: '#E8F0FF', accentColor: '#5080E0' },
  { id: 3, emoji: '📝', title: '三方协议\n避坑手册', reason: '签约高峰期', urgency: 'high', bg: '#E8FFE8', accentColor: '#40A060' },
  { id: 4, emoji: '💰', title: '补贴领取\n申请指南', reason: '截止倒计时', urgency: 'critical', bg: '#FFF0E0', accentColor: '#E07030' },
]

// 咕咕提示
const birdTips = [
  '今天记得查社保缴纳状态哦~ 🏦',
  '三方协议红线处仔细看看哦！📋',
  '毕业手续清单核对了没？🎓',
  '补贴申请别拖延，快去领！💰',
  '论文查重记得提前预约呀~ 📄',
  '公积金开户跟HR确认一下✅',
]

// 数字动画组件
function AnimatedNumber({ target }: { target: number }) {
  const [current, setCurrent] = useState(0)

  useEffect(() => {
    const start = Date.now()
    const duration = 900
    const tick = () => {
      const t = Math.min((Date.now() - start) / duration, 1)
      const eased = 1 - Math.pow(1 - t, 3)
      setCurrent(Math.round(eased * target))
      if (t < 1) {
        setTimeout(tick, 16)
      }
    }
    tick()
  }, [target])

  return <Text>{current}</Text>
}

export default function StatsPage() {
  const [countdowns, setCountdowns] = useState<Countdown[]>(defaultCountdowns)
  const [isCollapsed, setIsCollapsed] = useState(false)
  const [showAddModal, setShowAddModal] = useState(false)
  const [tipIndex, setTipIndex] = useState(0)
  const [showToast, setShowToast] = useState(false)
  const [toastMsg, setToastMsg] = useState('')

  // 轮播提示
  useEffect(() => {
    const id = setInterval(() => setTipIndex((i) => (i + 1) % birdTips.length), 5000)
    return () => clearInterval(id)
  }, [])

  // 显示提示
  const showActionToast = (msg: string) => {
    setToastMsg(msg)
    setShowToast(true)
    setTimeout(() => setShowToast(false), 2200)
  }

  // 删除倒计时
  const removeCountdown = (id: number) => {
    if (countdowns.length > 1) {
      setCountdowns((prev) => prev.filter((c) => c.id !== id))
    }
  }

  return (
    <View className="stats-page">
      {/* 拖拽手柄 / 折叠按钮 */}
      <View className="drag-handle">
        <View className="drag-line" />
        <View className="collapse-btn" onClick={() => setIsCollapsed(!isCollapsed)}>
          <Text className="collapse-icon">{isCollapsed ? '⌄' : '⌃'}</Text>
          <Text className="collapse-text">{isCollapsed ? '展开看板' : '收起看板'}</Text>
        </View>
        <View className="drag-line" />
      </View>

      {isCollapsed ? (
        /* 收起状态 - 紧凑条 */
        <View className="compact-strip">
          <View className="compact-content">
            {countdowns.map((c) => (
              <View key={c.id} className="compact-item">
                <Text className="compact-emoji">{c.emoji}</Text>
                <Text className="compact-days" style={{ color: c.textColor }}>
                  <AnimatedNumber target={getDaysUntil(c.date)} />
                </Text>
                <Text className="compact-label">{c.label}</Text>
              </View>
            ))}
            <View className="expand-btn" onClick={() => setIsCollapsed(false)}>
              <Text className="expand-icon">⌃</Text>
              <Text className="expand-text">展开</Text>
            </View>
          </View>
        </View>
      ) : (
        /* 展开状态 - 完整看板 */
        <View className="full-panel">
          {/* 倒计时面板 */}
          <View className="countdown-section">
            <View className="section-header">
              <View className="section-title-group">
                <Text className="section-title">倒计时面板</Text>
                <Text className="section-subtitle">滑动查看全部节点</Text>
              </View>
              <View className="add-btn" onClick={() => setShowAddModal(true)}>
                <Text className="add-icon">+</Text>
              </View>
            </View>

            {/* 倒计时卡片 */}
            <View className="countdown-cards">
              {countdowns.map((c, i) => {
                const days = getDaysUntil(c.date)
                const isUrgent = days <= 14
                return (
                  <View
                    key={c.id}
                    className="countdown-card"
                    style={{ background: `linear-gradient(145deg, ${c.catBg}, white)` }}
                  >
                    {countdowns.length > 1 && (
                      <View className="remove-btn" onClick={() => removeCountdown(c.id)}>
                        <Text className="remove-icon">×</Text>
                      </View>
                    )}
                    <Text className="card-emoji">{c.emoji}</Text>
                    <Text className="card-days" style={{ color: c.textColor }}>
                      <AnimatedNumber target={days} />
                    </Text>
                    <Text className="card-unit">天</Text>
                    <Text className="card-label">{c.label}</Text>
                    <Text className="card-date">{c.date}</Text>
                    {isUrgent && (
                      <View className="urgent-badge" style={{ background: c.catBg, color: c.textColor }}>
                        <Text>紧迫！</Text>
                      </View>
                    )}
                  </View>
                )
              })}
              {/* 添加占位 */}
              <View className="add-placeholder" onClick={() => setShowAddModal(true)}>
                <Text className="placeholder-icon">+</Text>
                <Text className="placeholder-text">添加节点</Text>
              </View>
            </View>
          </View>

          {/* 高频待办 */}
          <View className="quick-section">
            <View className="section-header">
              <Text className="section-title">高频待办</Text>
              <Text className="section-subtitle">用完即走，直达核心诉求</Text>
            </View>
            <View className="quick-grid">
              {quickActions.map((action) => (
                <View
                  key={action.id}
                  className="quick-card"
                  style={{ background: action.bg }}
                  onClick={() => showActionToast(`正在打开「${action.title}」入口~`)}
                >
                  <Text className="quick-emoji">{action.emoji}</Text>
                  <Text className="quick-title">{action.title}</Text>
                  <Text className="quick-sub">{action.sub}</Text>
                  <Text className="quick-arrow" style={{ color: action.color }}>›</Text>
                </View>
              ))}
            </View>
          </View>

          {/* 智能推荐 */}
          <View className="recommend-section">
            <View className="section-header-row">
              <View className="section-title-group">
                <Text className="section-title">智能推荐</Text>
                <Text className="section-subtitle">根据你的毕业进度精准推送</Text>
              </View>
              <Text className="recommend-hint">基于最近7天 →</Text>
            </View>
            <View className="recommend-cards">
              {recommendations.map((rec) => (
                <View
                  key={rec.id}
                  className="recommend-card"
                  style={{ background: rec.bg }}
                >
                  <Text className="recommend-emoji">{rec.emoji}</Text>
                  <Text className="recommend-title">{rec.title}</Text>
                  <View
                    className="recommend-tag"
                    style={{ background: rec.bg, borderColor: rec.accentColor, color: rec.accentColor }}
                  >
                    <Text>{rec.urgency === 'critical' ? '⚡ ' : rec.urgency === 'high' ? '🔔 ' : ''}{rec.reason}</Text>
                  </View>
                </View>
              ))}
            </View>
          </View>

          {/* 咕咕提示 */}
          <View className="tip-section">
            <View className="tip-bird">
              <Text className="tip-bird-emoji">🐧</Text>
            </View>
            <View className="tip-content">
              <View className="tip-bubble">
                <Text className="tip-text">{birdTips[tipIndex]}</Text>
              </View>
              <Text className="tip-hint">点击提示可切换 · 咕咕毕业小提醒</Text>
            </View>
          </View>
        </View>
      )}

      {/* Toast 提示 */}
      {showToast && (
        <View className="toast">
          <Text className="toast-text">{toastMsg}</Text>
        </View>
      )}

      {/* 添加弹窗 */}
      {showAddModal && (
        <View className="modal-overlay" onClick={() => setShowAddModal(false)}>
          <View className="modal-content" onClick={(e) => e.stopPropagation()}>
            <View className="modal-handle" />
            <View className="modal-header">
              <Text className="modal-title">添加关注节点</Text>
              <View className="modal-close" onClick={() => setShowAddModal(false)}>
                <Text>×</Text>
              </View>
            </View>
            <Text className="modal-label">快速添加</Text>
            <View className="preset-list">
              <View className="preset-item">
                <Text className="preset-emoji">📮</Text>
                <View className="preset-info">
                  <Text className="preset-name">省考报名</Text>
                  <Text className="preset-date">2026-04-25</Text>
                </View>
                <Text className="preset-arrow">›</Text>
              </View>
              <View className="preset-item">
                <Text className="preset-emoji">💰</Text>
                <View className="preset-info">
                  <Text className="preset-name">补贴申请截止</Text>
                  <Text className="preset-date">2026-05-31</Text>
                </View>
                <Text className="preset-arrow">›</Text>
              </View>
              <View className="preset-item">
                <Text className="preset-emoji">🏠</Text>
                <View className="preset-info">
                  <Text className="preset-name">公积金截止</Text>
                  <Text className="preset-date">2026-04-20</Text>
                </View>
                <Text className="preset-arrow">›</Text>
              </View>
            </View>
            <Text className="modal-label">自定义节点</Text>
            <View className="custom-input">
              <Text className="input-placeholder">节点名称（如：省考报名）</Text>
            </View>
            <View className="custom-input">
              <Text className="input-placeholder">选择日期</Text>
            </View>
            <View className="confirm-btn">
              <Text className="confirm-text">确认添加</Text>
            </View>
          </View>
        </View>
      )}
    </View>
  )
}
