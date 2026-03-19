import { View, Text } from '@tarojs/components'
import { useState, useEffect } from 'react'
import { useStore } from '../../../store'
import { stats, texts, countdown, getRandomBirdTip } from '../../../config'
import { useScreen } from '../../../hooks'
import { CountdownCard } from '../../../components/CountdownCard'
import { Modal } from '../../../components/Modal'
import { ActionSheet, ActionSheetOption } from '../../../components/ActionSheet'
import './index.scss'

export default function StatsPage() {
  const [tipIndex, setTipIndex] = useState(0)
  const { countdowns, addCountdown, removeCountdown } = useStore()
  const [showAddModal, setShowAddModal] = useState(false)
  const [showActionSheet, setShowActionSheet] = useState(false)
  const [selectedCountdownId, setSelectedCountdownId] = useState<string>('')
  const { getResponsiveFontSize } = useScreen()

  useEffect(() => {
    if (countdowns.length === 0) {
      countdown.defaultCountdowns.forEach((c) => addCountdown(c))
    }
  }, [])

  useEffect(() => {
    const interval = setInterval(() => {
      setTipIndex((i) => (i + 1) % stats.birdTips.length)
    }, 5000)
    return () => clearInterval(interval)
  }, [])

  const handleCountdownClick = (id: string) => {
    setSelectedCountdownId(id)
    setShowActionSheet(true)
  }

  const actionOptions: ActionSheetOption[] = [
    { key: 'delete', label: '删除', color: '#FF6B6B', onClick: () => {
      removeCountdown(selectedCountdownId)
    }},
  ]

  return (
    <View className="stats-page">
      <View className="stats-header">
        <Text
          className="stats-title"
          style={{ fontSize: getResponsiveFontSize(28) }}
        >
          {texts.stats.title}
        </Text>
        <Text className="stats-subtitle">{texts.stats.subtitle}</Text>
      </View>

      <View className="countdown-section">
        <View className="section-header">
          <Text className="section-title">倒计时</Text>
          <Text className="section-action" onClick={() => setShowAddModal(true)}>+ 添加</Text>
        </View>
        <View className="countdown-list">
          {countdowns.map((item) => (
            <View
              key={item.id}
              onClick={() => handleCountdownClick(item.id)}
            >
              <CountdownCard
                title={item.title}
                date={item.date}
                color={item.color}
              />
            </View>
          ))}
        </View>
      </View>

      <View className="todo-section">
        <View className="section-header">
          <Text className="section-title">高频待办</Text>
        </View>
        <View className="todo-list">
          {stats.defaultTodos.map((todo) => (
            <View key={todo.id} className={`todo-item ${todo.done ? 'done' : ''}`}>
              <View className="todo-checkbox">
                {todo.done && <Text>✓</Text>}
              </View>
              <View className="todo-content">
                <Text className="todo-title">{todo.title}</Text>
                <Text className="todo-tag">{todo.tag}</Text>
              </View>
            </View>
          ))}
        </View>
      </View>

      <View className="recommend-section">
        <View className="section-header">
          <Text className="section-title">智能推荐</Text>
        </View>
        <View className="recommend-list">
          {stats.defaultRecommendations.map((job) => (
            <View key={job.id} className="recommend-item">
              <View className="recommend-info">
                <Text className="recommend-title">{job.title}</Text>
                <View className="recommend-meta">
                  <Text className="recommend-company">{job.company}</Text>
                  <Text className="recommend-location">{job.location}</Text>
                </View>
              </View>
              <View className="recommend-action">
                <Text>查看</Text>
              </View>
            </View>
          ))}
        </View>
      </View>

      <View className="tip-section">
        <View className="tip-bird">
          <Text style={{ fontSize: getResponsiveFontSize(32) }}>🐧</Text>
        </View>
        <View className="tip-content">
          <Text className="tip-text">{stats.birdTips[tipIndex]}</Text>
        </View>
      </View>

      <Modal
        visible={showAddModal}
        title="添加倒计时"
        content="功能开发中，敬请期待..."
        confirmText="知道了"
        onClose={() => setShowAddModal(false)}
      />

      <ActionSheet
        visible={showActionSheet}
        options={actionOptions}
        onClose={() => setShowActionSheet(false)}
      />
    </View>
  )
}
